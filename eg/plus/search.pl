#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;

use FindBin;
use JSON;
use Data::Dumper;

use Google::API::Client;
use Google::API::OAuth2::Client;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;


my $client = Google::API::Client->new;
my $service = $client->build('plus', 'v1');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);

my $res = $service->people->search(body => { query => 'vic gundotra', fields => 'items/displayName' })->execute({ auth_driver => $auth_driver });
say Dumper($res);

$res = $service->activities->search(body => { query => 'cookie recipes', fields => 'items/object/content' })->execute({ auth_driver => $auth_driver });
say Dumper($res);

store_token($dat_file, $auth_driver);
__END__

