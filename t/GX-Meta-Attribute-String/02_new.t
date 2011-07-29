#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;
use GX::Meta::Attribute::String;


use Test::More tests => 14;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );


# new( ... )
{

    my $attribute = GX::Meta::Attribute::String->new(
        class => $CLASS_A,
        name  => 'attribute_1'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::String' );

    is( $attribute->type, 'String' );
    is( $attribute->native_value, '' );

}

# new( default => $value, ... )
{

    for my $value ( '', 'abc' ) {

        my $attribute = GX::Meta::Attribute::String->new(
            class   => $CLASS_A,
            name    => 'attribute_1',
            default => $value
        );

        is( $attribute->default_value, $value );

    }

}

# new( default => $value, ... ), invalid default value
{

    for my $value ( undef, \'abc' ) {

        local $@;

        eval {
            GX::Meta::Attribute::String->new(
                class   => $CLASS_A,
                name    => 'attribute_1',
                default => $value
            );
        };

        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 9 );

    }

}

# GX::Meta::Attribute->new( isa => 'String', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'String'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::String' );

}

# GX::Meta::Attribute->new( isa => 'GX::Meta::Attribute::String', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'GX::Meta::Attribute::String'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::String' );

}

# GX::Meta::Attribute->new( type => 'String', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        type  => 'String'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::String' );

}

