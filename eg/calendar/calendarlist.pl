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


use constant MAX_PAGE_SIZE => 3;

my $client = Google::API::Client->new;
my $service = $client->build('calendar', 'v3');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);

my $page_token;
my $count = 1;
do {
    say "=== page $count ===";
    my %body = (
        maxResults => MAX_PAGE_SIZE,
    );
    if ($page_token) {
        $body{pageToken} = $page_token;
    }
    # Call calendarlist.list
    my $list = $service->calendarList->list(
        body => \%body,
    )->execute({ auth_driver => $auth_driver });
    $page_token = $list->{nextPageToken};
    for my $entry (@{$list->{items}}) {
        say '* ' . encode_utf8($entry->{summary});
        # Call calendarlist.get
        my $calendar = $service->calendarList->get(
            body => {
                calendarId => $entry->{id},
            }
        )->execute({ auth_driver => $auth_driver });
        if (my $description = $calendar->{description}) {
            say '  ' . encode_utf8($description);
        }
    }
    $count++;
} until (!$page_token);

store_token($dat_file, $auth_driver);
__END__
