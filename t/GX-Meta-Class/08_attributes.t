#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;


use Test::More tests => 60;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );
my $CLASS_B = GX::Meta::Class->new( 'My::Class::B' );

$CLASS_B->inherit_from( $CLASS_A );


{

    is_deeply( [ $CLASS_A->attributes ],     [] );
    is_deeply( [ $CLASS_A->all_attributes ], [] );
    is_deeply( [ $CLASS_B->attributes ],     [] );
    is_deeply( [ $CLASS_B->all_attributes ], [] );

    is_deeply( [ $CLASS_A->instance_attributes ],     [] );
    is_deeply( [ $CLASS_A->all_instance_attributes ], [] );
    is_deeply( [ $CLASS_B->instance_attributes ],     [] );
    is_deeply( [ $CLASS_B->all_instance_attributes ], [] );

    is_deeply( [ $CLASS_A->class_attributes ],     [] );
    is_deeply( [ $CLASS_A->all_class_attributes ], [] );
    is_deeply( [ $CLASS_B->class_attributes ],     [] );
    is_deeply( [ $CLASS_B->all_class_attributes ], [] );

    my $attribute_a_1 = $CLASS_A->add_attribute( name => 'attribute_1' );

    isa_ok( $attribute_a_1, 'GX::Meta::Attribute::Scalar' );
    is( $attribute_a_1->class, $CLASS_A );
    is( $attribute_a_1->name, 'attribute_1' );

    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->attributes ],     [ $attribute_a_1 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->all_attributes ], [ $attribute_a_1 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->attributes ],     [] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->all_attributes ], [ $attribute_a_1 ] );

    my $attribute_a_2 = $CLASS_A->add_attribute( name => 'attribute_2' );

    isa_ok( $attribute_a_2, 'GX::Meta::Attribute::Scalar' );
    is( $attribute_a_2->class, $CLASS_A );
    is( $attribute_a_2->name, 'attribute_2' );

    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->attributes ],     [ $attribute_a_1, $attribute_a_2 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->all_attributes ], [ $attribute_a_1, $attribute_a_2 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->attributes ],     [] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->all_attributes ], [ $attribute_a_1, $attribute_a_2 ] );

    my $attribute_b_2 = $CLASS_B->add_attribute( name => 'attribute_2' );

    isa_ok( $attribute_b_2, 'GX::Meta::Attribute::Scalar' );
    is( $attribute_b_2->class, $CLASS_B );
    is( $attribute_b_2->name, 'attribute_2' );

    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->attributes ],     [ $attribute_a_1, $attribute_a_2 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->all_attributes ], [ $attribute_a_1, $attribute_a_2 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->attributes ],     [ $attribute_b_2 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->all_attributes ], [ $attribute_a_1, $attribute_b_2 ] );


    my $attribute_b_3 = $CLASS_B->add_attribute( name => 'attribute_3', static => 1 );

    isa_ok( $attribute_b_3, 'GX::Meta::Attribute::Scalar' );
    is( $attribute_b_3->class, $CLASS_B );
    is( $attribute_b_3->name, 'attribute_3' );

    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->attributes ],     [ $attribute_a_1, $attribute_a_2 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->all_attributes ], [ $attribute_a_1, $attribute_a_2 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->attributes ],     [ $attribute_b_2, $attribute_b_3 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->all_attributes ], [ $attribute_a_1, $attribute_b_2, $attribute_b_3 ] );

    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->instance_attributes ],     [ $attribute_a_1, $attribute_a_2 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->all_instance_attributes ], [ $attribute_a_1, $attribute_a_2 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->instance_attributes ],     [ $attribute_b_2 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->all_instance_attributes ], [ $attribute_a_1, $attribute_b_2 ] );

    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->class_attributes ],     [] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_A->all_class_attributes ], [] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->class_attributes ],     [ $attribute_b_3 ] );
    is_deeply( [ sort { $a->name cmp $b->name } $CLASS_B->all_class_attributes ], [ $attribute_b_3 ] );

    ok( $CLASS_A->has_attribute( 'attribute_1' ) );
    ok( $CLASS_A->has_attribute( 'attribute_2' ) );
    ok( ! $CLASS_A->has_attribute( 'attribute_3' ) );

    ok( ! $CLASS_B->has_attribute( 'attribute_1' ) );
    ok( $CLASS_B->has_attribute( 'attribute_2' ) );
    ok( $CLASS_B->has_attribute( 'attribute_3' ) );

    is( $CLASS_A->attribute( 'attribute_1' ), $attribute_a_1 );
    is( $CLASS_A->attribute( 'attribute_2' ), $attribute_a_2 );
    is( $CLASS_A->attribute( 'attribute_3' ), undef );

    is( $CLASS_B->attribute( 'attribute_1' ), undef );
    is( $CLASS_B->attribute( 'attribute_2' ), $attribute_b_2 );
    is( $CLASS_B->attribute( 'attribute_3' ), $attribute_b_3 );

}

