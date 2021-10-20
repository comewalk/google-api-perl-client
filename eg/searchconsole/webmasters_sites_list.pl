#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;

use FindBin;
use Google::API::Client;
use Google::API::OAuth2::Client;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;


my $client = Google::API::Client->new;

# https://developers.google.com/search/blog/2020/12/search-console-api-updates#api-library-changes
# my $service = $client->build('webmasters', 'v3');
my $service = $client->build('searchconsole', 'v1');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);

# Call webmasters.sites.list
my $res = $service->sites->list->execute({ auth_driver => $auth_driver });

my %sites;
for my $site (@{$res->{siteEntry}}) {
    $sites{$site->{siteUrl}} = $site->{permissionLevel};
}
for my $url (sort keys %sites) {
    say $sites{$url} . "\t" . $url;
}

store_token($dat_file, $auth_driver);

__END__
