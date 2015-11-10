requires 'URI';
requires 'URI::Escape';
requires 'URI::Template';
requires 'HTTP::Request';
requires 'JSON';
requires 'JSON::WebToken';
requires 'LWP::Protocol::https';
on test => sub {
    requires 'Test::TCP';
};
