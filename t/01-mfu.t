use strict;
use warnings;
use utf8;
use autodie;
use Test::More;

use FindBin;

use_ok('Google::API::MediaFileUpload');

my $basename = 'cloud_storage-32.png';
my $filename = "$FindBin::Bin/$basename";
my $media = Google::API::MediaFileUpload->new({
    filename => $filename,
    resumable => 1,
});

open my $fh, '<', $filename;
my $data = do { local $/; <$fh> };
close $fh;

is $media->filename, $filename;
is $media->basename, $basename;
is $media->bytes, $data;
is $media->length, length($data);
is $media->mime_type, 'image/png';
is $media->resumable, 1;
is $media->chunk_size, 0;

$media = Google::API::MediaFileUpload->new({
    filename => $filename,
    mime_type => 'image/jpg',
    chunk_size => 64 * 1024 * 1024,
});
is $media->mime_type, 'image/jpg';
is $media->chunk_size, 64 * 1024 * 1024;

done_testing;
__END__
