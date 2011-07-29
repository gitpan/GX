#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

sub new { my $class = shift; bless { @_ }, $class }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Bool;


use Test::More tests => 10;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Bool->new(
    class      => $CLASS_A,
    name       => 'attribute_1',
    constraint => sub { ref( $_[0] ) eq 'CODE' && ! $_[1]; }
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1
);

my @ACCESSOR_TYPES = qw( default get set clear defined );


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

        $object->attribute_1_set( 0 );

        eval { $object->attribute_1_set( 1 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        eval { $object->attribute_1_default( 1 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, { 'attribute_1' => 0 } );

    }

    {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_1' => 0 };

        eval { $ATTRIBUTE_1->initialize_instance_slot( $object, $data ) };

        is_deeply( $object, { 'attribute_1' => 0 } );

    }

    {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_1' => 1 };

        eval { $ATTRIBUTE_1->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }


}

