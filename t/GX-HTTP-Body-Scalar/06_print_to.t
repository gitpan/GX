#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::Scalar;
use IO::File ();


use Test::More tests => 6;


my $DATA = "Hello World!\n";


# print_to( $handle )
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add( $DATA );

    my $output = '';
    ok( $body->print_to( IO::File->new( \$output, '>' ) ) );
    is( $output, $DATA );

}

# print_to( *OUTPUT )
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add( $DATA );

    my $output = '';
    open OUTPUT, '>', \$output;
    ok( $body->print_to( *OUTPUT ) );
    is( $output, $DATA );
    close OUTPUT;

}

# print_to( \*OUTPUT )
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add( $DATA );

    my $output = '';
    open OUTPUT, '>', \$output;
    ok( $body->print_to( \*OUTPUT ) );
    is( $output, $DATA );
    close OUTPUT;

}

