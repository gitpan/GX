#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Test::More;

BEGIN {

    if ( ! eval { require DBD::SQLite } ) {
        plan skip_all => "DBD::SQLite is not installed";
        exit;
    }

}


use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


plan tests => 34;


my $TIME = time();


require_ok( 'MyApp' );


# Setup the table
{

    my $dbh = MyApp::Database::SQLite->dbh;

    $dbh->do(
        'CREATE TABLE sessions (' .
        '  id             VARCHAR(32) NOT NULL PRIMARY KEY,' .
        '  remote_address VARCHAR,' .
        '  started_at     INTEGER,' .
        '  updated_at     INTEGER,' .
        '  expires_at     INTEGER,' .
        '  data           BLOB' .
        ')'
    );

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

        local $@;

        eval { MyApp::Session::A->store->save( $session_id, $session_info, $session_data ) };

        isa_ok( $@, 'GX::Exception' );

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

