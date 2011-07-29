#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::Scalar;


use Test::More tests => 12;


# open()
{

    my $string = "Hello World!\n";

    my $body = GX::HTTP::Body::Scalar->new( \$string );

    for ( 1 .. 2 ) {
        ok( my $fh = $body->open );
        is( join( '', <$fh> ), $string );
        $fh->close;
    }

}

# open( '<' )
{

    my $string = "Hello World!\n";

    my $body = GX::HTTP::Body::Scalar->new( \$string );

    for ( 1 .. 2 ) {
        ok( my $fh = $body->open( '<' ) );
        is( join( '', <$fh> ), $string );
        $fh->close;
    }

}

# open( '>' )
{

    my $string = "Hello World!\n";

    my $body = GX::HTTP::Body::Scalar->new;

    for ( 1 .. 2 ) {
        ok( my $fh = $body->open( '>' ) );
        $fh->print( $string );
        $fh->print( $_ );
        $fh->close;
        is( $body->as_string, $string . $_ );
    }

}

