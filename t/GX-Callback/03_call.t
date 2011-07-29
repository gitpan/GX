#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Callback;


use Test::More tests => 6;


# call( ... )
{

    my $callback = GX::Callback->new( sub { @_ } );

    is_deeply( [ $callback->call ], [] );
    is_deeply( [ $callback->call( 1 ) ], [ 1 ] );
    is_deeply( [ $callback->call( 1 .. 3 ) ], [ 1 .. 3 ] );

}

# call( ... ), code => $code, arguments => \@arguments
{

    my $code      = sub { @_ };
    my @arguments = ( 1 .. 3 );

    my $callback = GX::Callback->new(
        code      => $code,
        arguments => [ @arguments ]
    );

    is_deeply( [ $callback->call ],           [ @arguments ] );
    is_deeply( [ $callback->call( 4 ) ],      [ @arguments, 4 ] );
    is_deeply( [ $callback->call( 4 .. 6 ) ], [ @arguments, 4 .. 6 ] );

}

