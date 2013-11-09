#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;

use FindBin;
use Data::Dumper;
use Google::API::Client;
use Google::API::OAuth2::Client;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;


my $service = Google::API::Client->new->build('urlshortener', 'v1');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);

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

store_token($dat_file, $auth_driver);
__END__
