# NAME

Google::API::Client - A client for Google APIs Discovery Service

# SYNOPSIS

    use Google::API::Client;

    my $client = Google::API::Client->new;
    my $service = $client->build('urlshortener', 'v1');

    # Get shortened URL 
    my $body = {
        'longUrl' => 'http://code.google.com/apis/urlshortener/',
    };
    my $result = $url->insert(body => $body)->execute;
    $result->{id}; # shortened URL

# DESCRIPTION

Google::API::Client is a client for Google APIs Discovery Service. You make using Google APIs easy.

# METHODS

- new
- build

    Construct a resource for interacting with an API. The service name and version
    are passed to specify the build function to retrieve the appropriate discovery
    document from the server. Calls `build_from_document()` with the downloaded file.

- build\_from\_document

    Same as the `build()` function, but the document is to be passed _locally_
    instead of being downloaded. The `discovery_service_url` is a deprecated 
    argument. Instead, the URL is constructed by combining the `rootUrl` and 
    the `servicePath`.

# AUTHOR

Takatsugu Shigeta <shigeta@cpan.org>

# CONTRIBUTORS

Yusuke Ueno (uechoco)

Gustavo Chaves (gnustavo)

Hatsuhito UENO (uehatsu)

chylli

Richie Foreman <richieforeman@google.com> (richieforeman)

ljanvier

razsh

# COPYRIGHT

Copyright 2011- Takatsugu Shigeta

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
