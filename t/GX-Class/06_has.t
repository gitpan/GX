#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

use GX::Class;

has 'attribute_1';
has 'attribute_2'  => ( isa => 'Scalar' );
has 'attribute_3'  => ( isa => 'GX::Meta::Attribute::Scalar' );
has 'attribute_4'  => ( type => 'Scalar' );
has 'attribute_5'  => ( accessor => undef );
has 'attribute_6'  => ( accessors => [] );
has 'attribute_7'  => ( accessor => 'attribute_7_default' );
has 'attribute_8'  => ( accessors => [ 'attribute_8_default' ] );
has 'attribute_9'  => ( accessor => { type => 'get' } );
has 'attribute_10' => ( accessors => [ { type => 'get' } ] );
has 'attribute_11' => ( accessor => { type => 'get', name => 'attribute_11_get' } );
has 'attribute_12' => ( accessors => [ { type => 'get', name => 'attribute_12_get' } ] );
has 'attribute_13' => ( accessor => { name => 'attribute_13_default' } );
has 'attribute_14' => ( accessors => [ { name => 'attribute_14_default' } ] );
has 'attribute_15' => ( accessors => [ { type => 'get', name => 'attribute_15_get' }, 'attribute_15_default' ] );
has 'attribute_16' => ( isa => 'Object', delegator => 'attribute_16_delegator' );
has 'attribute_17' => ( isa => 'Object', delegators => [ 'attribute_17_delegator' ] );
has 'attribute_18' => ( isa => 'Object', delegator => { name => 'attribute_18_delegator', to => 'foreign_method' } );
has 'attribute_19' => ( isa => 'Object', delegators => [ { name => 'attribute_19_delegator', to => 'foreign_method' } ] );
has 'attribute_20' => ( isa => 'Object', delegators => [ 'attribute_20_delegator_1', 'attribute_20_delegator_2' ] );

has static 'static_attribute_1';
has static 'static_attribute_2'  => ( isa => 'Scalar' );
has static 'static_attribute_3'  => ( isa => 'GX::Meta::Attribute::Scalar' );
has static 'static_attribute_4'  => ( type => 'Scalar' );
has static 'static_attribute_5'  => ( accessor => undef );
has static 'static_attribute_6'  => ( accessors => [] );
has static 'static_attribute_7'  => ( accessor => 'static_attribute_7_default' );
has static 'static_attribute_8'  => ( accessors => [ 'static_attribute_8_default' ] );
has static 'static_attribute_9'  => ( accessor => { type => 'get' } );
has static 'static_attribute_10' => ( accessors => [ { type => 'get' } ] );
has static 'static_attribute_11' => ( accessor => { type => 'get', name => 'static_attribute_11_get' } );
has static 'static_attribute_12' => ( accessors => [ { type => 'get', name => 'static_attribute_12_get' } ] );
has static 'static_attribute_13' => ( accessor => { name => 'static_attribute_13_default' } );
has static 'static_attribute_14' => ( accessors => [ { name => 'static_attribute_14_default' } ] );
has static 'static_attribute_15' => ( accessors => [ { type => 'get', name => 'static_attribute_15_get' }, 'static_attribute_15_default' ] );
has static 'static_attribute_16' => ( isa => 'Object', delegator => 'static_attribute_16_delegator' );
has static 'static_attribute_17' => ( isa => 'Object', delegators => [ 'static_attribute_17_delegator' ] );
has static 'static_attribute_18' => ( isa => 'Object', delegator => { name => 'static_attribute_18_delegator', to => 'foreign_method' } );
has static 'static_attribute_19' => ( isa => 'Object', delegators => [ { name => 'static_attribute_19_delegator', to => 'foreign_method' } ] );
has static 'static_attribute_20' => ( isa => 'Object', delegators => [ 'static_attribute_20_delegator_1', 'static_attribute_20_delegator_2' ] );

has 'invalid method name';
has 'existing_method';

sub existing_method {}


package main;

use Scalar::Util qw( refaddr );


use Test::More tests => 340;


# Attributes
{

    my $meta = My::Class::A->meta;

    for ( 1 .. 15 ) {

        my $attribute = $meta->attribute( "attribute_$_" );

        isa_ok( $attribute, 'GX::Meta::Attribute::Scalar' );

        is( $attribute->name, "attribute_$_" );
        is( refaddr( $attribute->class ), refaddr( $meta ) );

    }

    for ( 16 .. 20 ) {

        my $attribute = $meta->attribute( "attribute_$_" );

        isa_ok( $attribute, 'GX::Meta::Attribute::Object' );

        is( $attribute->name, "attribute_$_" );
        is( refaddr( $attribute->class ), refaddr( $meta ) );

    }

    for ( 1 .. 15 ) {

        my $attribute = $meta->attribute( "static_attribute_$_" );

        isa_ok( $attribute, 'GX::Meta::Attribute::Scalar' );

        is( $attribute->name, "static_attribute_$_" );
        ok( $attribute->is_static );
        is( refaddr( $attribute->class ), refaddr( $meta ) );

    }

    for ( 16 .. 20 ) {

        my $attribute = $meta->attribute( "static_attribute_$_" );

        isa_ok( $attribute, 'GX::Meta::Attribute::Object' );

        is( $attribute->name, "static_attribute_$_" );
        ok( $attribute->is_static );
        is( refaddr( $attribute->class ), refaddr( $meta ) );

    }

    for (
        'invalid method name',
        'existing_method'
    ) {

        my $attribute = $meta->attribute( $_ );

        isa_ok( $attribute, 'GX::Meta::Attribute::Scalar' );

        is( $attribute->name, $_ );
        is( refaddr( $attribute->class ), refaddr( $meta ) );

    }

}

# Default accessor
{

    my $meta = My::Class::A->meta;

    for my $attribute_name (
        map( { "attribute_$_" } 1 .. 4 ),
        map( { "static_attribute_$_" } 1 .. 4 )
    ) {

        my $attribute = $meta->attribute( $attribute_name );

        my @accessors = $attribute->accessors;
        is( scalar @accessors, 1 );

        is( refaddr( $accessors[0]->attribute ), refaddr( $attribute ) );
        is( $accessors[0]->name, $attribute_name );
        is( $accessors[0]->type, 'default' );
        is( $accessors[0]->code, My::Class::A->can( $attribute_name ) );

    }

}

# No default accessor
{

    my $meta = My::Class::A->meta;

    for my $attribute_name (
        map( { "attribute_$_" } 5 .. 6 ),
        map( { "static_attribute_$_" } 5 .. 6 )
    ) {

        my $attribute = $meta->attribute( $attribute_name );

        my @accessors = $attribute->accessors;
        is( scalar @accessors, 0 );

        ok( ! My::Class::A->can( $attribute_name ) );

    }

}

# No default accessor (invalid method name)
{

    my $meta = My::Class::A->meta;

    for my $attribute_name (
        'invalid method name'
    ) {

        my $attribute = $meta->attribute( $attribute_name );

        my @accessors = $attribute->accessors;
        is( scalar @accessors, 0 );

    }

}

# No default accessor (existing method)
{

    my $meta = My::Class::A->meta;

    for my $attribute_name (
        'existing_method'
    ) {

        my $attribute = $meta->attribute( $attribute_name );

        my @accessors = $attribute->accessors;
        is( scalar @accessors, 0 );

    }

}

# Default accessor ( $name )
{

    my $meta = My::Class::A->meta;

    for my $attribute_name (
        map( { "attribute_$_" } 7 .. 8 ),
        map( { "static_attribute_$_" } 7 .. 8 )
    ) {

        my $attribute = $meta->attribute( $attribute_name );

        my @accessors = $attribute->accessors;
        is( scalar @accessors, 1 );

        is( refaddr( $accessors[0]->attribute ), refaddr( $attribute ) );
        is( $accessors[0]->name, $attribute_name . '_default' );
        is( $accessors[0]->type, 'default' );
        is( $accessors[0]->code, My::Class::A->can( $attribute_name . '_default' ) );

    }

}

# Default accessor ( name => $name )
{

    my $meta = My::Class::A->meta;

    for my $attribute_name (
        map( { "attribute_$_" } 13 .. 14 ),
        map( { "static_attribute_$_" } 13 .. 14 )
    ) {

        my $attribute = $meta->attribute( $attribute_name );

        my @accessors = $attribute->accessors;
        is( scalar @accessors, 1 );

        is( refaddr( $accessors[0]->attribute ), refaddr( $attribute ) );
        is( $accessors[0]->name, $attribute_name . '_default' );
        is( $accessors[0]->type, 'default' );
        is( $accessors[0]->code, My::Class::A->can( $attribute_name . '_default' ) );

    }

}

# Custom accessor ( type => $type )
{

    my $meta = My::Class::A->meta;

    for my $attribute_name (
        map( { "attribute_$_" } 9 .. 10 ),
        map( { "static_attribute_$_" } 9 .. 10 )
    ) {

        my $attribute = $meta->attribute( $attribute_name );

        my @accessors = $attribute->accessors;
        is( scalar @accessors, 1 );

        is( refaddr( $accessors[0]->attribute ), refaddr( $attribute ) );
        is( $accessors[0]->name, $attribute_name );
        is( $accessors[0]->type, 'get' );
        is( $accessors[0]->code, My::Class::A->can( $attribute_name ) );

    }

}

# Custom accessor ( type => $type, name => $name )
{

    my $meta = My::Class::A->meta;

    for my $attribute_name (
        map( { "attribute_$_" } 11 .. 12 ),
        map( { "static_attribute_$_" } 11 .. 12 )
    ) {

        my $attribute = $meta->attribute( $attribute_name );

        my @accessors = $attribute->accessors;
        is( scalar @accessors, 1 );

        is( refaddr( $accessors[0]->attribute ), refaddr( $attribute ) );
        is( $accessors[0]->name, $attribute_name . '_get' );
        is( $accessors[0]->type, 'get' );
        is( $accessors[0]->code, My::Class::A->can( $attribute_name . '_get' ) );

    }

}

# Mulitple accessors
{

    my $meta = My::Class::A->meta;

    for my $attribute_name (
        map( { "attribute_$_" } 15 ),
        map( { "static_attribute_$_" } 15 )
    ) {

        my $attribute = $meta->attribute( $attribute_name );

        my @accessors = $attribute->accessors;
        is( scalar @accessors, 2 );

        is( refaddr( $accessors[0]->attribute ), refaddr( $attribute ) );
        is( $accessors[0]->name, $attribute_name . '_get' );
        is( $accessors[0]->type, 'get' );
        is( $accessors[0]->code, My::Class::A->can( $attribute_name . '_get' ) );

        is( refaddr( $accessors[1]->attribute ), refaddr( $attribute ) );
        is( $accessors[1]->name, $attribute_name . '_default' );
        is( $accessors[1]->type, 'default' );
        is( $accessors[1]->code, My::Class::A->can( $attribute_name . '_default' ) );

    }

}

# Delegators
{

    my $meta = My::Class::A->meta;

    for my $attribute_name (
        map( { "attribute_$_" } 16 .. 19 ),
        map( { "static_attribute_$_" } 16 .. 19 )
    ) {

        my $attribute = $meta->attribute( $attribute_name );

        my @delegators = $attribute->delegators;
        is( scalar @delegators, 1 );

        is( refaddr( $delegators[0]->attribute ), refaddr( $attribute ) );
        is( $delegators[0]->name, $attribute_name . '_delegator' );
        is( $delegators[0]->code, My::Class::A->can( $attribute_name . '_delegator' ) );

    }

    for my $attribute_name (
        map( { "attribute_$_" } ( 20 ) ),
        map( { "static_attribute_$_" } ( 20 ) )
    ) {

        my $attribute = $meta->attribute( $attribute_name );

        my @delegators = $attribute->delegators;
        is( scalar @delegators, 2 );

        is( refaddr( $delegators[0]->attribute ), refaddr( $attribute ) );
        is( $delegators[0]->name, $attribute_name . '_delegator_1' );
        is( $delegators[0]->code, My::Class::A->can( $attribute_name . '_delegator_1' ) );

        is( refaddr( $delegators[1]->attribute ), refaddr( $attribute ) );
        is( $delegators[1]->name, $attribute_name . '_delegator_2' );
        is( $delegators[1]->code, My::Class::A->can( $attribute_name . '_delegator_2' ) );

    }

}

