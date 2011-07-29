#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

sub new { my $class = shift; bless { @_ }, $class }

sub attribute_3_initializer  { 'attribute_3_initializer_value' }
sub attribute_7_initializer  { 'attribute_7_initializer_value' }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::String;


use Test::More tests => 64;


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

my $ATTRIBUTE_5 = GX::Meta::Attribute::String->new(
    class      => $CLASS_A,
    name       => 'attribute_5',
    initialize => 1
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::String->new(
    class      => $CLASS_A,
    name       => 'attribute_6',
    default    => 'attribute_6_default_value',
    initialize => 1
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::String->new(
    class       => $CLASS_A,
    name        => 'attribute_7',
    initializer => 'attribute_7_initializer',
    initialize  => 1,
);

my $ATTRIBUTE_8 = GX::Meta::Attribute::String->new(
    class       => $CLASS_A,
    name        => 'attribute_8',
    initializer => sub { 'attribute_8_initializer_value' },
    initialize  => 1
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

# attribute_1
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_1->initialize_instance_slot( $object );

    is_deeply( $object, {} );

}

# attribute_2
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_2->initialize_instance_slot( $object );

    is_deeply( $object, {} );

}

# attribute_3
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_3->initialize_instance_slot( $object );

    is_deeply( $object, {} );

}

# attribute_4
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_4->initialize_instance_slot( $object );

    is_deeply( $object, {} );

}

# attribute_5
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_5 ->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_5' => '' } );

}

# attribute_6
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_6 ->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_6' => 'attribute_6_default_value' } );

}

# attribute_7
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_7 ->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_7' => 'attribute_7_initializer_value' } );

}

# attribute_8
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_8 ->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_8' => 'attribute_8_initializer_value' } );

}

# Already existing slot
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        {
            my $object = My::Class::A->new( $attribute_name => 'x' );
            $attribute->initialize_instance_slot( $object, { $attribute_name => "${attribute_name}_value_1" } );
            is_deeply( $object, { $attribute->slot_key => 'x' } );
        }

    }

}

# Initialize with data
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        for my $value ( '', "${attribute_name}_value_1" ) {
            my $object = My::Class::A->new;
            $attribute->initialize_instance_slot( $object, { $attribute_name => $value } );
            is_deeply( $object, { $attribute->slot_key => $value } );
        }

    }

}

# Initialize with invalid data
{

    for my $value ( undef, \'abc' ) {

        for my $attribute ( @ATTRIBUTES ) {

            my $object = My::Class::A->new;

            local $@;
            eval { $attribute->initialize_instance_slot( $object, { $attribute->name => $value } ) };
            isa_ok( $@, 'GX::Meta::Exception' );

            is_deeply( $object, {} );

        }

    }

}

