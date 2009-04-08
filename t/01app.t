use strict;
use warnings;
use Test::More 'no_plan';
use Data::Dumper;
use HTTP::Request::Common qw/GET POST PUT DELETE/;
use HTTP::Status qw(:constants);

BEGIN { use_ok 'Catalyst::Test', 'TM::IP::Surface' }

my $cwd;
chomp($cwd = `pwd`);
'TM::IP::Surface'->config->{mapbase} = $cwd . '/t/';      # we want to test this whereever it is located

use File::Path;
rmtree ([ map { 'TM::IP::Surface'->config->{mapbase} . "test/.surface/$_" }     qw(x1 x2 x3)], 0, 1);
unlink (  map { 'TM::IP::Surface'->config->{mapbase} . "test/.surface/$_.png" } qw(x1 x2 x3));

use constant DONE => 1;

use Image::Magick;

if (DONE) {
    my $image = Image::Magick->new;
    $image->Set (size=>'600x400');
    $image->ReadImage ('xc:white');

    my ($png) = $image->ImageToBlob (magick=>'png');
    my $resp = request (PUT '/test/.surface/x3.png', 'Accept' => '*/*', 'Content-Type' => 'image/png', Content => $png);

    is ($resp->code, HTTP_CREATED,                                                  'surface PNG was created');
    is ($resp->header ('Location'),       'http://localhost/test/.surface/x3.png',  'surface location');

    my ($gif) = $image->ImageToBlob (magick=>'gif');
    $resp = request (PUT '/test/.surface/x3.png', 'Accept' => '*/*', 'Content-Type' => 'image/gif', Content => $gif);
    is ($resp->code, HTTP_BAD_REQUEST,                                              'surface GIF was not created');

    $resp = request (GET '/test/.surface/x3.png', 'Accept' => 'image/png');
    is ($resp->code, HTTP_OK,                                                       'surface was fetched');
    is ($png, $resp->content,                                                       'surface same PNG');

    $resp = request (GET '/test/.surface/x2.png', 'Accept' => 'image/png');
    is ($resp->code, HTTP_NOT_FOUND,                                                'surface was not found');
    $resp = request (GET '/test/.surface/x1.png', 'Accept' => 'image/png');
    is ($resp->code, HTTP_NOT_FOUND,                                                'surface was not found');
}

if (DONE) {
    my $image = Image::Magick->new;
    $image->Set (size=>'600x400');
    $image->ReadImage ('xc:white');

    my ($blob) = $image->ImageToBlob (magick=>'png');
    my $resp = request (PUT '/test/.surface/x3.png', 'Accept' => '*/*', 'Content-Type' => 'image/png', Content => $blob);

    $resp = request (GET '/test/.surface/x2/60x40/13x4.png', 'Accept' => 'image/png');
    is ($resp->code, HTTP_NOT_FOUND,                                                'surface x2 was not found');

    # get one arbitrary
    $resp = request (GET '/test/.surface/x3/60x40/13x4.png', 'Accept' => 'image/png');
    is ($resp->code, HTTP_OK,                                                       'tile x3 was fetched');

    $image = Image::Magick->new (magick=>'png');
    $image->BlobToImage ($resp->content);
    ok (1, 'obviously PNG content');
    is ($image->Get ('width'),  10, 'tile dX');
    is ($image->Get ('height'), 10, 'tile dY');

    # get all
    for (my $m = 0; $m < 30; $m++) {
	for(my $n = 0; $n < 20; $n++) {
	    $resp = request (GET "/test/.surface/x3/30x20/${m}x${n}.png", 'Accept' => 'image/png');
	    is ($resp->code, HTTP_OK,                                               'inner tile found');
	    $image = Image::Magick->new (magick=>'png');
	    $image->BlobToImage ($resp->content);
	    ok (1, 'obviously PNG content');
	    is ($image->Get ('width'),  20, 'tile dX');
	    is ($image->Get ('height'), 20, 'tile dY');
	}
    }
    $resp = request (GET '/test/.surface/x3/30x20/30x4.png', 'Accept' => 'image/png');
    is ($resp->code, HTTP_NOT_FOUND,                                                'outer tile not found');
}

if (DONE) {
    my $image = Image::Magick->new;
    $image->Set (size=>'600x400');
    $image->ReadImage ('xc:white');

    my ($blob) = $image->ImageToBlob (magick=>'png');
    my $resp = request (PUT '/test/.surface/x2.png', 'Accept' => '*/*', 'Content-Type' => 'image/png', Content => $blob);

    $resp = request (GET '/test/.surface/x2/30x20/13x4.png', 'Accept' => 'image/png');
    my $tile = Image::Magick->new (magick=>'png');
    $tile->BlobToImage ($resp->content);
    my @pixels = $tile->GetPixel ('x' => 10, 'y' => 10);
    is_deeply (\@pixels, [1, 1, 1], 'all white tile');
#warn Dumper \@pixels;

    sleep 2; # we need to wait a bit

    $image = Image::Magick->new;
    $image->Set (size=>'600x400');
    $image->ReadImage ('xc:black');

    ($blob) = $image->ImageToBlob (magick=>'png');
    $resp = request (PUT '/test/.surface/x2.png', 'Accept' => '*/*', 'Content-Type' => 'image/png', Content => $blob);

    $resp = request (GET '/test/.surface/x2/30x20/13x4.png', 'Accept' => 'image/png');
    $tile = Image::Magick->new (magick=>'png');
    $tile->BlobToImage ($resp->content);
    @pixels = $tile->GetPixel ('x' => 10, 'y' => 10);
#warn Dumper \@pixels;
    is_deeply (\@pixels, [0, 0, 0], 'all black tile');
}

__END__

