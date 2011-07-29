#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Request;


use Test::More tests => 4;


use constant CRLF => "\015\012";


# as_string(), GET request
{

    my $request = GX::HTTP::Request->new;

    $request->protocol( 'HTTP/1.1' );
    $request->method( 'GET' );
    $request->uri( '/some/path' );
    $request->headers->host( 'www.example.com' );
    $request->headers->add( 'X-Header-1' => 'value 1' );
    $request->headers->add( 'X-Header-2' => 'value 2' );

    for ( 1 .. 2 ) {

        is(
            $request->as_string,
            'GET /some/path HTTP/1.1' . CRLF .
            'Host: www.example.com' . CRLF .
            'X-HEADER-1: value 1' . CRLF .
            'X-HEADER-2: value 2' . CRLF .
            CRLF
        );

    }

}

# as_string(), POST request
{

    my $request = GX::HTTP::Request->new;

    $request->protocol( 'HTTP/1.1' );
    $request->method( 'POST' );
    $request->uri( '/some/path' );
    $request->headers->host( 'www.example.com' );
    $request->headers->add( 'X-Header-1' => 'value 1' );
    $request->headers->add( 'X-Header-2' => 'value 2' );
    $request->add( "Hello World!\nThis is GX.\n" );

    for ( 1 .. 2 ) {

        is(
            $request->as_string,
            'POST /some/path HTTP/1.1' . CRLF .
            'Host: www.example.com' . CRLF .
            'X-HEADER-1: value 1' . CRLF .
            'X-HEADER-2: value 2' . CRLF .
            CRLF .
            "Hello World!\nThis is GX.\n"
        );

    }

}

