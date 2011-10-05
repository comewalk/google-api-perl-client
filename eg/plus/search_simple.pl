#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;
use Data::Dumper;

use Google::API::Client;


my $simple_api_access_key = '<YOUR SIMPLE API ACCESS KEY>';

my $client = Google::API::Client->new;
my $service = $client->build('plus', 'v1');

my $res = $service->people->search(body => { query => 'vic gundotra', fields => 'items/displayName' })->execute({ key => $simple_api_access_key });
say Dumper($res);

$res = $service->activities->search(body => { query => 'cookie recipes', fields => 'items/object/content' })->execute({ key => $simple_api_access_key });
say Dumper($res);
__END__

