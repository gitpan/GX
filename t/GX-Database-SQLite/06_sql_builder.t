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

    plan tests => 2;

}


use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );

require_ok( 'MyApp' );


# sql_builder()
{

    isa_ok( MyApp::Database::A->instance->sql_builder, 'GX::SQL::Builder::SQLite' );

}

