use strict;
use warnings;
use Google::API::Client;
use Google::API::OAuth2::Client;
use FindBin;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;

my $code   = shift;
my $client = Google::API::Client->new;
my ($service, $batch) = $client->build('drive', 'v3');
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets("$FindBin::Bin/../client_secrets.json", $service->{auth_doc});

my $dat_file     = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver, 'drive.readonly');

my $files;
my $files_a;
my $files_b;

# 'q' parameter syntax reference: https://developers.google.com/drive/api/guides/search-files
# Replace with your own queries
$service->files->list->batch(sub { $files = shift });
$service->files->list(body => {q => qq{name = 'One Piece Film Red'}})->batch(sub { $files_a = shift });
$service->files->list(body => {q => qq{name = 'Upcoming PS4 Games'}})->batch(sub { $files_b = shift });
$batch->execute({auth_driver => $auth_driver, debug => 1});

print $_->{name} . "\n" foreach @{$files->{files}};
store_token($dat_file, $auth_driver);
__END__
