use inc::Module::Install;
all_from 'lib/Google/API/Client.pm';
requires 'JSON', 2.53;
requires 'LWP::Protocol::https', 6.03;
build_requires 'Test::More', 0.88;
test_requires 'Test::Requires';
WriteAll;
