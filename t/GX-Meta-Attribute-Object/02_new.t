#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;
use GX::Meta::Attribute::Object;

use Scalar::Util qw( refaddr );


use Test::More tests => 16;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );


# new( ... )
{

    my $attribute = GX::Meta::Attribute::Object->new(
        class => $CLASS_A,
        name  => 'attribute_1'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Object' );

    is( $attribute->type, 'Object' );
    is( $attribute->native_value, undef );

}

# new( default => $value, ... )
{

    my $value = bless {}, 'Foo';

    my $attribute = GX::Meta::Attribute::Object->new(
        class   => $CLASS_A,
        name    => 'attribute_1',
        default => $value
    );

    is( refaddr( $attribute->default_value ), refaddr( $value ) );

}

# new( default => $value, ... ), invalid default value
{

    for my $value ( undef, '', {} ) {

        local $@;

        eval {
            my $attribute = GX::Meta::Attribute::Object->new(
                class   => $CLASS_A,
                name    => 'attribute_1',
                default => $value
            )
        };

        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 9 );

    }

}

# GX::Meta::Attribute->new( isa => 'Object', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'Object'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Object' );

}

# GX::Meta::Attribute->new( isa => 'GX::Meta::Attribute::Object', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'GX::Meta::Attribute::Object'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Object' );

}

# GX::Meta::Attribute->new( type => 'Object', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        type  => 'Object'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Object' );

}

