#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

our $ATTRIBUTE_2_DEFAULT_VALUE = do {
    tie my %hash, 'GX::Tie::Hash::Ordered';
    %hash = map { ( "k$_" => "v$_" ) } 1 .. 2;
    \%hash;
};

our $ATTRIBUTE_6_DEFAULT_VALUE = do {
    tie my %hash, 'GX::Tie::Hash::Ordered';
    %hash = map { ( "k$_" => "v$_" ) } 1 .. 6;
    \%hash;
};


sub new { my $class = shift; return bless { @_ }, $class; }

sub attribute_3_initializer {
    tie my %hash, 'GX::Tie::Hash::Ordered';
    %hash = map { ( "k$_" => "v$_" ) } 1 .. 3;
    return \%hash;
}

sub attribute_7_initializer {
    tie my %hash, 'GX::Tie::Hash::Ordered';
    %hash = map { ( "k$_" => "v$_" ) } 1 .. 7;
    return \%hash;
}


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Hash::Ordered;


use Test::More tests => 116;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Hash::Ordered->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Hash::Ordered->new(
    class   => $CLASS_A,
    name    => 'attribute_2',
    default => $ATTRIBUTE_2_DEFAULT_VALUE
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Hash::Ordered->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    initializer => 'attribute_3_initializer'
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Hash::Ordered->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    initializer => sub {
        tie my %hash, 'GX::Tie::Hash::Ordered';
        %hash = map { ( "k$_" => "v$_" ) } 1 .. 4;
        return \%hash;
    }
);

my $ATTRIBUTE_5 = GX::Meta::Attribute::Hash::Ordered->new(
    class      => $CLASS_A,
    name       => 'attribute_5',
    initialize => 1
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::Hash::Ordered->new(
    class      => $CLASS_A,
    name       => 'attribute_6',
    default    => $ATTRIBUTE_6_DEFAULT_VALUE,
    initialize => 1
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::Hash::Ordered->new(
    class       => $CLASS_A,
    name        => 'attribute_7',
    initialize  => 1,
    initializer => 'attribute_7_initializer'
);

my $ATTRIBUTE_8 = GX::Meta::Attribute::Hash::Ordered->new(
    class       => $CLASS_A,
    name        => 'attribute_8',
    initialize  => 1,
    initializer => sub {
        tie my %hash, 'GX::Tie::Hash::Ordered';
        %hash = map { ( "k$_" => "v$_" ) } 1 .. 8;
        return \%hash;
    }
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

    is( ref( tied( %{$object->{'attribute_5'}} ) ), 'GX::Tie::Hash::Ordered' );

}

# attribute_6
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_6->initialize_instance_slot( $object );

    is( $object->{'attribute_6'}, $ATTRIBUTE_6_DEFAULT_VALUE );

    is( ref( tied( %{$object->{'attribute_6'}} ) ), 'GX::Tie::Hash::Ordered' );

}

# attribute_7
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_7->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_7' => { map { ( "k$_" => "v$_" ) } 1 .. 7 } } );

    is( ref( tied( %{$object->{'attribute_7'}} ) ), 'GX::Tie::Hash::Ordered' );

}

# attribute_8
{

    my $object = My::Class::A->new;

    $ATTRIBUTE_8->initialize_instance_slot( $object );

    is_deeply( $object, { 'attribute_8' => { map { ( "k$_" => "v$_" ) } 1 .. 8 } } );

    is( ref( tied( %{$object->{'attribute_8'}} ) ), 'GX::Tie::Hash::Ordered' );

}

# Initialize, already existing slot
{

    my $existing_value = do {
        tie my %hash, 'GX::Tie::Hash::Ordered';
        %hash = ( 'k1' => 'v1' );
        \%hash;
    };

    my $new_value = do {
        tie my %hash, 'GX::Tie::Hash::Ordered';
        %hash = ( 'kx' => 'vx' );
        \%hash;
    };

    for my $attribute ( @ATTRIBUTES ) {
        my $attribute_name = $attribute->name;
        my $object = My::Class::A->new( $attribute_name => $existing_value );
        $attribute->initialize_instance_slot( $object, { $attribute_name => $new_value } );
        is_deeply( $object, { $attribute_name => $existing_value } );
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

            my $value = do {
                tie my %hash, 'GX::Tie::Hash::Ordered';
                %hash = %$data;
                \%hash;
            };

            $attribute->initialize_instance_slot( $object, { $attribute_name => $value } );

            is_deeply( $object, { $attribute_name => $value } );
            is( ref( tied( %{$object->{$attribute_name}} ) ), 'GX::Tie::Hash::Ordered' );

        }

    }

}

# Initialize with invalid data
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        for my $data ( undef, '', 1, [], {}, \'' ) {
            my $object = My::Class::A->new;
            local $@;
            eval { $attribute->initialize_instance_slot( $object, { $attribute_name => $data } ) };
            isa_ok( $@, 'GX::Meta::Exception' );
        }

    }

}

