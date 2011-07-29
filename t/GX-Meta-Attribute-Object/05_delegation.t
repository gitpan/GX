#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

sub new { my $class = shift; bless { @_ }, $class }


package My::Class::B;

sub new { my $class = shift; bless { @_ }, $class }

sub method_1 { return 'My::Class::B::method_1', @_ }
sub method_2 { return 'My::Class::B::method_2', @_ }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Object;


use Test::More tests => 18;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Object->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Object->new(
    class       => $CLASS_A,
    name        => 'attribute_2',
    initializer => sub { My::Class::B->new }
);


my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2
);


# Delegator setup
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        my @delegators;

        for my $to ( qw( method_1 method_2 ) ) {

            my $delegator_name = "${attribute_name}_delegate_to_${to}";

            my $delegator = $attribute->add_delegator(
                name => $delegator_name,
                to   => $to
            );

            isa_ok( $delegator, 'GX::Meta::Delegator' );
            is( $delegator->attribute, $attribute );
            is( $delegator->name, $delegator_name );

            push @delegators, $delegator;

        }

        is_deeply(
            [ sort @delegators ],
            [ sort $attribute->delegators ]
        );

        $attribute->install_delegators;

    }

}

# attribute_1
{

    {

        my $object_b = My::Class::B->new;
        my $object_a = My::Class::A->new( attribute_1 => $object_b );

        is_deeply(
            [ $object_a->attribute_1_delegate_to_method_1( 1 ..  3 ) ],
            [ 'My::Class::B::method_1', $object_b, 1 .. 3 ]
        );

        is_deeply(
            [ $object_a->attribute_1_delegate_to_method_2( 1 ..  3 ) ],
            [ 'My::Class::B::method_2', $object_b, 1 .. 3 ]
        );


    }

}

# attribute_2
{

    {

        my $object_a = My::Class::A->new;

        is_deeply(
            [ $object_a->attribute_2_delegate_to_method_1( 1 ..  3 ) ],
            [ 'My::Class::B::method_1', $object_a->{'attribute_2'}, 1 .. 3 ]
        );

        is_deeply(
            [ $object_a->attribute_2_delegate_to_method_2( 1 ..  3 ) ],
            [ 'My::Class::B::method_2', $object_a->{'attribute_2'}, 1 .. 3 ]
        );


    }

}

