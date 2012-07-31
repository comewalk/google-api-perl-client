#!/usr/bin/env perl

use strict;
use warnings;
use feature qw/say/;

use Data::Dumper;
use Encode qw/encode_utf8/;
use FindBin;
use Google::API::Client;
use OAuth2::Client;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;


use constant MAX_PAGE_SIZE => 50;

my $client = Google::API::Client->new;
my $service = $client->build('calendar', 'v3');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);

# Call calendarlist.list
my $res = $service->calendarList->list(
    body => {
        maxResults => MAX_PAGE_SIZE,
        minAccessRole => 'owner',
    }
)->execute({ auth_driver => $auth_driver });

my $calendar_id = $res->{items}->[0]->{id};

# Call events.list
my $page_token;
my $count = 1;
do {
    say "=== page $count ===";
    my %body = (
        calendarId => $calendar_id,
    );
    if ($page_token) {
        $body{pageToken} = $page_token;
    }
    $res = $service->events->list(
        body => \%body,
    )->execute({ auth_driver => $auth_driver });
    $page_token = $res->{nextPageToken};
    for my $event (@{$res->{items}}) {
        say encode_utf8($event->{summary});
    }
    $count++;
} until (!$page_token);

store_token($dat_file, $auth_driver);
__END__
