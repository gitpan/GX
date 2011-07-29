#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package  My::Class::A;

use GX::Class ( code_attributes => [ 'Attribute_1', 'Attribute_2', 'Attribute_3' ] );

sub method_1_1 :Attribute_1 {}
sub method_2_1 :Attribute_2 {}
sub method_2_2 :Attribute_2 {}
sub method_3_1 :Attribute_3 {}
sub method_3_2 :Attribute_3 {}
sub method_3_3 :Attribute_3 {}
sub method_4_1 {}
sub method_4_2 {}


package  My::Class::B;

use GX::Class ( extends => 'My::Class::A', code_attributes => [ 'Attribute_4' ] );

sub method_1_1 {}
sub method_2_1 {}
sub method_2_2 :Attribute_2 {}
sub method_3_2 {}
sub method_3_3 :Attribute_3 {}
sub method_4_2 :Attribute_4 {}
sub method_4_3 :Attribute_4 {}
sub method_4_4 :Attribute_4 {}


package main;


use Test::More tests => 4;


# methods_with_code_attribute()
{

    my $class_a = My::Class::A->meta;
    my $class_b = My::Class::B->meta;

    is_deeply(
        [ sort { $a->name cmp $b->name } $class_a->methods_with_code_attribute ],
        [
            sort { $a->name cmp $b->name } (
                $class_a->method( 'method_1_1' ),
                $class_a->method( 'method_2_1' ),
                $class_a->method( 'method_2_2' ),
                $class_a->method( 'method_3_1' ),
                $class_a->method( 'method_3_2' ),
                $class_a->method( 'method_3_3' )
            )
        ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $class_b->methods_with_code_attribute ],
        [
            sort { $a->name cmp $b->name } (
                $class_b->method( 'method_2_2' ),
                $class_b->method( 'method_3_3' ),
                $class_b->method( 'method_4_2' ),
                $class_b->method( 'method_4_3' ),
                $class_b->method( 'method_4_4' )
            )
        ]
    );

}

# all_methods_with_code_attribute()
{

    my $class_a = My::Class::A->meta;
    my $class_b = My::Class::B->meta;

    is_deeply(
        [ sort { $a->name cmp $b->name } $class_a->all_methods_with_code_attribute ],
        [
            sort { $a->name cmp $b->name } (
                $class_a->method( 'method_1_1' ),
                $class_a->method( 'method_2_1' ),
                $class_a->method( 'method_2_2' ),
                $class_a->method( 'method_3_1' ),
                $class_a->method( 'method_3_2' ),
                $class_a->method( 'method_3_3' )
            )
        ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $class_b->all_methods_with_code_attribute ],
        [
            sort { $a->name cmp $b->name } (
                $class_b->method( 'method_2_2' ),
                $class_a->method( 'method_3_1' ),
                $class_b->method( 'method_3_3' ),
                $class_b->method( 'method_4_2' ),
                $class_b->method( 'method_4_3' ),
                $class_b->method( 'method_4_4' )
            )
        ]
    );

}

