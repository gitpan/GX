#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Request;
{

    use GX::Request;

}


package main;

use constant CRLF => "\015\012";


use Test::More tests => 14;


# uploads(), upload() - multiple uploads
{

    my $request = MyApp::Request->new;

    $request->content_type( 'multipart/form-data; boundary=GXBOUNDARY' );
    $request->body->add(
        join ( '',
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_1"; filename="filename_1.txt"' . CRLF,
            CRLF,
            'File content 1' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_2"; filename="filename_2.txt"' . CRLF,
            CRLF,
            'File content 2' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_3"; filename="filename_3.txt"' . CRLF,
            CRLF,
            'File content 3' . CRLF,
            '--GXBOUNDARY--'
        )
    );

    my $uploads = $request->uploads;

    isa_ok( $uploads, 'GX::HTTP::Uploads' );

    is( @$uploads, 3 );

    for my $i ( 1 .. 3 ) {
        my $upload = $request->upload( "file_$i" );
        isa_ok( $upload, 'GX::HTTP::Upload' );
        is( $upload->name, "file_$i" );
        is( $upload->filename, "filename_$i.txt" );
    }

}

# uploads(), upload() - no uploads
{

    my $request = MyApp::Request->new;

    my $uploads = $request->uploads;

    isa_ok( $uploads, 'GX::HTTP::Uploads' );

    is( @$uploads, 0 );

    ok( ! $request->upload( 'file_x' ) );

}

