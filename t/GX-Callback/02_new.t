#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Callback;


use Test::More tests => 9;


# new( $code )
{

    my $code = sub {};

    my $callback = GX::Callback->new( $code );

    isa_ok( $callback, 'GX::Callback' );

    is( $callback->code, $code );
    is_deeply( [ $callback->arguments ], [] );

}

# new( code => $code )
{

    my $code = sub {};

    my $callback = GX::Callback->new( code => $code );

    isa_ok( $callback, 'GX::Callback' );

    is( $callback->code, $code );
    is_deeply( [ $callback->arguments ], [] );

}

# new( code => $code, arguments => \@arguments )
{

    my $code      = sub {};
    my @arguments = ( 1 .. 3 );

    my $callback = GX::Callback->new(
        code      => $code,
        arguments => [ @arguments ]
    );

    isa_ok( $callback, 'GX::Callback' );

    is( $callback->code, $code );
    is_deeply( [ $callback->arguments ], \@arguments );

}

