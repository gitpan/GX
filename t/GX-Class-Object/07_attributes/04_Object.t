#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;
{

    use GX::Class::Object;

    our $OBJECT_10_DEFAULT_VALUE     = bless( do { \( my $scalar = 'object_10 default' ) }, 'My::Class' );
    our $OBJECT_11_INITIALIZER_VALUE = bless( do { \( my $scalar = 'object_11 My::Class::A initializer' ) }, 'My::Class' );
    our $OBJECT_12_INITIALIZER_VALUE = bless( do { \( my $scalar = 'object_12 My::Class::A initializer' ) }, 'My::Class' );

    has 'object_1' => (
        isa => 'Object'
    );

    has 'object_2' => (
        isa     => 'Object',
        default => bless( do { \( my $scalar = 'object_2 default' ) }, 'My::Class' )
    );

    has 'object_3' => (
        isa         => 'Object',
        initializer => sub { bless( do { \( my $scalar = 'object_3 My::Class::A initializer' ) }, 'My::Class' ) }
    );

    has 'object_4' => (
        isa         => 'Object',
        initializer => 'object_4_initializer'
    );

    has 'object_5' => (
        isa        => 'Object',
        initialize => 1
    );

    has 'object_6' => (
        isa        => 'Object',
        default    => bless( do { \( my $scalar = 'object_6 default' ) }, 'My::Class' ),
        initialize => 1
    );

    has 'object_7' => (
        isa         => 'Object',
        initializer => sub { bless( do { \( my $scalar = 'object_7 My::Class::A initializer' ) }, 'My::Class' ) },
        initialize  => 1
    );

    has 'object_8' => (
        isa         => 'Object',
        initializer => 'object_8_initializer',
        initialize  => 1
    );

    has 'object_9' => (
        isa        => 'Object',
        initialize => 1,
        weaken     => 1
    );

    has 'object_10' => (
        isa        => 'Object',
        default    => $OBJECT_10_DEFAULT_VALUE,
        initialize => 1,
        weaken     => 1
    );

    has 'object_11' => (
        isa         => 'Object',
        initializer => sub { $OBJECT_11_INITIALIZER_VALUE },
        initialize  => 1,
        weaken      => 1
    );

    has 'object_12' => (
        isa         => 'Object',
        initializer => 'object_12_initializer',
        initialize  => 1,
        weaken      => 1
    );


    sub object_4_initializer  { bless( do { \( my $scalar = 'object_4 My::Class::A initializer' ) }, 'My::Class' ) }
    sub object_8_initializer  { bless( do { \( my $scalar = 'object_8 My::Class::A initializer' ) }, 'My::Class' ) }
    sub object_12_initializer { $OBJECT_12_INITIALIZER_VALUE }

}


package main;

use Scalar::Util qw( isweak );


use Test::More tests => 33 * 2;


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
                'object_5'  => undef,
                'object_6'  => \'object_6 default',
                'object_7'  => \'object_7 My::Class::A initializer',
                'object_8'  => \'object_8 My::Class::A initializer',
                'object_9'  => undef,
                'object_10' => $My::Class::A::OBJECT_10_DEFAULT_VALUE,
                'object_11' => $My::Class::A::OBJECT_11_INITIALIZER_VALUE,
                'object_12' => $My::Class::A::OBJECT_12_INITIALIZER_VALUE,
            }
        );

        ok( isweak( $object->{'object_10'} ) );
        ok( isweak( $object->{'object_11'} ) );
        ok( isweak( $object->{'object_12'} ) );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data )
    {

        my %data = map { ( "object_$_" => bless( do { \( my $scalar = "object_$_" ) }, 'My::Class' ) ) } 1 .. 12;

        my $object = My::Class::A->new(
            %data,
            'object_x' => bless( do { \( my $scalar = 'object_x' ) }, 'My::Class' )
        );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, \%data );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data ), invalid data
    {

        local $@;

        for my $value ( undef, '', \'reference', [], {} ) {
            eval { my $object = My::Class::A->new( 'object_1' => $value ) };
            isa_ok( $@, 'GX::Exception' );
            is( $@->stack_trace->[0]->filename, $0 );
            is( $@->stack_trace->[0]->line, __LINE__ - 3 );
        }

    }

    # My::Class::A, new( %data ), weaken references
    {

        my $value_9  = bless( do { \( my $scalar = 'object_9'  ) }, 'My::Class' );
        my $value_10 = bless( do { \( my $scalar = 'object_10' ) }, 'My::Class' );
        my $value_11 = bless( do { \( my $scalar = 'object_11' ) }, 'My::Class' );
        my $value_12 = bless( do { \( my $scalar = 'object_12' ) }, 'My::Class' );

        my $object = My::Class::A->new(
            'object_9'  => $value_9,
            'object_10' => $value_10,
            'object_11' => $value_11,
            'object_12' => $value_12
        );

        isa_ok( $object, 'My::Class::A' );

        is( $object->{'object_9'},  $value_9  );
        is( $object->{'object_10'}, $value_10 );
        is( $object->{'object_11'}, $value_11 );
        is( $object->{'object_12'}, $value_12 );

        ok( isweak( $object->{'object_9'}  ) );
        ok( isweak( $object->{'object_10'} ) );
        ok( isweak( $object->{'object_11'} ) );
        ok( isweak( $object->{'object_12'} ) );

    }

}

