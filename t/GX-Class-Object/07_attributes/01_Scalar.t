#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;
{

    use GX::Class::Object;

    our $SCALAR_11_DEFAULT_VALUE     = \'scalar_11 default';
    our $SCALAR_12_INITIALIZER_VALUE = \'scalar_12 My::Class::A initializer';
    our $SCALAR_13_INITIALIZER_VALUE = \'scalar_13 My::Class::A initializer';

    has 'scalar_1';

    has 'scalar_2' => (
        isa => 'Scalar'
    );

    has 'scalar_3' => (
        isa     => 'Scalar',
        default => 'scalar_3 default'
    );

    has 'scalar_4' => (
        isa         => 'Scalar',
        initializer => sub { 'scalar_4 initializer' }
    );

    has 'scalar_5' => (
        isa         => 'Scalar',
        initializer => 'scalar_5_initializer'
    );

    has 'scalar_6' => (
        isa        => 'Scalar',
        initialize => 1
    );

    has 'scalar_7' => (
        isa        => 'Scalar',
        default    => 'scalar_7 default',
        initialize => 1
    );

    has 'scalar_8' => (
        isa         => 'Scalar',
        initializer => sub { 'scalar_8 initializer' },
        initialize  => 1
    );

    has 'scalar_9' => (
        isa         => 'Scalar',
        initializer => 'scalar_9_initializer',
        initialize  => 1
    );

    has 'scalar_10' => (
        isa        => 'Scalar',
        initialize => 1,
        weaken     => 1
    );

    has 'scalar_11' => (
        isa        => 'Scalar',
        default    => $SCALAR_11_DEFAULT_VALUE,
        initialize => 1,
        weaken     => 1
    );

    has 'scalar_12' => (
        isa         => 'Scalar',
        initializer => sub { $SCALAR_12_INITIALIZER_VALUE },
        initialize  => 1,
        weaken      => 1
    );

    has 'scalar_13' => (
        isa         => 'Scalar',
        initializer => 'scalar_13_initializer',
        initialize  => 1,
        weaken      => 1
    );


    sub scalar_5_initializer  { 'scalar_5 My::Class::A initializer' }
    sub scalar_9_initializer  { 'scalar_9 My::Class::A initializer' }
    sub scalar_13_initializer { $SCALAR_13_INITIALIZER_VALUE }

}


package main;

use Scalar::Util qw( isweak );


use Test::More tests => 18 * 2;


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
                'scalar_6'  => undef,
                'scalar_7'  => 'scalar_7 default',
                'scalar_8'  => 'scalar_8 initializer',
                'scalar_9'  => 'scalar_9 My::Class::A initializer',
                'scalar_10' => undef,
                'scalar_11' => $My::Class::A::SCALAR_11_DEFAULT_VALUE,
                'scalar_12' => $My::Class::A::SCALAR_12_INITIALIZER_VALUE,
                'scalar_13' => $My::Class::A::SCALAR_13_INITIALIZER_VALUE,
            }
        );

        ok( isweak( $object->{'scalar_11'} ) );
        ok( isweak( $object->{'scalar_12'} ) );
        ok( isweak( $object->{'scalar_13'} ) );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data )
    {

        my %data = map { ( "scalar_$_" => "value $_" ) } 1 .. 13;

        my $object = My::Class::A->new(
            %data,
            'scalar_x' => 'value x'
        );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, \%data );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data ), weaken references
    {

        my $value_10 = \'scalar_10 value';
        my $value_11 = \'scalar_11 value';
        my $value_12 = \'scalar_12 value';
        my $value_13 = \'scalar_13 value';

        my $object = My::Class::A->new(
            'scalar_10' => $value_10,
            'scalar_11' => $value_11,
            'scalar_12' => $value_12,
            'scalar_13' => $value_13
        );

        isa_ok( $object, 'My::Class::A' );

        is( $object->{'scalar_10'}, $value_10 );
        is( $object->{'scalar_11'}, $value_11 );
        is( $object->{'scalar_12'}, $value_12 );
        is( $object->{'scalar_13'}, $value_13 );

        ok( isweak( $object->{'scalar_10'} ) );
        ok( isweak( $object->{'scalar_11'} ) );
        ok( isweak( $object->{'scalar_12'} ) );
        ok( isweak( $object->{'scalar_13'} ) );

    }

}

