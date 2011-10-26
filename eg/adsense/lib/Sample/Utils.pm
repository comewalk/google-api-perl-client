package Sample::Utils;

use strict;
use warnings;
use feature qw/say/;
use base 'Exporter';
our @EXPORT_OK = qw/get_or_restore_token store_token/;

sub get_or_restore_token {
    my ($file, $auth_driver) = @_;
    my $access_token;
    if (-f $file) {
        open my $fh, '<', $file;
        if ($fh) {
            local $/;
            require JSON;
            $access_token = JSON->new->decode(<$fh>);
            close $fh;
        }
        $auth_driver->token_obj($access_token);
    } else {
        my $auth_url = $auth_driver->authorize_uri;
        say 'Go to the following link in your browser:';
        say $auth_url;
    
        say 'Enter verification code:';
        my $code = <STDIN>;
        chomp $code;
        $access_token = $auth_driver->exchange($code);
    }
    return $access_token;
}

sub store_token {
    my ($file, $auth_driver) = @_;
    my $access_token = $auth_driver->token_obj;
    open my $fh, '>', $file;
    if ($fh) {
        require JSON;
        print $fh JSON->new->encode($access_token);
        close $fh;
    }
}

1;
__END__
