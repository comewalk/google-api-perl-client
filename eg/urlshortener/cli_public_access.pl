#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;
use Data::Dumper;
use URI;

use Google::API::Client;


my $service = Google::API::Client->new->build('urlshortener', 'v1');

my $url = $service->url;

# Create a shortened URL by inserting the URL into the url collection.
my $body = {
    'longUrl' => 'http://code.google.com/apis/urlshortener/',
};
my $res = $url->insert(body => $body)->execute;
say Dumper($res);

my $short_url = $res->{'id'};

# Convert the shortened URL back into a long URL
$res = $url->get(body => { shortUrl => $short_url })->execute;
say Dumper($res);

__END__
