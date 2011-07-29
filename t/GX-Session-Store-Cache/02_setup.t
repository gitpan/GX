#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Test::More;

BEGIN {

    if ( ! eval { require Cache::Memcached } ) {
        plan skip_all => "Cache::Memcached is not installed";
        exit;
    }

    if ( ! eval { require IO::Socket::INET } ) {
        plan skip_all => "IO::Socket::INET is not installed";
        exit;
    }

    my $server_address = '127.0.0.1:11211';

    my $socket = IO::Socket::INET->new(
        PeerAddr => $server_address,
        Timeout  => 3
    );

    if ( ! $socket ) {
        plan skip_all => "No memcached instance found at $server_address\n";
        exit;
    }

}


use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


plan tests => 5;


require_ok( 'MyApp' );


# MyApp::Session::A->store
{

    my $store = MyApp::Session::A->store;

    isa_ok( $store, 'GX::Session::Store::Cache' );

    is( $store->cache, MyApp::Cache::Memcached->instance );
    is( $store->key_prefix, '' );
    isa_ok( $store->serializer, 'GX::Serializer::Storable' );

}

