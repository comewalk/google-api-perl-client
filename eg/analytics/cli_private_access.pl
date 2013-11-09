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


my $service = Google::API::Client->new->build('analytics', 'v2.4');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";

my $access_token = get_or_restore_token($dat_file, $auth_driver);

my $res = $service->management->accounts->list->execute({ auth_driver => $auth_driver });
say Dumper($res);

store_token($dat_file, $auth_driver);
__END__
