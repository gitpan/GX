#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;
{

    use GX::Class::Object;

    has 'bool_1' => (
        isa => 'Bool'
    );

    has 'bool_2' => (
        isa     => 'Bool',
        default => 1
    );

    has 'bool_3' => (
        isa         => 'Bool',
        initializer => sub { 1 }
    );

    has 'bool_4' => (
        isa         => 'Bool',
        initializer => 'bool_4_initializer'
    );

    has 'bool_5' => (
        isa        => 'Bool',
        initialize => 1
    );

    has 'bool_6' => (
        isa        => 'Bool',
        default    => 1,
        initialize => 1
    );

    has 'bool_7' => (
        isa         => 'Bool',
        initializer => sub { 1 },
        initialize  => 1
    );

    has 'bool_8' => (
        isa         => 'Bool',
        initializer => 'bool_8_initializer',
        initialize  => 1
    );


    sub bool_4_initializer { 1 }
    sub bool_8_initializer { 1 }

}


package main;


use Test::More tests => 14 * 2;


{

    run_tests();

    eval "package My::Class::A; build; 1;" or die $@;

    run_tests();

}


sub run_tests {

    # My::Class::A, new()
    {

        my $object = My::Class::A->new;

        isa_ok( $object, 'My::Class::A' );

        is_deeply(
            $object,
            {
                'bool_5'  => undef,
                'bool_6'  => 1,
                'bool_7'  => 1,
                'bool_8'  => 1,
            }
        );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data ), value: 1
    {

        my %data = map { ( "bool_$_" => 1 ) } 1 .. 8;

        my $object = My::Class::A->new(
            %data,
            'bool_x' => 'value x'
        );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, \%data );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data ), value: 0
    {

        my %data = map { ( "bool_$_" => 0 ) } 1 .. 8;

        my $object = My::Class::A->new( %data );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, \%data );

    }

    # My::Class::A, new( %data ), value: undef
    {

        my %data = map { ( "bool_$_" => undef ) } 1 .. 8;

        my $object = My::Class::A->new( %data );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, \%data );

    }

    # My::Class::A, new( %data ), value: 'true'
    {

        my %data = map { ( "bool_$_" => 'true' ) } 1 .. 8;

        my $object = My::Class::A->new( %data );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, { map { ( "bool_$_" => 1 ) } 1 .. 8 } );

    }

    # My::Class::A, new( %data ), value: ''
    {

        my %data = map { ( "bool_$_" => '' ) } 1 .. 8;

        my $object = My::Class::A->new( %data );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, { map { ( "bool_$_" => 0 ) } 1 .. 8 } );

    }

}

