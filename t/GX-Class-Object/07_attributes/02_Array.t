#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;
{

    use GX::Class::Object;

    our $ARRAY_10_DEFAULT_VALUE     = [ \'array_11 default' ];
    our $ARRAY_11_INITIALIZER_VALUE = [ \'array_12 My::Class::A initializer' ];
    our $ARRAY_12_INITIALIZER_VALUE = [ \'array_13 My::Class::A initializer' ];

    has 'array_1' => (
        isa => 'Array'
    );

    has 'array_2' => (
        isa     => 'Array',
        default => [ 'array_2 default' ]
    );

    has 'array_3' => (
        isa         => 'Array',
        initializer => sub { [ 'array_3 initializer' ] }
    );

    has 'array_4' => (
        isa         => 'Array',
        initializer => 'array_4_initializer'
    );

    has 'array_5' => (
        isa        => 'Array',
        initialize => 1
    );

    has 'array_6' => (
        isa        => 'Array',
        default    => [ 'array_6 default' ],
        initialize => 1
    );

    has 'array_7' => (
        isa         => 'Array',
        initializer => sub { [ 'array_7 initializer' ] },
        initialize  => 1
    );

    has 'array_8' => (
        isa         => 'Array',
        initializer => 'array_8_initializer',
        initialize  => 1
    );

    has 'array_9' => (
        isa        => 'Array',
        initialize => 1,
        weaken     => 1
    );

    has 'array_10' => (
        isa        => 'Array',
        default    => $ARRAY_10_DEFAULT_VALUE,
        initialize => 1,
        weaken     => 1
    );

    has 'array_11' => (
        isa         => 'Array',
        initializer => sub { $ARRAY_11_INITIALIZER_VALUE },
        initialize  => 1,
        weaken      => 1
    );

    has 'array_12' => (
        isa         => 'Array',
        initializer => 'array_12_initializer',
        initialize  => 1,
        weaken      => 1
    );


    sub array_4_initializer  { [ 'array_4 My::Class::A initializer' ] }
    sub array_8_initializer  { [ 'array_8 My::Class::A initializer' ] }
    sub array_12_initializer { $ARRAY_12_INITIALIZER_VALUE }

}


package main;

use Scalar::Util qw( isweak );


use Test::More tests => 35 * 2;


{

    run_tests();

    eval "package My::Class::A; build; 1;" or die $@;

    run_tests();

}


sub run_tests {

    ok( 1 );
 
    # My::Class::A, new()
    {

        my $object = My::Class::A->new;

        isa_ok( $object, 'My::Class::A' );

        is_deeply(
            $object,
            {
                'array_5'  => [],
                'array_6'  => [ 'array_6 default' ],
                'array_7'  => [ 'array_7 initializer' ],
                'array_8'  => [ 'array_8 My::Class::A initializer' ],
                'array_9'  => [],
                'array_10' => $My::Class::A::ARRAY_10_DEFAULT_VALUE,
                'array_11' => $My::Class::A::ARRAY_11_INITIALIZER_VALUE,
                'array_12' => $My::Class::A::ARRAY_12_INITIALIZER_VALUE
            }
        );

        ok( defined $object->{'array_10'}[0] );
        ok( defined $object->{'array_11'}[0] );
        ok( defined $object->{'array_12'}[0] );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data )
    {

        my %data = map { ( "array_$_" => [ "value $_" ] ) } 1 .. 12;

        my $object = My::Class::A->new(
            %data,
            'array_x' => [ 'value x' ]
        );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, \%data );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data ), empty arrays
    {

        my %data = map { ( "array_$_" => [] ) } 1 .. 12;

        my $object = My::Class::A->new(
            %data,
            'array_x' => [ 'value x' ]
        );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, \%data );

    }

    # My::Class::A, new( %data ), invalid data
    {

        local $@;

        for my $value ( undef, '', \'reference', {} ) {
            eval { my $object = My::Class::A->new( 'array_1' => $value ) };
            isa_ok( $@, 'GX::Exception' );
            is( $@->stack_trace->[0]->filename, $0 );
            is( $@->stack_trace->[0]->line, __LINE__ - 3 );
        }

    }

    # My::Class::A, new( %data ), weaken references
    {

        my $ref_1 = \'ref_1';
        my $ref_2 = \'ref_2';
        my $ref_3 = \'ref_3';

        my $value_9  = [];
        my $value_10 = [ $ref_1 ];
        my $value_11 = [ $ref_1, $ref_2, ];
        my $value_12 = [ $ref_1, $ref_2, $ref_3 ];

        my $object = My::Class::A->new(
            'array_9'  => $value_9,
            'array_10' => $value_10,
            'array_11' => $value_11,
            'array_12' => $value_12
        );

        isa_ok( $object, 'My::Class::A' );

        is( $object->{'array_9'},  $value_9  );
        is( $object->{'array_10'}, $value_10 );
        is( $object->{'array_11'}, $value_11 );
        is( $object->{'array_12'}, $value_12 );

        ok( isweak( $object->{'array_10'}[0] ) );
        ok( isweak( $object->{'array_11'}[0] ) );
        ok( isweak( $object->{'array_11'}[1] ) );
        ok( isweak( $object->{'array_12'}[0] ) );
        ok( isweak( $object->{'array_12'}[1] ) );
        ok( isweak( $object->{'array_12'}[2] ) );

    }

}

