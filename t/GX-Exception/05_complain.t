#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


# ==================================================================================================
# DO NOT MOVE THIS SECTION
# ==================================================================================================

package My::Package::A;

sub complain_1 {

    my $package  = shift;
    my $complain_at = shift;

    GX::Exception->complain( "$package\::complain_1" ) if $complain_at == 1;

    $package->complain_2( $complain_at );

    return;

}

sub complain_2 {

    my $package  = shift;
    my $complain_at = shift;

    GX::Exception->complain( "$package\::complain_2" ) if $complain_at == 2;

    $package->complain_3( $complain_at );

    return;

}

sub complain_3 {

    my $package  = shift;
    my $complain_at = shift;

    GX::Exception->complain( "$package\::complain_3" ) if $complain_at == 3;

    return;

}


package My::Package::B;

sub complain_1 {

    my $package  = shift;
    my $complain_at = shift;

    if ( $complain_at == 1 ) {
        my $exception = GX::Exception->new( "$package\::complain_1" );
        $exception->complain;
    }

    $package->complain_2( $complain_at );

    return;

}

sub complain_2 {

    my $package  = shift;
    my $complain_at = shift;

    if ( $complain_at == 2 ) {
        my $exception = GX::Exception->new( "$package\::complain_2" );
        $exception->complain;
    }

    $package->complain_3( $complain_at );

    return;

}

sub complain_3 {

    my $package  = shift;
    my $complain_at = shift;

    if ( $complain_at == 3 ) {
        my $exception = GX::Exception->new( "$package\::complain_3" );
        $exception->complain;
    }

    return;

}


package My::Package::C;

use GX::Exception;

sub complain_1 {

    my $package  = shift;
    my $complain_at = shift;

    if ( $complain_at == 1 ) {
        complain "$package\::complain_1";
    }

    $package->complain_2( $complain_at );

    return;

}

sub complain_2 {

    my $package  = shift;
    my $complain_at = shift;

    if ( $complain_at == 2 ) {
        complain "$package\::complain_2";
    }

    $package->complain_3( $complain_at );

    return;

}

sub complain_3 {

    my $package  = shift;
    my $complain_at = shift;

    if ( $complain_at == 3 ) {
        complain "$package\::complain_3";
    }

    return;

}


package My::Package::D;

use GX::Exception;

sub complain_1 {

    my $package  = shift;
    my $complain_at = shift;

    if ( $complain_at == 1 ) {
        complain GX::Exception->new( "$package\::complain_1" );
    }

    $package->complain_2( $complain_at );

    return;

}

sub complain_2 {

    my $package  = shift;
    my $complain_at = shift;

    if ( $complain_at == 2 ) {
        complain GX::Exception->new( "$package\::complain_2" );
    }

    $package->complain_3( $complain_at );

    return;

}

sub complain_3 {

    my $package  = shift;
    my $complain_at = shift;

    if ( $complain_at == 3 ) {
        complain GX::Exception->new( "$package\::complain_3" );
    }

    return;

}


# ==================================================================================================
# END OF SECTION
# ==================================================================================================


package main;

require GX::Exception;


use Test::More tests => 81;


# My::Package::A

{

    eval { My::Package::A->complain_1( 1 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::A::complain_1' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 2 );

    is( $stack_trace->[0]->filename, $0 );
    ok( $stack_trace->[0]->line );
    is( $stack_trace->[0]->subroutine, 'My::Package::A::complain_1' );

    is( $stack_trace->[1]->filename, $0 );
    ok( $stack_trace->[1]->line );
    is( $stack_trace->[1]->subroutine, '(eval)' );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

{

    eval { My::Package::A->complain_1( 2 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::A::complain_2' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 3 );

    is( $stack_trace->[0]->filename, $0 );
    is( $stack_trace->[0]->line, 20 );
    is( $stack_trace->[0]->subroutine, 'My::Package::A::complain_2' );

    is( $stack_trace->[1]->filename, $0 );
    ok( $stack_trace->[1]->line );
    is( $stack_trace->[1]->subroutine, 'My::Package::A::complain_1' );

    is( $stack_trace->[2]->filename, $0 );
    ok( $stack_trace->[2]->line );
    is( $stack_trace->[2]->subroutine, '(eval)' );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

{

    eval { My::Package::A->complain_1( 3 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::A::complain_3' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 4 );

    is( $stack_trace->[0]->filename, $0 );
    is( $stack_trace->[0]->line, 33 );
    is( $stack_trace->[0]->subroutine, 'My::Package::A::complain_3' );

    is( $stack_trace->[1]->filename, $0 );
    is( $stack_trace->[1]->line, 20 );
    is( $stack_trace->[1]->subroutine, 'My::Package::A::complain_2' );

    is( $stack_trace->[2]->filename, $0 );
    ok( $stack_trace->[2]->line );
    is( $stack_trace->[2]->subroutine, 'My::Package::A::complain_1' );

    is( $stack_trace->[3]->filename, $0 );
    ok( $stack_trace->[3]->line );
    is( $stack_trace->[3]->subroutine, '(eval)' );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

# My::Package::B

{

    eval { My::Package::B->complain_1( 3 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::B::complain_3' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 4 );

    is( $stack_trace->[0]->filename, $0 );
    is( $stack_trace->[0]->line, 79 );
    is( $stack_trace->[0]->subroutine, 'My::Package::B::complain_3' );

    is( $stack_trace->[1]->filename, $0 );
    is( $stack_trace->[1]->line, 63 );
    is( $stack_trace->[1]->subroutine, 'My::Package::B::complain_2' );

    is( $stack_trace->[2]->filename, $0 );
    ok( $stack_trace->[2]->line );
    is( $stack_trace->[2]->subroutine, 'My::Package::B::complain_1' );

    is( $stack_trace->[3]->filename, $0 );
    ok( $stack_trace->[3]->line );
    is( $stack_trace->[3]->subroutine, '(eval)' );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

# My::Package::C

{

    eval { My::Package::C->complain_1( 3 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::C::complain_3' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 4 );

    is( $stack_trace->[0]->filename, $0 );
    is( $stack_trace->[0]->line, 128 );
    is( $stack_trace->[0]->subroutine, 'My::Package::C::complain_3' );

    is( $stack_trace->[1]->filename, $0 );
    is( $stack_trace->[1]->line, 113 );
    is( $stack_trace->[1]->subroutine, 'My::Package::C::complain_2' );

    is( $stack_trace->[2]->filename, $0 );
    ok( $stack_trace->[2]->line );
    is( $stack_trace->[2]->subroutine, 'My::Package::C::complain_1' );

    is( $stack_trace->[3]->filename, $0 );
    ok( $stack_trace->[3]->line );
    is( $stack_trace->[3]->subroutine, '(eval)' );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

# My::Package::D

{

    eval { My::Package::D->complain_1( 3 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::D::complain_3' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 4 );

    is( $stack_trace->[0]->filename, $0 );
    is( $stack_trace->[0]->line, 176 );
    is( $stack_trace->[0]->subroutine, 'My::Package::D::complain_3' );

    is( $stack_trace->[1]->filename, $0 );
    is( $stack_trace->[1]->line, 161 );
    is( $stack_trace->[1]->subroutine, 'My::Package::D::complain_2' );

    is( $stack_trace->[2]->filename, $0 );
    ok( $stack_trace->[2]->line );
    is( $stack_trace->[2]->subroutine, 'My::Package::D::complain_1' );

    is( $stack_trace->[3]->filename, $0 );
    ok( $stack_trace->[3]->line );
    is( $stack_trace->[3]->subroutine, '(eval)' );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

