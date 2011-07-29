#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

our $ATTRIBUTE_10_DEFAULT_VALUE            = \'attribute_10_default_value';
our $ATTRIBUTE_11_INITIALIZER_VALUE        = \'attribute_11_initializer_value';
our $ATTRIBUTE_12_INITIALIZER_VALUE        = \'attribute_12_initializer_value';
our $STATIC_ATTRIBUTE_10_DEFAULT_VALUE     = \'static_attribute_10_default_value';
our $STATIC_ATTRIBUTE_11_INITIALIZER_VALUE = \'static_attribute_11_initializer_value';
our $STATIC_ATTRIBUTE_12_INITIALIZER_VALUE = \'static_attribute_12_initializer_value';

sub new { my $class = shift; bless { @_ }, $class }

sub attribute_3_initializer         { 'attribute_3_initializer_value' }
sub attribute_7_initializer         { 'attribute_7_initializer_value' }
sub attribute_11_initializer        { $ATTRIBUTE_11_INITIALIZER_VALUE }
sub static_attribute_3_initializer  { 'static_attribute_3_initializer_value' }
sub static_attribute_7_initializer  { 'static_attribute_7_initializer_value' }
sub static_attribute_11_initializer { $STATIC_ATTRIBUTE_11_INITIALIZER_VALUE }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Scalar;

use Scalar::Util qw( isweak );


use Test::More tests => 277;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Scalar->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Scalar->new(
    class   => $CLASS_A,
    name    => 'attribute_2',
    default => 'attribute_2_default_value'
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    initializer => 'attribute_3_initializer'
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    initializer => sub { 'attribute_4_initializer_value' }
);

my $ATTRIBUTE_5 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'attribute_5',
    initialize => 1
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'attribute_6',
    default    => 'attribute_6_default_value',
    initialize => 1
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_7',
    initializer => 'attribute_7_initializer',
    initialize  => 1,
);

my $ATTRIBUTE_8 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_8',
    initializer => sub { 'attribute_8_initializer_value' },
    initialize  => 1
);

my $ATTRIBUTE_9 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'attribute_9',
    initialize => 1,
    weaken     => 1
);

my $ATTRIBUTE_10 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'attribute_10',
    default    => $My::Class::A::ATTRIBUTE_10_DEFAULT_VALUE,
    initialize => 1,
    weaken     => 1
);

my $ATTRIBUTE_11 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_11',
    initializer => 'attribute_11_initializer',
    initialize  => 1,
    weaken      => 1
);

my $ATTRIBUTE_12 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'attribute_12',
    initializer => sub { $My::Class::A::ATTRIBUTE_12_INITIALIZER_VALUE },
    initialize  => 1,
    weaken      => 1
);

my $ATTRIBUTE_13 = GX::Meta::Attribute::Scalar->new(
    class    => $CLASS_A,
    name     => 'attribute_13',
    required => 1
);

my $STATIC_ATTRIBUTE_1 = GX::Meta::Attribute::Scalar->new(
    class  => $CLASS_A,
    name   => 'static_attribute_1',
    static => 1
);

my $STATIC_ATTRIBUTE_2 = GX::Meta::Attribute::Scalar->new(
    class   => $CLASS_A,
    name    => 'static_attribute_2',
    default => 'static_attribute_2_default_value',
    static  => 1
);

my $STATIC_ATTRIBUTE_3 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'static_attribute_3',
    initializer => 'static_attribute_3_initializer',
    static      => 1
);

my $STATIC_ATTRIBUTE_4 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'static_attribute_4',
    initializer => sub { 'static_attribute_4_initializer_value' },
    static      => 1
);

my $STATIC_ATTRIBUTE_5 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'static_attribute_5',
    initialize => 1,
    static     => 1
);

my $STATIC_ATTRIBUTE_6 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'static_attribute_6',
    default    => 'static_attribute_6_default_value',
    initialize => 1,
    static     => 1
);

my $STATIC_ATTRIBUTE_7 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'static_attribute_7',
    initializer => 'static_attribute_7_initializer',
    initialize  => 1,
    static      => 1
);

my $STATIC_ATTRIBUTE_8 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'static_attribute_8',
    initializer => sub { 'static_attribute_8_initializer_value' },
    initialize  => 1,
    static      => 1
);

my $STATIC_ATTRIBUTE_9 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'static_attribute_9',
    initialize => 1,
    weaken     => 1,
    static     => 1
);

my $STATIC_ATTRIBUTE_10 = GX::Meta::Attribute::Scalar->new(
    class      => $CLASS_A,
    name       => 'static_attribute_10',
    default    => $My::Class::A::STATIC_ATTRIBUTE_10_DEFAULT_VALUE,
    initialize => 1,
    weaken     => 1,
    static     => 1
);

my $STATIC_ATTRIBUTE_11 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'static_attribute_11',
    initializer => 'static_attribute_11_initializer',
    initialize  => 1,
    weaken      => 1,
    static      => 1
);

my $STATIC_ATTRIBUTE_12 = GX::Meta::Attribute::Scalar->new(
    class       => $CLASS_A,
    name        => 'static_attribute_12',
    initializer => sub { $My::Class::A::STATIC_ATTRIBUTE_12_INITIALIZER_VALUE },
    initialize  => 1,
    weaken      => 1,
    static      => 1
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2,
    $ATTRIBUTE_3,
    $ATTRIBUTE_4,
    $ATTRIBUTE_5,
    $ATTRIBUTE_6,
    $ATTRIBUTE_7,
    $ATTRIBUTE_8,
    $ATTRIBUTE_9,
    $ATTRIBUTE_10,
    $ATTRIBUTE_11,
    $ATTRIBUTE_12,
    $ATTRIBUTE_13
);

my @STATIC_ATTRIBUTES = (
    $STATIC_ATTRIBUTE_1,
    $STATIC_ATTRIBUTE_2,
    $STATIC_ATTRIBUTE_3,
    $STATIC_ATTRIBUTE_4,
    $STATIC_ATTRIBUTE_5,
    $STATIC_ATTRIBUTE_6,
    $STATIC_ATTRIBUTE_7,
    $STATIC_ATTRIBUTE_8,
    $STATIC_ATTRIBUTE_9,
    $STATIC_ATTRIBUTE_10,
    $STATIC_ATTRIBUTE_11,
    $STATIC_ATTRIBUTE_12
);


# attribute_1
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_1->initialize_instance_slot( $object );

    is_deeply( $object, {} );

}

# attribute_2
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_2->initialize_instance_slot( $object );

    is_deeply( $object, {} );

}

# attribute_3
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_3->initialize_instance_slot( $object );

    is_deeply( $object, {} );

}

# attribute_4
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_4->initialize_instance_slot( $object );

    is_deeply( $object, {} );

}

# attribute_5
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_5->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_5' => undef } );

}

# attribute_6
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_6->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_6' => 'attribute_6_default_value' } );

}

# attribute_7
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_7->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_7' => 'attribute_7_initializer_value' } );

}

# attribute_8
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_8->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_8' => 'attribute_8_initializer_value' } );

}

# attribute_9
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_9->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_9' => undef } );

}

# attribute_10
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_10->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_10' => $My::Class::A::ATTRIBUTE_10_DEFAULT_VALUE } );

    ok( isweak( $object->{'attribute_10'} ) );

}

# attribute_11
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_11->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_11' => $My::Class::A::ATTRIBUTE_11_INITIALIZER_VALUE } );

    ok( isweak( $object->{'attribute_11'} ) );

}

# attribute_12
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_12->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_12' => $My::Class::A::ATTRIBUTE_12_INITIALIZER_VALUE } );

    ok( isweak( $object->{'attribute_12'} ) );

}

# attribute_13
{

    {
        my $object = My::Class::A->new;
        local $@;
        eval { $ATTRIBUTE_13->initialize_instance_slot( $object ) };
        isa_ok( $@, 'GX::Meta::Exception' );
    }

    {
        my $object = My::Class::A->new;
        local $@;
        eval { $ATTRIBUTE_13->initialize_instance_slot( $object, {} ) };
        isa_ok( $@, 'GX::Meta::Exception' );
    }

}

# static_attribute_1
{

    $STATIC_ATTRIBUTE_1->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, {} );

    _clear_class_data( $CLASS_A );

}

# static_attribute_2
{

    $STATIC_ATTRIBUTE_2->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, {} );

    _clear_class_data( $CLASS_A );

}

# static_attribute_3
{

    $STATIC_ATTRIBUTE_3->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, {} );

    _clear_class_data( $CLASS_A );

}

# static_attribute_4
{

    $STATIC_ATTRIBUTE_4->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, {} );

    _clear_class_data( $CLASS_A );

}

# static_attribute_5
{

    $STATIC_ATTRIBUTE_5->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, { 'static_attribute_5' => undef } );

    _clear_class_data( $CLASS_A );

}

# static_attribute_6
{

    $STATIC_ATTRIBUTE_6->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, { 'static_attribute_6' => 'static_attribute_6_default_value' } );

    _clear_class_data( $CLASS_A );

}

# static_attribute_7
{

    $STATIC_ATTRIBUTE_7->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, { 'static_attribute_7' => 'static_attribute_7_initializer_value' } );

    _clear_class_data( $CLASS_A );

}

# static_attribute_8
{

    $STATIC_ATTRIBUTE_8->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, { 'static_attribute_8' => 'static_attribute_8_initializer_value' } );

    _clear_class_data( $CLASS_A );

}

# static_attribute_9
{

    $STATIC_ATTRIBUTE_9->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, { 'static_attribute_9' => undef } );

    _clear_class_data( $CLASS_A );

}

# static_attribute_10
{

    $STATIC_ATTRIBUTE_10->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, { 'static_attribute_10' => $My::Class::A::STATIC_ATTRIBUTE_10_DEFAULT_VALUE } );

    _clear_class_data( $CLASS_A );

}

# static_attribute_11
{

    $STATIC_ATTRIBUTE_11->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, { 'static_attribute_11' => $My::Class::A::STATIC_ATTRIBUTE_11_INITIALIZER_VALUE } );

    _clear_class_data( $CLASS_A );

}

# static_attribute_12
{

    $STATIC_ATTRIBUTE_12->initialize_class_data_slot;

    is_deeply( $CLASS_A->class_data, { 'static_attribute_12' => $My::Class::A::STATIC_ATTRIBUTE_12_INITIALIZER_VALUE } );

    _clear_class_data( $CLASS_A );

}

# Already existing slot
{

    for my $attribute ( @ATTRIBUTES ) {

        for my $value ( undef, 0, '', 'abc' ) {
            my $object = My::Class::A->new( $attribute->name => $value );
            $attribute->initialize_instance_slot( $object, { $attribute->name => 'x' } );
            is_deeply( $object, { $attribute->slot_key => $value } );
        }

    }

    for my $attribute ( @STATIC_ATTRIBUTES ) {

        for my $value ( undef, 0, '', 'abc' ) {
            $CLASS_A->class_data->{$attribute->name} = $value;
            $attribute->initialize_class_data_slot( { $attribute->name => 'x' } );
            is_deeply( $CLASS_A->class_data, { $attribute->slot_key => $value } );
            _clear_class_data( $CLASS_A );
        }

    }

}

# Initialize with data
{

    for my $attribute ( @ATTRIBUTES ) {

        for my $value ( undef, 0, '', 'abc' ) {
            my $object = My::Class::A->new;
            $attribute->initialize_instance_slot( $object, { $attribute->name => $value } );
            is_deeply( $object, { $attribute->slot_key => $value } );
        }

    }

    for my $attribute ( @STATIC_ATTRIBUTES ) {

        for my $value ( undef, 0, '', 'abc' ) {
            $attribute->initialize_class_data_slot( { $attribute->name => $value } );
            is_deeply( $CLASS_A->class_data, { $attribute->slot_key => $value } );
            _clear_class_data( $CLASS_A );
        }

    }

}

# Initialize with data, weaken
{

    for my $attribute (
        $ATTRIBUTE_1,
        $ATTRIBUTE_2,
        $ATTRIBUTE_3,
        $ATTRIBUTE_4,
        $ATTRIBUTE_5,
        $ATTRIBUTE_6,
        $ATTRIBUTE_7,
        $ATTRIBUTE_8
    ) {

        {
            my $object = My::Class::A->new;
            my $value  = \'reference'; 
            $attribute->initialize_instance_slot( $object, { $attribute->name => $value } );
            is_deeply( $object, { $attribute->slot_key => $value } );
            ok( ! isweak( $object->{$attribute->slot_key} ) );
        }

    }

    for my $attribute (
        $ATTRIBUTE_9,
        $ATTRIBUTE_10,
        $ATTRIBUTE_11,
        $ATTRIBUTE_12
    ) {

        {
            my $object = My::Class::A->new;
            my $value  = \'reference';  
            $attribute->initialize_instance_slot( $object, { $attribute->name => $value } );
            is_deeply( $object, { $attribute->slot_key => $value } );
            ok( isweak( $object->{$attribute->slot_key} ) );
        }

    }

    for my $attribute (
        $STATIC_ATTRIBUTE_1,
        $STATIC_ATTRIBUTE_2,
        $STATIC_ATTRIBUTE_3,
        $STATIC_ATTRIBUTE_4,
        $STATIC_ATTRIBUTE_5,
        $STATIC_ATTRIBUTE_6,
        $STATIC_ATTRIBUTE_7,
        $STATIC_ATTRIBUTE_8
    ) {

        {
            my $value  = \'reference';  
            $attribute->initialize_class_data_slot( { $attribute->name => $value } );
            is_deeply( $CLASS_A->class_data, { $attribute->slot_key => $value } );
            ok( ! isweak( $CLASS_A->class_data->{$attribute->slot_key} ) );
            _clear_class_data( $CLASS_A );
        }

    }

    for my $attribute (
        $STATIC_ATTRIBUTE_9,
        $STATIC_ATTRIBUTE_10,
        $STATIC_ATTRIBUTE_11,
        $STATIC_ATTRIBUTE_12
    ) {

        {
            my $value  = \'reference';  
            $attribute->initialize_class_data_slot( { $attribute->name => $value } );
            is_deeply( $CLASS_A->class_data, { $attribute->slot_key => $value } );
            ok( isweak( $CLASS_A->class_data->{$attribute->slot_key} ) );
            _clear_class_data( $CLASS_A );
        }

    }

}


# ----------------------------------------------------------------------------------------------------------------------

sub _clear_class_data {

    my $class = shift;

    delete $class->package->symbol_table->{$class->class_data_identifier};

}

