#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require Apache2::RequestRec } ) {
        plan skip_all => "mod_perl-2.x is not installed";
        exit;
    }

    plan tests => 1;

}


{

    require_ok( 'GX::Engine::Apache2' );

}

