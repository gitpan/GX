#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

sub new { my $class = shift; bless { @_ }, $class }

sub attribute_3_initializer { 1 }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Bool;


use Test::More tests => 205;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Bool->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Bool->new(
    class   => $CLASS_A,
    name    => 'attribute_2',
    default => 1
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Bool->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    initializer => 'attribute_3_initializer'
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Bool->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    initializer => sub { 1 }
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2,
    $ATTRIBUTE_3,
    $ATTRIBUTE_4
);

my @ACCESSOR_TYPES = qw( default get set clear defined );


# Accessor setup
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        for my $accessor_type ( @ACCESSOR_TYPES ) {

            my $accessor_name = "${attribute_name}_${accessor_type}";

            $attribute->add_accessor(
                name => $accessor_name,
                type => $accessor_type
            );

        }

        $attribute->install_accessors;

    }

}

# set(), get(), clear(), defined()
{

    my $object = My::Class::A->new;

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        my $accessor_get     = "${attribute_name}_get";
        my $accessor_set     = "${attribute_name}_set";
        my $accessor_clear   = "${attribute_name}_clear";
        my $accessor_defined = "${attribute_name}_defined";

        is( $object->$accessor_set( 1 ), undef );
        is( $object->{$attribute->slot_key}, 1 );

        is( $object->$accessor_get, 1 );
        is_deeply( [ $object->$accessor_get ], [ 1 ] );

        ok( $object->$accessor_defined );

        is( $object->$accessor_set( 0 ), undef );
        is( $object->{$attribute->slot_key}, 0 );

        is( $object->$accessor_get, 0 );
        is_deeply( [ $object->$accessor_get ], [ 0 ] );

        ok( $object->$accessor_defined );

        is( $object->$accessor_set( undef ), undef );
        is( $object->{$attribute->slot_key}, undef );

        is( $object->$accessor_get, undef );
        is_deeply( [ $object->$accessor_get ], [ undef ] );

        ok( ! $object->$accessor_defined );

        is( $object->$accessor_set( '' ), undef );
        is( $object->{$attribute->slot_key}, 0 );

        is( $object->$accessor_set( 'true' ), undef );
        is( $object->{$attribute->slot_key}, 1 );

        is_deeply( [ $object->$accessor_set( 0 ) ], [] );
        is( $object->{$attribute->slot_key}, 0 );

        $object->$accessor_clear;
        ok( ! exists $object->{$attribute->slot_key} );

    }

}

# default() - set and get
{

    my $object = My::Class::A->new;

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        my $accessor_default = "${attribute_name}_default";

        is( $object->$accessor_default( 1 ), 1 );
        is( $object->{$attribute->slot_key}, 1 );
        is( $object->$accessor_default, 1 );
        is_deeply( [ $object->$accessor_default ], [ 1 ] );

        is( $object->$accessor_default( 0 ), 0 );
        is( $object->{$attribute->slot_key}, 0 );
        is( $object->$accessor_default, 0 );
        is_deeply( [ $object->$accessor_default ], [ 0 ] );

        is( $object->$accessor_default( undef ), undef );
        is( $object->{$attribute->slot_key}, undef );
        is( $object->$accessor_default, undef );
        is_deeply( [ $object->$accessor_default ], [ undef ] );

        is( $object->$accessor_default( 'true' ), 1 );
        is( $object->{$attribute->slot_key}, 1 );
        is( $object->$accessor_default, 1 );
        is_deeply( [ $object->$accessor_default ], [ 1 ] );

        is( $object->$accessor_default( '' ), 0 );
        is( $object->{$attribute->slot_key}, 0 );
        is( $object->$accessor_default, 0 );
        is_deeply( [ $object->$accessor_default ], [ 0 ] );

        is_deeply( [ $object->$accessor_default( 1 ) ], [ 1 ] );
        is_deeply( [ $object->$accessor_default( 0 ) ], [ 0 ] );
        is_deeply( [ $object->$accessor_default( undef ) ], [ undef ] );
        is_deeply( [ $object->$accessor_default( 'true' ) ], [ 1 ] );
        is_deeply( [ $object->$accessor_default( '' ) ], [ 0 ] );

    }

}

# get() - native / default value
{

    for my $attribute ( $ATTRIBUTE_1 ) {
        my $object = My::Class::A->new;
        my $attribute_name = $attribute->name;
        my $accessor_get = "${attribute_name}_get";
        is( $object->$accessor_get, undef );
        is_deeply( $object, { $attribute->slot_key => undef } );

    }

    for my $attribute ( $ATTRIBUTE_2 ) {
        my $object = My::Class::A->new;
        my $attribute_name = $attribute->name;
        my $accessor_get = "${attribute_name}_get";
        is( $object->$accessor_get, 1 );
        is_deeply( $object, { $attribute->slot_key => 1 } );
    }

}

# get() - initializer value
{

    for my $attribute ( $ATTRIBUTE_3, $ATTRIBUTE_4 ) {
        my $object = My::Class::A->new;
        my $attribute_name = $attribute->name;
        my $accessor_get = "${attribute_name}_get";
        is( $object->$accessor_get, 1 );
        is_deeply( $object, { $attribute->slot_key => 1 } );
    }

}

# default() - default value
{

    for my $attribute ( $ATTRIBUTE_1 ) {
        my $object = My::Class::A->new;
        my $attribute_name = $attribute->name;
        my $accessor_default = "${attribute_name}_default";
        is( $object->$accessor_default, undef );
        ok( exists $object->{$attribute->slot_key} );
        is_deeply( $object, { $attribute->slot_key => undef } );
    }

    for my $attribute ( $ATTRIBUTE_2 ) {
        my $object = My::Class::A->new;
        my $attribute_name = $attribute->name;
        my $accessor_default = "${attribute_name}_default";
        is( $object->$accessor_default, 1 );
        is_deeply( $object, { $attribute->slot_key => 1 } );
    }

}

# default() - initializer value
{

    for my $attribute ( $ATTRIBUTE_3, $ATTRIBUTE_4 ) {
        my $object = My::Class::A->new;
        my $attribute_name = $attribute->name;
        my $accessor_default = "${attribute_name}_default";
        is( $object->$accessor_default, 1 );
        is_deeply( $object, { $attribute->slot_key => 1 } );
    }

}

