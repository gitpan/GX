#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

sub new { my $class = shift; return bless { @_ }, $class; }

sub constraint {
    ( ref( $_[0] ) || $_[0] ) eq __PACKAGE__ or die; return $_[1] ? 1 : 0;
};

sub constraint_exception {
    ( ref( $_[0] ) || $_[0] ) eq __PACKAGE__ or die; GX::Meta::Exception->throw;
};


package My::Constraint;

sub new {
    my $class = shift;
    my $code  = eval '
        sub {
            ( ref( $_[0] ) || $_[0] ) eq "My::Constraint" or die;
            return $_[1] ? 1 : 0;
        }';
    return bless( $code, $class );
}


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Scalar;


use Test::More tests => 85;


my $CONSTRAINT_SUB_TRUE      = sub { ref( $_[0] ) eq 'CODE' or die; return 1; };
my $CONSTRAINT_SUB_FALSE     = sub { ref( $_[0] ) eq 'CODE' or die; return 0; };
my $CONSTRAINT_SUB_EXCEPTION = sub { ref( $_[0] ) eq 'CODE' or die; GX::Meta::Exception->throw; };
my $CONSTRAINT_OBJECT        = My::Constraint->new;

my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'attribute_1',
    constraint => $CONSTRAINT_SUB_TRUE
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'attribute_2',
    constraint => $CONSTRAINT_SUB_FALSE
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    constraints => [ $CONSTRAINT_SUB_TRUE, $CONSTRAINT_SUB_TRUE ]
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    constraints => [ $CONSTRAINT_SUB_TRUE, $CONSTRAINT_SUB_FALSE, $CONSTRAINT_SUB_TRUE ]
);

my $ATTRIBUTE_5 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'attribute_5',
    constraint => $CONSTRAINT_SUB_EXCEPTION
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'attribute_6',
    constraint => $CONSTRAINT_OBJECT
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'attribute_7',
    constraint => 'constraint'
);

my $ATTRIBUTE_8 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'attribute_8',
    constraint => 'constraint_exception'
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2,
    $ATTRIBUTE_3,
    $ATTRIBUTE_4,
    $ATTRIBUTE_5,
    $ATTRIBUTE_6,
    $ATTRIBUTE_7,
    $ATTRIBUTE_8
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

    {
        is_deeply( [ $ATTRIBUTE_1->value_constraints ], [ $CONSTRAINT_SUB_TRUE ] );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_1_set( 1 );
        is_deeply( $object, { 'attribute_1' => 1 } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_1_default( 1 );
        is_deeply( $object, { 'attribute_1' => 1 } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_1' => 1 };
        $ATTRIBUTE_1->initialize_instance_slot( $object, $data );
        is_deeply( $object, $data );
    }

}

# attribute_2
{

    {
        is_deeply( [ $ATTRIBUTE_2->value_constraints ], [ $CONSTRAINT_SUB_FALSE ] );
    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_2_set( 2 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_2_default( 2 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {
        my $object = My::Class::A->new;
        my $data   = {};
        $ATTRIBUTE_2->initialize_instance_slot( $object, $data );
        is_deeply( $object, {} );
    }

    {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_2' => 2 };

        local $@;
        eval { $ATTRIBUTE_2->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

# attribute_3
{

    {
        is_deeply( [ $ATTRIBUTE_3->value_constraints ], [ $CONSTRAINT_SUB_TRUE, $CONSTRAINT_SUB_TRUE ] );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_3_set( 3 );
        is_deeply( $object, { 'attribute_3' => 3 } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_3_default( 3 );
        is_deeply( $object, { 'attribute_3' => 3 } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_3' => 3 };
        $ATTRIBUTE_3->initialize_instance_slot( $object, $data );
        is_deeply( $object, $data );
    }

}

# attribute_4
{

    {
        is_deeply( [ $ATTRIBUTE_4->value_constraints ], [ $CONSTRAINT_SUB_TRUE, $CONSTRAINT_SUB_FALSE, $CONSTRAINT_SUB_TRUE ] );
    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_4_set( 4 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_4_default( 4 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {
        my $object = My::Class::A->new;
        my $data   = {};
        $ATTRIBUTE_4->initialize_instance_slot( $object, $data );
        is_deeply( $object, {} );
    }

    {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_4' => 4 };

        local $@;
        eval { $ATTRIBUTE_4->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

# attribute_5
{

    {
        is_deeply( [ $ATTRIBUTE_5->value_constraints ], [ $CONSTRAINT_SUB_EXCEPTION ] );
    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_5_set( 'x' ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_5_default( 'x' ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_5' => 'x' };

        local $@;
        eval { $ATTRIBUTE_5->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

# attribute_6
{

    {
        is_deeply( [ $ATTRIBUTE_6->value_constraints ], [ $CONSTRAINT_OBJECT ] );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_6_set( 1 );
        is_deeply( $object, { 'attribute_6' => 1 } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_6_default( 1 );
        is_deeply( $object, { 'attribute_6' => 1 } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_6' => 1 };
        $ATTRIBUTE_6->initialize_instance_slot( $object, $data );
        is_deeply( $object, $data );
    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_6_set( 0 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_6_default( 0 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }


    {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_6' => 0 };

        local $@;
        eval { $ATTRIBUTE_6->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

# attribute_7
{

    {
        is_deeply( [ $ATTRIBUTE_7->value_constraints ], [ 'constraint' ] );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_7_set( 1 );
        is_deeply( $object, { 'attribute_7' => 1 } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_7_default( 1 );
        is_deeply( $object, { 'attribute_7' => 1 } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_7' => 1 };
        $ATTRIBUTE_7->initialize_instance_slot( $object, $data );
        is_deeply( $object, $data );
    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_7_set( 0 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_7_default( 0 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_7' => 0 };

        local $@;
        eval { $ATTRIBUTE_7->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

# attribute_8
{

    {
        is_deeply( [ $ATTRIBUTE_8->value_constraints ], [ 'constraint_exception' ] );
    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_8_set( 'x' ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_8_default( 'x' ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_8' => 'x' };

        local $@;
        eval { $ATTRIBUTE_8->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

# Default value
{

    local $@;

    eval {

        my $attribute = GX::Meta::Attribute::Scalar->new(
            class      => $CLASS_A,
            name       => 'attribute_1',
            default    => 'x',
            constraint => sub { 0 }
        );

    };

    isa_ok( $@, 'GX::Meta::Exception' );
    is( $@->stack_trace->[0]->filename, $0 );
    is( $@->stack_trace->[0]->line, __LINE__ - 6 );

}

