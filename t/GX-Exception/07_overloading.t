#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


# ==================================================================================================
# DO NOT MOVE THIS SECTION
# ==================================================================================================

package My::Package::A;

sub throw_1 {

    my $package  = shift;
    my $throw_at = shift;

    GX::Exception->throw( "$package\::throw_1" ) if $throw_at == 1;

    $package->throw_2( $throw_at );

    return;

}

sub throw_2 {

    my $package  = shift;
    my $throw_at = shift;

    GX::Exception->throw( "$package\::throw_2" ) if $throw_at == 2;

    $package->throw_3( $throw_at );

    return;

}

sub throw_3 {

    my $package  = shift;
    my $throw_at = shift;

    GX::Exception->throw( "$package\::throw_3" ) if $throw_at == 3;

    return;

}


package main;

require GX::Exception;


use Test::More tests => 4;


{

    eval { My::Package::A->throw_1( 3 ) };

    my $exception = $@;

    is(
        "$exception",
        "My::Package::A::throw_3 at $0 line 44.\n"
    );

    $exception->verbosity( 0 );

    is(
        "$exception",
        "My::Package::A::throw_3 at $0 line 44.\n"
    );

    $exception->verbosity( 2 );

    is(
        "$exception",
        "My::Package::A::throw_3 at $0 line 44.\n" .
        "[1] My::Package::A::throw_3 called at $0 line 33\n" .
        "[2] My::Package::A::throw_2 called at $0 line 20\n" .
        "[3] My::Package::A::throw_1 called at $0 line 61\n" .
        "[4] (eval) at $0 line 61\n"
    );

    $exception->verbosity( 3 );

    is(
        "$exception",
        "My::Package::A::throw_3 at $0 line 44.\n" .
        "[1] My::Package::A::throw_3 called at $0 line 33\n" .
        "[2] My::Package::A::throw_2 called at $0 line 20\n" .
        "[3] My::Package::A::throw_1 called at $0 line 61\n" .
        "[4] (eval) at $0 line 61\n"
    );

}

# ==================================================================================================
# END OF SECTION
# ==================================================================================================

