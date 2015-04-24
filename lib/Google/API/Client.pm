package Google::API::Client;

use strict;
use 5.008_001;
our $VERSION = '0.14';

use Google::API::Method;
use Google::API::Resource;


use constant AUTH_URI => 'https://accounts.google.com/o/oauth2/auth';
use constant TOKEN_URI => 'https://accounts.google.com/o/oauth2/token';

sub new {
    my $class = shift;
    my ($param) = @_;
    unless (defined $param->{ua}) {
        $param->{ua} = $class->_new_ua;
    }
    unless (defined $param->{json_parser}) {
        $param->{json_parser} = $class->_new_json_parser;
    }
    bless { %$param }, $class;
}

sub build {
    my $self = shift;
    my ($service, $version, $args) = @_;

    my $discovery_service_url = 'https://www.googleapis.com/discovery/v1/apis/{api}/{apiVersion}/rest';
    $discovery_service_url =~ s/{api}/$service/;
    $discovery_service_url =~ s/{apiVersion}/$version/;

    my $req = HTTP::Request->new(GET => $discovery_service_url);
    my $res = $self->{ua}->request($req);
    unless ($res->is_success) {
        # throw an error
        die 'could not get service document.' . $res->status_line;
    }
    my $document = $self->{json_parser}->decode($res->content);
    $self->build_from_document($document, $discovery_service_url, $args);
}

sub build_from_document {
    my $self = shift;
    my ($document, $url, $args) = @_;
    my $base = $document->{rootUrl}.$document->{servicePath};
    my $base_url = URI->new($base);
    my $resource = $self->_create_resource($document, $base_url, $args); 
    return $resource;
}

sub _create_resource {
    my $self = shift;
    my ($document, $base_url, $args) = @_;
    my $root_resource_obj = Google::API::Resource->new;
    for my $resource (keys %{$document->{resources}}) {
        my $resource_obj;
        if ($document->{resources}{$resource}{resources}) {
            $resource_obj = $self->_create_resource($document->{resources}{$resource}, $base_url, $args);
        }
        if ($document->{resources}{$resource}{methods}) {
            unless ($resource_obj) {
                $resource_obj = Google::API::Resource->new;
            }
            for my $method (keys %{$document->{resources}{$resource}{methods}}) {
                $resource_obj->set_attr($method, sub {
                    my (%param) = @_;
                    return Google::API::Method->new(
                        ua => $self->{ua},
                        json_parser => $self->{json_parser},
                        base_url => $base_url,
                        doc => $document->{resources}{$resource}{methods}{$method},
                        opt => \%param,
                    );
                });
            }
        }
        $root_resource_obj->set_attr($resource, sub { $resource_obj } );
    }
    if ($document->{auth}) {
        $root_resource_obj->{auth_doc} = $document->{auth};
    }
    return $root_resource_obj;
}

sub _new_ua {
    my $class = shift;
    require LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
    return $ua;
}

sub _new_json_parser {
    my $class = shift;
    require JSON;
    my $parser = JSON->new;
    return $parser;
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Google::API::Client - A client for Google APIs Discovery Service

=head1 SYNOPSIS

  use Google::API::Client;

  my $client = Google::API::Client->new;
  my $service = $client->build('urlshortener', 'v1');

  # Get shortened URL 
  my $body = {
      'longUrl' => 'http://code.google.com/apis/urlshortener/',
  };
  my $result = $url->insert(body => $body)->execute;
  $result->{id}; # shortened URL

=head1 DESCRIPTION

Google::API::Client is a client for Google APIs Discovery Service. You make using Google APIs easy.

=head1 METHODS

=over 4

=item new

=item build

Construct a resource for interacting with an API. The service name and version
are passed to specify the build function to retrieve the appropriate discovery
document from the server. Calls C<build_from_document()> with the downloaded file.

=item build_from_document

Same as the C<build()> function, but the document is to be passed I<locally>
instead of being downloaded. The C<discovery_service_url> is a deprecated 
argument. Instead, the URL is constructed by combining the C<rootUrl> and 
the C<servicePath>.

=back

=head1 AUTHOR

Takatsugu Shigeta E<lt>shigeta@cpan.orgE<gt>

=head1 CONTRIBUTORS

Yusuke Ueno (uechoco)

Gustavo Chaves (gnustavo)

Hatsuhito UENO (uehatsu)

chylli

Richie Foreman <richieforeman@google.com> (richieforeman)

ljanvier

razsh

=head1 COPYRIGHT

Copyright 2011- Takatsugu Shigeta

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
