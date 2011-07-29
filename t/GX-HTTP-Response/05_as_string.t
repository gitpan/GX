#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Response;

use constant CRLF => "\015\012";


use Test::More tests => 2;


# as_string()
{

    my $response = GX::HTTP::Response->new;

    $response->protocol( 'HTTP/1.1' );
    $response->status( 200 );
    $response->content_type( 'text/html' );
    $response->headers->add( 'X-Header-1' => 'value 1' );
    $response->headers->add( 'X-Header-2' => 'value 2' );
    $response->add( "Hello World!\nThis is GX.\n" );

    for ( 1 .. 2 ) {

        is(
            $response->as_string,
            'HTTP/1.1 200 OK' . CRLF .
            'Content-Type: text/html' . CRLF .
            'X-HEADER-1: value 1' . CRLF .
            'X-HEADER-2: value 2' . CRLF .
            CRLF .
            "Hello World!\nThis is GX.\n"
        );

    }

}

