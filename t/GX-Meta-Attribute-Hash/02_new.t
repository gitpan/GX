#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;
use GX::Meta::Attribute::Hash;

use Scalar::Util qw( refaddr );


use Test::More tests => 20;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );


# new( ... )
{

    my $attribute = GX::Meta::Attribute::Hash->new(
        class => $CLASS_A,
        name  => 'attribute_1'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Hash' );

    is( $attribute->type, 'Hash' );

    is_deeply( $attribute->native_value, {} );
    ok( refaddr( $attribute->native_value ) != refaddr( $attribute->native_value ) );

}

# new( default => $value, ... )
{

    {

        my $default_value = { 'k1' => 'v1' };

        my $attribute = GX::Meta::Attribute::Hash->new(
            class   => $CLASS_A,
            name    => 'attribute_1',
            default => $default_value
        );

        is( refaddr( $attribute->default_value ), refaddr( $default_value ) );

    }

}

# new( default => $value, ... ), invalid default value
{

    for my $default_value ( undef, '', [], \'' ) {

        local $@;

        eval {
            my $attribute = GX::Meta::Attribute::Hash->new(
                class   => $CLASS_A,
                name    => 'attribute_1',
                default => $default_value
            )
        };

        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 9 );

    }

}

# GX::Meta::Attribute->new( isa => 'Hash', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'Hash'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Hash' );

}

# GX::Meta::Attribute->new( isa => 'GX::Meta::Attribute::Hash', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'GX::Meta::Attribute::Hash'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Hash' );

}

# GX::Meta::Attribute->new( type => 'Hash', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        type  => 'Hash'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Hash' );

}

