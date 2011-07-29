#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;
{

    use GX::Class::Object;

    our $HASH_10_DEFAULT_VALUE     = { 'key_10' => \'hash_11 default' };
    our $HASH_11_INITIALIZER_VALUE = { 'key_11' => \'hash_12 My::Class::A initializer' };
    our $HASH_12_INITIALIZER_VALUE = { 'key_12' => \'hash_13 My::Class::A initializer' };

    has 'hash_1' => (
        isa => 'Hash'
    );

    has 'hash_2' => (
        isa     => 'Hash',
        default => { 'key_2' => 'hash_2 default' }
    );

    has 'hash_3' => (
        isa         => 'Hash',
        initializer => sub { { 'key_3' => 'hash_3 initializer' } }
    );

    has 'hash_4' => (
        isa         => 'Hash',
        initializer => 'hash_4_initializer'
    );

    has 'hash_5' => (
        isa        => 'Hash',
        initialize => 1
    );

    has 'hash_6' => (
        isa        => 'Hash',
        default    => { 'key_6' => 'hash_6 default' },
        initialize => 1
    );

    has 'hash_7' => (
        isa         => 'Hash',
        initializer => sub { { 'key_7' => 'hash_7 initializer' } },
        initialize  => 1
    );

    has 'hash_8' => (
        isa         => 'Hash',
        initializer => 'hash_8_initializer',
        initialize  => 1
    );

    has 'hash_9' => (
        isa        => 'Hash',
        initialize => 1,
        weaken     => 1
    );

    has 'hash_10' => (
        isa        => 'Hash',
        default    => $HASH_10_DEFAULT_VALUE,
        initialize => 1,
        weaken     => 1
    );

    has 'hash_11' => (
        isa         => 'Hash',
        initializer => sub { $HASH_11_INITIALIZER_VALUE },
        initialize  => 1,
        weaken      => 1
    );

    has 'hash_12' => (
        isa         => 'Hash',
        initializer => 'hash_12_initializer',
        initialize  => 1,
        weaken      => 1
    );


    sub hash_4_initializer  { { 'key_4' => 'hash_4 My::Class::A initializer' } }
    sub hash_8_initializer  { { 'key_8' => 'hash_8 My::Class::A initializer' } }
    sub hash_12_initializer { $HASH_12_INITIALIZER_VALUE }

}


package main;

use Scalar::Util qw( isweak );


use Test::More tests => 36 * 2;


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
                'hash_5'  => {},
                'hash_6'  => { 'key_6' => 'hash_6 default' },
                'hash_7'  => { 'key_7' => 'hash_7 initializer' },
                'hash_8'  => { 'key_8' => 'hash_8 My::Class::A initializer' },
                'hash_9'  => {},
                'hash_10' => $My::Class::A::HASH_10_DEFAULT_VALUE,
                'hash_11' => $My::Class::A::HASH_11_INITIALIZER_VALUE,
                'hash_12' => $My::Class::A::HASH_12_INITIALIZER_VALUE
            }
        );

        ok( defined $object->{'hash_10'}{'key_10'} );
        ok( defined $object->{'hash_11'}{'key_11'} );
        ok( defined $object->{'hash_12'}{'key_12'} );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data )
    {

        my %data = map { ( "hash_$_" => { "key_$_" => "value $_" } ) } 1 .. 12;

        my $object = My::Class::A->new(
            %data,
            'hash_x' => { 'key_x' => 'value x' }
        );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, \%data );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data ), empty hashs
    {

        my %data = map { ( "hash_$_" => {} ) } 1 .. 12;

        my $object = My::Class::A->new(
            %data,
            'hash_x' => { 'key_x' => 'value x' }
        );

        isa_ok( $object, 'My::Class::A' );

        is_deeply( $object, \%data );

        $object->clear;

        is_deeply( $object, {} );

    }

    # My::Class::A, new( %data ), invalid data
    {

        local $@;

        for my $value ( undef, '', \'reference', [] ) {
            eval { my $object = My::Class::A->new( 'hash_1' => $value ) };
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

        my $value_9  = {};
        my $value_10 = { 'key_1' => $ref_1 };
        my $value_11 = { 'key_1' => $ref_1, 'key_2' => $ref_2 };
        my $value_12 = { 'key_1' => $ref_1, 'key_2' => $ref_2, 'key_3' => $ref_3 };

        my $object = My::Class::A->new(
            'hash_9'  => $value_9,
            'hash_10' => $value_10,
            'hash_11' => $value_11,
            'hash_12' => $value_12
        );

        isa_ok( $object, 'My::Class::A' );

        is( $object->{'hash_9'},  $value_9  );
        is( $object->{'hash_10'}, $value_10 );
        is( $object->{'hash_11'}, $value_11 );
        is( $object->{'hash_12'}, $value_12 );

        ok( isweak( $object->{'hash_10'}{'key_1'} ) );
        ok( isweak( $object->{'hash_11'}{'key_1'} ) );
        ok( isweak( $object->{'hash_11'}{'key_2'} ) );
        ok( isweak( $object->{'hash_12'}{'key_1'} ) );
        ok( isweak( $object->{'hash_12'}{'key_2'} ) );
        ok( isweak( $object->{'hash_12'}{'key_3'} ) );

    }

}

