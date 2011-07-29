#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;
use GX::Meta::Attribute::Hash::Ordered;

use Scalar::Util qw( refaddr );


use Test::More tests => 24;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );


# new( ... )
{

    my $attribute = GX::Meta::Attribute::Hash::Ordered->new(
        class => $CLASS_A,
        name  => 'attribute_1'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Hash::Ordered' );

    is( $attribute->type, 'Hash::Ordered' );

    is_deeply( $attribute->native_value, {} );
    is( ref( tied( %{$attribute->native_value} ) ), 'GX::Tie::Hash::Ordered' );
    ok( refaddr( $attribute->native_value ) != refaddr( $attribute->native_value ) );

}

# new( default => $value, ... )
{

    {

        tie my %default_value, 'GX::Tie::Hash::Ordered';
        %default_value = ( 'k1' => 'v1' );
        my $default_value = \%default_value;

        my $attribute = GX::Meta::Attribute::Hash::Ordered->new(
            class   => $CLASS_A,
            name    => 'attribute_1',
            default => $default_value
        );

        is( refaddr( $attribute->default_value ), refaddr( $default_value ) );

    }

}

# new( default => $value, ... ), invalid default value
{

    for my $default_value ( undef, '', {}, [], \'' ) {

        local $@;

        eval {
            my $attribute = GX::Meta::Attribute::Hash::Ordered->new(
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

# GX::Meta::Attribute->new( isa => 'Hash::Ordered', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'Hash::Ordered'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Hash::Ordered' );

}

# GX::Meta::Attribute->new( isa => 'GX::Meta::Attribute::Hash::Ordered', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        isa   => 'GX::Meta::Attribute::Hash::Ordered'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Hash::Ordered' );

}

# GX::Meta::Attribute->new( type => 'Hash::Ordered', ... )
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1',
        type  => 'Hash::Ordered'
    );

    isa_ok( $attribute, 'GX::Meta::Attribute::Hash::Ordered' );

}

