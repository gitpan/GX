#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::File;
use IO::File ();


use Test::More tests => 27;


my $DATA = "Hello World!\n" x 2;


# print_to( $handle ) - no content
{

    my $body = GX::HTTP::Body::File->new;

    for ( 0 .. 2 ) {
        my $output = '';
        ok( $body->print_to( IO::File->new( \$output, '>' ) ) );
        is( $output, '' );
    }

    {
        is( $body->as_string, '' );
    }

}

# print_to( $handle ) - small content
{

    my $body = GX::HTTP::Body::File->new;

    $body->add( $DATA );

    for ( 0 .. 2 ) {
        my $output = '';
        ok( $body->print_to( IO::File->new( \$output, '>' ) ) );
        is( $output, $DATA );
    }

    {
        is( $body->as_string, $DATA );
    }

    {
        my $fh = $body->open;
        is( join( '', <$fh> ), $DATA );
    }

}

# print_to( $handle ) - large content
{

    my $body = GX::HTTP::Body::File->new;

    $body->add( $DATA x 8192 );

    for ( 0 .. 2 ) {
        my $output = '';
        ok( $body->print_to( IO::File->new( \$output, '>' ) ) );
        is( $output, $DATA x 8192 );
    }

    {
        is( $body->as_string, $DATA x 8192 );
    }

    {
        my $fh = $body->open;
        is( join( '', <$fh> ), $DATA x 8192 );
    }

}

# print_to( *OUTPUT )
{

    my $body = GX::HTTP::Body::File->new;

    $body->add( $DATA x 8192 );

    my $output = '';
    open OUTPUT, '>', \$output;
    ok( $body->print_to( *OUTPUT ) );
    is( $output, $DATA x 8192 );
    close OUTPUT;

}

# print_to( \*OUTPUT )
{

    my $body = GX::HTTP::Body::File->new;

    $body->add( $DATA x 8192 );

    my $output = '';
    open OUTPUT, '>', \$output;
    ok( $body->print_to( \*OUTPUT ) );
    is( $output, $DATA x 8192 );
    close OUTPUT;

}

