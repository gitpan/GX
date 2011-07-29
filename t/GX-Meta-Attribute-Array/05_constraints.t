#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

package My::Class::A;

sub new { my $class = shift; return bless { @_ }, $class; }

sub attribute_7_constraint {
    ( ( ref( $_[0] ) || $_[0] ) eq __PACKAGE__ ) && ref( $_[1] ) eq 'ARRAY' && $_[1]->[0];
};


package My::Constraint;

sub new {
    my $class = shift;
    my $code  = eval '
        sub {
            ref( $_[0] ) eq "My::Constraint" &&
            ref( $_[1] ) eq "ARRAY"          &&
            $_[1]->[0];
        }';
    return bless( $code, $class );
}


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Array;


use Test::More tests => 67;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Array->new(
    class      => $CLASS_A,
    name       => 'attribute_1',
    constraint => sub { ref( $_[0] ) eq 'CODE' && ref( $_[1] ) eq 'ARRAY' && 1 }
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Array->new(
    class      => $CLASS_A,
    name       => 'attribute_2',
    constraint => sub { 0 }
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Array->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    constraints => [ sub { 1 }, sub { 1 } ]
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Array->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    constraints => [ sub { 1 }, sub { 0 } ]
);

my $ATTRIBUTE_5 = GX::Meta::Attribute::Array->new(
    class      => $CLASS_A,
    name       => 'attribute_5',
    constraint => My::Constraint->new
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::Array->new(
    class      => $CLASS_A,
    name       => 'attribute_6',
    constraint => sub { GX::Meta::Exception->throw( "Exception attribute_6" ) }
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::Array->new(
    class      => $CLASS_A,
    name       => 'attribute_7',
    constraint => 'attribute_7_constraint'
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2,
    $ATTRIBUTE_3,
    $ATTRIBUTE_4,
    $ATTRIBUTE_5,
    $ATTRIBUTE_6,
    $ATTRIBUTE_7
);

my @ACCESSOR_TYPES = qw(
    clear
    default
    get
    get_list
    get_reference
    set
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

    {
        my $object = My::Class::A->new;
        $object->attribute_1_set( 1 );
        is_deeply( $object, { 'attribute_1' => [ 1 ] } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_1_default( 1 );
        is_deeply( $object, { 'attribute_1' => [ 1 ] } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_1' => [ 1 ] };
        $ATTRIBUTE_1->initialize_instance_slot( $object, $data );
        is_deeply( $object, $data );
    }

}

# attribute_2
{

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_2_set( 1 .. 2 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_2_default( 1 .. 2 ) };
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
        my $data   = { 'attribute_2' => [ 1 .. 2 ] };

        local $@;
        eval { $ATTRIBUTE_2->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

# attribute_3
{

    {
        my $object = My::Class::A->new;
        $object->attribute_3_set( 1 .. 3 );
        is_deeply( $object, { 'attribute_3' => [ 1 .. 3 ] } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_3_default( 1 .. 3 );
        is_deeply( $object, { 'attribute_3' => [ 1 .. 3 ] } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_3' => [ 1 .. 3 ] };
        $ATTRIBUTE_3->initialize_instance_slot( $object, $data );
        is_deeply( $object, $data );
    }

}

# attribute_4
{

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_4_set( 1 .. 4 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_4_default( 1 .. 4 ) };
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
        my $data   = { 'attribute_4' => [ 1 .. 4 ] };

        local $@;
        eval { $ATTRIBUTE_4->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

# attribute_5
{

    {
        my $object = My::Class::A->new;
        $object->attribute_5_set( 1 );
        is_deeply( $object, { 'attribute_5' => [ 1 ] } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_5_default( 1 );
        is_deeply( $object, { 'attribute_5' => [ 1 ] } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_5' => [ 1 ] };
        $ATTRIBUTE_5->initialize_instance_slot( $object, $data );
        is_deeply( $object, $data );
    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_5_set( 0 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_5_default( 0 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );

        is_deeply( $object, {} );

    }


    {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_5' => [ 0 ] };

        local $@;
        eval { $ATTRIBUTE_5->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

# attribute_6
{

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_6_set( 0 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );
        is( $@->message, "Exception attribute_6" );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;

        local $@;
        eval { $object->attribute_6_default( 0 ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->stack_trace->[0]->filename, $0 );
        is( $@->stack_trace->[0]->line, __LINE__ - 3 );
        is( $@->message, "Exception attribute_6" );

        is_deeply( $object, {} );

    }

    {

        my $object = My::Class::A->new;
        my $data   = { 'attribute_6' => [ 0 ] };

        local $@;
        eval { $ATTRIBUTE_6->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );
        is( $@->message, "Exception attribute_6" );

        is_deeply( $object, {} );

    }

}

# attribute_7
{

    {
        my $object = My::Class::A->new;
        $object->attribute_7_set( 7 );
        is_deeply( $object, { 'attribute_7' => [ 7 ] } );
    }

    {
        my $object = My::Class::A->new;
        $object->attribute_7_default( 7 );
        is_deeply( $object, { 'attribute_7' => [ 7 ] } );
    }

    {
        my $object = My::Class::A->new;
        my $data   = { 'attribute_7' => [ 7 ] };
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
        my $data   = { 'attribute_7' => [ 0 ] };

        local $@;
        eval { $ATTRIBUTE_7->initialize_instance_slot( $object, $data ) };
        isa_ok( $@, 'GX::Meta::Exception' );

        is_deeply( $object, {} );

    }

}

