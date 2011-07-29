#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Response;
use IO::File ();


use Test::More tests => 12;


use constant CRLF => "\015\012";


# print_to( $object );
{

    my $response = GX::HTTP::Response->new;

    $response->protocol( 'HTTP/1.1' );
    $response->status( 200 );

    for ( 0 .. 1 ) {
        my $output = '';
        ok( $response->print_to( IO::File->new( \$output, '>' ) ) );
        is( $output, 'HTTP/1.1 200 OK' . CRLF . CRLF );
    }

}

# print_to( *FH )
{

    my $response = GX::HTTP::Response->new;

    $response->protocol( 'HTTP/1.1' );
    $response->status( 200 );

    for ( 0 .. 1 ) {
        my $output = '';
        open FH, '>', \$output;
        ok( $response->print_to( *FH ) );
        is( $output, 'HTTP/1.1 200 OK' . CRLF . CRLF );
        close FH;
    }

}

# print_to( \*FH )
{

    my $response = GX::HTTP::Response->new;

    $response->protocol( 'HTTP/1.1' );
    $response->status( 200 );

    for ( 0 .. 1 ) {
        my $output = '';
        open FH, '>', \$output;
        ok( $response->print_to( \*FH ) );
        is( $output, 'HTTP/1.1 200 OK' . CRLF . CRLF );
        close FH;
    }

}

