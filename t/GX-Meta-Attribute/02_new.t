#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;
use GX::Meta::Attribute;


use Test::More tests => 42;


my @TYPES = qw(
    Array
    Bool
    Hash
    Object
    Scalar
    String
);

my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );


# new( ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Scalar' );

    is( $attribute->class, $CLASS_A );
    is( $attribute->name, 'attribute_1' );
    is( $attribute->slot_key, 'attribute_1' );
    is( $attribute->quoted_slot_key, "'attribute_1'" );
    is( $attribute->type, 'Scalar' );

    ok( ! $attribute->is_static );

    ok( $attribute->is_public );
    ok( ! $attribute->is_protected );
    ok( ! $attribute->is_private );

    is( $attribute->default_value, undef );
    ok( ! $attribute->has_default_value );

    is( $attribute->initializer, undef );
    ok( ! $attribute->has_initializer );

    is_deeply( [ $attribute->type_constraints ], [] );
    is_deeply( [ $attribute->value_constraints ], [] );
    is_deeply( [ $attribute->preprocessors ], [] );
    is_deeply( [ $attribute->processors ], [] );
    is_deeply( [ $attribute->accessors ], [] );

    is( $attribute->type_constraints, undef );
    is( $attribute->value_constraints, undef );
    is( $attribute->preprocessors, undef );
    is( $attribute->processors, undef );
    is( $attribute->accessors, undef );

}

# new( type => $type, ... )
{

    for my $type ( @TYPES ) {

        my $attribute = GX::Meta::Attribute->new(
            class => $CLASS_A,
            name  => 'attribute_1',
            type  => $type
        );

        isa_ok( $attribute, "GX::Meta::Attribute::${type}" );

    }

}

# new( isa => $type, ... )
{

    for my $type ( @TYPES ) {

        my $attribute = GX::Meta::Attribute->new(
            class => $CLASS_A,
            name  => 'attribute_1',
            isa   => $type
        );

        isa_ok( $attribute, "GX::Meta::Attribute::${type}" );

    }

}

# new( isa => $class, ... )
{

    for my $type ( @TYPES ) {

        my $attribute = GX::Meta::Attribute->new(
            class => $CLASS_A,
            name  => 'attribute_1',
            isa   => "GX::Meta::Attribute::${type}"
        );

        isa_ok( $attribute, "GX::Meta::Attribute::${type}" );

    }

}

