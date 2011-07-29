#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Headers;


use Test::More tests => 29;


# add()
{

    my $headers = GX::HTTP::Headers->new;

    $headers->add( 'Content-Type' => 'text/html' );
    $headers->add( 'Content-Encoding' => 'gzip' );
    $headers->add( 'X-Header' => 'foo' );
    $headers->add( 'X-HeAdEr' => 'bar' );

    is_deeply(
        scalar $headers->_headers,
        {
            'CONTENT-TYPE'     => [ 'text/html' ],
            'CONTENT-ENCODING' => [ 'gzip' ],
            'X-HEADER'         => [ qw( foo bar ) ]
        }
    );

}

# set()
{

    my $headers = GX::HTTP::Headers->new;

    $headers->set( 'Content-Type' => 'text/plain' );
    $headers->set( 'CONTENT-TYPE' => 'text/html' );
    $headers->set( 'X-HEADER' => 'foo' );
    $headers->set( 'X-Header' => qw( foo bar ) );

    is_deeply(
        scalar $headers->_headers,
        {
            'CONTENT-TYPE' => [ 'text/html' ],
            'X-HEADER'     => [ qw( foo bar ) ]
        }
    );

}

# get()
{

    my $headers = GX::HTTP::Headers->new;

    $headers->set( 'Content-Type' => 'text/html' );
    $headers->set( 'Content-Encoding' => 'gzip' );
    $headers->set( 'X-Header' => qw( foo bar ) );

    # scalar context

    is( scalar $headers->get( 'Content-Type' ), 'text/html' );
    is( scalar $headers->get( 'content-type' ), 'text/html' );

    is( scalar $headers->get( 'Content-Encoding' ), 'gzip' );
    is( scalar $headers->get( 'CONTENT-ENCODING' ), 'gzip' );

    is( scalar $headers->get( 'X-Header' ), 'foo' );
    is( scalar $headers->get( 'X-HeAdEr' ), 'foo' );

    is( scalar $headers->get( 'X-Foo' ), undef );

    # list context

    is_deeply( [ $headers->get( 'Content-Type' ) ], [ 'text/html' ] );
    is_deeply( [ $headers->get( 'content-type' ) ], [ 'text/html' ] );

    is_deeply( [ $headers->get( 'Content-Encoding' ) ], [ 'gzip' ] );
    is_deeply( [ $headers->get( 'CONTENT-ENCODING' ) ], [ 'gzip' ] );

    is_deeply( [ $headers->get( 'X-Header' ) ], [ qw( foo bar ) ] );
    is_deeply( [ $headers->get( 'X-HeAdEr' ) ], [ qw( foo bar ) ] );

    is_deeply( [ $headers->get( 'X-Foo' ) ], [] );

}

# remove()
{

    my $headers = GX::HTTP::Headers->new;

    $headers->set( 'Content-Type' => 'text/html' );
    $headers->set( 'Content-Encoding' => 'gzip' );
    $headers->set( 'X-Header' => qw( foo bar ) );

    ok( ! $headers->remove( 'Content-X' ) );

    ok( $headers->remove( 'Content-Type' ) );

    is_deeply(
        scalar $headers->_headers,
        {
            'CONTENT-ENCODING' => [ 'gzip' ],
            'X-HEADER'         => [ qw( foo bar ) ]
        }
    );

    ok( $headers->remove( 'content-encoding' ) );

    is_deeply(
        scalar $headers->_headers,
        {
            'X-HEADER' => [ qw( foo bar ) ]
        }
    );

    ok( $headers->remove( 'X-HeAdEr' ) );

    is_deeply( scalar $headers->_headers, {} );

}

# field_names()
{

    my $headers = GX::HTTP::Headers->new;

    $headers->set( 'Content-Type' => 'text/html' );
    $headers->set( 'Content-Encoding' => 'gzip' );
    $headers->set( 'X-Header' => qw( foo bar ) );

    is_deeply(
        [ sort $headers->field_names ],
        [ sort qw( Content-Type Content-Encoding X-HEADER ) ]
    );

}

# clear()
{

    my $headers = GX::HTTP::Headers->new;

    $headers->set( 'Content-Type' => 'text/html' );
    $headers->set( 'Content-Encoding' => 'gzip' );
    $headers->set( 'X-Header' => qw( foo bar ) );

    $headers->clear;

    is_deeply( [ $headers->field_names ], [] );
    is_deeply( scalar $headers->_headers, {} );

}

# count()
{

    my $headers = GX::HTTP::Headers->new;

    is( $headers->count, 0 );

    $headers->add( 'Content-Type' => 'text/html' );

    is( $headers->count, 1 );

    $headers->add( 'Content-Encoding' => 'gzip' );

    is( $headers->count, 2 );

}

