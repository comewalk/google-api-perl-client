#!perl
use strict;
use warnings;

use Test::More;

use FindBin;
use lib "$FindBin::Bin/lib";
use Google::API::Dummy;

my $service = Google::API::Dummy->new;
$service->set_attr('foo', sub { 'foo' });

is($service->foo, 'foo');

eval { $service->bar; };
my $err = $@;
like($err, qr{^Unknown method}, $err);

done_testing;
__END__
