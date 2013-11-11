requires 'URI';
requires 'URI::Escape';
requires 'HTTP::Request';
requires 'JSON';
on test => sub {
    requires 'Test::TCP';
};
