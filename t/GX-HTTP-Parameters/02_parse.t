#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Parameters;


use Test::More tests => 23;


# GX::HTTP::Parameters->parse
{

    my $parameters = GX::HTTP::Parameters->parse(
        'k0&k1=v11&k2=v21&k2=v22&k3=v31&k3=v32&k3=v33'
    );

    isa_ok( $parameters, 'GX::HTTP::Parameters' );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k0 k1 k2 k3 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k0' ) ],
        [ '' ]
    );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        [ qw( v11 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k2' ) ],
        [ qw( v21 v22 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k3' ) ],
        [ qw( v31 v32 v33 ) ]
    );

}

# $parameters->parse
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->parse(
        'k0&k1=v11&k2=v21&k2=v22&k3=v31&k3=v32&k3=v33'
    );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k0 k1 k2 k3 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k0' ) ],
        [ '' ]
    );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        [ qw( v11 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k2' ) ],
        [ qw( v21 v22 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k3' ) ],
        [ qw( v31 v32 v33 ) ]
    );

}

# No value
{

    my $parameters = GX::HTTP::Parameters->parse(
        'k0&k1=&k2&k2=&k3&k3=&k3'
    );

    isa_ok( $parameters, 'GX::HTTP::Parameters' );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k0 k1 k2 k3 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k0' ) ],
        [ '' ]
    );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        [ '' ]
    );

    is_deeply(
        [ $parameters->get( 'k2' ) ],
        [ '', '' ]
    );

    is_deeply(
        [ $parameters->get( 'k3' ) ],
        [ '', '', '' ]
    );

}

# Order
{

    my $parameters = GX::HTTP::Parameters->new;

    my @keys = 0 .. 9;

    $parameters->parse( join( '&', map { "k$_=v$_" } @keys )  );

    is_deeply(
        [ $parameters->keys ],
        [ map { "k$_" } 0 .. 9 ]
    );

}

# parse(), with default encoding
{

    my $parameters = GX::HTTP::Parameters->new( encoding => 'Windows-1252' );

    $parameters->parse( 'k0=&k1=v11&k2=%80v21&%80k3=&%80k3=&%80k3=v31&%80k3=%80v32' );

    is_deeply(
        [ $parameters->keys ],
        [ "k0", "k1", "k2", "\x{20AC}k3" ]
    );

    is_deeply(
        [ $parameters->get( "k0" ) ],
        [ '' ]
    );

    is_deeply(
        [ $parameters->get( "k1" ) ],
        [ "v11" ]
    );

    is_deeply(
        [ $parameters->get( "k2" ) ],
        [ "\x{20AC}v21" ]
    );

    is_deeply(
        [ $parameters->get( "\x{20AC}k3" ) ],
        [ '', '', "v31", "\x{20AC}v32" ]
    );

}

