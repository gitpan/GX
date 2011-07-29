#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

use GX::Class::Singleton;

has 'scalar_attribute_1';


package main;

use Scalar::Util qw( refaddr );


use Test::More tests => 11;


{

    my $object = My::Class::A->new( 'scalar_attribute_1' => 1 );

    isa_ok( $object, 'My::Class::A' );
    isa_ok( $object, 'GX::Class::Singleton' );

    my $object_refaddr = refaddr( $object );

    is( refaddr( My::Class::A->new ),      $object_refaddr );
    is( refaddr( My::Class::A->instance ), $object_refaddr );

    undef $object;

    is( refaddr( My::Class::A->new ),      $object_refaddr );
    is( refaddr( My::Class::A->instance ), $object_refaddr );

}

{

    my $object_refaddr = refaddr( My::Class::A->instance );

    local $@;
    eval { My::Class::A->new( 'scalar_attribute_1' => 2 ) };
    isa_ok( $@, 'GX::Exception' );

    is( refaddr( My::Class::A->instance ), $object_refaddr );

}

{

    My::Class::A->destroy;

    my $object = My::Class::A->new( 'scalar_attribute_1' => 3 );

    isa_ok( $object, 'My::Class::A' );

    my $object_refaddr = refaddr( $object );

    is( refaddr( My::Class::A->new ),      $object_refaddr );
    is( refaddr( My::Class::A->instance ), $object_refaddr );

}

