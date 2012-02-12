package Google::API::Base;

use strict;
use warnings;
use Carp;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub set_attr {
    my $self = shift;
    my ($name, $callback) = @_;
    $self->{METHODS}{$name} = $callback;
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    my (%param) = @_;
    my $func_name = $AUTOLOAD;
    $func_name =~ s/^.*:://;
    return if $func_name eq 'DESTROY';
    if (exists $self->{METHODS}{$func_name}) {
	return $self->{METHODS}{$func_name}->(%param);
    }
    Carp::croak("Unknown method: $func_name");
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

Google::API::Base - Base class for objects of Discovery Document Resource 

=head1 SYNOPSIS

  package Google::API::Resource;
  use base qw/Google::API::Base/;

=head1 DESCRIPTION

Google::API::Base is a base class for objects for Discovery Document Resource in this module.

=head1 METHODS

=over 4

=item new

=item set_attr

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
