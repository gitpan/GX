#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Exception;


use Test::More tests => 21;


# try { ... }, scalar context #1
{

    my $result = try {
        return 42;
    };

    is( $result, 42 );

}

# try { ... }, scalar context #2
{

    my $result = try {
        my @array = ( 1 .. 3 );
        return @array;
    };

    is( $result, 3 );

}

# try { ... }, list context
{

    my @result = try {
        my @array = ( 1 .. 3 );
        return @array;
    };

    is_deeply( \@result, [ 1 .. 3 ] );

}

# try { ... }, die()
{

    try {
        die "Oops.\n";
    };

    is( $_[0], undef );
    is( $_, undef );
    is( $@, '' );

}

# try { ... } catch { ... }
{

    my $result = try {
        return 42;
    }
    catch {
        die "This should not happen!";
    };

    is( $result, 42 );
    is( $_[0], undef );
    is( $_, undef );
    is( $@, '' );

}

# try { ... } catch { ... }, die()
{

    my $result = try {
        die "Oops.\n";
    }
    catch {
        is( $_[0], "Oops.\n" );
        is( $_, "Oops.\n" );
        is( $@, '' );
        return 42;
    };

    is( $result, 42 );
    is( $_[0], undef );
    is( $_, undef );
    is( $@, '' );

}

# die() in catch { ... }
{

    eval {

        try {
            die "Oops.\n";
        }
        catch {
            is( $_[0], "Oops.\n" );
            is( $_, "Oops.\n" );
            is( $@, '' );
            die "Oh noes!\n";
        };

    };

    is( $@, "Oh noes!\n" );

}

