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
    }

}


use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


plan tests => 34;


my $TIME = time();


require_ok( 'MyApp' );


# Clear the cache
{
    
    MyApp::Cache::Memcached->instance->clear;

}

# save()
{

    for my $i ( 1 .. 3 ) {

        my $session_id   = $i;
        my $session_info = {
            'remote_address' => undef,
            'started_at'     => $TIME,
            'updated_at'     => undef,
            'expires_at'     => ( $TIME + 3600 )
        };
        my $session_data = {
            'k1' => $i
        };

        ok( MyApp::Session::A->store->save( $session_id, $session_info, $session_data ) );

    }

}

# save(), existing key
{

    for my $i ( 1 .. 3 ) {

        my $session_id   = $i;
        my $session_info = {};
        my $session_data = {};

        ok( ! MyApp::Session::A->store->save( $session_id, $session_info, $session_data ) );

    }

}

# load()
{

    for my $i ( 1 .. 3 ) {

        my $session_id = $i;

        is_deeply(
            [ MyApp::Session::A->store->load( $session_id ) ],
            [
                {
                    'remote_address' => undef,
                    'started_at'     => $TIME,
                    'updated_at'     => undef,
                    'expires_at'     => ( $TIME + 3600 )
                },
                {
                    'k1' => $i
                }
            ]
        );

    }

}

# load(), non-existing key
{

    for my $i ( 4 .. 5 ) {

        my $session_id = $i;

        is_deeply( [ MyApp::Session::A->store->load( $session_id ) ], [] );

    }

}

# update()
{

    for my $i ( 1 .. 3 ) {

        my $session_id   = $i;
        my $session_info = {
            'remote_address' => undef,
            'started_at'     => $TIME,
            'updated_at'     => $TIME + 1,
            'expires_at'     => ( $TIME + 3600 + 1 )
        };
        my $session_data = {
            'k1' => $i + 1,
            'k2' => ( $i + 2 )
        };

        ok( MyApp::Session::A->store->update( $session_id, $session_info, $session_data ) );

    }

    for my $i ( 1 .. 3 ) {

        my $session_id = $i;

        is_deeply(
            [ MyApp::Session::A->store->load( $session_id ) ],
            [
                {
                    'remote_address' => undef,
                    'started_at'     => $TIME,
                    'updated_at'     => $TIME + 1,
                    'expires_at'     => ( $TIME + 3600 + 1 )
                },
                {
                    'k1' => ( $i + 1 ),
                    'k2' => ( $i + 2 )
                }
            ]
        );

    }

}

# update(), non-existing key
{

    for my $i ( 4 .. 5 ) {

        my $session_id   = $i;
        my $session_info = {};
        my $session_data = {};

        ok( ! MyApp::Session::A->store->update( $session_id, $session_info, $session_data ) );

        is_deeply( [ MyApp::Session::A->store->load( $session_id ) ], [] );

    }

}

# delete()
{

    for my $i ( 1 .. 3 ) {

        my $session_id = $i;

        ok( MyApp::Session::A->store->delete( $session_id ) );

        is_deeply( [ MyApp::Session::A->store->load( $session_id ) ], [] );

    }

}

# delete(), non-existing key
{

    for my $i ( 1 .. 3 ) {

        my $session_id = $i;

        ok( ! MyApp::Session::A->store->delete( $session_id ) );

        is_deeply( [ MyApp::Session::A->store->load( $session_id ) ], [] );

    }

}

# Clear the cache
{
    
    MyApp::Cache::Memcached->instance->clear;

}

