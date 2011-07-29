#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

our $ATTRIBUTE_2_DEFAULT_VALUE = { map { ( "k$_" => "v$_" ) } 1 .. 2 };
our $ATTRIBUTE_6_DEFAULT_VALUE = { map { ( "k$_" => "v$_" ) } 1 .. 6 };

sub new { my $class = shift; return bless { @_ }, $class; }

sub attribute_3_initializer { return { map { ( "k$_" => "v$_" ) } 1 .. 3 } }
sub attribute_7_initializer { return { map { ( "k$_" => "v$_" ) } 1 .. 7 } }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Hash;

use Scalar::Util qw( isweak refaddr weaken );


use Test::More tests => 282;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Hash->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Hash->new(
    class   => $CLASS_A,
    name    => 'attribute_2',
    default => $ATTRIBUTE_2_DEFAULT_VALUE
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Hash->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    initializer => 'attribute_3_initializer'
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Hash->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    initializer => sub { return { map { ( "k$_" => "v$_" ) } 1 .. 4 } }
);

my $ATTRIBUTE_5 = GX::Meta::Attribute::Hash->new(
    class  => $CLASS_A,
    name   => 'attribute_5',
    weaken => 1
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::Hash->new(
    class   => $CLASS_A,
    name    => 'attribute_6',
    default => $ATTRIBUTE_6_DEFAULT_VALUE,
    weaken  => 1
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::Hash->new(
    class       => $CLASS_A,
    name        => 'attribute_7',
    initializer => 'attribute_7_initializer',
    weaken      => 1
);

my $ATTRIBUTE_8 = GX::Meta::Attribute::Hash->new(
    class       => $CLASS_A,
    name        => 'attribute_8',
    initializer => sub { return { map { ( "k$_" => "v$_" ) } 1 .. 8 } },
    weaken      => 1
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

my @ACCESSOR_TYPES = qw(
    clear
    default
    delete
    exists
    get
    get_keys
    get_list
    get_reference
    get_value
    get_values
    set
    set_value
    set_values
    size
);


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

# attribute_1, lazy initialization
{

    # default(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_1_default, $object->{'attribute_1'} );
        is_deeply( $object->{'attribute_1'}, {} );
    }

    # default(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_1_default }, {} );
        is_deeply( $object->{'attribute_1'}, {} );
    }

    # exists()
    {
        my $object = My::Class::A->new;
        ok( ! $object->attribute_1_exists( 'x' ) );
        is_deeply( $object->{'attribute_1'}, {} );
    }

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_1_get, $object->{'attribute_1'} );
        is_deeply( $object->{'attribute_1'}, {} );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_1_get }, {} );
        is_deeply( $object->{'attribute_1'}, {} );
    }

    # get_keys()
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_1_get_keys ], [] );
        is_deeply( $object->{'attribute_1'}, {} );
    }

    # get_list()
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_1_get_list }, {} );
        is_deeply( $object->{'attribute_1'}, {} );
    }

    # get_reference()
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_1_get_reference, $object->{'attribute_1'} );
        is_deeply( $object->{'attribute_1'}, {} );
    }

    # get_value()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_1_get_value( 'x' ), undef );
        is_deeply( $object->{'attribute_1'}, {} );
    }

    # get_values()
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_1_get_values ], [] );
        is_deeply( $object->{'attribute_1'}, {} );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_1_size, 0 );
        is_deeply( $object->{'attribute_1'}, {} );
    }

}

# attribute_2, lazy initialization
{

    # default(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_2_default, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # default(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_2_default }, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # exists()
    {
        my $object = My::Class::A->new;
        ok( ! $object->attribute_2_exists( 'x' ) );
        ok( $object->attribute_2_exists( "k1" ) ) for 1 .. 2;
    }

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_2_get, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_2_get }, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # get_keys()
    {
        my $object = My::Class::A->new;
        is_deeply( [ sort $object->attribute_2_get_keys ], [ map { "k$_" } 1 .. 2 ] );
    }

    # get_list()
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_2_get_list }, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # get_reference()
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_2_get_reference, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # get_value()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_2_get_value( "k$_" ), "v$_" ) for 1 .. 2;
    }

    # get_values()
    {
        my $object = My::Class::A->new;
        is_deeply( [ sort $object->attribute_2_get_values ], [ map { "v$_" } 1 .. 2 ] );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_2_size, 2 );
    }

}

# attribute_3, lazy initialization
{

    my $value = { map { ( "k$_" => "v$_" ) } 1 .. 3 };

    # default(), scalar context
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_3_default, $value );
    }

    # default(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_3_default }, $value );
    }

    # exists()
    {
        my $object = My::Class::A->new;
        ok( ! $object->attribute_3_exists( 'x' ) );
        ok( $object->attribute_3_exists( "k1" ) ) for 1 .. 3;
    }

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_3_get, $value );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_3_get }, $value );
    }

    # get_keys()
    {
        my $object = My::Class::A->new;
        is_deeply( [ sort $object->attribute_3_get_keys ], [ map { "k$_" } 1 .. 3 ] );
    }

    # get_list()
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_3_get_list }, $value );
    }

    # get_reference()
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_3_get_reference, $value );
    }

    # get_value()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_3_get_value( "k$_" ), "v$_" ) for 1 .. 3;
    }

    # get_values()
    {
        my $object = My::Class::A->new;
        is_deeply( [ sort $object->attribute_3_get_values ], [ map { "v$_" } 1 .. 3 ] );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_3_size, 3 );
    }

}

# attribute_4, lazy initialization
{

    my $value = { map { ( "k$_" => "v$_" ) } 1 .. 4 };

    # default(), scalar context
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_4_default, $value );
    }

    # default(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_4_default }, $value );
    }

    # exists()
    {
        my $object = My::Class::A->new;
        ok( ! $object->attribute_4_exists( 'x' ) );
        ok( $object->attribute_4_exists( "k1" ) ) for 1 .. 4;
    }

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_4_get, $value );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_4_get }, $value );
    }

    # get_keys()
    {
        my $object = My::Class::A->new;
        is_deeply( [ sort $object->attribute_4_get_keys ], [ map { "k$_" } 1 .. 4 ] );
    }

    # get_list()
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_4_get_list }, $value );
    }

    # get_reference()
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_4_get_reference, $value );
    }

    # get_value()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_4_get_value( "k$_" ), "v$_" ) for 1 .. 4;
    }

    # get_values()
    {
        my $object = My::Class::A->new;
        is_deeply( [ sort $object->attribute_4_get_values ], [ map { "v$_" } 1 .. 4 ] );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_4_size, 4 );
    }

}

# default(), delete(), set(), set_value(), set_values(), clear()
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;
        my $slot_key       = $attribute->slot_key;

        my $accessor_clear      = "${attribute_name}_clear";
        my $accessor_default    = "${attribute_name}_default";
        my $accessor_delete     = "${attribute_name}_delete";
        my $accessor_set        = "${attribute_name}_set";
        my $accessor_set_value  = "${attribute_name}_set_value";
        my $accessor_set_values = "${attribute_name}_set_values";

        my $object = My::Class::A->new;

        # default( 'k1' => 'v11' )
        is_deeply( { $object->$accessor_default( 'k1' => 'v11' ) }, { 'k1' => 'v11' } );
        is_deeply( $object->{$slot_key}, { 'k1' => 'v11' } );

        # default( 'k2' => 'v21', 'k3' => 'v31' )
        is_deeply( { $object->$accessor_default( 'k2' => 'v21', 'k3' => 'v31' ) }, { 'k2' => 'v21', 'k3' => 'v31' } );
        is_deeply( $object->{$slot_key}, { 'k2' => 'v21', 'k3' => 'v31' } );

        # set()
        is_deeply( { $object->$accessor_set() }, {} );
        is_deeply( $object->{$slot_key}, {} );

        # set( 'k1' => 'v12' )
        is_deeply( { $object->$accessor_set( 'k1' => 'v12' ) }, {} );
        is_deeply( $object->{$slot_key}, { 'k1' => 'v12' } );

        # set( 'k2' => 'v22', 'k3' => 'v32' )
        is_deeply( { $object->$accessor_set( 'k2' => 'v22', 'k3' => 'v32' ) }, {} );
        is_deeply( $object->{$slot_key}, { 'k2' => 'v22', 'k3' => 'v32' } );

        # set_value( 'k1' => 'v13' )
        is_deeply( { $object->$accessor_set_value( 'k1' => 'v13' ) }, {} );
        is_deeply( $object->{$slot_key}, { 'k1' => 'v13', 'k2' => 'v22', 'k3' => 'v32' } );

        # set_values( 'k2' => 'v23', 'k3' => 'v33' )
        is_deeply( { $object->$accessor_set_value( 'k2' => 'v23', 'k3' => 'v33' ) }, {} );
        is_deeply( $object->{$slot_key}, { 'k1' => 'v13', 'k2' => 'v23', 'k3' => 'v33' } );

        # delete( 'k1' )
        is_deeply( [ $object->$accessor_delete( 'k1' ) ], [ 'v13' ] );
        is_deeply( $object->{$slot_key}, { 'k2' => 'v23', 'k3' => 'v33' } );

        # delete( 'x' )
        is_deeply( [ $object->$accessor_delete( 'x' ) ], [ undef ] );
        is_deeply( $object->{$slot_key}, { 'k2' => 'v23', 'k3' => 'v33' } );

        # clear()
        $object->$accessor_clear;
        ok( ! exists $object->{$slot_key} );

    }

}

# Weaken
{

    my $v1 = \'v1';
    my $v2 = \'v2';
    my $v3 = \'v3';

    for my $attribute (
        $ATTRIBUTE_5,
        $ATTRIBUTE_6,
        $ATTRIBUTE_7,
        $ATTRIBUTE_8
    ) {

        my $attribute_name = $attribute->name;
        my $slot_key       = $attribute->slot_key;

        my $accessor_default    = "${attribute_name}_default";
        my $accessor_set        = "${attribute_name}_set";
        my $accessor_set_value  = "${attribute_name}_set_value";
        my $accessor_set_values = "${attribute_name}_set_values";

        {
            my $object = My::Class::A->new;
            $object->$accessor_default( 'k1' => $v1 );
            is_deeply( $object->{$slot_key}, { 'k1' => $v1 } );
            ok( isweak( $object->{$slot_key}{'k1'} ) );
        }

        {
            my $object = My::Class::A->new;
            $object->$accessor_default( 'k1' => $v1, 'k2' => $v2 );
            is_deeply( $object->{$slot_key}, { 'k1' => $v1, 'k2' => $v2 } );
            ok( isweak( $object->{$slot_key}{'k1'} ) );
            ok( isweak( $object->{$slot_key}{'k2'} ) );
        }

        {
            my $object = My::Class::A->new;
            $object->$accessor_set( 'k1' => $v1 );
            is_deeply( $object->{$slot_key}, { 'k1' => $v1 } );
            ok( isweak( $object->{$slot_key}{'k1'} ) );
        }

        {
            my $object = My::Class::A->new;
            $object->$accessor_set( 'k1' => $v1, 'k2' => $v2 );
            is_deeply( $object->{$slot_key}, { 'k1' => $v1, 'k2' => $v2 } );
            ok( isweak( $object->{$slot_key}{'k1'} ) );
            ok( isweak( $object->{$slot_key}{'k2'} ) );
        }

        {
            my $object = My::Class::A->new;
            $object->$accessor_set_value( 'k1' => $v1 );
            $object->$accessor_set_value( 'k2' => $v2 );
            ok( isweak( $object->{$slot_key}{'k1'} ) );
            ok( isweak( $object->{$slot_key}{'k2'} ) );
        }

        {
            my $object = My::Class::A->new;
            $object->$accessor_set_values( 'k1' => $v1 );
            $object->$accessor_set_values( 'k2' => $v2, 'k3' => $v3 );
            ok( isweak( $object->{$slot_key}{'k1'} ) );
            ok( isweak( $object->{$slot_key}{'k2'} ) );
            ok( isweak( $object->{$slot_key}{'k3'} ) );
        }

    }

}

