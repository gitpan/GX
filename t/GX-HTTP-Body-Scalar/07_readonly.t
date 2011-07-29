#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::Scalar;


use Test::More tests => 5;


# add()
{

    my $string = "Hello World!\n";

    my $body = GX::HTTP::Body::Scalar->new( content => \$string, readonly => 1 );

    local $@;

    eval { $body->add( 'xxx' ) };

    isa_ok( $@, 'GX::Exception' );

}

# open()
{

    my $string = "Hello World!\n";

    my $body = GX::HTTP::Body::Scalar->new( content => \$string, readonly => 1 );

    isa_ok( $body->open, 'IO::File' );

}

# open( '<' )
{

    my $string = "Hello World!\n";

    my $body = GX::HTTP::Body::Scalar->new( content => \$string, readonly => 1 );

    isa_ok( $body->open( '<' ), 'IO::File' );

}

# open( '>' ), open( '>>' )
{

    my $string = "Hello World!\n";

    my $body = GX::HTTP::Body::Scalar->new( content => \$string, readonly => 1 );

    for my $mode ( qw( > >> ) ) {
        local $@;
        eval { $body->open( $mode ) };
        isa_ok( $@, 'GX::Exception' );
    }

}

