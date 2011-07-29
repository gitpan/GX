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


use Test::More tests => 4;


{

    my $class = GX::Meta::Class->new( 'My::Class::A' );

    my $method = GX::Meta::Method->new( class => $class, name => 'method_1' );

    is( $method->(), 'My::Class::A::method_1' );
    is( $method->code, \&{'My::Class::A::method_1'} );

    {
        no warnings 'redefine';
        *My::Class::A::method_1 = sub { 'My::Class::A::redefined_method_1' };
    }

    is( $method->(), 'My::Class::A::redefined_method_1' );
    is( $method->code, \&{'My::Class::A::method_1'} );

}

