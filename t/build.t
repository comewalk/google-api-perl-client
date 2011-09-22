use strict;
use Test::More;

use Google::API::Client;

my $service = Google::API::Client->new->build('buzz', 'v1');
ok($service);
is(ref(Google::API::Client->_new_ua), 'LWP::UserAgent');
is(ref(Google::API::Client->_new_json_parser), 'JSON');

done_testing();
