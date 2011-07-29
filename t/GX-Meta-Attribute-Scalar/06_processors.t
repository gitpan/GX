#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

sub new { my $class = shift; return bless { @_ }, $class; }

sub attribute_2_processor    { $_[1] += 1 }
sub attribute_2_preprocessor { $_[1] += 2 }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Scalar;


use Test::More tests => 10;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $PREPROCESSOR = sub { $_[1] += 1 };
my $PROCESSOR    = sub { $_[1] += 2 };

my $ATTRIBUTE_1 = GX::Meta::Attribute::Scalar->new(
    class         => $CLASS_A,
    name          => 'attribute_1',
    preprocessor  => $PREPROCESSOR,
    processor     => $PROCESSOR,
    constraint    => sub { $_[1] > 1 }
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Scalar->new(
    class         => $CLASS_A,
    name          => 'attribute_2',
    preprocessor  => 'attribute_2_preprocessor',
    processor     => 'attribute_2_processor',
    constraint    => sub { $_[1] > 1 }
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2
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

# attribute_1
{

    {
        is_deeply( [ $ATTRIBUTE_1->preprocessors ], [ $PREPROCESSOR ] );
        is_deeply( [ $ATTRIBUTE_1->processors ], [ $PROCESSOR ] );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_1_set( 1 );
        is_deeply( $object, { 'attribute_1' => 4 } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_1_default( 1 );
        is_deeply( $object, { 'attribute_1' => 4 } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_1' => 1 };
        $ATTRIBUTE_1->initialize_instance_slot( $object, $data );
        is_deeply( $object, { 'attribute_1' => 4 } );
    }

}

# attribute_2
{

    {
        is_deeply( [ $ATTRIBUTE_2->preprocessors ], [ 'attribute_2_preprocessor' ] );
        is_deeply( [ $ATTRIBUTE_2->processors ], [ 'attribute_2_processor' ] );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_2_set( 1 );
        is_deeply( $object, { 'attribute_2' => 4 } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_2_default( 1 );
        is_deeply( $object, { 'attribute_2' => 4 } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_2' => 1 };
        $ATTRIBUTE_2->initialize_instance_slot( $object, $data );
        is_deeply( $object, { 'attribute_2' => 4 } );
    }

}

