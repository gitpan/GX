#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp;
{

    use GX;

}


package main;

use Test::More tests => 1;


{

    ok( MyApp->isa( 'GX::Application' ) );

}

