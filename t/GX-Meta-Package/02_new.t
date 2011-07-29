#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;
{

    our @array_1;
    our %hash_1;
    our $scalar_1;

    sub function_1 { 1 }

    sub constant_1 () { 'constant_1' }

    use constant constant_2 => 'constant_2';

}


package main;

use GX::Meta::Package;


use Test::More tests => 4;


# new( $package_name )
{

    my $package = GX::Meta::Package->new( 'My::Class::A' );

    isa_ok( $package, 'GX::Meta::Package' );

    is( $package->name, 'My::Class::A' );

}

# new( name => $package_name )
{

    my $package = GX::Meta::Package->new( name => 'My::Class::A' );

    isa_ok( $package, 'GX::Meta::Package' );

    is( $package->name, 'My::Class::A' );

}

