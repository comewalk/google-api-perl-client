use strict;
use Test::More;

use Google::API::Client;

my $client = Google::API::Client->new;

subtest 'discovery url v2 style' => sub {
    my $service = $client->build('gmail', 'v1');
    is($client->{ua}{response}->request->uri, 'https://gmail.googleapis.com/$discovery/rest?version=v1');

    $service = $client->build('analyticsreporting', 'v4');
    is($client->{ua}{response}->request->uri, 'https://analyticsreporting.googleapis.com/$discovery/rest?version=v4');

    $service = $client->build('searchconsole', 'v1');
    is($client->{ua}{response}->request->uri, 'https://searchconsole.googleapis.com/$discovery/rest?version=v1');
};

subtest 'without version' => sub {
    my $service = $client->build('calendar');
    is($client->{ua}{response}->request->uri, 'https://calendar-json.googleapis.com/$discovery/rest');
};

subtest 'backward compatibility' => sub {
    my $service = $client->build('compute', 'alpha');
    is($client->{ua}{response}->request->uri, 'https://www.googleapis.com/discovery/v1/apis/compute/alpha/rest');

    $service = $client->build('compute', 'beta');
    is($client->{ua}{response}->request->uri, 'https://www.googleapis.com/discovery/v1/apis/compute/beta/rest');

    $service = $client->build('compute', 'v1');
    is($client->{ua}{response}->request->uri, 'https://www.googleapis.com/discovery/v1/apis/compute/v1/rest');

    $service = $client->build('drive', 'v2');
    is($client->{ua}{response}->request->uri, 'https://www.googleapis.com/discovery/v1/apis/drive/v2/rest');

    $service = $client->build('drive', 'v3');
    is($client->{ua}{response}->request->uri, 'https://www.googleapis.com/discovery/v1/apis/drive/v3/rest');

    $service = $client->build('oauth2', 'v2');
    is($client->{ua}{response}->request->uri, 'https://www.googleapis.com/discovery/v1/apis/oauth2/v2/rest');

};

subtest 'convert name to sub domain' => sub {
    my $service = $client->build('adexchangebuyer2', 'v2beta1');
    is($client->{ua}{response}->request->uri, 'https://adexchangebuyer.googleapis.com/$discovery/rest?version=v2beta1');

    $service = $client->build('calendar', 'v3');
    is($client->{ua}{response}->request->uri, 'https://calendar-json.googleapis.com/$discovery/rest?version=v3');

    $service = $client->build('content', 'v2.1');
    is($client->{ua}{response}->request->uri, 'https://shoppingcontent.googleapis.com/$discovery/rest?version=v2.1');

    $service = $client->build('prod_tt_sasportal', 'v1alpha1');
    is($client->{ua}{response}->request->uri, 'https://prod-tt-sasportal.googleapis.com/$discovery/rest?version=v1alpha1');

    $service = $client->build('translate', 'v3');
    is($client->{ua}{response}->request->uri, 'https://translation.googleapis.com/$discovery/rest?version=v3');
};

subtest 'custom discovery url' => sub {
    my $service = $client->build('webmaster', 'v3', { discovery_service_url => 'https://searchconsole.googleapis.com/$discovery/rest' });
    is($client->{ua}{response}->request->uri, 'https://searchconsole.googleapis.com/$discovery/rest');
};

done_testing;
