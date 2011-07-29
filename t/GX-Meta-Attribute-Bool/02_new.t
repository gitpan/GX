#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;
use GX::Meta::Attribute::Bool;


use Test::More tests => 10;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );


# new( ... )
{

    my $attribute = GX::Meta::Attribute::Bool->new(
        class => $CLASS_A,
        name  => 'attribute_1'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Bool' );

    is( $attribute->type, 'Bool' );
    is( $attribute->native_value, undef );

}

# new( default => $value, ... )
{

    {

        my $attribute = GX::Meta::Attribute::Bool->new(
            class   => $CLASS_A,
            name    => 'attribute_1',
            default => 0
        );

        is( $attribute->default_value, 0 );

    }

    {

        my $attribute = GX::Meta::Attribute::Bool->new(
            class   => $CLASS_A,
            name    => 'attribute_1',
            default => ''
        );

        is( $attribute->default_value, 0 );

    }

    {

        my $attribute = GX::Meta::Attribute::Bool->new(
            class   => $CLASS_A,
            name    => 'attribute_1',
            default => 'true'
        );

        is( $attribute->default_value, 1 );

    }

    {

        my $attribute = GX::Meta::Attribute::Bool->new(
            class   => $CLASS_A,
            name    => 'attribute_1',
            default => undef
        );

        is( $attribute->default_value, undef );

    }

}

# GX::Meta::Attribute->new( isa => 'Bool', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'Bool'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Bool' );

}

# GX::Meta::Attribute->new( isa => 'GX::Meta::Attribute::Bool', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'GX::Meta::Attribute::Bool'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Bool' );

}

# GX::Meta::Attribute->new( type => 'Bool', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        type  => 'Bool'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Bool' );

}

