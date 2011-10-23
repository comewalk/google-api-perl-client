#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;
use FindBin;
use JSON;
use Data::Dumper;

use Google::API::Client;
use OAuth2::Client;


my $client = Google::API::Client->new;
my $service = $client->build('plus', 'v1');

my $file = "$FindBin::Bin/client_secrets.json";
my $auth_driver = OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";

my $access_token;
if (-f $dat_file) {
    open my $fh, '<', $dat_file;
    if ($fh) {
        local $/;
        $access_token = JSON->new->decode(<$fh>);
        close $fh;
    }
    $auth_driver->token_obj($access_token);
} else {
    my $auth_url = $auth_driver->authorize_uri;
    say 'Go to the following link in your browser:';
    say $auth_url;

    say 'Enter verification code:';
    my $code = <STDIN>;
    chomp $code;

    $access_token = $auth_driver->exchange($code);
}

my $res = $service->people->get(body => { userId => 'me' })->execute({ auth_driver => $auth_driver });
say Dumper($res);

$res = $service->activities->list(body => { userId => '112126540051396629828', collection => 'public' })->execute({ auth_driver => $auth_driver });
say Dumper($res);

$access_token = $auth_driver->token_obj;
open my $fh, '>', $dat_file;
if ($fh) {
    print $fh JSON->new->encode($access_token);
    close $fh;
}

__END__
