#!/usr/bin/env perl

use strict;
use warnings;

use lib 'lib';
use lib 'eg/lib';

use feature qw/say/;

use Data::Dumper;
use Encode qw/encode_utf8/;
use FindBin;

use Google::API::Client;
use Google::API::OAuth2::Client;

use Google::API::OAuth2::SignedJWT;

my $client = Google::API::Client->new;
my $service = $client->build('reseller', 'v1');

my $file = "$FindBin::Bin/../client_secrets.json";
my $privateKey = "$FindBin::Bin/../client_secrets.json";

my @scopes = (
    'https://www.googleapis.com/auth/apps.order'
);

my $auth_driver = Google::API::OAuth2::SignedJWT->new({
    service_account_name => '<< service account email here >>', 
    private_key => "$FindBin::<<private key path here >>",
    sub => '<< sub is optional, but can be here... >>',
    scopes => join(" ", @scopes)
});

my $response = $service->customers->get((
    customerId => 'google.com'
))->execute({
    auth_driver => $auth_driver
});

print $response->{customerId};

exit;
__END__
