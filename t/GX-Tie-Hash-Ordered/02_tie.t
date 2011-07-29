#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Tie::Hash::Ordered;
use List::Util qw( shuffle );


use Test::More tests => 82;


# tie()
{

    isa_ok( tie( my %hash, 'GX::Tie::Hash::Ordered' ), 'GX::Tie::Hash::Ordered' );

    is( scalar %hash, 0 );
    is_deeply( [ keys %hash ], [] );
    is_deeply( [ values %hash ], [] );

    my @names = shuffle( 0 .. 9 );

    %hash = map { ( "k_$_" => "v_$_" ) } @names;

    is( scalar %hash, 10 );
    is_deeply( [ keys %hash ], [ map { "k_$_" } @names ] );
    is_deeply( [ values %hash ], [ map { "v_$_" } @names ] );

}

# store, fetch, exists(), delete()
{

    tie my %hash, 'GX::Tie::Hash::Ordered';

    my @names = shuffle( 0 .. 9 );

    for ( @names ) {
        ok( ! exists $hash{"k_$_"} );
        $hash{"k_$_"} = "v_$_";
        ok( exists $hash{"k_$_"} );
        is( $hash{"k_$_"}, "v_$_" );
    }

    is( scalar %hash, 10 );
    is_deeply( [ keys %hash ], [ map { "k_$_" } @names ] );
    is_deeply( [ values %hash ], [ map { "v_$_" } @names ] );

    for ( @names ) {
        is( delete( $hash{"k_$_"} ), "v_$_" );
        ok( ! exists $hash{"k_$_"} );
        is( $hash{"k_$_"}, undef );
    }

    is( scalar %hash, 0 );
    is_deeply( [ keys %hash ], [] );
    is_deeply( [ values %hash ], [] );

}

# clear
{

    tie my %hash, 'GX::Tie::Hash::Ordered';

    my @names = shuffle( 0 .. 9 );

    %hash = map { ( "k_$_" => "v_$_" ) } @names;

    %hash = ();

    is( scalar %hash, 0 );
    is_deeply( [ keys %hash ], [] );
    is_deeply( [ values %hash ], [] );

    my @keys;
    my @values;

    while ( my ( $k, $v ) = each %hash ) {
        push @keys, $k;
        push @values, $v;
    }

    is_deeply( \@keys, [] );
    is_deeply( \@values, [] );

}

# each()
{

    tie my %hash, 'GX::Tie::Hash::Ordered';

    my @names = shuffle( 0 .. 9 );

    %hash = map { ( "k_$_" => "v_$_" ) } @names;

    my @keys;
    my @values;

    while ( my ( $k, $v ) = each %hash ) {
        push @keys, $k;
        push @values, $v;
    }

    is_deeply( \@keys, [ map { "k_$_" } @names ] );
    is_deeply( \@values, [ map { "v_$_" } @names ] );

}

# each(), empty hash
{

    tie my %hash, 'GX::Tie::Hash::Ordered';

    my @keys;
    my @values;

    while ( my ( $k, $v ) = each %hash ) {
        push @keys, $k;
        push @values, $v;
    }

    is_deeply( \@keys, [] );
    is_deeply( \@values, [] );

}

