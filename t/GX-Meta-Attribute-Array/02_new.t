#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;
use GX::Meta::Attribute::Array;

use Scalar::Util qw( refaddr );


use Test::More tests => 20;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );


# new( ... )
{

    my $attribute = GX::Meta::Attribute::Array->new(
        class => $CLASS_A,
        name  => 'attribute_1'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Array' );

    is( $attribute->type, 'Array' );

    is_deeply( $attribute->native_value, [] );
    ok( refaddr( $attribute->native_value ) != refaddr( $attribute->native_value ) );

}

# new( default => $value, ... )
{

    {

        my $default_value = [ 1 .. 3 ];

        my $attribute = GX::Meta::Attribute::Array->new(
            class   => $CLASS_A,
            name    => 'attribute_1',
            default => $default_value
        );

        is( refaddr( $attribute->default_value ), refaddr( $default_value ) );

    }

}

# new( default => $value, ... ), invalid default value
{

    for my $default_value ( undef, '', {}, \'' ) {

        local $@;

        eval {
            my $attribute = GX::Meta::Attribute::Array->new(
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

# GX::Meta::Attribute->new( isa => 'Array', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'Array'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Array' );

}

# GX::Meta::Attribute->new( isa => 'GX::Meta::Attribute::Array', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'GX::Meta::Attribute::Array'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Array' );

}

# GX::Meta::Attribute->new( type => 'Array', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        type  => 'Array'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Array' );

}

