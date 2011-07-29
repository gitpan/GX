#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

my $ATTRIBUTE_7_INITIALIZER_VALUE        = \'attribute_7_initializer_value';
my $STATIC_ATTRIBUTE_7_INITIALIZER_VALUE = \'static_attribute_7_initializer_value';

sub new { bless {}, $_[0] }

sub attribute_3_initializer        { 'attribute_3_initializer_value' }
sub attribute_7_initializer        { $ATTRIBUTE_7_INITIALIZER_VALUE }
sub static_attribute_3_initializer { 'static_attribute_3_initializer_value' }
sub static_attribute_7_initializer { $STATIC_ATTRIBUTE_7_INITIALIZER_VALUE }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Scalar;

use Scalar::Util qw( isweak );


use Test::More tests => 774;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_6_DEFAULT_VALUE            = \'attribute_6_default_value';
my $ATTRIBUTE_8_INITIALIZER_VALUE        = \'attribute_8_initializer_value';
my $STATIC_ATTRIBUTE_6_DEFAULT_VALUE     = \'static_attribute_6_default_value';
my $STATIC_ATTRIBUTE_8_INITIALIZER_VALUE = \'static_attribute_8_initializer_value';

my $ATTRIBUTE_1 = GX::Meta::Attribute::Scalar->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Scalar->new(
    class   => $CLASS_A,
    name    => 'attribute_2',
    default => 'attribute_2_default_value'
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    initializer => 'attribute_3_initializer'
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    initializer => sub { 'attribute_4_initializer_value' }
);

my $ATTRIBUTE_5 = GX::Meta::Attribute::Scalar->new(
    class  => $CLASS_A,
    name   => 'attribute_5',
    weaken => 1
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::Scalar->new(
    class   => $CLASS_A,
    name    => 'attribute_6',
    weaken  => 1,
    default => $ATTRIBUTE_6_DEFAULT_VALUE
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_7',
    weaken      => 1,
    initializer => 'attribute_7_initializer'
);

my $ATTRIBUTE_8 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_8',
    weaken      => 1,
    initializer => sub { $ATTRIBUTE_8_INITIALIZER_VALUE }
);

my $STATIC_ATTRIBUTE_1 = GX::Meta::Attribute::Scalar->new(
    class  => $CLASS_A,
    name   => 'static_attribute_1',
    static => 1
);

my $STATIC_ATTRIBUTE_2 = GX::Meta::Attribute::Scalar->new(
    class   => $CLASS_A,
    name    => 'static_attribute_2',
    default => 'static_attribute_2_default_value',
    static  => 1
);

my $STATIC_ATTRIBUTE_3 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'static_attribute_3',
    initializer => 'static_attribute_3_initializer',
    static      => 1
);

my $STATIC_ATTRIBUTE_4 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'static_attribute_4',
    initializer => sub { 'static_attribute_4_initializer_value' },
    static      => 1
);

my $STATIC_ATTRIBUTE_5 = GX::Meta::Attribute::Scalar->new(
    class  => $CLASS_A,
    name   => 'static_attribute_5',
    weaken => 1,
    static => 1
);

my $STATIC_ATTRIBUTE_6 = GX::Meta::Attribute::Scalar->new(
    class   => $CLASS_A,
    name    => 'static_attribute_6',
    weaken  => 1,
    default => $STATIC_ATTRIBUTE_6_DEFAULT_VALUE,
    static  => 1
);

my $STATIC_ATTRIBUTE_7 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'static_attribute_7',
    weaken      => 1,
    initializer => 'static_attribute_7_initializer',
    static      => 1
);

my $STATIC_ATTRIBUTE_8 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'static_attribute_8',
    weaken      => 1,
    initializer => sub { $STATIC_ATTRIBUTE_8_INITIALIZER_VALUE },
    static      => 1
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2,
    $ATTRIBUTE_3,
    $ATTRIBUTE_4,
    $ATTRIBUTE_5,
    $ATTRIBUTE_6,
    $ATTRIBUTE_7,
    $ATTRIBUTE_8
);

my @STATIC_ATTRIBUTES = (
    $STATIC_ATTRIBUTE_1,
    $STATIC_ATTRIBUTE_2,
    $STATIC_ATTRIBUTE_3,
    $STATIC_ATTRIBUTE_4,
    $STATIC_ATTRIBUTE_5,
    $STATIC_ATTRIBUTE_6,
    $STATIC_ATTRIBUTE_7,
    $STATIC_ATTRIBUTE_8
);

my @ACCESSOR_TYPES = qw( default get set clear defined );


# Accessor setup
{

    for my $attribute ( @ATTRIBUTES, @STATIC_ATTRIBUTES ) {

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

# set(), get(), defined(), clear()
{

    my $class_name = $CLASS_A->name;
    my $object     = $class_name->new;

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        my $accessor_get     = "${attribute_name}_get";
        my $accessor_set     = "${attribute_name}_set";
        my $accessor_defined = "${attribute_name}_defined";
        my $accessor_clear   = "${attribute_name}_clear";

        is( $object->$accessor_set( "${attribute_name}_value_1" ), undef );
        is( $object->{$attribute->slot_key}, "${attribute_name}_value_1" );

        is( $object->$accessor_get, "${attribute_name}_value_1" );
        is_deeply( [ $object->$accessor_get ], [ "${attribute_name}_value_1" ] );

        is( $object->$accessor_set( "${attribute_name}_value_2" ), undef );
        is( $object->{$attribute->slot_key}, "${attribute_name}_value_2" );

        is( $object->$accessor_get, "${attribute_name}_value_2" );
        is_deeply( [ $object->$accessor_get ], [ "${attribute_name}_value_2" ] );

        ok( $object->$accessor_defined );

        is( $object->$accessor_set( undef ), undef );
        is( $object->{$attribute->slot_key}, undef );

        is( $object->$accessor_get, undef );
        is_deeply( [ $object->$accessor_get ], [ undef ] );

        ok( ! $object->$accessor_defined );

        $object->$accessor_clear;
        ok( ! exists $object->{$attribute->slot_key} );

    }

    for my $invocant ( $object, $class_name ) {

        for my $attribute ( @STATIC_ATTRIBUTES ) {

            my $attribute_name = $attribute->name;

            my $accessor_get     = "${attribute_name}_get";
            my $accessor_set     = "${attribute_name}_set";
            my $accessor_defined = "${attribute_name}_defined";
            my $accessor_clear   = "${attribute_name}_clear";

            is( $invocant->$accessor_set( "${attribute_name}_value_1" ), undef );
            is( $CLASS_A->class_data->{$attribute->slot_key}, "${attribute_name}_value_1" );

            is( $invocant->$accessor_get, "${attribute_name}_value_1" );
            is_deeply( [ $invocant->$accessor_get ], [ "${attribute_name}_value_1" ] );

            is( $invocant->$accessor_set( "${attribute_name}_value_2" ), undef );
            is( $CLASS_A->class_data->{$attribute->slot_key}, "${attribute_name}_value_2" );

            is( $invocant->$accessor_get, "${attribute_name}_value_2" );
            is_deeply( [ $invocant->$accessor_get ], [ "${attribute_name}_value_2" ] );

            ok( $invocant->$accessor_defined );

            is( $invocant->$accessor_set( undef ), undef );
            is( $CLASS_A->class_data->{$attribute->slot_key}, undef );

            is( $invocant->$accessor_get, undef );
            is_deeply( [ $invocant->$accessor_get ], [ undef ] );

            ok( ! $invocant->$accessor_defined );

            $invocant->$accessor_clear;
            ok( ! exists $CLASS_A->class_data->{$attribute->slot_key} );

        }

    }

    _clear_class_data( $CLASS_A );

}

# default()
{

    my $class_name = $CLASS_A->name;
    my $object     = $class_name->new;

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        my $accessor_default = "${attribute_name}_default";

        is( $object->$accessor_default( "${attribute_name}_value_1" ), "${attribute_name}_value_1" );
        is( $object->{$attribute->slot_key}, "${attribute_name}_value_1" );

        is( $object->$accessor_default, "${attribute_name}_value_1" );
        is_deeply( [ $object->$accessor_default ], [ "${attribute_name}_value_1" ] );

        is( $object->$accessor_default( undef ), undef );
        is( $object->{$attribute->slot_key}, undef );

        is( $object->$accessor_default, undef );
        is_deeply( [ $object->$accessor_default ], [ undef ] );

        is_deeply( [ $object->$accessor_default( "${attribute_name}_value_2" ) ], [ "${attribute_name}_value_2" ] );
        is( $object->{$attribute->slot_key}, "${attribute_name}_value_2" );

        is_deeply( [ $object->$accessor_default( undef ) ], [ undef ] );
        is( $object->{$attribute->slot_key}, undef );

    }

    for my $invocant ( $object, $class_name ) {

        for my $attribute ( @STATIC_ATTRIBUTES ) {

            my $attribute_name   = $attribute->name;
            my $accessor_default = "${attribute_name}_default";

            is( $invocant->$accessor_default( "${attribute_name}_value_1" ), "${attribute_name}_value_1" );
            is( $CLASS_A->class_data->{$attribute->slot_key}, "${attribute_name}_value_1" );

            is( $invocant->$accessor_default, "${attribute_name}_value_1" );
            is_deeply( [ $invocant->$accessor_default ], [ "${attribute_name}_value_1" ] );

            is( $invocant->$accessor_default( undef ), undef );
            is( $CLASS_A->class_data->{$attribute->slot_key}, undef );

            is( $invocant->$accessor_default, undef );
            is_deeply( [ $invocant->$accessor_default ], [ undef ] );

            is_deeply( [ $invocant->$accessor_default( "${attribute_name}_value_2" ) ], [ "${attribute_name}_value_2" ] );
            is( $CLASS_A->class_data->{$attribute->slot_key}, "${attribute_name}_value_2" );

            is_deeply( [ $invocant->$accessor_default( undef ) ], [ undef ] );
            is( $CLASS_A->class_data->{$attribute->slot_key}, undef );

        }

    }

    _clear_class_data( $CLASS_A );

}

# get() - default value
{

    my $object = My::Class::A->new;

    for my $attribute ( $ATTRIBUTE_2 ) {
        my $attribute_name = $attribute->name;
        my $accessor_get   = "${attribute_name}_get";
        is( $object->$accessor_get, "${attribute_name}_default_value" );
        is( $object->{$attribute->slot_key}, "${attribute_name}_default_value" );
    }

    for my $invocant ( $object, 'My::Class::A' ) {

        for my $attribute ( $STATIC_ATTRIBUTE_2 ) {
            my $attribute_name = $attribute->name;
            my $accessor_get   = "${attribute_name}_get";
            is( $invocant->$accessor_get, "${attribute_name}_default_value" );
            is( $CLASS_A->class_data->{$attribute->slot_key}, "${attribute_name}_default_value" );
        }

    }

    _clear_class_data( $CLASS_A );

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

    for my $invocant ( $object, 'My::Class::A' ) {

        for my $attribute ( $STATIC_ATTRIBUTE_3, $STATIC_ATTRIBUTE_4 ) {
            my $attribute_name = $attribute->name;
            my $accessor_get = "${attribute_name}_get";
            is( $invocant->$accessor_get, "${attribute_name}_initializer_value" );
            is( $CLASS_A->class_data->{$attribute->slot_key}, "${attribute_name}_initializer_value" );
        }

    }

    _clear_class_data( $CLASS_A );

}

# default() - default value
{

    my $object = My::Class::A->new;

    for my $attribute ( $ATTRIBUTE_2 ) {
        my $attribute_name = $attribute->name;
        my $accessor_default = "${attribute_name}_default";
        is( $object->$accessor_default, "${attribute_name}_default_value" );
        is( $object->{$attribute->slot_key}, "${attribute_name}_default_value" );
    }

    for my $invocant ( $object, 'My::Class::A' ) {

        for my $attribute ( $STATIC_ATTRIBUTE_2 ) {
            my $attribute_name = $attribute->name;
            my $accessor_default = "${attribute_name}_default";
            is( $invocant->$accessor_default, "${attribute_name}_default_value" );
            is( $CLASS_A->class_data->{$attribute->slot_key}, "${attribute_name}_default_value" );
        }

    }

    _clear_class_data( $CLASS_A );

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

    for my $invocant ( $object, 'My::Class::A' ) {

        for my $attribute ( $STATIC_ATTRIBUTE_3, $STATIC_ATTRIBUTE_4 ) {
            my $attribute_name = $attribute->name;
            my $accessor_default = "${attribute_name}_default";
            is( $invocant->$accessor_default, "${attribute_name}_initializer_value" );
            is( $CLASS_A->class_data->{$attribute->slot_key}, "${attribute_name}_initializer_value" );
        }

    }

    _clear_class_data( $CLASS_A );

}

# defined() - default value, initializer value
{

    my $object = My::Class::A->new;

    for my $attribute ( $ATTRIBUTE_2, $ATTRIBUTE_3, $ATTRIBUTE_4 ) {
        my $attribute_name = $attribute->name;
        my $accessor_defined = "${attribute_name}_defined";
        ok( $object->$accessor_defined );
        like( $object->{$attribute->slot_key}, qr/^${attribute_name}_.*_value$/ );
    }

    for my $invocant ( $object, 'My::Class::A' ) {

        for my $attribute ( $STATIC_ATTRIBUTE_2, $STATIC_ATTRIBUTE_3, $STATIC_ATTRIBUTE_4 ) {
            my $attribute_name = $attribute->name;
            my $accessor_defined = "${attribute_name}_defined";
            ok( $invocant->$accessor_defined );
            like( $CLASS_A->class_data->{$attribute->slot_key}, qr/^${attribute_name}_.*_value$/ );
        }

    }

    _clear_class_data( $CLASS_A );

}

# set(), default(), weaken refs
{

    my $object = My::Class::A->new;

    for my $attribute ( $ATTRIBUTE_5, $ATTRIBUTE_6, $ATTRIBUTE_7, $ATTRIBUTE_8 ) {

        my $attribute_name   = $attribute->name;
        my $accessor_default = "${attribute_name}_default";
        my $accessor_set     = "${attribute_name}_set";

        {
            my $value = {};
            $object->$accessor_default( $value );
            is( $object->{$attribute->slot_key}, $value );
            ok( isweak( $object->{$attribute->slot_key} ) );
        }

        is( $object->{$attribute->slot_key}, undef );

        {
            my $value = {};
            $object->$accessor_set( $value );
            is( $object->{$attribute->slot_key}, $value );
            ok( isweak( $object->{$attribute->slot_key} ) );
        }

        is( $object->{$attribute->slot_key}, undef );

    }

    for my $invocant ( $object, 'My::Class::A' ) {

        for my $attribute ( $STATIC_ATTRIBUTE_5, $STATIC_ATTRIBUTE_6, $STATIC_ATTRIBUTE_7, $STATIC_ATTRIBUTE_8 ) {

            my $attribute_name   = $attribute->name;
            my $accessor_default = "${attribute_name}_default";
            my $accessor_set     = "${attribute_name}_set";

            {
                my $value = {};
                $invocant->$accessor_default( $value );
                is( $CLASS_A->class_data->{$attribute->slot_key}, $value );
                ok( isweak( $CLASS_A->class_data->{$attribute->slot_key} ) );
            }

            is( $CLASS_A->class_data->{$attribute->slot_key}, undef );

            {
                my $value = {};
                $invocant->$accessor_set( $value );
                is( $CLASS_A->class_data->{$attribute->slot_key}, $value );
                ok( isweak( $CLASS_A->class_data->{$attribute->slot_key} ) );
            }

            is( $CLASS_A->class_data->{$attribute->slot_key}, undef );

        }

    }

    _clear_class_data( $CLASS_A );

}


# ----------------------------------------------------------------------------------------------------------------------

sub _clear_class_data {

    my $class = shift;

    delete $class->package->symbol_table->{$class->class_data_identifier};

}

