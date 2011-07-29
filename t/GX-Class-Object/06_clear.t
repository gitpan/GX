#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

use GX::Class::Object;


package My::Class::B;

use GX::Class::Object;

extends 'My::Class::A';

has 'scalar_attribute_1';
has 'scalar_attribute_2';
has 'scalar_attribute_3';


package My::Class::C;

use GX::Class::Object;

use base 'My::Class::B';

has 'scalar_attribute_2';
has 'scalar_attribute_3';
has 'scalar_attribute_4';
has 'scalar_attribute_5';


package My::Class::D;

use GX::Class::Object;

extends 'My::Class::B';

has 'scalar_attribute_2' => ( sticky => 1 );
has 'scalar_attribute_3' => ( sticky => 1 );
has 'scalar_attribute_4' => ( sticky => 1 );


package main;


use Test::More tests => 8 + 10 * 5;


{

    is( \&My::Class::A::__clear_instance, \&GX::Class::Object::__clear_instance );
    is( \&My::Class::B::__clear_instance, \&GX::Class::Object::__clear_instance );
    is( \&My::Class::C::__clear_instance, \&GX::Class::Object::__clear_instance );
    is( \&My::Class::D::__clear_instance, \&GX::Class::Object::__clear_instance );

    run_tests();

    eval "package My::Class::A; build; 1;" or die;

    isnt( \&My::Class::A::__clear_instance, \&GX::Class::Object::__clear_instance );

    run_tests();

    eval "package My::Class::B; build; 1;" or die;

    isnt( \&My::Class::B::__clear_instance, \&GX::Class::Object::__clear_instance );

    run_tests();

    eval "package My::Class::C; build; 1;" or die;

    isnt( \&My::Class::C::__clear_instance, \&GX::Class::Object::__clear_instance );

    run_tests();

    eval "package My::Class::D; build; 1;" or die;

    isnt( \&My::Class::D::__clear_instance, \&GX::Class::Object::__clear_instance );

    run_tests();

}


sub run_tests {

    # My::Class::A
    {

        my $object = My::Class::A->new( 'attribute_x' => 'x' );

        is_deeply( $object, {} );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::B
    {

        my $object = My::Class::B->new(
            'scalar_attribute_1' => '1',
            'scalar_attribute_2' => '2',
            'scalar_attribute_3' => '3'
        );

        is_deeply(
            $object,
            {
                'scalar_attribute_1' => '1',
                'scalar_attribute_2' => '2',
                'scalar_attribute_3' => '3'
            }
        );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::C, new( %data )
    {

        my $object = My::Class::C->new(
            'scalar_attribute_1' => '1',
            'scalar_attribute_2' => '2',
            'scalar_attribute_3' => '3',
            'scalar_attribute_4' => '4',
            'scalar_attribute_5' => '5'
        );

        is_deeply(
            $object,
            {
                'scalar_attribute_1' => '1',
                'scalar_attribute_2' => '2',
                'scalar_attribute_3' => '3',
                'scalar_attribute_4' => '4',
                'scalar_attribute_5' => '5'
            }
        );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::C, foreign attribute
    {

        my $object = My::Class::C->new(
            'scalar_attribute_1'  => '1',
            'scalar_attribute_2'  => '2',
            'scalar_attribute_3'  => '3',
            'scalar_attribute_4'  => '4',
            'scalar_attribute_5'  => '5'
        );

        is_deeply(
            $object,
            {
                'scalar_attribute_1' => '1',
                'scalar_attribute_2' => '2',
                'scalar_attribute_3' => '3',
                'scalar_attribute_4' => '4',
                'scalar_attribute_5' => '5'
            }
        );

        $object->{'foreign_attribute_1'} = '1';

        $object->clear;

        is_deeply(
            $object,
            {
                'foreign_attribute_1' => '1'
            }
        );

    }

    # My::Class::D
    {

        my $object = My::Class::D->new(
            'scalar_attribute_1'  => '1',
            'scalar_attribute_2'  => '2',
            'scalar_attribute_3'  => '3',
            'scalar_attribute_4'  => '4'
        );

        is_deeply(
            $object,
            {
                'scalar_attribute_1' => '1',
                'scalar_attribute_2' => '2',
                'scalar_attribute_3' => '3',
                'scalar_attribute_4' => '4'
            }
        );

        $object->{'foreign_attribute_1'} = '1';

        $object->clear;

        is_deeply(
            $object,
            {
                'scalar_attribute_2'  => '2',
                'scalar_attribute_3'  => '3',
                'scalar_attribute_4'  => '4',
                'foreign_attribute_1' => '1',
            }
        );

    }

}

