#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if( eval { require Template } ) {
        plan tests => 1;
    }
    else {
        plan skip_all => "Template is not installed";
    }

}


{

    require_ok( 'GX::View::Template::TT' );

}

