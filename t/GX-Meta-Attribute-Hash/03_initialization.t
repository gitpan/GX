#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

our $ATTRIBUTE_2_DEFAULT_VALUE = { map { ( "k$_" => "v$_" ) } 1 .. 2 };
our $ATTRIBUTE_6_DEFAULT_VALUE = { map { ( "k$_" => "v$_" ) } 1 .. 2 };

sub new { my $class = shift; return bless { @_ }, $class; }

sub attribute_3_initializer { return { map { ( "k$_" => "v$_" ) } 1 .. 3 } }
sub attribute_7_initializer { return { map { ( "k$_" => "v$_" ) } 1 .. 7 } }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Hash;

use Scalar::Util qw( isweak );


use Test::More tests => 120;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Hash->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Hash->new(
    class   => $CLASS_A,
    name    => 'attribute_2',
    default => $ATTRIBUTE_2_DEFAULT_VALUE
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Hash->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    initializer => 'attribute_3_initializer'
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Hash->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    initializer => sub { return { map { ( "k$_" => "v$_" ) } 1 .. 4 } }
);

my $ATTRIBUTE_5 = GX::Meta::Attribute::Hash->new(
    class      => $CLASS_A,
    name       => 'attribute_5',
    initialize => 1,
    weaken     => 1
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::Hash->new(
    class      => $CLASS_A,
    name       => 'attribute_6',
    default    => $ATTRIBUTE_6_DEFAULT_VALUE,
    initialize => 1,
    weaken     => 1
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::Hash->new(
    class       => $CLASS_A,
    name        => 'attribute_7',
    initializer => 'attribute_7_initializer',
    initialize  => 1,
    weaken      => 1
);

my $ATTRIBUTE_8 = GX::Meta::Attribute::Hash->new(
    class       => $CLASS_A,
    name        => 'attribute_8',
    initializer => sub { return { map { ( "k$_" => "v$_" ) } 1 .. 8 } },
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
    $ATTRIBUTE_8
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

    is_deeply( $object, { 'attribute_5' => {} } );

}

# attribute_6
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_6->initialize_instance_slot( $object );

    is( $object->{'attribute_6'}, $ATTRIBUTE_6_DEFAULT_VALUE );

}

# attribute_7
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_7->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_7' => { map { ( "k$_" => "v$_" ) } 1 .. 7 } } );

}

# attribute_8
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_8->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_8' => { map { ( "k$_" => "v$_" ) } 1 .. 8 } } );

}

# Initialize, already existing slot
{

    for my $attribute ( @ATTRIBUTES ) {
        my $attribute_name = $attribute->name;
        my $object = My::Class::A->new( $attribute_name => { 'k1' => 'v1' } );
        $attribute->initialize_instance_slot( $object, { $attribute_name => { 'kx' => 'vx' } } );
        is_deeply( $object, { $attribute_name => { 'k1' => 'v1' } } );
    }

}

# Initialize with data
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;
        my $v1 = undef;
        my $v2 = 'v2';
        my $v3 = \'v3';

        for my $data ( {}, { 'k1' => $v1 }, { 'k2' => $v2, 'k3' => $v3 } ) {
            my $object = My::Class::A->new;
            $attribute->initialize_instance_slot( $object, { $attribute_name => $data } );
            is_deeply( $object, { $attribute_name => $data } );
        }

    }

    for my $attribute (
        $ATTRIBUTE_5,
        $ATTRIBUTE_6,
        $ATTRIBUTE_7,
        $ATTRIBUTE_8
    ) {

        my $attribute_name = $attribute->name;
        my $v1 = undef;
        my $v2 = 'v2';
        my $v3 = \'v3';

        for my $data ( { 'k1' => $v1, 'k2' => $v2, 'k3' => $v3 } ) {
            my $object = My::Class::A->new;
            $attribute->initialize_instance_slot( $object, { $attribute_name => $data } );
            is_deeply( $object, { $attribute_name => $data } );
            ok( ! isweak( $object->{$attribute_name}{'k1'} ) );
            ok( ! isweak( $object->{$attribute_name}{'k2'} ) );
            ok( isweak( $object->{$attribute_name}{'k3'} ) );
        }

    }

}

# Initialize with invalid data
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        for my $data ( undef, '', 1, [] ) {
            my $object = My::Class::A->new;
            local $@;
            eval { $attribute->initialize_instance_slot( $object, { $attribute_name => $data } ) };
            isa_ok( $@, 'GX::Meta::Exception' );
            is( $@->message, "Invalid value for attribute \"$attribute_name\"");
        }

    }

}

