#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    if ( ! eval { require DBD::SQLite } ) {
        plan skip_all => "DBD::SQLite is not installed";
        exit;
    }

    plan tests => 27;

}


use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );

require_ok( 'MyApp' );


# connect(), is_connected(), disconnect()
{

    my $database = MyApp::Database::A->instance;

    ok( ! $database->is_connected );

    ok( my $dbh = $database->connect );

    isa_ok( $dbh, 'DBI::db' );

    ok( $database->is_connected );

    ok( $dbh->{'AutoCommit'} );
    ok( $dbh->{'RaiseError'} );
    ok( $dbh->{'HandleError'} == \&{'GX::Database::_dbi_error_handler'} );
    ok( ! $dbh->{'PrintError'} );

    my ( $result ) = $dbh->selectrow_array( "SELECT 1" );
    is( $result, 1 );

    ok( $dbh == $database->connect );
    ok( $dbh == MyApp::Database::A->connect );

    ok( $database->disconnect );

}

# Reconnect
{

    for my $invocant ( MyApp::Database::A->instance, 'MyApp::Database::A' ) {

        ok( ! $invocant->is_connected );

        ok( my $dbh = $invocant->connect );
    
        isa_ok( $dbh, 'DBI::db' );

        ok( $invocant->is_connected );

        my ( $result ) = $dbh->selectrow_array( "SELECT 1" );
        is( $result, 1 );

        ok( $dbh == $invocant->connect );

        ok( $invocant->disconnect );

    }

}

