#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

my $iterations;
my $total_tests;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    if ( ! eval { require DBD::mysql } ) {
        plan skip_all => "DBD::mysql is not installed";
        exit;
    }

    if ( ! eval {
        DBI->connect( 'DBI:mysql:dbname=gxtest', 'gxuser', 'gxpassword', { PrintError => 0 } )
    } ) {
        plan skip_all => "Cannot connect to test database";
        exit;
    }

    my $prefork_tests  = 2;
    my $child_tests    = 6;
    my $parent_tests   = 4;
    my $postfork_tests = 2;

    $iterations = 3;

    my $tests_per_iteration = $prefork_tests + $child_tests + $parent_tests + $postfork_tests;

    $total_tests = ( $iterations * $tests_per_iteration ) + 1;

    plan tests => $total_tests;

    Test::More->builder->use_numbers( 0 );

}


use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );

require_ok( 'MyApp' );


my $p_database = MyApp::Database::A->instance;
my $p_dbh      = $p_database->connect;


for my $iteration ( 1 .. $iterations ) {

    isa_ok( $p_dbh, 'DBI::db', "[$iteration] [$$] Parent dbh" );

    {
        my ( $result ) = $p_dbh->selectrow_array( 'SELECT 1' );
        is( $result, 1, "[$iteration] [$$] Parent can SELECT 1 before fork" );
    }

    # This is fetched later
    my $sth = $p_dbh->prepare( 'SELECT 1' );
    $sth->execute;

    my $pid = fork();

    if ( ! defined $pid ) {
        die "Can't fork(): $!";
    }

    if ( $pid ) {

        # Parent

        isa_ok( $p_dbh, 'DBI::db', "[$iteration] [$$] Parent dbh" );

        {
            my ( $result ) = $p_dbh->selectrow_array( 'SELECT 1' );
            is( $result, 1, "[$iteration] [$$] Parent can SELECT 1 while the child is alive" );
        }

        is( wait(), $pid, "[$iteration] [$$] Child died" );

        {
            my ( $result ) = $p_dbh->selectrow_array( 'SELECT 1' );
            is( $result, 1, "[$iteration] [$$] Parent can SELECT 1 after the child has died" );
        }

    }
    else {

        # Child

        my $c_database = MyApp::Database::A->instance;

        ok( ! $c_database->is_connected, "[$iteration] [$$] Child is not connected" );

        my $c_dbh = $c_database->connect;

        ok( $c_dbh, "[$iteration] [$$] Child connected" );

        isa_ok( $c_dbh, 'DBI::db', "[$iteration] [$$] Handle object" );

        ok( $c_database->is_connected, "[$iteration] [$$] Child is_connected()" );

        {
            my ( $result ) = $c_dbh->selectrow_array( 'SELECT 1' );
            is( $result, 1, "[$iteration] [$$] Child can SELECT 1" );
        }

        ok( $c_database->disconnect, "[$iteration] [$$] disconnect() in child" );

        exit;

    }

    ok( $p_database->is_connected, "[$iteration] [$$] Parent is still connected" );

    {
        my ( $result ) = $sth->fetchrow_array;
        is( $result, 1, "[$iteration] [$$] Parent can still fetch from the sth executed before the fork" );
    }

}


Test::More->builder->current_test( $total_tests );

