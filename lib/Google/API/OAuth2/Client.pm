package Google::API::OAuth2::Client;

use strict;
use warnings;

use Carp;
use URI;
use URI::Escape qw/uri_escape/;

sub new {
    my $class = shift;
    my ($param) = @_;
    for my $key (qw/auth_uri token_uri client_id client_secret/) {
        return unless $param->{$key};
    }
    unless (defined $param->{ua}) {
        $param->{ua} = $class->_new_ua;
    }
    unless (defined $param->{json_parser}) {
        $param->{json_parser} = $class->_new_json_parser;
    }
    bless {%$param}, $class;
}

sub new_from_client_secrets {
    my $class = shift;
    my ($file, $auth_doc) = @_;
    open my $fh, '<', $file
      or croak "$file not found";
    my $content = do { local $/; <$fh> };
    close $fh;
    require JSON;
    my $json = JSON->new->decode($content);
    my ($client_type) = keys(%$json);
    $class->new({
        auth_uri      => $json->{$client_type}->{auth_uri},
        token_uri     => $json->{$client_type}->{token_uri},
        client_id     => $json->{$client_type}->{client_id},
        client_secret => $json->{$client_type}->{client_secret},
        redirect_uri  => @{$json->{$client_type}->{redirect_uris}}[0],
        auth_doc      => $auth_doc,
    });
}

sub authorize_uri {
    my $self = shift;
    my %param;
    if (@_ == 1) {
        ($param{response_type}) = @_;
    } else {
        %param = @_;
    }
    for my $key (qw/client_id redirect_uri/) {
        return unless $self->{$key};
    }
    $param{scope} = [ $param{scope} ] if defined $param{scope} && !ref($param{scope});
    my @scope = ref($param{scope}) eq 'ARRAY' ? @{$param{scope}} : ();
    @scope = keys %{$self->{auth_doc}{oauth2}{scopes}} unless @scope || !$self->{auth_doc};
    foreach my $i (0 .. $#scope) {
        next if $scope[$i] =~ /^http/;
        next if $scope[$i] eq 'openid';
        $scope[$i] =~ s|^(.+)$|https://www.googleapis.com/auth/$1|;
    }
    push @scope, 'openid' unless @scope;
    my %parameters = (
        client_id     => $self->{client_id},
        redirect_uri  => $self->{redirect_uri},
        response_type => $param{response_type} || 'code',
        scope         => join(' ', @scope),
    );
    $parameters{access_type}            = $param{access_type}            if $param{access_type};
    $parameters{state}                  = $param{state}                  if $param{state};
    $parameters{include_granted_scopes} = $param{include_granted_scopes} if $param{include_granted_scopes};
    $parameters{login_hint}             = $param{login_hint}             if $param{login_hint};
    $parameters{approval_prompt}        = $self->{approval_prompt}       if $self->{approval_prompt};
    $parameters{prompt}                 = $param{prompt}                 if $param{prompt};
    $parameters{hd}                     = $param{hd}                     if $param{hd};

    my @parameters;
    my $authorize_uri = $self->{auth_uri} . '?';
    foreach my $param (qw/client_id redirect_uri response_type scope access_type state include_granted_scopes login_hint approval_prompt prompt hd/) {
        next unless $parameters{$param};
        push @parameters, "$param=" . uri_escape($parameters{$param});
    }
    $authorize_uri .= join('&', @parameters);

    return URI->new($authorize_uri)->as_string;
}

sub exchange {
    my $self = shift;
    my ($code) = @_;
    return unless $code;
    return unless $self->{auth_doc};
    for my $key (qw/client_id client_secret/) {
        return unless $self->{$key};
    }
    my @scopes = keys %{$self->{auth_doc}{oauth2}{scopes}};
    my $scopes = join ' ', @scopes;
    my @param  = (
        client_id     => $self->{client_id},
        client_secret => $self->{client_secret},
        redirect_uri  => $self->{redirect_uri},
        code          => $code,
        scope         => $scopes,
        grant_type    => 'authorization_code',
    );
    require HTTP::Request::Common;
    my $res = $self->{ua}->request(
        HTTP::Request::Common::POST(
            $self->{token_uri},
            Content_Type => 'application/x-www-form-urlencoded',
            Content      => [@param]));
    unless ($res->is_success) {
        return;
    }
    my $access_token = $self->{json_parser}->decode($res->content);
    $self->{token_obj} = $access_token;
    return $self->{token_obj};
}

sub refresh {
    my $self = shift;
    for my $key (qw/client_id client_secret token_obj/) {
        return unless $self->{$key};
    }
    my @param = (
        client_id     => $self->{client_id},
        client_secret => $self->{client_secret},
        refresh_token => $self->{token_obj}{refresh_token},
        grant_type    => 'refresh_token',
    );
    require HTTP::Request::Common;
    my $res = $self->{ua}->request(
        HTTP::Request::Common::POST(
            $self->{token_uri},
            Content_Type => 'application/x-www-form-urlencoded',
            Content      => [@param]));
    unless ($res->is_success) {
        return;
    }
    my $access_token = $self->{json_parser}->decode($res->content);
    unless ($access_token->{refresh_token}) {
        $access_token->{refresh_token} = $self->{token_obj}{refresh_token};
    }
    $self->{token_obj} = $access_token;
    return $self->{token_obj};
}

sub token_obj {
    my $self = shift;
    my ($token_obj) = @_;
    return $self->{token_obj} unless $token_obj;
    $self->{token_obj} = $token_obj;
}

sub token_type {
    my $self = shift;
    return unless $self->{token_obj};
    return $self->{token_obj}{token_type};
}

sub access_token {
    my $self = shift;
    return unless $self->{token_obj};
    return $self->{token_obj}{access_token};
}

sub auth_doc {
    my $self = shift;
    if (@_) {
        my ($doc) = @_;
        $self->{auth_doc} = $doc;
    }
    return $self->{auth_doc};
}

sub _new_ua {
    my $class = shift;
    require LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
    return $ua;
}

sub _new_json_parser {
    my $class = shift;
    require JSON;
    my $parser = JSON->new;
    return $parser;
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Google::API::OAuth2::Client - A simple client for OAuth2

=head1 SYNOPSIS

  use Google::API::OAuth2::Client;

=head1 DESCRIPTION

Google::API::OAuth2::Client is a simple client for OAuth2. This module generates an URL for authorization, calls token URI with authorized code and refresh access token.

=head1 METHODS

=over 4

=item new

=item new_from_client_secrets

=item authorize_uri

=item exchange

=item refresh

=item token_obj

=item token_type

=item access_token

=item auth_doc

=back

=head1 AUTHOR

Takatsugu Shigeta E<lt>shigeta@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2011- Takatsugu Shigeta

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
