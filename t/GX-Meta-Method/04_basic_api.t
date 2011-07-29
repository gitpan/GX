#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;
{

    sub method_1 { 'My::Class::A::method_1' }

}


package main;

use GX::Meta::Class;
use GX::Meta::Method;


use Test::More tests => 6;


{

    my $class = GX::Meta::Class->new( 'My::Class::A' );

    my $method = GX::Meta::Method->new( class => $class, name => 'method_1' );

    isa_ok( $method, 'GX::Meta::Method' );

    is( $method->name, 'method_1' );
    is( $method->full_name, 'My::Class::A::method_1' );
    is( $method->class, $class );
    is( $method->code, \&My::Class::A::method_1 );
    is_deeply( [ $method->code_attributes ], [] );

}

