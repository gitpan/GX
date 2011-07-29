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


use Test::More tests => 8;


# new()
{

    my $class = GX::Meta::Class->new( 'My::Class::A' );

    my $method = GX::Meta::Method->new( class => $class, name => 'method_1' );

    isa_ok( $method, 'GX::Meta::Method' );

    is( $method->name, 'method_1' );
    is( $method->class, $class );
    is( $method->code, \&My::Class::A::method_1 );

}

# new(), non-existing method
{

    my $class = GX::Meta::Class->new( 'My::Class::A' );

    {
        local $@;
        eval { my $method = GX::Meta::Method->new( class => $class, name => 'method_x' ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@, "Method &My::Class::A::method_x does not exist at $0 line " . ( __LINE__ - 2 ) . ".\n" );
    }

    ok( ! defined &{'My::Class::A::method_x'} );

    is_deeply(
        [ keys %{$class->package->symbol_table} ],
        [ qw( method_1 ) ]
    );

}

