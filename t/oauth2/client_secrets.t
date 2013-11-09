use Test::More;
use FindBin;
use Google::API::OAuth2::Client;


my $file = "$FindBin::Bin/client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file);
is $auth_driver->{auth_uri}, 'https://accounts.google.com/o/oauth2/auth';
like $auth_driver->authorize_uri, qr{https://accounts.google.com/o/oauth2/auth};

my $auth_doc = {
    oauth2 => {
        scopes => { 
            'https://www.googleapis.com/auth/urlshortener'
                => 'description'
        },
    },
};
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $auth_doc);
like $auth_driver->authorize_uri, qr{scope=https://www.googleapis.com/auth/urlshortener};

done_testing;
__END__
