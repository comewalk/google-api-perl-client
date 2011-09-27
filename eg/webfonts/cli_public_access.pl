#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;

use Google::API::Client;

my $service = Google::API::Client->new->build('webfonts', 'v1');

my $simple_api_access_key = '<YOUR API KEY>';
my $res = $service->webfonts->list->execute({ key => $simple_api_access_key });

my @families;
for my $item (@{$res->{items}}) {
    push @families, $item->{family};
}
say join ', ', @families;

__END__
