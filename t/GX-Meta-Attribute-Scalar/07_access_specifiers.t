#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

our $VERSION = 1;


package My::Class::B;

use base qw( My::Class::A );


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Scalar;


use Test::More tests => 27;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );
my $CLASS_B = GX::Meta::Class->new( 'My::Class::B' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Scalar->new(
    class  => $CLASS_A,
    name   => 'attribute_1',
    public => 1
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Scalar->new(
    class     => $CLASS_A,
    name      => 'attribute_2',
    protected => 1
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Scalar->new(
    class   => $CLASS_A,
    name    => 'attribute_3',
    private => 1
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2,
    $ATTRIBUTE_3
);

my @ACCESSOR_TYPES = qw( default get set clear defined );


# is_public(), is_protected(), is_private()
{

    ok( $ATTRIBUTE_1->is_public );
    ok( ! $ATTRIBUTE_1->is_protected );
    ok( ! $ATTRIBUTE_1->is_private );

    ok( ! $ATTRIBUTE_2->is_public );
    ok( $ATTRIBUTE_2->is_protected );
    ok( ! $ATTRIBUTE_2->is_private );

    ok( ! $ATTRIBUTE_3->is_public );
    ok( ! $ATTRIBUTE_3->is_protected );
    ok( $ATTRIBUTE_3->is_private );

}

# Accessor setup
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        for my $accessor_type ( @ACCESSOR_TYPES ) {
            $attribute->add_accessor(
                name => "${attribute_name}_${accessor_type}",
                type => $accessor_type
            );
        }

        $attribute->install_accessors;

    }

}

# Protected
{

    local $@;

    my $object = bless {}, 'My::Class::A';

    eval {
        package My::Class::A;
        $object->attribute_2_default;
    };

    ok( ! $@ );

    eval {
        package My::Class::B;
        $object->attribute_2_default;
    };

    ok( ! $@ );

    eval {
        package main;
        $object->attribute_2_default;
    };

    ok( $@ );
    isa_ok( $@, 'GX::Meta::Exception' );
    like( "$@", '/protected/i' );
    is( $@->stack_trace->[0]->filename, $0 );
    is( $@->stack_trace->[0]->line, __LINE__ - 7 );

}

# Private
{

    local $@;

    my $object = bless {}, 'My::Class::A';

    eval {
        package My::Class::A;
        $object->attribute_3_default;
    };

    ok( ! $@ );

    eval {
        package My::Class::B;
        $object->attribute_3_default;
    };

    ok( $@ );
    isa_ok( $@, 'GX::Meta::Exception' );
    like( "$@", '/private/i' );
    is( $@->stack_trace->[0]->filename, $0 );
    is( $@->stack_trace->[0]->line, __LINE__ - 7 );


    eval {
        package main;
        $object->attribute_3_default;
    };

    ok( $@ );
    isa_ok( $@, 'GX::Meta::Exception' );
    like( "$@", '/private/i' );
    is( $@->stack_trace->[0]->filename, $0 );
    is( $@->stack_trace->[0]->line, __LINE__ - 7 );

}

