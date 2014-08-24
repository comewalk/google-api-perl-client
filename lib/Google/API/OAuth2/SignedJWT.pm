package Google::API::OAuth2::SignedJWT;

use strict;
use warnings;

use HTTP::Request::Common;
use JSON;
use JSON::WebToken;

use constant OAUTH2_TOKEN_ENDPOINT => "https://accounts.google.com/o/oauth2/token";
use constant OAUTH2_CLAIM_AUDIENCE => "https://accounts.google.com/o/oauth2/token";
use constant JWT_GRANT_TYPE => "urn:ietf:params:oauth:grant-type:jwt-bearer";
use constant JWT_ALGORITHIM => "RS256";
use constant JWT_TYP => "JWT";
use constant OAUTH2_TOKEN_LIFETIME_SECS => 3600;

sub new {
    my ($self, $args) = @_;

    # get an access token
    my $json_response = $self->_get_access_token($args);

    # set the access token on the object instance.
    $args->{access_token} = $json_response->{access_token};
    $args->{token_type} = $json_response->{token_type};

    bless { %$args }, $self;
}

sub _get_access_token {
    my ($self, $args) = @_;

    # fetch private key contents.
    my $key_contents = $self->_readfile($args->{private_key});

    my $jwt_params = {
      iss => $args->{service_account_name},
      scope => $args->{scopes},
      aud => OAUTH2_CLAIM_AUDIENCE,
      exp => time() + OAUTH2_TOKEN_LIFETIME_SECS,
      iat => time()
    };

    # sub is defined, push to the array
    if(defined($args->{sub})) {
        $jwt_params->{sub} = $args->{sub};
    }
 
    # encode jwt.
    my $jwt = JSON::WebToken::encode_jwt($jwt_params, $key_contents, JWT_ALGORITHIM, {
      typ => JWT_TYP
    });

    # request an access token
    my $jwt_ua = LWP::UserAgent->new;
    my $jwt_response = $jwt_ua->request(POST OAUTH2_TOKEN_ENDPOINT, {
        grant_type => JWT_GRANT_TYPE,
        assertion => $jwt
    });

    # decode JSON response.
    my $json_response = JSON->new->utf8->decode($jwt_response->decoded_content);
    return $json_response;
}

sub refresh {
    my ($self) = @_;

    # get access token
    my $json_response = $self->_get_access_token($self);

    # set response on the object instance.
    $self->{access_token} = $json_response->{access_token};
    $self->{token_type} = $json_response->{token_type};
}

sub token_type {
    my ($self) = @_;
    return $self->{token_type};
}

sub access_token {
    my ($self) = @_;
    return $self->{access_token};
}

sub _readfile {
    my ($self, $file) = @_;

    open my $handler, '<', $file
        or die "$file not found";
    my $key_contents = join("", <$handler>);
    close $handler;
    return $key_contents;
}

1;