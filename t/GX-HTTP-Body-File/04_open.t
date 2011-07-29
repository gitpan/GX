#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::File;


use Test::More tests => 12;


# open()
{

    my $body = GX::HTTP::Body::File->new;

    for ( 1 .. 2 ) {
        ok( my $fh = $body->open );
        is( join( '', <$fh> ), '' );
        $fh->close;
    }

}

# open( '<' )
{

    my $body = GX::HTTP::Body::File->new;

    for ( 1 .. 2 ) {
        ok( my $fh = $body->open( '<' ) );
        is( join( '', <$fh> ), '' );
        $fh->close;
    }

}

# open( '>' )
{

    my $data = "Hello World!\n";

    my $body = GX::HTTP::Body::File->new;

    for ( 1 .. 2 ) {
        ok( my $fh = $body->open( '>' ) );
        $fh->print( $data );
        $fh->print( $_ );
        $fh->close;
        is( $body->as_string, $data . $_ );
    }

}

