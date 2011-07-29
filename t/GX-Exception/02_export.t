#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Package::A;

use GX::Exception;


package main;


use Test::More tests => 4;


{

    ok( defined &My::Package::A::complain );
    ok( defined &My::Package::A::throw );
    ok( defined &My::Package::A::try );
    ok( defined &My::Package::A::catch );

}

