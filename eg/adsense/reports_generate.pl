#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;

use FindBin;
use Google::API::Client;
use Google::API::OAuth2::Client;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;

use constant MAX_PAGE_SIZE => 50;


my $client = Google::API::Client->new;
my $service = $client->build('adsense', 'v1.3');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);

# Call adclients.list 
my $res = $service->adclients->list(
    body => {
        maxResults => MAX_PAGE_SIZE
    })->execute({ auth_driver => $auth_driver });
for my $ad_client (@{$res->{items}}) {
    # Call reports.generate
    my $report = $service->reports->generate(body => {
        startDate => '2011-01-01',
        endDate => '2011-10-26',
        filter => [ 'AD_CLIENT_ID==' . $ad_client->{id} ],
        metric => [
            'PAGE_VIEWS', 'AD_REQUESTS', 'AD_REQUESTS_COVERAGE',
            'CLICKS', 'AD_REQUESTS_CTR', 'COST_PER_CLICK',
            'AD_REQUESTS_RPM', 'EARNINGS',
        ],
        dimension => [ 'DATE' ],
        sort => [ '+DATE' ],
    })->execute({ auth_driver => $auth_driver });
    say "== $ad_client->{id} ==";
    my @headers;
    for my $header (@{$report->{headers}}) {
        push @headers, $header->{name};
    }
    say join("\t", @headers);
    for my $row (@{$report->{rows}}) {
        my @rows;
        for my $column (@$row) {
            push @rows, defined $column ? $column : 'N/A';
        }
        say join("\t", @rows);
    }
}

store_token($dat_file, $auth_driver);

say 'Done';
__END__
