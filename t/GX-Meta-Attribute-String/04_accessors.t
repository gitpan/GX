#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

sub new { my $class = shift; bless { @_ }, $class }

sub attribute_3_initializer { 'attribute_3_initializer_value' }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::String;


use Test::More tests => 110;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::String->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::String->new(
    class   => $CLASS_A,
    name    => 'attribute_2',
    default => 'attribute_2_default_value'
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::String->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    initializer => 'attribute_3_initializer'
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::String->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    initializer => sub { 'attribute_4_initializer_value' }
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2,
    $ATTRIBUTE_3,
    $ATTRIBUTE_4
);

my @ACCESSOR_TYPES = qw( default get set clear length );


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

# set(), get(), clear(), length()
{

    my $object = My::Class::A->new;

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        my $accessor_get    = "${attribute_name}_get";
        my $accessor_set    = "${attribute_name}_set";
        my $accessor_clear  = "${attribute_name}_clear";
        my $accessor_length = "${attribute_name}_length";

        is( $object->$accessor_set( "${attribute_name}_value_1" ), undef );
        is( $object->{$attribute->slot_key}, "${attribute_name}_value_1" );

        is( $object->$accessor_get, "${attribute_name}_value_1" );
        is_deeply( [ $object->$accessor_get ], [ "${attribute_name}_value_1" ] );

        is( $object->$accessor_length, length( "${attribute_name}_value_1" ) );

        is_deeply( [ $object->$accessor_set( "${attribute_name}_value_2" ) ], [] );
        is( $object->{$attribute->slot_key}, "${attribute_name}_value_2" );

        is( $object->$accessor_get, "${attribute_name}_value_2" );
        is_deeply( [ $object->$accessor_get ], [ "${attribute_name}_value_2" ] );

        is( $object->$accessor_set( '' ), undef );
        is( $object->{$attribute->slot_key}, '' );

        is( $object->$accessor_length, 0 );

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

        is( $object->$accessor_default( '' ), '' );
        is( $object->{$attribute->slot_key}, '' );

        is( $object->$accessor_default, '' );
        is_deeply( [ $object->$accessor_default ], [ '' ] );

        is( $object->$accessor_default( "${attribute_name}_value_1" ), "${attribute_name}_value_1" );
        is( $object->{$attribute->slot_key}, "${attribute_name}_value_1" );

        is( $object->$accessor_default, "${attribute_name}_value_1" );
        is_deeply( [ $object->$accessor_default ], [ "${attribute_name}_value_1" ] );

        is_deeply( [ $object->$accessor_default( "${attribute_name}_value_2" ) ], [ "${attribute_name}_value_2" ] );
        is( $object->{$attribute->slot_key}, "${attribute_name}_value_2" );

    }

}

# get() - native / default value
{

    my $object = My::Class::A->new;

    for my $attribute ( $ATTRIBUTE_1 ) {
        my $attribute_name = $attribute->name;
        my $accessor_get = "${attribute_name}_get";
        is( $object->$accessor_get, '' );
        is( $object->{$attribute->slot_key}, '' );
    }

    for my $attribute ( $ATTRIBUTE_2 ) {
        my $attribute_name = $attribute->name;
        my $accessor_get = "${attribute_name}_get";
        is( $object->$accessor_get, "${attribute_name}_default_value" );
        is( $object->{$attribute->slot_key}, "${attribute_name}_default_value" );
    }

}

# get() - initializer value
{

    my $object = My::Class::A->new;

    for my $attribute ( $ATTRIBUTE_3, $ATTRIBUTE_4 ) {
        my $attribute_name = $attribute->name;
        my $accessor_get = "${attribute_name}_get";
        is( $object->$accessor_get, "${attribute_name}_initializer_value" );
        is( $object->{$attribute->slot_key}, "${attribute_name}_initializer_value" );
    }

}

# default() - native / default value
{

    my $object = My::Class::A->new;

    for my $attribute ( $ATTRIBUTE_1 ) {
        my $attribute_name = $attribute->name;
        my $accessor_default = "${attribute_name}_default";
        is( $object->$accessor_default, '' );
        is( $object->{$attribute->slot_key}, '' );
    }

    for my $attribute ( $ATTRIBUTE_2 ) {
        my $attribute_name = $attribute->name;
        my $accessor_default = "${attribute_name}_default";
        is( $object->$accessor_default, "${attribute_name}_default_value" );
        is( $object->{$attribute->slot_key}, "${attribute_name}_default_value" );
    }

}

# default() - initializer value
{

    my $object = My::Class::A->new;

    for my $attribute ( $ATTRIBUTE_3, $ATTRIBUTE_4 ) {
        my $attribute_name = $attribute->name;
        my $accessor_default = "${attribute_name}_default";
        is( $object->$accessor_default, "${attribute_name}_initializer_value" );
        is( $object->{$attribute->slot_key}, "${attribute_name}_initializer_value" );
    }

}

# length() - uninitialized value
{

    my $object = My::Class::A->new;

    for my $attribute ( $ATTRIBUTE_1 ) {
        my $attribute_name = $attribute->name;
        my $accessor_length = "${attribute_name}_length";
        is( $object->$accessor_length, 0 );
        is( $object->{$attribute->slot_key}, '' );
    }

}

