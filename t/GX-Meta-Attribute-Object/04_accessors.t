#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

sub new { my $class = shift; bless { @_ }, $class }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Object;

use Scalar::Util qw( isweak );


use Test::More tests => 40;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Object->new(
    class => $CLASS_A,
    name  => 'attribute_1'
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

# set(), default(), type constraint
{

    local $@;

    my $class_name = $CLASS_A->name;
    my $object     = $class_name->new;

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        my $accessor_default = "${attribute_name}_default";
        my $accessor_set     = "${attribute_name}_set";

        for my $value ( 0, 1, '', 'abc', {} ) {

            eval { $object->$accessor_default( $value ) };
            isa_ok( $@, 'GX::Meta::Exception' );
            is( $@->stack_trace->[0]->filename, $0 );
            is( $@->stack_trace->[0]->line, __LINE__ - 3 );

            is_deeply( $object, {} );

            eval { $object->$accessor_set( $value ) };
            isa_ok( $@, 'GX::Meta::Exception' );
            is( $@->stack_trace->[0]->filename, $0 );
            is( $@->stack_trace->[0]->line, __LINE__ - 3 );

            is_deeply( $object, {} );

        }

    }

}

