## If you want to run translate API, you need to pay usage fees.
#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;

use FindBin;
use Google::API::Client;
use Google::API::OAuth2::Client;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;


my $service = Google::API::Client->new->build('translate', 'v2');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});
my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);

my $res = $service->translations->list(body => {source => 'en', target => 'fr', q => [qw/flower car/]})->execute;
use Data::Dumper;
warn Dumper($res);

store_token($dat_file, $auth_driver);

say 'done';
__END__
