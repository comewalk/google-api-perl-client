#!/usr/bin/perl

use strict;
use warnings;

use Plack::Builder;
use Plack::Request;

use Google::API::Client;
use Google::API::OAuth2::Client;


my $client = Google::API::Client->new;
my $service = $client->build('urlshortener', 'v1');

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

    my $access_token;
    if ($request->path eq '/callback') {
        my $code = $request->param('code');
        $access_token = $auth_driver->exchange($code);
    }

    my $content;
    if ($request->path eq '/shorten') {
        my $body = {
            'longUrl' => $request->param('url'),
        };
        my $res = $service->url->insert(body => $body)->execute;

        my $shorten_url = $res ? $res->{id} : 'sorry, something wrong';
        $content = <<"HTML";
<html>
<head>
</head>
<body>
<h1>Google URL Shortener API Sample</h1>
<p>$shorten_url</p>
</body>
</html>
HTML
    } else {
        my $auth_url = $auth_driver->authorize_uri;
        my $out;
        if ($access_token) {
            my $list = $service->url->list->execute({ auth_driver => $auth_driver });
            use Data::Dumper;
            $out = 'Your history:<br/>';
            $out .= '<textarea cols="100" rows="10">' . Dumper($list) . '</textarea>';
        } else {
            $out = qq{<a href="$auth_url">Private access?</a>};
        }
        $content = <<"HTML";
<html>
<head>
</head>
<body>
<h1>Google URL Shortener API Sample</h1>
<form method="POST" action="/shorten">
<input type="text" name="url" />
<input type="submit" value="shorten" /> 
</form>
$out
</body>
</html>
HTML
    }
    my $response = $request->new_response(200);
    $response->content_type('text/html');
    $response->content($content);
    $response->finalize;
};

builder {
#    enable 'Debug';
    $app;
};

__END__
