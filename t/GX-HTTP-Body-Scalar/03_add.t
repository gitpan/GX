#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::Scalar;
use IO::File ();


use Test::More tests => 26;


# add( undef )
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add( undef );

    is( $body->as_string, '' );
    is( $body->length, 0 );

}

# add( '' )
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add( '' );

    is( $body->as_string, '' );
    is( $body->length, 0 );

}

# add( $string )
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add( 'Hello' );

    is( $body->as_string, 'Hello' );
    is( $body->length, 5 );

    $body->add( ' World!' );

    is( $body->as_string, 'Hello World!' );
    is( $body->length, 12 );

}

# add( \$string )
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add( \'Hello' );

    is( $body->as_string, 'Hello' );
    is( $body->length, 5 );

    $body->add( \' World!' );

    is( $body->as_string, 'Hello World!' );
    is( $body->length, 12 );

}

# add( $io_file )
{

    my $body = GX::HTTP::Body::Scalar->new;

    my $fh_1 = IO::File->new_tmpfile or die;
    my $fh_2 = IO::File->new_tmpfile or die;

    $fh_1->print( 'Hello' );
    $fh_1->flush;
    $fh_1->seek( 0, 0 );

    $fh_2->print( ' World!' );
    $fh_2->flush;
    $fh_2->seek( 0, 0 );

    $body->add( $fh_1 );

    is( $body->as_string, 'Hello' );
    is( $body->length, 5 );

    $body->add( $fh_2 );

    is( $body->as_string, 'Hello World!' );
    is( $body->length, 12 );

}

# add( $fh )
{

    my $body = GX::HTTP::Body::Scalar->new;

    my $string_1 = 'Hello';
    my $string_2 = ' World!';

    open( my $fh_1, '<', \$string_1 ) or die;
    open( my $fh_2, '<', \$string_2 ) or die;

    $body->add( $fh_1 );

    is( $body->as_string, 'Hello' );
    is( $body->length, 5 );

    $body->add( $fh_2 );

    is( $body->as_string, 'Hello World!' );
    is( $body->length, 12 );

}

# add( \&code )
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add( sub { 'Hello' } );

    is( $body->as_string, 'Hello' );
    is( $body->length, 5 );

    $body->add( sub { ' World!' } );

    is( $body->as_string, 'Hello World!' );
    is( $body->length, 12 );

}

# add( $utf8_string )
{

    my $body = GX::HTTP::Body::Scalar->new;

    local $@;

    eval {
        $body->add( "\x{263A}" );
    };

    isa_ok( $@, 'GX::Exception' );

}

# add( $utf8_string )
{

    my $body = GX::HTTP::Body::Scalar->new( \( my $string = 'abc' ) );

    local $@;

    eval {
        $body->add( "\x{263A}" );
    };

    isa_ok( $@, 'GX::Exception' );

}

