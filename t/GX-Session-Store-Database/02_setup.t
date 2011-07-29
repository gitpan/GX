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


plan tests => 5;


require_ok( 'MyApp' );


# MyApp::Session::A->store
{

    my $store = MyApp::Session::A->store;

    isa_ok( $store, 'GX::Session::Store::Database' );

    is( $store->database, MyApp::Database::SQLite->instance );
    is( $store->table, 'sessions' );
    isa_ok( $store->serializer, 'GX::Serializer::Storable' );

}

