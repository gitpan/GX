#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

use GX::Class::Object;

sub __initialize { push @{$_[0]->{'__initialize'}}, __PACKAGE__ }


package My::Class::B;

use GX::Class::Object;

extends 'My::Class::A';

has 'scalar_attribute_1';
has 'scalar_attribute_2';
has 'scalar_attribute_3';

sub __initialize { push @{$_[0]->{'__initialize'}}, __PACKAGE__ }


package My::Class::C;

use GX::Class::Object;

use base 'My::Class::B';

has 'scalar_attribute_2';
has 'scalar_attribute_3';
has 'scalar_attribute_4';
has 'scalar_attribute_5';

sub __initialize { push @{$_[0]->{'__initialize'}}, __PACKAGE__ }


package main;


use Test::More tests => 12 * 4;


{

    run_tests();

    eval "package My::Class::A; build; 1;" or die;

    run_tests();

    eval "package My::Class::B; build; 1;" or die;

    run_tests();

    eval "package My::Class::C; build; 1;" or die;

    run_tests();

}


sub run_tests {

    # My::Class::A, new()
    {

        my $object = My::Class::A->new;

        isa_ok( $object, 'My::Class::A' );
        isa_ok( $object, 'GX::Class::Object' );

        is_deeply(
            $object,
            {
                '__initialize' => [ 'My::Class::A' ]
            }
        );

    }

    # My::Class::A, new( %data )
    {

        my $object = My::Class::A->new( 'attribute_x' => 'x' );

        is_deeply(
            $object,
            {
                '__initialize' => [ 'My::Class::A' ]
            }
        );

    }

    # My::Class::B, new()
    {

        my $object = My::Class::B->new;

        isa_ok( $object, 'My::Class::B' );
        isa_ok( $object, 'GX::Class::Object' );

        is_deeply(
            $object,
            {
                '__initialize' => [ 'My::Class::A', 'My::Class::B' ]
            }
        );

    }

    # My::Class::B, new( %data )
    {

        my $object = My::Class::B->new(
            'scalar_attribute_1' => '1',
            'scalar_attribute_2' => '2',
            'scalar_attribute_3' => '3',
            'attribute_x'        => 'x'
        );

        is_deeply(
            $object,
            {
                'scalar_attribute_1' => '1',
                'scalar_attribute_2' => '2',
                'scalar_attribute_3' => '3',
                '__initialize' => [ 'My::Class::A', 'My::Class::B' ]
            }
        );

    }

    # My::Class::C, new()
    {

        my $object = My::Class::C->new;

        isa_ok( $object, 'My::Class::C' );
        isa_ok( $object, 'GX::Class::Object' );

        is_deeply(
            $object,
            {
                '__initialize' => [ 'My::Class::A', 'My::Class::B', 'My::Class::C' ]
            }
        );

    }

    # My::Class::C, new( %data )
    {

        my $object = My::Class::C->new(
            'scalar_attribute_1' => '1',
            'scalar_attribute_2' => '2',
            'scalar_attribute_3' => '3',
            'scalar_attribute_4' => '4',
            'scalar_attribute_5' => '5',
            'attribute_x'        => 'x'
        );

        is_deeply(
            $object,
            {
                'scalar_attribute_1' => '1',
                'scalar_attribute_2' => '2',
                'scalar_attribute_3' => '3',
                'scalar_attribute_4' => '4',
                'scalar_attribute_5' => '5',
                '__initialize' => [ 'My::Class::A', 'My::Class::B', 'My::Class::C' ]
            }
        );

    }

}

