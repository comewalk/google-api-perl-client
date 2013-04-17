package Google::API::MediaFileUpload;

use strict;
use warnings;

use Carp;
use MIME::Types 'by_suffix';

sub new {
    my $class = shift;
    my ($param) = @_;
    my $self = bless { %$param }, $class;
    open my $fh, '<', $param->{filename}
        or Carp::croak "could not open $param->{filename}";
    $self->{bytes} = do { local $/; <$fh> };
    close $fh;
    return $self;
}

sub bytes {
    my $self = shift;
    return $self->{bytes};
}

sub length {
    my $self = shift;
    return length($self->{bytes});
}

sub mime_type {
    my $self = shift;
    if ($self->{mime_type}) {
        return $self->{mime_type};
    }
    my $mime = by_suffix($self->{filename});
    return $mime->[0];
}

sub filename {
    my $self = shift;
    return $self->{filename};
}

sub basename {
    my $self = shift;
    my ($name, $path, $suffix) = File::Basename::fileparse($self->{filename});
    return $name . $suffix;
}

sub resumable {
    my $self = shift;
    return $self->{resumable};
}

sub chunk_size {
    my $self = shift;
    return $self->{chunk_size} || 0;
}
1;
__END__
