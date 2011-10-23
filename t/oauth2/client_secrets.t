use Test::More;
use FindBin;
use OAuth2::Client;


my $file = "$FindBin::Bin/client_secrets.json";
my $auth_driver = OAuth2::Client->new_from_client_secrets($file);
is $auth_driver->{auth_uri}, 'https://accounts.google.com/o/oauth2/auth';
like $auth_driver->authorize_uri, qr{https://accounts.google.com/o/oauth2/auth};

done_testing;
__END__
