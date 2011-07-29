#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Request;
use IO::File ();


use Test::More tests => 12;


use constant CRLF => "\015\012";


# print_to( $object );
{

    my $request = GX::HTTP::Request->new;

    $request->protocol( 'HTTP/1.1' );
    $request->method( 'GET' );
    $request->uri( 'http://www.gxframework.org' );

    for ( 0 .. 1 ) {
        my $output = '';
        ok( $request->print_to( IO::File->new( \$output, '>' ) ) );
        is( $output, 'GET http://www.gxframework.org HTTP/1.1' . CRLF . CRLF );
    }

}

# print_to( *FH )
{

    my $request = GX::HTTP::Request->new;

    $request->protocol( 'HTTP/1.1' );
    $request->method( 'GET' );
    $request->uri( 'http://www.gxframework.org' );

    for ( 0 .. 1 ) {
        my $output = '';
        open FH, '>', \$output;
        ok( $request->print_to( *FH ) );
        is( $output, 'GET http://www.gxframework.org HTTP/1.1' . CRLF . CRLF );
        close FH;
    }

}

# print_to( \*FH )
{

    my $request = GX::HTTP::Request->new;

    $request->protocol( 'HTTP/1.1' );
    $request->method( 'GET' );
    $request->uri( 'http://www.gxframework.org' );

    for ( 0 .. 1 ) {
        my $output = '';
        open FH, '>', \$output;
        ok( $request->print_to( \*FH ) );
        is( $output, 'GET http://www.gxframework.org HTTP/1.1' . CRLF . CRLF );
        close FH;
    }

}

