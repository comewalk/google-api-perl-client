#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;
use Data::Dumper;

use Google::API::Client;


my $service = Google::API::Client->new->build('blogger', 'v2');

my $simple_api_access_key = '<YOUR API KEY>';

my $res;
say 'Show Blog Object with blogs.get method';
$res = $service->blogs->get(body => { blogId => '6291620338181432245' })->execute({ key => $simple_api_access_key });
say Dumper($res);

say 'Show PostId with posts.list method';
my $blog_id = $res->{id};
$res = $service->posts->list(body => { blogId => $blog_id, fields => 'items/id' })->execute({ key => $simple_api_access_key });
say Dumper($res);

say 'Show URL with posts.get method';
for my $item (@{$res->{items}}) {
    my $post = $service->posts->get(body => { blogId => $blog_id, postId => $item->{id}, fields => 'url' })->execute({ key => $simple_api_access_key });
    say $post->{url};
}

__END__
