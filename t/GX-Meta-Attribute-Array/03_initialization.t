#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

our $ATTRIBUTE_2_DEFAULT_VALUE = [ 1 .. 2 ];
our $ATTRIBUTE_6_DEFAULT_VALUE = [ 1 .. 6 ];

sub new { my $class = shift; return bless { @_ }, $class; }

sub attribute_3_initializer { [ 1 .. 3 ] }
sub attribute_7_initializer { [ 1 .. 7 ] }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Array;


use Test::More tests => 64;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Array->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Array->new(
    class   => $CLASS_A,
    name    => 'attribute_2',
    default => $ATTRIBUTE_2_DEFAULT_VALUE
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Array->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    initializer => 'attribute_3_initializer'
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Array->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    initializer => sub { [ 1 .. 4 ] }
);

my $ATTRIBUTE_5 = GX::Meta::Attribute::Array->new(
    class      => $CLASS_A,
    name       => 'attribute_5',
    initialize => 1
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::Array->new(
    class      => $CLASS_A,
    name       => 'attribute_6',
    default    => $ATTRIBUTE_6_DEFAULT_VALUE,
    initialize => 1
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::Array->new(
    class       => $CLASS_A,
    name        => 'attribute_7',
    initializer => 'attribute_7_initializer',
    initialize  => 1,
);

my $ATTRIBUTE_8 = GX::Meta::Attribute::Array->new(
    class       => $CLASS_A,
    name        => 'attribute_8',
    initializer => sub { [ 1 .. 8 ] },
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

    $ATTRIBUTE_5->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_5' => [] } );

}

# attribute_6
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_6->initialize_instance_slot( $object );

    is( $object->{'attribute_6'}, $ATTRIBUTE_6_DEFAULT_VALUE );

}

# attribute_7
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_7->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_7' => [ 1 .. 7 ] } );

}

# attribute_8
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_8->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_8' => [ 1 .. 8 ] } );

}

# Initialize, already existing slot
{

    for my $attribute ( @ATTRIBUTES ) {
        my $attribute_name = $attribute->name;
        my $object = My::Class::A->new( $attribute_name => [ 0 ] );
        $attribute->initialize_instance_slot( $object, { $attribute_name => [ -1 ] } );
        is_deeply( $object, { $attribute_name => [ 0 ] } );
    }

}

# Initialize with data
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        for my $data ( [], [ 1 ], [ 1 .. 3 ] ) {
            my $object = My::Class::A->new;
            $attribute->initialize_instance_slot( $object, { $attribute_name => $data } );
            is_deeply( $object, { $attribute_name => $data } );
        }

    }

}

# Initialize with invalid data
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        for my $data ( undef, '', {} ) {
            my $object = My::Class::A->new;
            local $@;
            eval { $attribute->initialize_instance_slot( $object, { $attribute_name => $data } ) };
            isa_ok( $@, 'GX::Meta::Exception' );
        }

    }

}

