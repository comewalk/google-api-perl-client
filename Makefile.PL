use inc::Module::Install;
all_from 'lib/Google/API/Client.pm';
readme_from('lib/Google/API/Client.pm');
requires 'JSON', 2.53;
build_requires 'Test::More', 0.88;
test_requires 'Test::Requires';
auto_set_repository();
WriteAll;
