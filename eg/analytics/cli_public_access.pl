#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;
use FindBin;
use JSON;
use Data::Dumper;

use Google::API::Client;
use OAuth2::Client;

my $service = Google::API::Client->new->build('analytics', 'v2.4');
my $auth_driver = OAuth2::Client->new({
    auth_uri => Google::API::Client->AUTH_URI,
    token_uri => Google::API::Client->TOKEN_URI,
    client_id => '<YOUR CLIENT ID>',
    client_secret => '<YOUR CLIENT SECRET>',
    redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
    auth_doc => $service->{auth_doc},
});

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

my $res = $service->management->accounts->list->execute({ auth_driver => $auth_driver });
say Dumper($res);

$access_token = $auth_driver->token_obj;
open my $fh, '>', $dat_file;
if ($fh) {
    print $fh JSON->new->encode($access_token);
    close $fh;
}
__END__
