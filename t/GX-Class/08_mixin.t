#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'lib' );


package My::Mixin::B;

sub method_3 { 'My::Mixin::B::method_3' }
sub method_4 { 'My::Mixin::B::method_4' }


package My::Class::A;

use GX::Class;

with 'My::Mixin::A';


package My::Class::B;

use GX::Class;

with qw( My::Mixin::A My::Mixin::B );


package My::Class::C;

use GX::Class with => 'My::Mixin::A';


package My::Class::D;

use GX::Class with => [ qw( My::Mixin::A My::Mixin::B ) ];


package main;


use Test::More tests => 13;


# Runtime declaration
{

    ok( defined &My::Class::A::method_1 );
    ok( defined &My::Class::A::method_2 );

    ok( defined &My::Class::B::method_1 );
    ok( defined &My::Class::B::method_2 );
    ok( defined &My::Class::B::method_3 );
    ok( defined &My::Class::B::method_4 );

}

# Compile time declaration
{

    BEGIN {

        ok( defined &My::Class::C::method_1 );
        ok( defined &My::Class::C::method_2 );

        ok( defined &My::Class::D::method_1 );
        ok( defined &My::Class::D::method_2 );
        ok( defined &My::Class::D::method_3 );
        ok( defined &My::Class::D::method_4 );

    }

}

# Empty mixin package
{

    local $@;
    eval "package My::Class::X; use GX::Class with => 'GX::This::Mixin::Does::Not::Exist';";
    ok( $@ );

}


