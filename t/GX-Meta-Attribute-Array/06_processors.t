#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

package My::Class::A;

sub new { my $class = shift; return bless { @_ }, $class; }

sub attribute_2_preprocessor { $_ += 3 for @{ $_[1] } }
sub attribute_2_processor    { $_ += 2 for @{ $_[1] } }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Array;


use Test::More tests => 6;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Array->new(
    class        => $CLASS_A,
    name         => 'attribute_1',
    preprocessor => sub { $_ += 1 for @{ $_[1] } },
    processor    => sub { $_ += 2 for @{ $_[1] } }
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Array->new(
    class        => $CLASS_A,
    name         => 'attribute_2',
    preprocessor => 'attribute_2_preprocessor',
    processor    => 'attribute_2_processor'
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2
);

my @ACCESSOR_TYPES = qw(
    clear
    default
    get
    get_list
    get_reference
    set
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

# attribute_1
{

    {
        my $object = My::Class::A->new;
        $object->attribute_1_set( 1 .. 3 );
        is_deeply( $object, { 'attribute_1' => [ 4 .. 6 ] } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_1_default( 1 .. 3 );
        is_deeply( $object, { 'attribute_1' => [ 4 .. 6 ] } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_1' => [ 1 .. 3 ] };
        $ATTRIBUTE_1->initialize_instance_slot( $object, $data );
        is_deeply( $object, { 'attribute_1' => [ 4 .. 6 ] } );
    }

}

# attribute_2
{

    {
        my $object = My::Class::A->new;
        $object->attribute_2_set( 2 .. 4 );
        is_deeply( $object, { 'attribute_2' => [ 7 .. 9 ] } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_2_default( 2 .. 4 );
        is_deeply( $object, { 'attribute_2' => [ 7 .. 9 ] } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_2' => [ 2 .. 4 ] };
        $ATTRIBUTE_2->initialize_instance_slot( $object, $data );
        is_deeply( $object, { 'attribute_2' => [ 7 .. 9 ] } );
    }

}

