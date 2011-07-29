#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;
{

    use GX::Class::Object;

    has 'string_1' => (
        isa => 'String'
    );

    has 'string_2' => (
        isa     => 'String',
        default => 'string_2 default'
    );

    has 'string_3' => (
        isa         => 'String',
        initializer => sub { 'string_3 initializer' }
    );

    has 'string_4' => (
        isa         => 'String',
        initializer => 'string_4_initializer'
    );

    has 'string_5' => (
        isa        => 'String',
        initialize => 1
    );

    has 'string_6' => (
        isa        => 'String',
        default    => 'string_6 default',
        initialize => 1
    );

    has 'string_7' => (
        isa         => 'String',
        initializer => sub { 'string_7 initializer' },
        initialize  => 1
    );

    has 'string_8' => (
        isa         => 'String',
        initializer => 'string_8_initializer',
        initialize  => 1
    );


    sub string_4_initializer { 'string_4 My::Class::A initializer' }
    sub string_8_initializer { 'string_8 My::Class::A initializer' }

}


package main;


use Test::More tests => 12 * 2;


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
                'string_5'  => '',
                'string_6'  => 'string_6 default',
                'string_7'  => 'string_7 initializer',
                'string_8'  => 'string_8 My::Class::A initializer',
            }
        );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data )
    {

        my %data = map { ( "string_$_" => "value $_" ) } 1 .. 8;

        my $object = My::Class::A->new(
            %data,
            'string_x' => 'value x'
        );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, \%data );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data ), invalid data
    {

        local $@;

        for my $value ( undef, \'reference' ) {
            eval { my $object = My::Class::A->new( 'string_1' => $value ) };
            isa_ok( $@, 'GX::Exception' );
            is( $@->stack_trace->[0]->filename, $0 );
            is( $@->stack_trace->[0]->line, __LINE__ - 3 );
        }

    }

}

