#!/usr/bin/perl

use strict;
use warnings;

use Encode;
use Plack::Builder;
use Plack::Request;

use Google::API::Client;
use Google::API::OAuth2::Client;


my $client = Google::API::Client->new;
my $service = $client->build('plus', 'v1');

my $app = sub { 
    my $env = shift;
    my $request = Plack::Request->new($env);

    my $redirect_uri = sprintf qq(http://localhost:%s/callback), $request->port;
    my $auth_driver = Google::API::OAuth2::Client->new({
        auth_uri => Google::API::Client->AUTH_URI,
        token_uri => Google::API::Client->TOKEN_URI,
        client_id => '<YOUR CLIENT ID>',
        client_secret => '<YOUR CLIENT SECRET>',
        redirect_uri => $redirect_uri,
        auth_doc => $service->{auth_doc},
    });

    my $content;
    if ($request->path eq '/callback') {
        my $code = $request->param('code');
        my $access_token = $auth_driver->exchange($code);
        my $res = $service->people->get(body => { userId => 'me' })->execute({ auth_driver => $auth_driver });
        my $profile_url = $res->{url};
        my $name = $res->{displayName};
        $res = $service->activities->list(body => { userId => 'me', collection => 'public' })->execute({ auth_driver => $auth_driver });
        my @items;
        for my $item (@{$res->{items}}) {
            push @items, '<li>' . encode_utf8($item->{title}) . '</li>';
        }
        my $activities = join '', @items;
        $content = <<"HTML";
<html>
<head>
</head>
<body>
<h1>Google+ API sample</h1>
<p><a href="$profile_url">$name</a>'s activities</p>
<ul>
$activities
</ul>
</body>
</html>
HTML
    } else {
        my $auth_url = $auth_driver->authorize_uri;
        $content = <<"HTML";
<html>
<head>
</head>
<body>
<h1>Google+ API sample</h1>
<a href="$auth_url">Authorize with OAuth2</a>
</body>
</html>
HTML
    }
    my $response = $request->new_response(200);
    $response->content_type('text/html; charset=utf8');
    $response->content($content);
    $response->finalize;
};

builder {
    enable 'Debug';
    $app;
};

__END__
