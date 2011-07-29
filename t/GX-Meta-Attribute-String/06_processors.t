#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

sub new { my $class = shift; bless { @_ }, $class }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::String;


use Test::More tests => 5;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::String->new(
    class        => $CLASS_A,
    name         => 'attribute_1',
    preprocessor => sub { $_[1] .= 'x' },
    processor    => sub { $_[1] .= 'y' }
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1
);

my @ACCESSOR_TYPES = qw( default get set clear length );


# Accessor setup
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        for my $accessor_type ( @ACCESSOR_TYPES ) {

            my $accessor_name = "${attribute_name}_${accessor_type}";

            my $accessor = $attribute->add_accessor(
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
        $object->attribute_1_set( 'a' );
        is_deeply( $object, { 'attribute_1' => 'axy' } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_1_default( 'a' );
        is_deeply( $object, { 'attribute_1' => 'axy' } );
    }

    {
        my $object = My::Class::A->new;
        is( $object->attribute_1_length, 0 );
        is_deeply( $object, { 'attribute_1' => '' } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_1' => 'a' };
        $ATTRIBUTE_1->initialize_instance_slot( $object, $data );
        is_deeply( $object, { 'attribute_1' => 'axy' } );
    }

}

