#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

our $ATTRIBUTE_2_DEFAULT_VALUE             = bless {}, 'ATTRIBUTE_2_DEFAULT_VALUE';
our $ATTRIBUTE_3_INITIALIZER_VALUE         = bless {}, 'ATTRIBUTE_3_INITIALIZER_VALUE';
our $ATTRIBUTE_4_INITIALIZER_VALUE         = bless {}, 'ATTRIBUTE_4_INITIALIZER_VALUE';
our $ATTRIBUTE_6_DEFAULT_VALUE             = bless {}, 'ATTRIBUTE_6_DEFAULT_VALUE';
our $ATTRIBUTE_7_INITIALIZER_VALUE         = bless {}, 'ATTRIBUTE_7_INITIALIZER_VALUE';
our $ATTRIBUTE_8_INITIALIZER_VALUE         = bless {}, 'ATTRIBUTE_8_INITIALIZER_VALUE';
our $ATTRIBUTE_10_DEFAULT_VALUE            = bless {}, 'ATTRIBUTE_10_DEFAULT_VALUE';
our $ATTRIBUTE_11_INITIALIZER_VALUE        = bless {}, 'ATTRIBUTE_11_INITIALIZER_VALUE';
our $ATTRIBUTE_12_INITIALIZER_VALUE        = bless {}, 'ATTRIBUTE_12_INITIALIZER_VALUE';

sub new { my $class = shift; bless { @_ }, $class }

sub attribute_3_initializer  { $ATTRIBUTE_3_INITIALIZER_VALUE }
sub attribute_7_initializer  { $ATTRIBUTE_7_INITIALIZER_VALUE }
sub attribute_11_initializer { $ATTRIBUTE_11_INITIALIZER_VALUE }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Object;

use Scalar::Util qw( isweak );


use Test::More tests => 135;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Object->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Object->new(
    class   => $CLASS_A,
    name    => 'attribute_2',
    default => $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Object->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    initializer => 'attribute_3_initializer'
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Object->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    initializer => sub { $My::Class::A::ATTRIBUTE_4_INITIALIZER_VALUE }
);

my $ATTRIBUTE_5 = GX::Meta::Attribute::Object->new(
    class      => $CLASS_A,
    name       => 'attribute_5',
    initialize => 1
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::Object->new(
    class      => $CLASS_A,
    name       => 'attribute_6',
    default    => $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE,
    initialize => 1
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::Object->new(
    class       => $CLASS_A,
    name        => 'attribute_7',
    initializer => 'attribute_7_initializer',
    initialize  => 1,
);

my $ATTRIBUTE_8 = GX::Meta::Attribute::Object->new(
    class       => $CLASS_A,
    name        => 'attribute_8',
    initializer => sub { $My::Class::A::ATTRIBUTE_8_INITIALIZER_VALUE },
    initialize  => 1
);

my $ATTRIBUTE_9 = GX::Meta::Attribute::Object->new(
    class      => $CLASS_A,
    name       => 'attribute_9',
    initialize => 1,
    weaken     => 1
);

my $ATTRIBUTE_10 = GX::Meta::Attribute::Object->new(
    class      => $CLASS_A,
    name       => 'attribute_10',
    default    => $My::Class::A::ATTRIBUTE_10_DEFAULT_VALUE,
    initialize => 1,
    weaken     => 1
);

my $ATTRIBUTE_11 = GX::Meta::Attribute::Object->new(
    class       => $CLASS_A,
    name        => 'attribute_11',
    initializer => 'attribute_11_initializer',
    initialize  => 1,
    weaken      => 1
);

my $ATTRIBUTE_12 = GX::Meta::Attribute::Object->new(
    class       => $CLASS_A,
    name        => 'attribute_12',
    initializer => sub { $My::Class::A::ATTRIBUTE_12_INITIALIZER_VALUE },
    initialize  => 1,
    weaken      => 1
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
    $ATTRIBUTE_12
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

    is_deeply( $object, { 'attribute_6' => $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE } );

}

# attribute_7
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_7->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_7' => $My::Class::A::ATTRIBUTE_7_INITIALIZER_VALUE } );

}

# attribute_8
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_8->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_8' => $My::Class::A::ATTRIBUTE_8_INITIALIZER_VALUE } );

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

# Already existing slot
{

    my $existing_object = bless {}, 'Foo';

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        {
            my $object = My::Class::A->new( $attribute_name => $existing_object );
            my $value = bless {}, 'Bar';
            $attribute->initialize_instance_slot( $object, { $attribute_name => $value } );
            is_deeply( $object, { $attribute->slot_key => $existing_object } );
        }

    }

}

# Initialize with data
{

    my $test_object = bless {}, 'Foo';

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        for my $value ( $test_object ) {
            my $object = My::Class::A->new;
            $attribute->initialize_instance_slot( $object, { $attribute_name => $value } );
            is_deeply( $object, { $attribute->slot_key => $value } );
        }

    }

}

# Initialize with invalid data
{

    for my $value ( undef, '', {} ) {

        for my $attribute ( @ATTRIBUTES ) {

            my $object = My::Class::A->new;

            local $@;
            eval { $attribute->initialize_instance_slot( $object, { $attribute->name => $value } ) };
            isa_ok( $@, 'GX::Meta::Exception' );

            is_deeply( $object, {} );

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
            my $value  = bless {}, 'Foo';
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
            my $value  = bless {}, 'Foo';
            $attribute->initialize_instance_slot( $object, { $attribute->name => $value } );
            is_deeply( $object, { $attribute->slot_key => $value } );
            ok( isweak( $object->{$attribute->slot_key} ) );
        }

    }

}

