#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;

use FindBin;
use Google::API::Client;
use OAuth2::Client;
use URI::Escape;
use Encode;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;

use constant MAX_LIST_CALENDAR => 3;
use constant MAX_LIST_EVENTS   => 3;


my $client = Google::API::Client->new;
my $service = $client->build('calendar', 'v3');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);

# Call calendar list 
my $calendars = $service->calendarList->list(
    body => {
        maxResults => MAX_LIST_CALENDAR
    })->execute({ auth_driver => $auth_driver });
for my $calendar (@{$calendars->{items}}) {
    say "== Calendar $calendar->{id} ==";
    my $calendar_id = uri_escape($calendar->{id});
    # Call events.list
    my $events = $service->events->list(body => {
        calendarId => $calendar_id,
        maxResults => MAX_LIST_EVENTS,
        showDeleted => 'true',
    })->execute({ auth_driver => $auth_driver });
    for my $event (@{$events->{items}}) {
        say "== Event $event->{id} ==";
        my $event_title = defined($event->{summary}) ? encode('utf8', $event->{summary}) : 'N/A';
        my $event_start = defined($event->{start}) ?
                         (defined($event->{start}->{date}) ? $event->{start}->{date} :
                         (defined($event->{start}->{dateTime}) ? $event->{start}->{dateTime} : 'N/A')
                          ) : 'N/A';
        my $event_end   = defined($event->{end}) ?
                         (defined($event->{end}->{date}) ? $event->{end}->{date} :
                         (defined($event->{end}->{dateTime}) ? $event->{end}->{dateTime} : 'N/A')
                          ) : 'N/A';
        my $event_status = $event->{status};
        say <<EOF;
event_title  : $event_title
event_status : $event->{status}
event_start  : $event_start
event_end    : $event_end
EOF
    }
    say "";
}

store_token($dat_file, $auth_driver);

say 'Done';
__END__
