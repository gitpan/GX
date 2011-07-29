#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Callback;
use GX::Callback::Queue;


use Test::More tests => 93;


my @Callbacks = map { GX::Callback->new( code => sub { $_ } ) } ( 0 .. 5 );


# new(), all()
{

    my $queue = GX::Callback::Queue->new;

    isa_ok( $queue, 'GX::Callback::Queue' );
    is_deeply( [ $queue->all ], [] );

}

# clone(), empty queue
{

    my $queue = GX::Callback::Queue->new;

    my $clone = $queue->clone;

    isa_ok( $clone, 'GX::Callback::Queue' );
    is_deeply( [ $clone->all ], [ $queue->all ] );

}

# clone(), non-empty queue
{

    my $queue = GX::Callback::Queue->new;

    $queue->add( @Callbacks );

    my $clone = $queue->clone;

    isa_ok( $clone, 'GX::Callback::Queue' );
    is_deeply( [ $clone->all ], [ $queue->all ] );

}

# clone(), after next()
{

    my $queue = GX::Callback::Queue->new;

    $queue->add( @Callbacks );

    $queue->next;

    my $clone = $queue->clone;

    isa_ok( $clone, 'GX::Callback::Queue' );
    is_deeply( [ $clone->all ], [ $queue->all ] );
    is( $clone->current, $queue->current );
    is( $clone->next, $queue->next );

}

# add()
{

    my $queue = GX::Callback::Queue->new;

    for ( 0 .. 2 ) {
        $queue->add( $Callbacks[$_] );
        is_deeply( [ $queue->all ], [ @Callbacks[ 0 .. $_ ] ] );
    }

    $queue->add( @Callbacks[ 3 .. 4 ] );

    is_deeply( [ $queue->all ], [ @Callbacks[ 0 .. 4 ] ] );

}

# next(), current()
{

    my $queue = GX::Callback::Queue->new;

    for ( 0 .. 1 ) {
        is( $queue->next,    undef );
        is( $queue->current, undef );
    }

    $queue->add( @Callbacks[ 0 .. 1 ] );

    is( $queue->next,    $Callbacks[0] );
    is( $queue->current, $Callbacks[0] );

    is( $queue->next,    $Callbacks[1] );
    is( $queue->current, $Callbacks[1] );

    for ( 0 .. 1 ) {
        is( $queue->next,    undef );
        is( $queue->current, $Callbacks[1] );
    }

    $queue->add( $Callbacks[2] );

    is( $queue->next,    $Callbacks[2] );
    is( $queue->current, $Callbacks[2] );

    for ( 0 .. 1 ) {
        is( $queue->next,    undef );
        is( $queue->current, $Callbacks[2] );
    }

    $queue->add( @Callbacks[ 3 .. 4 ] );

    is( $queue->next,    $Callbacks[3] );
    is( $queue->current, $Callbacks[3] );

    is( $queue->next,    $Callbacks[4] );
    is( $queue->current, $Callbacks[4] );

    for ( 0 .. 1 ) {
        is( $queue->next,    undef );
        is( $queue->current, $Callbacks[4] );
    }

}

# clear(), empty queue
{

    my $queue = GX::Callback::Queue->new;

    $queue->clear;

    is_deeply( [ $queue->all ], [] );
    is( $queue->current, undef );
    is( $queue->next, undef );

}

# clear(), non-empty queue
{

    my $queue = GX::Callback::Queue->new;

    $queue->add( @Callbacks[ 0 .. 1 ] );

    $queue->clear;

    is_deeply( [ $queue->all ], [] );
    is( $queue->current, undef );
    is( $queue->next, undef );

}

# clear(), after next()
{

    my $queue = GX::Callback::Queue->new;

    $queue->add( @Callbacks[ 0 .. 1 ] );

    $queue->next;

    $queue->clear;

    is_deeply( [ $queue->all ], [] );
    is( $queue->current, undef );
    is( $queue->next, undef );

}

# remove(), non-empty queue
{

    my $queue = GX::Callback::Queue->new;

    $queue->add( @Callbacks[ 0 .. 2 ] );

    for ( 0 .. 2 ) {
        is_deeply( [ $queue->all ], [ @Callbacks[ $_ .. 2 ] ] );
        ok( $queue->remove( $Callbacks[$_] ) );
    }

    is_deeply( [ $queue->all ], [] );

}

# remove(), after next()
{

    my $queue = GX::Callback::Queue->new;

    $queue->add( @Callbacks[ 0 .. 2 ] );

    $queue->next;

    is_deeply( [ $queue->all ], [ @Callbacks[ 1 .. 2 ] ] );

    for ( 1 .. 2 ) {
        is_deeply( [ $queue->all ], [ @Callbacks[ $_ .. 2 ] ] );
        ok( $queue->remove( $Callbacks[$_] ) );
    }

    is_deeply( [ $queue->all ], [] );
    is( $queue->current, $Callbacks[0] );
    is( $queue->next, undef );

}

# remove(), multiple callbacks
{

    my $queue = GX::Callback::Queue->new;

    $queue->add(
        @Callbacks[ 0 .. 2 ],
        @Callbacks[ 1 .. 2 ],
        $Callbacks[2]
    );

    is( $queue->remove( $Callbacks[0] ), 1 );

    is_deeply( [ $queue->all ], [ @Callbacks[ 1, 2, 1, 2, 2 ] ] );

    is( $queue->remove( $Callbacks[1] ), 2 );

    is_deeply( [ $queue->all ], [ @Callbacks[ 2, 2, 2 ] ] );

    is( $queue->remove( $Callbacks[2] ), 3 );

    is_deeply( [ $queue->all ], [] );


}

# remove_all(), empty queue
{

    my $queue = GX::Callback::Queue->new;

    $queue->remove_all;

    is_deeply( [ $queue->all ], [] );
    is( $queue->current, undef );
    is( $queue->next, undef );

}

# remove_all(), non-empty queue
{

    my $queue = GX::Callback::Queue->new;

    $queue->add( @Callbacks[ 0 .. 2 ] );

    $queue->remove_all;

    is_deeply( [ $queue->all ], [] );
    is( $queue->current, undef );
    is( $queue->next, undef );

}

# remove_all(), after next()
{

    my $queue = GX::Callback::Queue->new;

    $queue->add( @Callbacks[ 0 .. 2 ] );

    $queue->next;

    $queue->remove_all;

    is_deeply( [ $queue->all ], [] );
    is( $queue->current, $Callbacks[0] );
    is( $queue->next, undef );

    $queue->remove_all;

    is_deeply( [ $queue->all ], [] );
    is( $queue->current, $Callbacks[0] );
    is( $queue->next, undef );

}

# replace_all(), empty queue
{

    my $queue = GX::Callback::Queue->new;

    for ( 0 .. 2 ) {
        $queue->replace_all( @Callbacks[ 0 .. $_ ] );
        is_deeply( [ $queue->all ], [ @Callbacks[ 0 .. $_ ] ] );
    }

    is( $queue->current, undef );
    is( $queue->next, $Callbacks[0] );

}

# replace_all(), non-empty queue
{

    my $queue = GX::Callback::Queue->new;

    $queue->add( @Callbacks[ 0 .. 1 ] );

    $queue->replace_all( @Callbacks[ 2 .. 5 ] );

    is_deeply( [ $queue->all ], [ @Callbacks[ 2 .. 5 ] ] );
    is( $queue->current, undef );
    is( $queue->next, $Callbacks[2] );

}

# replace_all(), after next()
{

    my $queue = GX::Callback::Queue->new;

    $queue->add( @Callbacks[ 0 .. 1 ] );

    $queue->next;

    $queue->replace_all( @Callbacks[ 2 .. 5 ] );

    is_deeply( [ $queue->all ], [ @Callbacks[ 2 .. 5 ] ] );
    is( $queue->current, $Callbacks[0] );
    is( $queue->next, $Callbacks[2] );

}

