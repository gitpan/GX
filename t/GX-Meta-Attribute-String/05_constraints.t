#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

sub new { my $class = shift; bless { @_ }, $class }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::String;


use Test::More tests => 54;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::String->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::String->new(
    class      => $CLASS_A,
    name       => 'attribute_2',
    constraint => sub { ref( $_[0] ) eq 'CODE' && length( $_[1] ) > 0 && length( $_[1] ) < 10; }
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2
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

    local $@;

    for my $value ( undef, \'reference' ) {

        my $object = My::Class::A->new;

        $object->attribute_1_set( 'abc' );

        eval { $object->attribute_1_set( $value ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        eval { $object->attribute_1_default( $value ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, { 'attribute_1' => 'abc' } );

    }

    for my $value ( undef, \'reference' ) {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_1' => $value };

        eval { $ATTRIBUTE_1->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

# attribute_2
{

    local $@;

    for my $value ( undef, \'reference', '', 'abcdefghij' ) {

        my $object = My::Class::A->new;

        $object->attribute_2_default( 'abc' );

        eval { $object->attribute_2_set( $value ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        eval { $object->attribute_2_default( $value ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, { 'attribute_2' => 'abc' } );

    }

    for my $value ( undef, \'reference', '', 'abcdefghij' ) {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_2' => $value };

        eval { $ATTRIBUTE_2->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

