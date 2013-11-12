requires 'URI';
requires 'URI::Escape';
requires 'HTTP::Request';
requires 'JSON';
requires 'LWP::Protocol::https';
on test => sub {
    requires 'Test::TCP';
};
