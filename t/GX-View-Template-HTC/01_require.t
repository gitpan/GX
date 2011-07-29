#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if( eval { require HTML::Template::Compiled } ) {
        plan tests => 1;
    }
    else {
        plan skip_all => "HTML::Template::Compiled is not installed";
    }

}


{

    require_ok( 'GX::View::Template::HTC' );

}

