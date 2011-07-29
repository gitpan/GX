#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Request::Cookies;


use Test::More tests => 84;


my @COOKIES = (
    GX::HTTP::Request::Cookie->new( name => "name_1", value => "value_1_1" ),
    GX::HTTP::Request::Cookie->new( name => "name_2", value => "value_2_1" ),
    GX::HTTP::Request::Cookie->new( name => "name_2", value => "value_2_2" ),
    GX::HTTP::Request::Cookie->new( name => "name_3", value => "value_3_1" ),
    GX::HTTP::Request::Cookie->new( name => "name_3", value => "value_3_2" ),
    GX::HTTP::Request::Cookie->new( name => "name_3", value => "value_3_3" ),
);

my @NAMELESS_COOKIES = (
    GX::HTTP::Request::Cookie->new( value => "value_0_1" ),
    GX::HTTP::Request::Cookie->new( value => "value_0_2" ),
    GX::HTTP::Request::Cookie->new( value => "value_0_3" )
);


# add( $cookie ), add( @cookies )
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    $cookies->add( $COOKIES[0] );

    is_deeply( [ $cookies->all ], [ $COOKIES[0] ] );
    is_deeply( [ $cookies->get( 'name_1' ) ], [ $COOKIES[0] ] );

    $cookies->add( $COOKIES[1] );

    is_deeply( [ $cookies->all ], [ @COOKIES[0,1] ] );
    is_deeply( [ $cookies->get( 'name_1' ) ], [ $COOKIES[0] ] );
    is_deeply( [ $cookies->get( 'name_2' ) ], [ $COOKIES[1] ] );

    $cookies->add( @COOKIES[2 .. 5] );

    is_deeply( [ $cookies->all ], \@COOKIES );
    is_deeply( [ $cookies->get( 'name_1' ) ], [ $COOKIES[0] ] );
    is_deeply( [ $cookies->get( 'name_2' ) ], [ @COOKIES[1,2] ] );
    is_deeply( [ $cookies->get( 'name_3' ) ], [ @COOKIES[3,4,5] ] );

}

# all()
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    is_deeply( [ $cookies->all ], [] );

    $cookies->add( @COOKIES );

    is_deeply( [ $cookies->all ], \@COOKIES );

}

# all(), scalar context
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    is( scalar $cookies->all, 0 );

    $cookies->add( @COOKIES );

    is( scalar $cookies->all, 6 );

}

# clear()
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    $cookies->add( @COOKIES );

    $cookies->clear;

    is_deeply( [ $cookies->all ], [] );

    for ( 0 .. 2 ) {
        is( $cookies->get( "name_$_" ), undef );
        is_deeply( [ $cookies->get( "name_$_" ) ], [] );
    }

}

# count()
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    is( $cookies->count, 0 );

    $cookies->add( @COOKIES );

    is( $cookies->count, 6 );

}

# get(), scalar context
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    $cookies->add( @COOKIES );

    is( $cookies->get( 'name_x' ), undef );
    is( $cookies->get( 'name_1' ), $COOKIES[0] );
    is( $cookies->get( 'name_2' ), $COOKIES[1] );
    is( $cookies->get( 'name_3' ), $COOKIES[3] );

}

# get(), list context
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    $cookies->add( @COOKIES );

    is_deeply( [ $cookies->get( 'name_x' ) ], [] );
    is_deeply( [ $cookies->get( 'name_1' ) ], [ $COOKIES[0] ] );
    is_deeply( [ $cookies->get( 'name_2' ) ], [ @COOKIES[1,2] ] );
    is_deeply( [ $cookies->get( 'name_3' ) ], [ @COOKIES[3,4,5] ] );

}

# names()
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    is_deeply( [ $cookies->names ], [] );

    $cookies->add( @COOKIES );

    is_deeply( [ $cookies->names ], [ qw( name_1 name_2 name_3 ) ] );

}

# remove( $name )
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    $cookies->add( @COOKIES );

    ok( ! $cookies->remove( 'name_x' ) );

    is_deeply( [ $cookies->all ], \@COOKIES );

    is( $cookies->remove( 'name_1' ), 1 );

    is_deeply( [ $cookies->all ], [ @COOKIES[1 .. 5] ] );

    is( $cookies->remove( 'name_2' ), 2 );

    is_deeply( [ $cookies->all ], [ @COOKIES[3 .. 5] ] );

    is ( $cookies->remove( 'name_3' ), 3 );

    is_deeply( [ $cookies->all ], [] );

}

# remove( @names )
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    $cookies->add( @COOKIES );

    is( $cookies->remove( 'name_x', 'name_1' ), 1 );

    is_deeply( [ $cookies->all ], [ @COOKIES[1 .. 5] ] );

    is( $cookies->remove( 'name_2', 'name_3' ), 5 );

    is_deeply( [ $cookies->all ], [] );

}

# set( $cookie ), set( @cookies )
{


    my $cookies = GX::HTTP::Request::Cookies->new;

    $cookies->set( $COOKIES[0] );

    is_deeply( [ $cookies->all ], [ $COOKIES[0] ] );
    is_deeply( [ $cookies->get( 'name_1' ) ], [ $COOKIES[0] ] );

    $cookies->set( $COOKIES[1], $COOKIES[3] );

    is_deeply( [ $cookies->all ], [ @COOKIES[0,1,3] ] );
    is_deeply( [ $cookies->get( 'name_1' ) ], [ $COOKIES[0] ] );
    is_deeply( [ $cookies->get( 'name_2' ) ], [ $COOKIES[1] ] );
    is_deeply( [ $cookies->get( 'name_3' ) ], [ $COOKIES[3] ] );

    $cookies->set( @COOKIES[2,4,5] );

    is_deeply( [ $cookies->all ], [ @COOKIES[0,2,4,5] ] );
    is_deeply( [ $cookies->get( 'name_1' ) ], [ $COOKIES[0] ] );
    is_deeply( [ $cookies->get( 'name_2' ) ], [ $COOKIES[2] ] );
    is_deeply( [ $cookies->get( 'name_3' ) ], [ @COOKIES[4,5] ] );

}

# create( %cookie_attributes )
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    my @cookies;

    for my $i ( 1 .. 3 ) {

        my $cookie = $cookies->create(
            name  => 'name_1',
            value => "value_1_$i"
        );

        isa_ok( $cookie, 'GX::HTTP::Request::Cookie' );

        is( $cookie->name, 'name_1' );
        is( $cookie->value, "value_1_$i" );

        push @cookies, $cookie;

        is_deeply( [ $cookies->all ], \@cookies );

    }

}

# undefined cookie name
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    $cookies->add( $NAMELESS_COOKIES[0], $COOKIES[0] );

    is_deeply( [ $cookies->all ], [ $NAMELESS_COOKIES[0], $COOKIES[0] ] );

    is_deeply( [ $cookies->names ], [ qw( name_1 ) ] );

    is( scalar $cookies->get( undef ), $NAMELESS_COOKIES[0] );

    is_deeply( [ $cookies->get( undef ) ], [ $NAMELESS_COOKIES[0] ] );

    $cookies->add( $NAMELESS_COOKIES[1] );

    is_deeply( [ $cookies->all ], [ $NAMELESS_COOKIES[0], $COOKIES[0], $NAMELESS_COOKIES[1] ] );

    is_deeply( [ $cookies->names ], [ qw( name_1 ) ] );

    is( scalar $cookies->get( undef ), $NAMELESS_COOKIES[0] );

    is_deeply( [ $cookies->get( undef ) ], [ $NAMELESS_COOKIES[0], $NAMELESS_COOKIES[1] ] );

    $cookies->set( $NAMELESS_COOKIES[2] );

    is_deeply( [ $cookies->all ], [ $COOKIES[0], $NAMELESS_COOKIES[2] ] );

    is_deeply( [ $cookies->names ], [ qw( name_1 ) ] );

    is( scalar $cookies->get( undef ), $NAMELESS_COOKIES[2] );

    is_deeply( [ $cookies->get( undef ) ], [ $NAMELESS_COOKIES[2] ] );

    is( $cookies->remove( undef ), 1 );

    is_deeply( [ $cookies->names ], [ qw( name_1 ) ] );

    is( scalar $cookies->get( undef ), undef );

    is_deeply( [ $cookies->get( undef ) ], [] );

}

# overloading
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    is_deeply( [ @$cookies ], [] );

    $cookies->add( @COOKIES );

    is_deeply( [ @$cookies ], \@COOKIES );

}

