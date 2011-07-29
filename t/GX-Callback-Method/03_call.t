#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class;
{

    sub new { bless {}, __PACKAGE__; }

    sub method_1 { __PACKAGE__, 'method_1', @_ }

}


package main;

use GX::Callback::Method;


use Test::More tests => 9;


# call( ... ), invocant => $class
{


    my $callback = GX::Callback::Method->new(
        invocant => 'My::Class',
        method   => 'method_1'
    );

    is_deeply( [ $callback->call ],           [ 'My::Class', 'method_1', 'My::Class' ] );
    is_deeply( [ $callback->call( 1 ) ],      [ 'My::Class', 'method_1', 'My::Class', 1 ] );
    is_deeply( [ $callback->call( 1 .. 3 ) ], [ 'My::Class', 'method_1', 'My::Class', 1 .. 3 ] );

}

# call( ... ), invocant => $object
{

    my $object = My::Class->new;

    my $callback = GX::Callback::Method->new(
        invocant => $object,
        method   => 'method_1'
    );

    is_deeply( [ $callback->call ],           [ 'My::Class', 'method_1', $object ] );
    is_deeply( [ $callback->call( 1 ) ],      [ 'My::Class', 'method_1', $object, 1 ] );
    is_deeply( [ $callback->call( 1 .. 3 ) ], [ 'My::Class', 'method_1', $object, 1 .. 3 ] );

}

# call( ... ), invocant => $class, arguments => \@arguments
{

    my @arguments = ( 1 .. 3 );

    my $callback = GX::Callback::Method->new(
        invocant  => 'My::Class',
        method    => 'method_1',
        arguments => [ @arguments ]
    );

    is_deeply( [ $callback->call ],           [ 'My::Class', 'method_1', 'My::Class', @arguments ] );
    is_deeply( [ $callback->call( 4 ) ],      [ 'My::Class', 'method_1', 'My::Class', @arguments, 4 ] );
    is_deeply( [ $callback->call( 4 .. 6 ) ], [ 'My::Class', 'method_1', 'My::Class', @arguments, 4 .. 6 ] );

}

