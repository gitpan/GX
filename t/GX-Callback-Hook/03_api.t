#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Callback;
use GX::Callback::Hook;


use Test::More tests => 47;


# add(), without priority
{

    my $hook = GX::Callback::Hook->new;

    my @callbacks = map { GX::Callback->new( code => sub { $_ } ) } 0 .. 9;

    for ( 0 .. 9 ) {
        $hook->add( $callbacks[$_] );
        is_deeply( [ $hook->all ], [ @callbacks[ 0 .. $_ ] ] );
    }

}

# add(), with decreasing priority
{

    my $hook = GX::Callback::Hook->new;

    my @callbacks = map { GX::Callback->new( code => sub { $_ } ) } 0 .. 9;

    for ( 0 .. 9 ) {
        $hook->add( $callbacks[$_], $_ );
        is_deeply( [ $hook->all ], [ @callbacks[ 0 .. $_ ] ] );
    }

}

# add(), with increasing priority
{

    my $hook = GX::Callback::Hook->new;

    my @callbacks = map { GX::Callback->new( code => sub { $_ } ) } 0 .. 9;

    for ( 0 .. 9 ) {
        my $priority = 9 - $_;
        $hook->add( $callbacks[$_], $priority );
        is_deeply( [ $hook->all ], [ reverse @callbacks[ 0 .. $_ ] ] );
    }

}

# add(), with identical priority
{

    my $hook = GX::Callback::Hook->new;

    my @callbacks_0 = map { GX::Callback->new( code => sub { $_ } ) } 0 .. 4;
    my @callbacks_1 = map { GX::Callback->new( code => sub { $_ } ) } 0 .. 4;
    my @callbacks_2 = map { GX::Callback->new( code => sub { $_ } ) } 0 .. 4;
    my @callbacks_3 = map { GX::Callback->new( code => sub { $_ } ) } 0 .. 4;
    my @callbacks_4 = map { GX::Callback->new( code => sub { $_ } ) } 0 .. 4;

    for ( 0 .. 4 ) {

        $hook->add( $callbacks_3[$_], 3 );
        $hook->add( $callbacks_4[$_], 4 );
        $hook->add( $callbacks_2[$_], 2 );
        $hook->add( $callbacks_0[$_], 0 );
        $hook->add( $callbacks_1[$_], 1 );

        is_deeply(
            [ $hook->all ],
            [
                @callbacks_0[ 0 .. $_ ],
                @callbacks_1[ 0 .. $_ ],
                @callbacks_2[ 0 .. $_ ],
                @callbacks_3[ 0 .. $_ ],
                @callbacks_4[ 0 .. $_ ],
            ]
        );

    }

}

# remove()
{

    my $hook = GX::Callback::Hook->new;

    my @callbacks = map { GX::Callback->new( code => sub { $_ } ) } 0 .. 4;

    $hook->add( $callbacks[$_] ) for 0 .. 4;

    for ( 0 .. 4 ) {
        is_deeply( [ $hook->all ], [ @callbacks[ $_ .. 4 ] ] );
        ok( $hook->remove( $callbacks[$_] ) );
    }

    is_deeply( [ $hook->all ], [] );

}

# remove_all()
{

    my $hook = GX::Callback::Hook->new;

    my @callbacks = map { GX::Callback->new( code => sub { $_ } ) } 0 .. 2;

    $hook->add( $callbacks[$_] ) for 0 .. 2;

    $hook->remove_all;

    is_deeply( [ $hook->all ], [] );

}

