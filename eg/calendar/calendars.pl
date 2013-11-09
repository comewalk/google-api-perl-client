#!/usr/bin/env perl

use strict;
use warnings;
use feature qw/say/;

use Data::Dumper;
use Encode qw/encode_utf8/;
use FindBin;
use Google::API::Client;
use Google::API::OAuth2::Client;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;


my $client = Google::API::Client->new;
my $service = $client->build('calendar', 'v3');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);

# Call calendarlist.list
my $res = $service->calendarList->list->execute({ auth_driver => $auth_driver });

my $calendar_id = $res->{items}->[0]->{id};

# Call calendars.get
$res = $service->calendars->get(
    body => {
        calendarId => $calendar_id,
    }
)->execute({ auth_driver => $auth_driver });

say encode_utf8($res->{summary});

store_token($dat_file, $auth_driver);
__END__
