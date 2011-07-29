#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require FCGI } ) {
        plan skip_all => "FCGI is not installed";
        exit;
    }

    plan tests => 1;

}


{

    require_ok( 'GX::Script::Server::FCGI' );

}

