#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;
{

    sub method_1 { 'My::Class::A::method_1', @_ }

    sub method_2 { 'My::Class::A::method_2', @_ }

}


package main;

use GX::Meta::Class;
use GX::Meta::Method;


use Test::More tests => 4;


# "$method"
{

    my $method = GX::Meta::Method->new(
        class => GX::Meta::Class->new( 'My::Class::A' ),
        name  => 'method_1'
    );

    is( "$method", 'method_1' );

}

# $method->( ... )
{

    my $method = GX::Meta::Method->new(
        class => GX::Meta::Class->new( 'My::Class::A' ),
        name  => 'method_1'
    );

    is_deeply( [ $method->( $method, 'foo', 'bar' ) ], [ 'My::Class::A::method_1', $method, 'foo', 'bar' ] );



}

# $method->( ... ), non-existing method
{

    my $class = GX::Meta::Class->new( 'My::Class::A' );

    my $method = GX::Meta::Method->new(
        class => $class,
        name  => 'method_2'
    );

    $class->remove_method( $method );

    {
        local $@;
        eval { $method->() };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@, "Undefined subroutine &My::Class::A::method_2 called at $0 line " . ( __LINE__ - 2 ) . ".\n" );
    }

}

