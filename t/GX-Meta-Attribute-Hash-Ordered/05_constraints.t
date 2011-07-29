#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

package My::Class::A;

sub new { my $class = shift; return bless { @_ }, $class; }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Hash::Ordered;


use Test::More tests => 17;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Hash::Ordered->new(
    class      => $CLASS_A,
    name       => 'attribute_1',
    constraint => sub { ref( $_[0] ) eq 'CODE' && ref( $_[1] ) eq 'HASH' && $_[1]->{'k1'} }
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1
);

my @ACCESSOR_TYPES = qw(
    clear
    default
    delete
    exists
    get
    get_keys
    get_list
    get_reference
    get_value
    get_values
    set
    set_value
    set_values
    size
);


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

    local $@;

    {
        my $object = My::Class::A->new;
        $object->attribute_1_set( 'k1' => 1 );
        is_deeply( $object, { 'attribute_1' => { 'k1' => 1 } } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_1_default( 'k1' => 1 );
        is_deeply( $object, { 'attribute_1' => { 'k1' => 1 } } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = {
            'attribute_1' => do {
                tie my %hash, 'GX::Tie::Hash::Ordered';
                %hash = ( 'k1' => 1 );
                \%hash;
            }
        };
        $ATTRIBUTE_1->initialize_instance_slot( $object, $data );
        is_deeply( $object, $data );
    }

    {
        my $object = My::Class::A->new;
        eval { $object->attribute_1_set() };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );
        is_deeply( $object, {} );
    }

    {
        my $object = My::Class::A->new;
        eval { $object->attribute_1_set( 'k1' => 0 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );
        is_deeply( $object, {} );
    }

    {
        my $object = My::Class::A->new;
        eval { $object->attribute_1_default( 'k1' => 0 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );
        is_deeply( $object, {} );
    }

    {
        my $object = My::Class::A->new;
        my $data   = {
            'attribute_1' => do {
                tie my %hash, 'GX::Tie::Hash::Ordered';
                %hash = ( 'k1' => 0, 'k2' => 1 );
                \%hash;
            }
        };
        eval { $ATTRIBUTE_1->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is_deeply( $object, {} );
    }

}

