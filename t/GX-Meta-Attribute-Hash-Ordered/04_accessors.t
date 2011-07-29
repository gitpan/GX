#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

our $ATTRIBUTE_2_DEFAULT_VALUE = do {
    tie my %hash, 'GX::Tie::Hash::Ordered';
    %hash = map { ( "k$_" => "v$_" ) } 1 .. 2;
    \%hash;
};

our $ATTRIBUTE_6_DEFAULT_VALUE = do {
    tie my %hash, 'GX::Tie::Hash::Ordered';
    %hash = map { ( "k$_" => "v$_" ) } 1 .. 6;
    \%hash;
};


sub new { my $class = shift; return bless { @_ }, $class; }

sub attribute_3_initializer {
    tie my %hash, 'GX::Tie::Hash::Ordered';
    %hash = map { ( "k$_" => "v$_" ) } 1 .. 3;
    return \%hash;
}

sub attribute_7_initializer {
    tie my %hash, 'GX::Tie::Hash::Ordered';
    %hash = map { ( "k$_" => "v$_" ) } 1 .. 7;
    return \%hash;
}


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Hash::Ordered;


use Test::More tests => 418;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Hash::Ordered->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Hash::Ordered->new(
    class   => $CLASS_A,
    name    => 'attribute_2',
    default => $ATTRIBUTE_2_DEFAULT_VALUE
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Hash::Ordered->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    initializer => 'attribute_3_initializer'
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Hash::Ordered->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    initializer => sub {
        tie my %hash, 'GX::Tie::Hash::Ordered';
        %hash = map { ( "k$_" => "v$_" ) } 1 .. 4;
        return \%hash;
    }
);

my $ATTRIBUTE_5 = GX::Meta::Attribute::Hash::Ordered->new(
    class      => $CLASS_A,
    name       => 'attribute_5',
    initialize => 1
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::Hash::Ordered->new(
    class      => $CLASS_A,
    name       => 'attribute_6',
    default    => $ATTRIBUTE_6_DEFAULT_VALUE,
    initialize => 1
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::Hash::Ordered->new(
    class       => $CLASS_A,
    name        => 'attribute_7',
    initialize  => 1,
    initializer => 'attribute_7_initializer'
);

my $ATTRIBUTE_8 = GX::Meta::Attribute::Hash::Ordered->new(
    class       => $CLASS_A,
    name        => 'attribute_8',
    initialize  => 1,
    initializer => sub {
        tie my %hash, 'GX::Tie::Hash::Ordered';
        %hash = map { ( "k$_" => "v$_" ) } 1 .. 8;
        return \%hash;
    }
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
        is( ref( tied( %{$object->{'attribute_1'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # default(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_1_default }, {} );
        is_deeply( $object->{'attribute_1'}, {} );
        is( ref( tied( %{$object->{'attribute_1'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # exists()
    {
        my $object = My::Class::A->new;
        ok( ! $object->attribute_1_exists( 'x' ) );
        is_deeply( $object->{'attribute_1'}, {} );
        is( ref( tied( %{$object->{'attribute_1'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_1_get, $object->{'attribute_1'} );
        is_deeply( $object->{'attribute_1'}, {} );
        is( ref( tied( %{$object->{'attribute_1'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_1_get }, {} );
        is_deeply( $object->{'attribute_1'}, {} );
        is( ref( tied( %{$object->{'attribute_1'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_keys()
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_1_get_keys ], [] );
        is_deeply( $object->{'attribute_1'}, {} );
        is( ref( tied( %{$object->{'attribute_1'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_list()
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_1_get_list }, {} );
        is_deeply( $object->{'attribute_1'}, {} );
        is( ref( tied( %{$object->{'attribute_1'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_reference()
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_1_get_reference, $object->{'attribute_1'} );
        is_deeply( $object->{'attribute_1'}, {} );
        is( ref( tied( %{$object->{'attribute_1'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_value()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_1_get_value( 'x' ), undef );
        is_deeply( $object->{'attribute_1'}, {} );
        is( ref( tied( %{$object->{'attribute_1'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_values()
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_1_get_values ], [] );
        is_deeply( $object->{'attribute_1'}, {} );
        is( ref( tied( %{$object->{'attribute_1'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_1_size, 0 );
        is_deeply( $object->{'attribute_1'}, {} );
        is( ref( tied( %{$object->{'attribute_1'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

}

# attribute_2, lazy initialization
{

    # default(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_2_default, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
        is( ref( tied( %{$object->{'attribute_2'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # default(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_2_default }, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
        is( ref( tied( %{$object->{'attribute_2'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # exists()
    {
        my $object = My::Class::A->new;
        ok( ! $object->attribute_2_exists( 'x' ) );
        ok( $object->attribute_2_exists( "k1" ) ) for 1 .. 2;
        is( ref( tied( %{$object->{'attribute_2'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_2_get, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
        is( ref( tied( %{$object->{'attribute_2'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_2_get }, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
        is( ref( tied( %{$object->{'attribute_2'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_keys()
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_2_get_keys ], [ map { "k$_" } 1 .. 2 ] );
        is( ref( tied( %{$object->{'attribute_2'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_list()
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_2_get_list }, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
        is( ref( tied( %{$object->{'attribute_2'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_reference()
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_2_get_reference, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
        is( ref( tied( %{$object->{'attribute_2'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_value()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_2_get_value( "k$_" ), "v$_" ) for 1 .. 2;
        is( ref( tied( %{$object->{'attribute_2'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_values()
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_2_get_values ], [ map { "v$_" } 1 .. 2 ] );
        is( ref( tied( %{$object->{'attribute_2'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_2_size, 2 );
        is( ref( tied( %{$object->{'attribute_2'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

}

# attribute_3, lazy initialization
{

    my $value = do {
        tie my %hash, 'GX::Tie::Hash::Ordered';
        %hash = map { ( "k$_" => "v$_" ) } 1 .. 3;
        \%hash;
    };

    # default(), scalar context
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_3_default, $value );
        is( ref( tied( %{$object->{'attribute_3'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # default(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_3_default }, $value );
        is( ref( tied( %{$object->{'attribute_3'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # exists()
    {
        my $object = My::Class::A->new;
        ok( ! $object->attribute_3_exists( 'x' ) );
        ok( $object->attribute_3_exists( "k1" ) ) for 1 .. 3;
        is( ref( tied( %{$object->{'attribute_3'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_3_get, $value );
        is( ref( tied( %{$object->{'attribute_3'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_3_get }, $value );
        is( ref( tied( %{$object->{'attribute_3'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_keys()
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_3_get_keys ], [ map { "k$_" } 1 .. 3 ] );
        is( ref( tied( %{$object->{'attribute_3'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_list()
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_3_get_list }, $value );
        is( ref( tied( %{$object->{'attribute_3'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_reference()
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_3_get_reference, $value );
        is( ref( tied( %{$object->{'attribute_3'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_value()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_3_get_value( "k$_" ), "v$_" ) for 1 .. 3;
        is( ref( tied( %{$object->{'attribute_3'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_values()
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_3_get_values ], [ map { "v$_" } 1 .. 3 ] );
        is( ref( tied( %{$object->{'attribute_3'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_3_size, 3 );
        is( ref( tied( %{$object->{'attribute_3'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

}

# attribute_4, lazy initialization
{

    my $value = do {
        tie my %hash, 'GX::Tie::Hash::Ordered';
        %hash = map { ( "k$_" => "v$_" ) } 1 .. 4;
        \%hash;
    };

    # default(), scalar context
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_4_default, $value );
        is( ref( tied( %{$object->{'attribute_4'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # default(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_4_default }, $value );
        is( ref( tied( %{$object->{'attribute_4'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # exists()
    {
        my $object = My::Class::A->new;
        ok( ! $object->attribute_4_exists( 'x' ) );
        ok( $object->attribute_4_exists( "k1" ) ) for 1 .. 4;
        is( ref( tied( %{$object->{'attribute_4'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_4_get, $value );
        is( ref( tied( %{$object->{'attribute_4'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_4_get }, $value );
        is( ref( tied( %{$object->{'attribute_4'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_keys()
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_4_get_keys ], [ map { "k$_" } 1 .. 4 ] );
        is( ref( tied( %{$object->{'attribute_4'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_list()
    {
        my $object = My::Class::A->new;
        is_deeply( { $object->attribute_4_get_list }, $value );
        is( ref( tied( %{$object->{'attribute_4'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_reference()
    {
        my $object = My::Class::A->new;
        is_deeply( scalar $object->attribute_4_get_reference, $value );
        is( ref( tied( %{$object->{'attribute_4'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_value()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_4_get_value( "k$_" ), "v$_" ) for 1 .. 4;
        is( ref( tied( %{$object->{'attribute_4'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # get_values()
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_4_get_values ], [ map { "v$_" } 1 .. 4 ] );
        is( ref( tied( %{$object->{'attribute_4'}} ) ), 'GX::Tie::Hash::Ordered' );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_4_size, 4 );
        is( ref( tied( %{$object->{'attribute_4'}} ) ), 'GX::Tie::Hash::Ordered' );
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
        is_deeply( [ keys %{$object->{$slot_key}} ],   [ qw( k2 k3 ) ] );
        is_deeply( [ values %{$object->{$slot_key}} ], [ qw( v21 v31 ) ] );

        # set()
        is_deeply( { $object->$accessor_set() }, {} );
        is_deeply( $object->{$slot_key}, {} );

        # set( 'k1' => 'v12' )
        is_deeply( { $object->$accessor_set( 'k1' => 'v12' ) }, {} );
        is_deeply( $object->{$slot_key}, { 'k1' => 'v12' } );

        # set( 'k2' => 'v22', 'k3' => 'v32' )
        is_deeply( { $object->$accessor_set( 'k2' => 'v22', 'k3' => 'v32' ) }, {} );
        is_deeply( $object->{$slot_key}, { 'k2' => 'v22', 'k3' => 'v32' } );
        is_deeply( [ keys %{$object->{$slot_key}} ],   [ qw( k2 k3 ) ] );
        is_deeply( [ values %{$object->{$slot_key}} ], [ qw( v22 v32 ) ] );

        # set_value( 'k1' => 'v13' )
        is_deeply( { $object->$accessor_set_value( 'k1' => 'v13' ) }, {} );
        is_deeply( $object->{$slot_key}, { 'k1' => 'v13', 'k2' => 'v22', 'k3' => 'v32' } );
        is_deeply( [ keys %{$object->{$slot_key}} ],   [ qw( k2 k3 k1 ) ] );
        is_deeply( [ values %{$object->{$slot_key}} ], [ qw( v22 v32 v13 ) ] );

        # set_values( 'k2' => 'v23', 'k3' => 'v33' )
        is_deeply( { $object->$accessor_set_value( 'k2' => 'v23', 'k3' => 'v33' ) }, {} );
        is_deeply( $object->{$slot_key}, { 'k1' => 'v13', 'k2' => 'v23', 'k3' => 'v33' } );
        is_deeply( [ keys %{$object->{$slot_key}} ],   [ qw( k2 k3 k1 ) ] );
        is_deeply( [ values %{$object->{$slot_key}} ], [ qw( v23 v33 v13 ) ] );

        # delete( 'k1' )
        is_deeply( [ $object->$accessor_delete( 'k1' ) ], [ 'v13' ] );
        is_deeply( $object->{$slot_key}, { 'k2' => 'v23', 'k3' => 'v33' } );
        is_deeply( [ keys %{$object->{$slot_key}} ],   [ qw( k2 k3 ) ] );
        is_deeply( [ values %{$object->{$slot_key}} ], [ qw( v23 v33 ) ] );

        # delete( 'x' )
        is_deeply( [ $object->$accessor_delete( 'x' ) ], [ undef ] );
        is_deeply( $object->{$slot_key}, { 'k2' => 'v23', 'k3' => 'v33' } );

        # clear()
        $object->$accessor_clear;
        ok( ! exists $object->{$slot_key} );

    }

}

# Order
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;
        my $slot_key       = $attribute->slot_key;

        my $accessor_default = "${attribute_name}_default";
        my $accessor_set     = "${attribute_name}_set";


        # default()
        {

            my $object = My::Class::A->new;

            $object->$accessor_default( map { ( "k$_" => "v$_" ) } 1 .. 10 );

            is_deeply( [ keys %{$object->{$slot_key}} ],   [ map { "k$_" } 1 .. 10 ] );
            is_deeply( [ values %{$object->{$slot_key}} ], [ map { "v$_" } 1 .. 10 ] );

        }

        # set()
        {

            my $object = My::Class::A->new;

            $object->$accessor_set( map { ( "k$_" => "v$_" ) } 1 .. 10 );

            is_deeply( [ keys %{$object->{$slot_key}} ],   [ map { "k$_" } 1 .. 10 ] );
            is_deeply( [ values %{$object->{$slot_key}} ], [ map { "v$_" } 1 .. 10 ] );

        }

    }

    # set_value()
    {

        my $object = My::Class::A->new;

        for ( 1 .. 10 ) {
            $object->attribute_1_set_value( "k$_" => "v$_" );
            is_deeply( [ keys %{$object->{'attribute_1'}} ],   [ map { "k$_" } 1 .. $_ ] );
            is_deeply( [ values %{$object->{'attribute_1'}} ], [ map { "v$_" } 1 .. $_ ] );
        }

    }

    # set_values()
    {

        my $object = My::Class::A->new;

        for ( 1 .. 10 ) {
            $object->attribute_1_set_values( "k$_\1" => "v$_\1",  "k$_\2" => "v$_\2" );
            is_deeply( [ keys %{$object->{'attribute_1'}} ],   [ map { ( "k$_\1", "k$_\2" ) } 1 .. $_ ] );
            is_deeply( [ values %{$object->{'attribute_1'}} ], [ map { ( "v$_\1", "v$_\2" ) } 1 .. $_ ] );
        }

    }

}

