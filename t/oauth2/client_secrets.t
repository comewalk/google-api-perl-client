use strict;
use warnings;

use Test::More;
use FindBin;
use URI::Escape qw/uri_escape/;
use Google::API::OAuth2::Client;

my $file        = "$FindBin::Bin/client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file);
is $auth_driver->{auth_uri}, 'https://accounts.google.com/o/oauth2/auth';
like $auth_driver->authorize_uri, qr{https://accounts.google.com/o/oauth2/auth};

my $auth_doc = {
    oauth2 => {
        scopes => {
            'https://www.googleapis.com/auth/urlshortener' => 'description'
        },
    },
};
$auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $auth_doc);
my $regex = 'scope=' . uri_escape('https://www.googleapis.com/auth/urlshortener');
like $auth_driver->authorize_uri, qr{$regex};

done_testing;
__END__
