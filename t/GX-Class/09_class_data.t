#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

use GX::Class;

has static 'attribute_1';
has static 'attribute_2';


package My::Class::B;

use GX::Class;

extends 'My::Class::A';

has static 'attribute_2';
has static 'attribute_3';


package main;


use Test::More tests => 11;


{

    My::Class::A->attribute_1( '1A' );

    is( My::Class::A->attribute_1, '1A' );
    is( My::Class::B->attribute_1, undef );

    My::Class::B->attribute_1( '1B' );

    is( My::Class::A->attribute_1, '1A' );
    is( My::Class::B->attribute_1, '1B' );

    My::Class::A->attribute_2( '2A' );

    is( My::Class::A->attribute_2, '2A' );
    is( My::Class::B->attribute_2, undef );

    My::Class::B->attribute_2( '2B' );

    is( My::Class::A->attribute_2, '2A' );
    is( My::Class::B->attribute_2, '2B' );

    My::Class::B->attribute_3( '3B' );

    is( My::Class::B->attribute_3, '3B' );

    is_deeply(
        My::Class::A->meta->class_data,
        {
            'attribute_1' => '1A',
            'attribute_2' => '2A'
        }
    );

    is_deeply(
        My::Class::B->meta->class_data,
        {
            'attribute_1' => '1B',
            'attribute_2' => '2B',
            'attribute_3' => '3B'
        }
    );

}

