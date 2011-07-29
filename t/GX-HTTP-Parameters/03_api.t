#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Parameters;


use Test::More tests => 79;


use Encode qw( encode );


# add(), keys(), get()
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->add( 'k1', 'v11' );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k1 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        [ qw( v11 ) ]
    );

    $parameters->add( 'k2', 'v21' );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k1 k2 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        [ qw( v11 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k2' ) ],
        [ qw( v21 ) ]
    );

    $parameters->add( 'k2', 'v22' );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k1 k2 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        [ qw( v11 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k2' ) ],
        [ qw( v21 v22 ) ]
    );

    $parameters->add( 'k3', 'v31', 'v32', 'v33' );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k1 k2 k3 ) ]
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
        [ $parameters->get( 'k2' ) ],
        [ qw( v21 v22 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k3' ) ],
        [ qw( v31 v32 v33 ) ]
    );

    $parameters->add( 'k3' );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k1 k2 k3 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k3' ) ],
        [ qw( v31 v32 v33 ) ]
    );

    $parameters->add( 'k4', undef );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k1 k2 k3 k4 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k4' ) ],
        [ undef ]
    );

}

# get() context
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->add( 'k1', 'v11' );
    $parameters->add( 'k2', 'v21', 'v22' );

    is( scalar $parameters->get( 'k1' ), 'v11' );
    is( scalar $parameters->get( 'k2' ), 'v21' );
    is( scalar $parameters->get( 'kx' ), undef );

    is_deeply( [ $parameters->get( 'k1' ) ], [ 'v11' ] );
    is_deeply( [ $parameters->get( 'k2' ) ], [ 'v21', 'v22' ] );
    is_deeply( [ $parameters->get( 'kx' ) ], [] );

}

# set()
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->set( 'k1', 'v11' );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k1 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        [ qw( v11 ) ]
    );

    $parameters->set( 'k1', 'v12' );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        [ qw( v12 ) ]
    );

    $parameters->set( 'k1', 'v13', 'v14' );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        [ qw( v13 v14 ) ]
    );

    $parameters->set( 'k1' );

    is_deeply(
        [ $parameters->keys ],
        []
    );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        []
    );

    $parameters->set( 'k1', undef );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k1 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        [ undef ]
    );

}

# remove()
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->add( 'k1', 'v11' );
    $parameters->add( 'k2', 'v21', 'v22' );
    $parameters->add( 'k3', 'v31', 'v32', 'v33' );

    ok( $parameters->remove( 'k1' ) );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k2 k3 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        []
    );

    ok( $parameters->remove( 'k2' ) );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k3 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k2' ) ],
        []
    );

    ok( $parameters->remove( 'k3' ) );

    is_deeply(
        [ $parameters->keys ],
        []
    );

    is_deeply(
        [ $parameters->get( 'k3' ) ],
        []
    );

}

# count()
{

    my $parameters = GX::HTTP::Parameters->new;

    is( $parameters->count, 0 );

    $parameters->add( 'k1', 'v11' );

    is( $parameters->count, 1 );

    $parameters->add( 'k2', 'v21', 'v22' );

    is( $parameters->count, 2 );

    $parameters->add( 'k3', 'v31', 'v32', 'v33' );

    is( $parameters->count, 3 );

}

# exists()
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->add( 'k1', 'v11' );

    ok( $parameters->exists( 'k1' ) );

    ok( ! $parameters->exists( 'kx' ) );

}

# as_string(), with default encoding
{

    my $parameters = GX::HTTP::Parameters->new( encoding => 'Windows-1252' );

    $parameters->add( "k0" => undef );
    $parameters->add( "k1" => "v11" );
    $parameters->add( "k2" => "\x{20AC}v21" );
    $parameters->add( "\x{20AC}k3" => undef, '', "v31", "\x{20AC}v32" );

    is(
        $parameters->as_string,
        'k0=&k1=v11&k2=%80v21&%80k3=&%80k3=&%80k3=v31&%80k3=%80v32'
    );

}

# as_string(), no default encoding, exception
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->add( "\x{20AC}", "\x{263A}" );

    local $@;

    eval { my $string = $parameters->as_string };

    isa_ok( $@, 'GX::Exception' );

}

# as_string(), no default encoding, ASCII-only
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->add( 'k0', undef );
    $parameters->add( 'k1', 'v11' );
    $parameters->add( 'k2', 'v21', 'v22' );
    $parameters->add( 'k3', 'v31', 'v32', 'v33' );

    is(
        $parameters->as_string,
        'k0=&k1=v11&k2=v21&k2=v22&k3=v31&k3=v32&k3=v33'
    );

}

# as_string(), no default encoding, ASCII-only, URL-encoding
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->add( 'k1', 'Hello World!' );

    is(
        $parameters->as_string,
        'k1=Hello%20World%21'
    );

}

# merge()
{

    my $parameters_0 = GX::HTTP::Parameters->new;
    my $parameters_1 = GX::HTTP::Parameters->new;
    my $parameters_2 = GX::HTTP::Parameters->new;
    my $parameters_3 = GX::HTTP::Parameters->new;

    $parameters_1->add( 'k0', undef );
    $parameters_1->add( 'k1', 'v11' );
    $parameters_1->add( 'k2', 'v21' );

    $parameters_2->add( 'k3', 'v31' );
    $parameters_2->add( 'k2', 'v22' );

    $parameters_3->add( 'k3', 'v32' );
    $parameters_3->add( 'k3', 'v33' );

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->merge( $parameters_0, $parameters_1, $parameters_2, $parameters_3 );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k0 k1 k2 k3 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k0' ) ],
        [ undef ]
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

# merge() as constructor
{

    my $parameters_0 = GX::HTTP::Parameters->new;
    my $parameters_1 = GX::HTTP::Parameters->new;
    my $parameters_2 = GX::HTTP::Parameters->new;
    my $parameters_3 = GX::HTTP::Parameters->new;

    $parameters_1->add( 'k0', undef );
    $parameters_1->add( 'k1', 'v11' );
    $parameters_1->add( 'k2', 'v21' );

    $parameters_2->add( 'k3', 'v31' );
    $parameters_2->add( 'k2', 'v22' );

    $parameters_3->add( 'k3', 'v32' );
    $parameters_3->add( 'k3', 'v33' );

    my $parameters = GX::HTTP::Parameters->merge( $parameters_0, $parameters_1, $parameters_2, $parameters_3 );

    isa_ok( $parameters, 'GX::HTTP::Parameters' );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k0 k1 k2 k3 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k0' ) ],
        [ undef ]
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

# decode(), fallback to UTF-8
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->add( "k0" => undef );
    $parameters->add( "k1" => "v11" );
    $parameters->add( "k2" => encode( 'UTF-8', "\x{263A}v21" ) );
    $parameters->add( encode( 'UTF-8', "\x{263A}k3" ) => undef, '', "v31", encode( 'UTF-8', "\x{263A}v32" ) );

    $parameters->decode;

    is_deeply(
        [ $parameters->keys ],
        [ "k0", "k1", "k2", "\x{263A}k3" ]
    );

    is_deeply(
        [ $parameters->get( "k0" ) ],
        [ undef ]
    );

    is_deeply(
        [ $parameters->get( "k1" ) ],
        [ "v11" ]
    );

    is_deeply(
        [ $parameters->get( "k2" ) ],
        [ "\x{263A}v21" ]
    );

    is_deeply(
        [ $parameters->get( "\x{263A}k3" ) ],
        [ undef, '', "v31", "\x{263A}v32" ]
    );

}

# decode( 'UTF-8' )
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->add( "k0" => undef );
    $parameters->add( "k1" => "v11" );
    $parameters->add( "k2" => encode( 'UTF-8', "\x{263A}v21" ) );
    $parameters->add( encode( 'UTF-8', "\x{263A}k3" ) => undef, '', "v31", encode( 'UTF-8', "\x{263A}v32" ) );

    $parameters->decode( 'UTF-8' );

    is_deeply(
        [ $parameters->keys ],
        [ "k0", "k1", "k2", "\x{263A}k3" ]
    );

    is_deeply(
        [ $parameters->get( "k0" ) ],
        [ undef ]
    );

    is_deeply(
        [ $parameters->get( "k1" ) ],
        [ "v11" ]
    );

    is_deeply(
        [ $parameters->get( "k2" ) ],
        [ "\x{263A}v21" ]
    );

    is_deeply(
        [ $parameters->get( "\x{263A}k3" ) ],
        [ undef, '', "v31", "\x{263A}v32" ]
    );

}

# decode(), with default encoding
{

    my $parameters = GX::HTTP::Parameters->new( encoding => 'Windows-1252' );

    $parameters->add( "k0" => undef );
    $parameters->add( "k1" => "v11" );
    $parameters->add( "k2" => encode( 'Windows-1252', "\x{20AC}v21" ) );
    $parameters->add( encode( 'Windows-1252', "\x{20AC}k3" ) => undef, '', "v31", encode( 'Windows-1252', "\x{20AC}v32" ) );

    $parameters->decode;

    is_deeply(
        [ $parameters->keys ],
        [ "k0", "k1", "k2", "\x{20AC}k3" ]
    );

    is_deeply(
        [ $parameters->get( "k0" ) ],
        [ undef ]
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
        [ undef, '', "v31", "\x{20AC}v32" ]
    );

}

# decode(), exception on double-decode
{

    my $parameters = GX::HTTP::Parameters->new;

    $parameters->add( "kx" => "\x{263A}" );

    local $@;

    eval {
        $parameters->decode;
    };

    isa_ok( $@, 'GX::Exception' );

}

# Value stringification
{

    my $parameters = GX::HTTP::Parameters->new;

    my $ref = {}; 

    $parameters->add( 'k1', $ref );

    is_deeply(
        [ $parameters->keys ],
        [ qw( k1 ) ]
    );

    is_deeply(
        [ $parameters->get( 'k1' ) ],
        [ "$ref" ]
    );

}

