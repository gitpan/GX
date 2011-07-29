#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    if ( ! eval { require DBD::Pg } ) {
        plan skip_all => "DBD::Pg is not installed";
        exit;
    }

    plan tests => 1;

}


{

    require_ok( 'GX::SQL::Builder::Pg' );

}

