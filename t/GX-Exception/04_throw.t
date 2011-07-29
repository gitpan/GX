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


package My::Package::B;

sub throw_1 {

    my $package  = shift;
    my $throw_at = shift;

    if ( $throw_at == 1 ) {
        my $exception = GX::Exception->new( "$package\::throw_1" );
        $exception->throw;
    }

    $package->throw_2( $throw_at );

    return;

}

sub throw_2 {

    my $package  = shift;
    my $throw_at = shift;

    if ( $throw_at == 2 ) {
        my $exception = GX::Exception->new( "$package\::throw_2" );
        $exception->throw;
    }

    $package->throw_3( $throw_at );

    return;

}

sub throw_3 {

    my $package  = shift;
    my $throw_at = shift;

    if ( $throw_at == 3 ) {
        my $exception = GX::Exception->new( "$package\::throw_3" );
        $exception->throw;
    }

    return;

}


package My::Package::C;

use GX::Exception;

sub throw_1 {

    my $package  = shift;
    my $throw_at = shift;

    if ( $throw_at == 1 ) {
        throw "$package\::throw_1";
    }

    $package->throw_2( $throw_at );

    return;

}

sub throw_2 {

    my $package  = shift;
    my $throw_at = shift;

    if ( $throw_at == 2 ) {
        throw "$package\::throw_2";
    }

    $package->throw_3( $throw_at );

    return;

}

sub throw_3 {

    my $package  = shift;
    my $throw_at = shift;

    if ( $throw_at == 3 ) {
        throw "$package\::throw_3";
    }

    return;

}


package My::Package::D;

use GX::Exception;

sub throw_1 {

    my $package  = shift;
    my $throw_at = shift;

    if ( $throw_at == 1 ) {
        throw GX::Exception->new( "$package\::throw_1" );
    }

    $package->throw_2( $throw_at );

    return;

}

sub throw_2 {

    my $package  = shift;
    my $throw_at = shift;

    if ( $throw_at == 2 ) {
        throw GX::Exception->new( "$package\::throw_2" );
    }

    $package->throw_3( $throw_at );

    return;

}

sub throw_3 {

    my $package  = shift;
    my $throw_at = shift;

    if ( $throw_at == 3 ) {
        throw GX::Exception->new( "$package\::throw_3" );
    }

    return;

}


# ==================================================================================================
# END OF SECTION
# ==================================================================================================


package main;

require GX::Exception;


use Test::More tests => 99;


# My::Package::A

{

    eval { My::Package::A->throw_1( 1 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::A::throw_1' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 3 );

    is( $stack_trace->[0]->filename, $0 );
    is( $stack_trace->[0]->line, 18 );
    is( $stack_trace->[0]->subroutine, 'GX::Exception::throw' );

    is( $stack_trace->[1]->filename, $0 );
    ok( $stack_trace->[1]->line );
    is( $stack_trace->[1]->subroutine, 'My::Package::A::throw_1' );

    is( $stack_trace->[2]->filename, $0 );
    ok( $stack_trace->[2]->line );
    is( $stack_trace->[2]->subroutine, '(eval)' );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

{

    eval { My::Package::A->throw_1( 2 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::A::throw_2' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 4 );

    is( $stack_trace->[0]->filename, $0 );
    is( $stack_trace->[0]->line, 31 );
    is( $stack_trace->[0]->subroutine, 'GX::Exception::throw' );

    is( $stack_trace->[1]->filename, $0 );
    is( $stack_trace->[1]->line, 20 );
    is( $stack_trace->[1]->subroutine, 'My::Package::A::throw_2' );

    is( $stack_trace->[2]->filename, $0 );
    ok( $stack_trace->[2]->line );
    is( $stack_trace->[2]->subroutine, 'My::Package::A::throw_1' );

    is( $stack_trace->[3]->filename, $0 );
    ok( $stack_trace->[3]->line );
    is( $stack_trace->[3]->subroutine, '(eval)' );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

{

    eval { My::Package::A->throw_1( 3 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::A::throw_3' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 5 );

    is( $stack_trace->[0]->filename, $0 );
    is( $stack_trace->[0]->line, 44 );
    is( $stack_trace->[0]->subroutine, 'GX::Exception::throw' );

    is( $stack_trace->[1]->filename, $0 );
    is( $stack_trace->[1]->line, 33 );
    is( $stack_trace->[1]->subroutine, 'My::Package::A::throw_3' );

    is( $stack_trace->[2]->filename, $0 );
    is( $stack_trace->[2]->line, 20 );
    is( $stack_trace->[2]->subroutine, 'My::Package::A::throw_2' );

    is( $stack_trace->[3]->filename, $0 );
    ok( $stack_trace->[3]->line );
    is( $stack_trace->[3]->subroutine, 'My::Package::A::throw_1' );

    is( $stack_trace->[4]->filename, $0 );
    ok( $stack_trace->[4]->line );
    is( $stack_trace->[4]->subroutine, '(eval)' );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

# My::Package::B

{

    eval { My::Package::B->throw_1( 3 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::B::throw_3' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 5 );

    is( $stack_trace->[0]->filename, $0 );
    is( $stack_trace->[0]->line, 92 );
    is( $stack_trace->[0]->subroutine, 'GX::Exception::throw' );

    is( $stack_trace->[1]->filename, $0 );
    is( $stack_trace->[1]->line, 79 );
    is( $stack_trace->[1]->subroutine, 'My::Package::B::throw_3' );

    is( $stack_trace->[2]->filename, $0 );
    is( $stack_trace->[2]->line, 63 );
    is( $stack_trace->[2]->subroutine, 'My::Package::B::throw_2' );

    is( $stack_trace->[3]->filename, $0 );
    ok( $stack_trace->[3]->line );
    is( $stack_trace->[3]->subroutine, 'My::Package::B::throw_1' );

    is( $stack_trace->[4]->filename, $0 );
    ok( $stack_trace->[4]->line );
    is( $stack_trace->[4]->subroutine, '(eval)' );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

# My::Package::C

{

    eval { My::Package::C->throw_1( 3 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::C::throw_3' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 5 );

    is( $stack_trace->[0]->filename, $0 );
    is( $stack_trace->[0]->line, 139 );
    is( $stack_trace->[0]->subroutine, 'GX::Exception::throw' );

    is( $stack_trace->[1]->filename, $0 );
    is( $stack_trace->[1]->line, 128 );
    is( $stack_trace->[1]->subroutine, 'My::Package::C::throw_3' );

    is( $stack_trace->[2]->filename, $0 );
    is( $stack_trace->[2]->line, 113 );
    is( $stack_trace->[2]->subroutine, 'My::Package::C::throw_2' );

    is( $stack_trace->[3]->filename, $0 );
    ok( $stack_trace->[3]->line );
    is( $stack_trace->[3]->subroutine, 'My::Package::C::throw_1' );

    is( $stack_trace->[4]->filename, $0 );
    ok( $stack_trace->[4]->line );
    is( $stack_trace->[4]->subroutine, '(eval)' );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

# My::Package::D

{

    eval { My::Package::D->throw_1( 3 ) };

    my $exception = $@;

    isa_ok( $exception, 'GX::Exception' );

    is( $exception->message, 'My::Package::D::throw_3' );

    my $stack_trace = $exception->stack_trace;

    is( @$stack_trace, 5 );

    is( $stack_trace->[0]->filename, $0 );
    is( $stack_trace->[0]->line, 187 );
    is( $stack_trace->[0]->subroutine, 'GX::Exception::throw' );

    is( $stack_trace->[1]->filename, $0 );
    is( $stack_trace->[1]->line, 176 );
    is( $stack_trace->[1]->subroutine, 'My::Package::D::throw_3' );

    is( $stack_trace->[2]->filename, $0 );
    is( $stack_trace->[2]->line, 161 );
    is( $stack_trace->[2]->subroutine, 'My::Package::D::throw_2' );

    is( $stack_trace->[3]->filename, $0 );
    ok( $stack_trace->[3]->line );
    is( $stack_trace->[3]->subroutine, 'My::Package::D::throw_1' );

    is( $stack_trace->[4]->filename, $0 );
    ok( $stack_trace->[4]->line );
    is( $stack_trace->[4]->subroutine, '(eval)' );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $stack_trace );

#     print STDERR scalar $exception->as_string( verbosity => 2 );

}

