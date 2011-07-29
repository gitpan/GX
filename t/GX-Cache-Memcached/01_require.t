#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( eval { require Cache::Memcached } ) {
        plan tests => 1;
    }
    else {
        plan skip_all => "Cache::Memcached is not installed";
    }

}


{

    require_ok( 'GX::Cache::Memcached' );

}

