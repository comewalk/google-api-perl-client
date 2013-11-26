#!perl

use strict;
use warnings;

use Test::More;
use Test::TCP;

use Google::API::OAuth2::Client;


my $auth_driver = Google::API::OAuth2::Client->new({
});
is undef, $auth_driver;

my $auth_uri = 'https://localhost:10500/oauth2/auth';
my $token_uri = 'https://localhost:10500/oauth2/token';
my $client_id = '40B88F40D2C354C69E0ADA2B3EB8B816';
my $client_secret = 'WHI6TPJLTKEFH19KVAXRDQ';
my $redirect_uri = 'urn:ietf:wg:oauth:2.0:oob';

$auth_driver = Google::API::OAuth2::Client->new({
    auth_uri => $auth_uri,
    token_uri => $token_uri,
    client_id => $client_id,
    client_secret => $client_secret,
    redirect_uri => $redirect_uri,
});
is ref($auth_driver), 'Google::API::OAuth2::Client';
is $auth_driver->authorize_uri, "$auth_uri?client_id=$client_id&redirect_uri=$redirect_uri&response_type=code";

$auth_driver = Google::API::OAuth2::Client->new({
    auth_uri => $auth_uri,
    token_uri => $token_uri,
    client_id => $client_id,
    client_secret => $client_secret,
    redirect_uri => $redirect_uri,
    access_type => 'offline',
});
is ref($auth_driver), 'Google::API::OAuth2::Client';
is $auth_driver->authorize_uri, "$auth_uri?client_id=$client_id&redirect_uri=$redirect_uri&response_type=code&access_type=offline";

$auth_driver = Google::API::OAuth2::Client->new({
    auth_uri => $auth_uri,
    token_uri => $token_uri,
    client_id => $client_id,
    client_secret => $client_secret,
    redirect_uri => $redirect_uri,
});
is $auth_driver->authorize_uri('token'), "$auth_uri?client_id=$client_id&redirect_uri=$redirect_uri&response_type=token";

$auth_driver = Google::API::OAuth2::Client->new({
    auth_uri => $auth_uri,
    token_uri => $token_uri,
    client_id => $client_id,
    client_secret => $client_secret,
    redirect_uri => $redirect_uri,
    auth_doc => {
       oauth2 => {
           scopes => { 
               'https://www.googleapis.com/auth/urlshortener'
                   => 'description'
           },
       },
    },
});
is $auth_driver->authorize_uri, "$auth_uri?client_id=$client_id&redirect_uri=$redirect_uri&response_type=code&scope=https://www.googleapis.com/auth/urlshortener";

# exchange
TODO: {
    local $TODO = "Add tests for exchange method";
};

my $access_token = {
    expires_in => 3600,
    refresh_token => '1/yoW6lxwDBTjlE-2If3edIlUB3pRe3dOYRFHsLAsAr4c',
    access_token => 'ya29.AHES6ZSAgsEl4Zw4BrFxIu9bDeb5jki11vEIlqrB8hzU7G-IVaieKQ',
    token_type => 'Bearer',
};
$auth_driver->token_obj($access_token);
is $auth_driver->access_token, $access_token->{access_token};
is $auth_driver->token_type, $access_token->{token_type};

# refresh
TODO: {
    local $TODO = "Add tests for refresh method";
};

$auth_driver = Google::API::OAuth2::Client->new({
    auth_uri => $auth_uri,
    token_uri => $token_uri,
    client_id => $client_id,
    client_secret => $client_secret,
    redirect_uri => $redirect_uri,
});
$auth_driver->auth_doc({
    oauth2 => {
        scopes => { 
            'https://www.googleapis.com/auth/urlshortener'
                => 'description'
        },
    },
});
my $auth_doc = $auth_driver->auth_doc;
my ($key) = keys(%$auth_doc);
is $key, 'oauth2';
is $auth_driver->authorize_uri, "$auth_uri?client_id=$client_id&redirect_uri=$redirect_uri&response_type=code&scope=https://www.googleapis.com/auth/urlshortener";
done_testing;
__END__
