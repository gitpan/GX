#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;
use GX::Meta::Attribute::Scalar;


use Test::More tests => 10;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );


# new( ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Scalar' );

    is( $attribute->type, 'Scalar' );
    is( $attribute->native_value, undef );

}

# new( default => $value, ... )
{

    for my $value ( undef, '', 1, [] ) {

        my $attribute = GX::Meta::Attribute::Scalar->new(
            class   => $CLASS_A,
            name    => 'attribute_1',
            default => $value
        );

        is( $attribute->default_value, $value );

    }

}

# GX::Meta::Attribute->new( isa => 'Scalar', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'Scalar'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Scalar' );

}

# GX::Meta::Attribute->new( isa => 'GX::Meta::Attribute::Scalar', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'GX::Meta::Attribute::Scalar'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Scalar' );

}

# GX::Meta::Attribute->new( type => 'Scalar', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        type  => 'Scalar'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Scalar' );

}

