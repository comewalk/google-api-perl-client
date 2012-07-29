package Google::API::Method;

use strict;
use warnings;

use Encode;
use HTTP::Request;
use URI;

sub new {
    my $class = shift;
    my (%param) = @_;
    for my $required (qw/ua json_parser base_url opt doc/) {
        die unless $param{$required};
    }
    bless { %param }, $class;
}

sub execute {
    my $self = shift;
    my ($arg) = @_;
    my $url = $self->{base_url} . $self->{doc}{path};
    my $url_org = $url;
    $url =~ s/{([^}]+)}/$self->{opt}{body}{$1}/g;
    while ( $url_org =~ /{([^}]+)}/g ) {
        delete( $self->{opt}{body}{$1} );
    }
    my $http_method = uc($self->{doc}{httpMethod});
    my $request;
    if ($http_method eq 'POST' ||
        $http_method eq 'PUT' ||
        $http_method eq 'PATCH') {
        $request = HTTP::Request->new($http_method => $url);
        $request->content_type('application/json');
        $request->content($self->{json_parser}->encode($self->{opt}{body}));
    } elsif ($http_method eq 'GET') {
        my $uri = URI->new($url);
        my $body = $self->{opt}{body} || {};
        my %q = (
            %$body,
        );
        if ($arg->{key}) {
            $q{key} = $arg->{key};
        }
        $uri->query_form(\%q);
        $request = HTTP::Request->new($http_method => $uri);
    }
    if ($arg->{auth_driver}) {
        $request->header('Authorization',
            sprintf "%s %s",
                $arg->{auth_driver}->token_type,
                $arg->{auth_driver}->access_token);
    }
    my $response = $self->{ua}->request($request);
    if ($response->code == 401 && $arg->{auth_driver}) {
        $arg->{auth_driver}->refresh;
        $request->header('Authorization',
            sprintf "%s %s",
                $arg->{auth_driver}->token_type,
                $arg->{auth_driver}->access_token);
        $response = $self->{ua}->request($request);
    }
    die $response->status_line unless $response->is_success;
    return $response->header('content-type') =~ m!^application/json!
           ? $self->{json_parser}->decode(decode_utf8($response->content))
           : $response->content
           ;
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Google::API::Method - An implementation of methods part in Discovery Document Resource

=head1 SYNOPSIS

  use Google::API::Method;
  my $method = Google::API::Method->new({
      # options
      # see also Google::API::Client 
  });
  my $result = $method->execute;

=head1 DESCRIPTION

Google::API::Method is an implementation of methods part in Discovery Document Resource.

=head1 METHODS

=over 4

=item new

=item execute

=back

=head1 AUTHOR

Takatsugu Shigeta E<lt>shigeta@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2011- Takatsugu Shigeta

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
