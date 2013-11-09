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


use constant MAX_PAGE_SIZE => 50;

my $client = Google::API::Client->new;
my $service = $client->build('calendar', 'v3');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

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
my $dest_calendar_id = $res->{items}->[1]->{id};

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

# Create a new event
say '=== Create a new event ===';
my $new_event = {
  'summary'  => 'Appointment',
  'location' => 'Somewhere',
  'start' => {
    'dateTime' => '2012-08-03T10:00:00+09:00',
  },
  'end' => {
    'dateTime' => '2012-08-03T10:25:00+09:00',
  },
};
my $added_event = $service->events->insert(
    calendarId => $calendar_id,
    body => $new_event,
)->execute({ auth_driver => $auth_driver });
say $added_event->{id};

# Get an event
say '=== Get a event ===';
my $got_event = $service->events->get(
    body => {
        calendarId => $calendar_id,
        eventId    => $added_event->{id},
    }
)->execute({ auth_driver => $auth_driver });
say $got_event->{id};

# Update an event
say '=== Update an event ===';
$got_event->{summary} = 'Appointment at Somewhere';
my $updated_event = $service->events->update(
    calendarId => $calendar_id,
    eventId    => $got_event->{id},
    body       => $got_event,
)->execute({ auth_driver => $auth_driver });
say $updated_event->{updated};

# Update an event (patch)
say '=== Update an event (patch) ===';
my $patched_event = $service->events->patch(
    calendarId => $calendar_id,
    eventId    => $got_event->{id},
    body => {
        description => 'We will have a lunch',
    }
)->execute({ auth_driver => $auth_driver });
say $patched_event->{updated};

# Delete an event
say '=== Delete an event ===';
my $deleted_event = $service->events->delete(
    calendarId => $calendar_id,
    eventId    => $got_event->{id},
)->execute({ auth_driver => $auth_driver });

# QuickAdd
say '=== QuickAdd ===';
my $quickadded_event = $service->events->quickAdd(
    calendarId => $calendar_id,
    text => 'Appointment at Somewhere on June 3rd 10am-10:25am',
)->execute({ auth_driver => $auth_driver });
say $quickadded_event->{id};

# Move an event
say '=== Move an event ===';
$service->events->move(
    calendarId  => $calendar_id,
    eventId     => $quickadded_event->{id},
    destination => $dest_calendar_id,
)->execute({ auth_driver => $auth_driver });

# Recurring events
say '=== Make recurring events via patch ===';
$service->events->patch(
    calendarId => $dest_calendar_id,
    eventId    => $quickadded_event->{id},
    body => {
        start => {
            timeZone => 'Asia/Tokyo',
        },
        end => {
            timeZone => 'Asia/Tokyo',
        },
        recurrence => [
            'RRULE:FREQ=WEEKLY;UNTIL=20120831T100000Z',
        ],
    }
)->execute({ auth_driver => $auth_driver });
say $quickadded_event->{updated};

# instances
say '=== Get instances ===';
my $instances = $service->events->instances(
    calendarId => $dest_calendar_id,
    eventId    => $quickadded_event->{id},
)->execute({ auth_driver => $auth_driver });
for my $instance (@{$instances->{items}}) {
    say $instance->{id};
}

store_token($dat_file, $auth_driver);
__END__
