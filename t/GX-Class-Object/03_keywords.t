#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

use GX::Class::Object;


package main;


use Test::More tests => 10;


{

    ok( defined &My::Class::A::build );
    ok( defined &My::Class::A::extends );
    ok( defined &My::Class::A::has );
    ok( defined &My::Class::A::static );
    ok( defined &My::Class::A::with );

    eval "package My::Class::A; no GX::Class;";

    ok( ! defined &My::Class::A::build );
    ok( ! defined &My::Class::A::extends );
    ok( ! defined &My::Class::A::has );
    ok( ! defined &My::Class::A::static );
    ok( ! defined &My::Class::A::with );

}

