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
use Scalar::Util qw( weaken );


use Test::More tests => 16;


# new( invocant => $class )
{

    my $callback = GX::Callback::Method->new(
        invocant => 'My::Class',
        method   => 'method_1'
    );

    isa_ok( $callback, 'GX::Callback::Method' );

    is( $callback->invocant, 'My::Class' );
    is( $callback->method, 'method_1' );
    is( $callback->code, My::Class->can( 'method_1' ) );
    is_deeply( [ $callback->arguments ], [] );

}

# new( invocant => $object )
{

    my $object = My::Class->new;

    my $callback = GX::Callback::Method->new(
        invocant => $object,
        method   => 'method_1'
    );

    isa_ok( $callback, 'GX::Callback::Method' );

    is( $callback->invocant, $object );
    is( $callback->method, 'method_1' );
    is( $callback->code, My::Class->can( 'method_1' ) );
    is_deeply( [ $callback->arguments ], [] );

    weaken $object;

    ok( ! defined $object );

}

# new( invocant => $class, arguments => \@arguments )
{

    my @arguments = ( 1 .. 3 );

    my $callback = GX::Callback::Method->new(
        invocant  => 'My::Class',
        method    => 'method_1',
        arguments => [ @arguments ]
    );

    isa_ok( $callback, 'GX::Callback::Method' );

    is( $callback->invocant, 'My::Class' );
    is( $callback->method, 'method_1' );
    is( $callback->code, My::Class->can( 'method_1' ) );
    is_deeply( [ $callback->arguments ], \@arguments );

}

