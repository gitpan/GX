#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

my $Server_Address;

BEGIN {

    if ( ! eval { require Cache::Memcached } ) {
        plan skip_all => "Cache::Memcached is not installed";
        exit;
    }

    if ( ! eval { require IO::Socket::INET } ) {
        plan skip_all => "IO::Socket::INET is not installed";
        exit;
    }

    $Server_Address = $ENV{'GX_MEMCACHED_SERVER'} || '127.0.0.1:11211';

    my $socket = IO::Socket::INET->new(
        PeerAddr => $Server_Address,
        Timeout  => 3
    );

    if ( ! $socket ) {
        plan skip_all => "No memcached instance found at $Server_Address\n";
    }

    plan tests => 58;

}


use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'MyApp', 'lib' );

require_ok( 'MyApp' );


my $Cache = MyApp->instance->cache( 'Memcached' );


# Setup options
{

    is( $Cache->namespace, ref $Cache );

    is_deeply( [ $Cache->servers ], [ $Server_Address ] );

    is_deeply( { $Cache->options }, {} );

}

# Memcached instance
{

    isa_ok( $Cache->memcached, 'Cache::Memcached' );

}

# clear()
{

    ok( $Cache->clear );

}

# get(), set()
{

    for my $i ( 1 .. 3 ) {
        ok( $Cache->set( "k$i", "v${i}_1" ) );    
        is( $Cache->get( "k$i" ), "v${i}_1" );
    }
    
    for my $i ( 1 .. 3 ) {
        ok( $Cache->set( "k$i", "v${i}_2" ) );    
        is( $Cache->get( "k$i" ), "v${i}_2" );
    }

    is( $Cache->get( '999' ), undef );

}

# get() - multiple keys
{

    is_deeply(
        [ $Cache->get( 'k1', 'k2' ) ],
        [ 'v1_2', 'v2_2' ]
    );

    is_deeply(
        [ $Cache->get( 'k1', 'k2', 'k3' ) ],
        [ 'v1_2', 'v2_2', 'v3_2' ]
    );

    is_deeply(
        scalar $Cache->get( 'k1', 'k2' ),
        {
            'k1' => 'v1_2',
            'k2' => 'v2_2'
        }
    );

    is_deeply(
        scalar $Cache->get( 'k1', 'k2', 'k3' ),
        {
            'k1' => 'v1_2',
            'k2' => 'v2_2',
            'k3' => 'v3_2'
        }
    );

}

# add()
{

    for my $i ( 1 .. 3 ) {
        ok( ! $Cache->add( "k$i", "v${i}_x" ) );    
        is( $Cache->get( "k$i" ), "v${i}_2" );
    }

    for my $i ( 4 .. 6 ) {
        ok( $Cache->add( "k$i", "v${i}_1" ) );    
        is( $Cache->get( "k$i" ), "v${i}_1" );
    }

}

# replace()
{

    for my $i ( 1 .. 3 ) {
        ok( $Cache->replace( "k$i", "v${i}_3" ) );    
        is( $Cache->get( "k$i" ), "v${i}_3" );
    }

    ok( ! $Cache->replace( "kx", "vx_1" ) );    
    is( $Cache->get( "kx" ), undef );

}

# remove()
{

    for my $i ( 1 .. 6 ) {
        ok( $Cache->remove( "k$i" ) );    
        is( $Cache->get( "k$i" ), undef );
    }

    ok( ! $Cache->remove( "kx" ) );    

}

# get(), set() - complex data
{

    my %data = ( 'k1' => 'v1' );

    $Cache->set( 'k1', \%data );    

    is_deeply( $Cache->get( 'k1' ), \%data );

}

# Cleanup
{

    ok( $Cache->clear );

}

