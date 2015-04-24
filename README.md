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
- build\_from\_document

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

Sudipta Chatterjee (sudiptachatterjee)

# COPYRIGHT

Copyright 2011- Takatsugu Shigeta

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
