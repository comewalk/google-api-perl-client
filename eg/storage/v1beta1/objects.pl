#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;

use FindBin;
use JSON;
use LWP::UserAgent;
use MIME::Base64;

use Google::API::Client;
use Google::API::MediaFileUpload;
use OAuth2::Client;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;


my $client = Google::API::Client->new;
my $service = $client->build('storage', 'v1beta1');

my $client_secret = "$FindBin::Bin/../../client_secrets.json";
my $auth_driver = OAuth2::Client->new_from_client_secrets($client_secret, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);
if ($access_token) {
    store_token($dat_file, $auth_driver);
}


my $basename = 'cloud_storage-32.png';
my $image = Google::API::MediaFileUpload->new({
    filename => "$FindBin::Bin/$basename", 
});

# retrieve files
my $projectId = '<YOUR PROJECT ID>';
my $buckets = $service->buckets->list(body => { projectId => $projectId })->execute({ auth_driver => $auth_driver });
for my $bucket (@{$buckets->{items}}) {
    say $bucket->{id};
    my $res = $service->objects->insert(
        bucket => $bucket->{id},
        name => $basename,
        media_body => $image,
    )->execute({ auth_driver => $auth_driver });
    my $objects = $service->objects->list(body => { bucket => $bucket->{id} })->execute({ auth_driver => $auth_driver });
    for my $object (@{$objects->{items}}) {
        say ' + ' . $object->{name};
    }
}

__END__
