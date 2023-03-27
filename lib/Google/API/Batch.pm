package Google::API::Batch;

use strict;
use warnings;

use Carp;
use Encode;
use Data::UUID;
use Email::MIME;
use HTTP::Request;
use Time::HiRes qw(usleep);

use constant MAX_BATCH_LIMIT => 1000;

sub new {
	my ($class, %param) = @_;
	my $self = {
		ua          => $param{ua},
		json_parser => $param{json_parser},
		batch_url   => $param{batch_url},
		_responses  => {},
		_requests   => [],
		_callbacks  => [],
		_indexes    => [],
		_last_index => 0,
		_uuid       => Data::UUID->new,
		_batch_uuid => undef,
	};
	return bless($self, $class);
}

sub add {
	my ($self, $request, $callback) = @_;
	croak "Exceeded the maximum calls($self->MAX_BATCH_LIMIT) in a single batch request"
	  if $self->{_last_index} >= $self->MAX_BATCH_LIMIT;
	my $index = $self->_next_index;
	push @{$self->{_requests}},  $request;
	push @{$self->{_callbacks}}, $callback;
	push @{$self->{_indexes}},   $index;
}

sub execute {
	my ($self, $arg) = @_;
	return unless @{$self->{_indexes}};
	$self->_execute($arg, $self->{_indexes});
	my $debug = $arg->{debug};
	$arg->{debug} = 0;
	my @retry_indexes;

	foreach my $index (@{$self->{_indexes}}) {
		my $response = $self->{_responses}->{$index};
		push @retry_indexes, $index if $response->code == 401;
	}

	if (@retry_indexes && $arg->{auth_driver}) {
		$arg->{auth_driver}->refresh;
		$self->_execute($arg, \@retry_indexes);
	}

	# https://developers.google.com/admin-sdk/directory/v1/limits#backoff
	unless ($arg->{disable_exponential_backoff}) {
		@retry_indexes = ();
		foreach my $index (@{$self->{_indexes}}) {
			my $response = $self->{_responses}->{$index};
			push @retry_indexes, $index if $self->_is_retriable($response);
		}

		if (@retry_indexes) {
			my $try_count = 0;
			while ($try_count < 5) {
				usleep(2**$try_count * 1000**2 + 1000 * rand(999));
				$self->_execute($arg, \@retry_indexes);
				my @retry_indexes_tmp;
				foreach my $index (@retry_indexes) {
					my $response = $self->{_responses}->{$index};
					push @retry_indexes_tmp, $index if $self->_is_retriable($response);
				}
				last unless @retry_indexes_tmp;
				@retry_indexes = @retry_indexes_tmp;
				$try_count++;
			}
		}
	}

	foreach my $index (@{$self->{_indexes}}) {
		my $response = $self->{_responses}->{$index};
		my $callback = $self->{_callbacks}->[$index];

		print STDERR $response->as_string . "\n" if $debug;
		return unless $response->is_success;
		return unless $callback;
		if ($response->code == 204) {
			$callback->(1);
		} else {
			my $content =
				$response->header('content-type') =~ m!^application/json!
			  ? $self->{json_parser}->decode(decode_utf8($response->content))
			  : $response->content;
			$callback->($content);
		}

	}
	$self->_reset;
}

sub _execute {
	my ($self, $arg, $indexes) = @_;
	my @parts;
	foreach my $index (@$indexes) {
		my $request = $self->{_requests}->[$index];
		my $part    = Email::MIME->create(
			header_str => [
				'Content-Type'              => 'application/http',
				'Content-Transfer-Encoding' => 'binary',
				'Content-ID'                => $self->_ix2header($index),
			],
			body => $self->_serialize_request($request));
		push @parts, $part;
	}
	my $batch_request = HTTP::Request->new;
	my $boundary      = $self->{_uuid}->create_str;
	$batch_request->method('POST');
	$batch_request->uri($self->{batch_url});
	$batch_request->header('Content-Type' => qq{multipart/mixed; boundary="$boundary"});
	$batch_request->add_part($_) foreach @parts;
	print STDERR $batch_request->as_string . "\n" if $arg->{debug};

	if ($arg->{auth_driver}) {
		$batch_request->header('Authorization', sprintf "%s %s", $arg->{auth_driver}->token_type, $arg->{auth_driver}->access_token);
	}
	my $response = $self->{ua}->request($batch_request);

	if ($response->is_success) {
		my $content_type = $response->header('Content-Type');
		croak 'Not a multipart response' unless $content_type =~ m|^multipart/mixed;|;
		my $header        = "Content-Type: $content_type\r\n\r\n";
		my $mime_response = Email::MIME->new($header . $response->decoded_content);
		my @parts         = $mime_response->parts;

		foreach my $part (@parts) {
			my $index = $self->_header2ix($part->header('Content-ID'));
			$self->{_responses}->{$index} = HTTP::Response->parse($part->body);
		}
	} else {
		my $content = $response->decoded_content;
		croak 'Batch request failed: ' . $self->{batch_url} . "\n$content";
	}
}

sub _is_retriable {
	my ($self, $response) = @_;
	my %retriable_reasons = (userRateLimitExceeded => 1, quotaExceeded => 1, rateLimitExceeded => 1, conflict => 1);
	if (   $response->code == 403
		|| $response->code == 429
		|| ($response->code == 409 && $response->request->method ne 'DELETE'))
	{
		my $data   = $self->{json_parser}->decode(decode_utf8($response->decoded_content));
		my $reason = $data->{error}->{errors}->[0]->{reason};
		return $retriable_reasons{$reason};
	} elsif ($response->code >= 500) {
		return 1;
	}
}

sub _ix2header {
	my ($self, $index) = @_;
	$self->{_batch_uuid} = $self->{_uuid}->create_str unless $self->{_batch_uuid};
	my $uuid = $self->{_batch_uuid};
	return "<$uuid + $index>";
}

sub _header2ix {
	my ($self, $header) = @_;
	my ($base, $index)  = split(/ \+ /, substr($header, 1, -1));
	return $index;
}

sub _next_index {
	my $self = shift;
	$self->{_last_index} = 0 unless $self->{_last_index};
	return $self->{_last_index}++;
}

sub _serialize_request {
	my ($self, $request) = @_;
	my $uri = $request->uri;
	$uri =~ s|^https?://.*?(/.*)$|$1|;
	$request->uri($uri);
	$request->protocol('HTTP/1.1');
	return $request->as_string;
}

sub _reset {
	my $self = shift;
	$self->{_responses}  = {};
	$self->{_requests}   = [];
	$self->{_callbacks}  = [];
	$self->{_indexes}    = [];
	$self->{_last_index} = 0;
	$self->{_batch_uuid} = undef;
}

1;
