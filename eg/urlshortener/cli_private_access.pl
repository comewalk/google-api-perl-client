#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;
use Data::Dumper;

use Google::API::Client;
use OAuth2::Client;


my $service = Google::API::Client->new->build('urlshortener', 'v1');

my $auth_driver = OAuth2::Client->new({
    auth_uri => Google::API::Client->AUTH_URI,
    token_uri => Google::API::Client->TOKEN_URI,
    client_id => '<YOUR CLIENT ID>',
    client_secret => '<YOUR CLIENT SECRET>',
    redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
    auth_doc => $service->{auth_doc},
});

say 'Go to the following link in your browser:';
say $auth_driver->authorize_uri;

say 'Enter verification code:';
my $code = <STDIN>;
chomp $code;

$auth_driver->exchange($code);


my $url = $service->url;

# Create a shortened URL by inserting the URL into the url collection.
my $body = {
    'longUrl' => 'http://code.google.com/apis/urlshortener/',
};
my $res = $url->insert(body => $body)->execute({ auth_driver => $auth_driver });
say Dumper($res);

my $short_url = $res->{'id'};

# Convert the shortened URL back into a long URL
$res = $url->get(body => { shortUrl => $short_url })->execute({ auth_driver => $auth_driver });
say Dumper($res);

$res = $url->list->execute({ auth_driver => $auth_driver });
say Dumper($res);
__END__
