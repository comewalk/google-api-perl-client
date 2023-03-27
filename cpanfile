requires 'URI';
requires 'URI::Escape';
requires 'HTTP::Request';
requires 'JSON';
requires 'JSON::WebToken';
requires 'LWP::Protocol::https';
requires 'Data::UUID';
requires 'Email::MIME';
requires 'Time::HiRes';
on test => sub {
    requires 'Test::TCP';
};
