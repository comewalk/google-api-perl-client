requires 'URI';
requires 'URI::Escape';
requires 'HTTP::Request';
requires 'JSON';
required 'JSON::WebToken';
requires 'LWP::Protocol::https';
on test => sub {
    requires 'Test::TCP';
};
