#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Callback;
use GX::Callback::Hook;
use GX::Callback::Hook::Queue;


use Test::More tests => 206;


my @Callbacks = map { GX::Callback->new( code => sub { $_ } ) } ( 0 .. 5 );

my @Hooks = map { GX::Callback::Hook->new( name => $_ ) } ( 0 .. 2 );
$Hooks[0]->add( $Callbacks[0] );
$Hooks[1]->add( $Callbacks[$_] ) for 1 .. 2;
$Hooks[2]->add( $Callbacks[$_] ) for 3 .. 5;


# current(), current_hook(), next() - empty queue
{

    my $queue = GX::Callback::Hook::Queue->new;

    is( $queue->next,         undef );
    is( $queue->current,      undef );
    is( $queue->current_hook, undef );

}

# add() callbacks, current(), next()
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( $_ ) for @Callbacks;

    is( $queue->current,      undef );
    is( $queue->current_hook, undef );

    for my $i ( 0 .. 5 ) {
        is( $queue->next,    $Callbacks[$i] );
        is( $queue->current, $Callbacks[$i] );
    }

    is( $queue->next,         undef         );
    is( $queue->current,      $Callbacks[5] );
    is( $queue->current_hook, undef         );

}

# add() hooks, current(), current_hook(), next()
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( $_ ) for @Hooks;

    is( $queue->current,      undef );
    is( $queue->current_hook, undef );

    for my $i ( 0 ) {
        is( $queue->next,         $Callbacks[$i] );
        is( $queue->current,      $Callbacks[$i] );
        is( $queue->current_hook, $Hooks[0]      );
    }

    for my $i ( 1 .. 2 ) {
        is( $queue->next,         $Callbacks[$i] );
        is( $queue->current,      $Callbacks[$i] );
        is( $queue->current_hook, $Hooks[1]      );
    }

    for my $i ( 3 .. 5 ) {
        is( $queue->next,         $Callbacks[$i] );
        is( $queue->current,      $Callbacks[$i] );
        is( $queue->current_hook, $Hooks[2]      );
    }

    is( $queue->next,         undef         );
    is( $queue->current,      $Callbacks[5] );
    is( $queue->current_hook, $Hooks[2]     );

}

# Empty / non-empty hooks
{

    my $queue = GX::Callback::Hook::Queue->new;

    my @callbacks = map { GX::Callback->new( code => sub { $_ } ) } ( 0 .. 5 );

    my @hooks = map { GX::Callback::Hook->new( name => $_ ) } ( 0 .. 6 );
    $hooks[1]->add( $callbacks[0] );
    $hooks[3]->add( $callbacks[$_] ) for 1 .. 2;
    $hooks[5]->add( $callbacks[$_] ) for 3 .. 5;

    $queue->add( $_ ) for @hooks;

    is( $queue->current,      undef );
    is( $queue->current_hook, undef );

    for my $i ( 0 .. 5 ) {
        is( $queue->next,    $callbacks[$i] );
        is( $queue->current, $callbacks[$i] );
    }

    is( $queue->next,         undef         );
    is( $queue->current,      $callbacks[5] );
    is( $queue->current_hook, $hooks[5]     );

}

# Only empty hooks
{

    my $queue = GX::Callback::Hook::Queue->new;

    my @hooks = map { GX::Callback::Hook->new( name => $_ ) } ( 0 .. 2 );

    $queue->add( $_ ) for @hooks;

    is( $queue->current,      undef );
    is( $queue->current_hook, undef );

    is( $queue->next,         undef );

    is( $queue->current,      undef );
    is( $queue->current_hook, undef );

}

# remove() hook
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( @Hooks );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks ]
    );

    is( $queue->remove( $Hooks[1] ), 2 );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks[ 0, 3 .. 5 ] ]
    );

    is( $queue->remove( $Hooks[2] ), 3 );

    is_deeply(
        [ $queue->all ],
        [ $Callbacks[0] ]
    );

    is( $queue->remove( $Hooks[0] ), 1 );

    is_deeply(
        [ $queue->all ],
        []
    );

    is( $queue->remove( $Hooks[$_] ), 0 ) for 0 .. 2;

}

# remove() hook name
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( @Hooks );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks ]
    );

    is( $queue->remove( $Hooks[1]->name ), 2 );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks[ 0, 3 .. 5 ] ]
    );

    is( $queue->remove( $Hooks[2]->name ), 3 );

    is_deeply(
        [ $queue->all ],
        [ $Callbacks[0] ]
    );

    is( $queue->remove( $Hooks[0]->name ), 1 );

    is_deeply(
        [ $queue->all ],
        []
    );

    is( $queue->remove( $Hooks[$_]->name ), 0 ) for 0 .. 2;

}

# remove() callback
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( @Hooks );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks ]
    );

    my @callbacks = @Callbacks;

    while ( my $callback = shift @callbacks ) {

        is( $queue->remove( $callback ), 1 );

        is_deeply( [ $queue->all ], \@callbacks );

    }

}

# remove() - empty queue
{

    my $queue = GX::Callback::Hook::Queue->new;

    is( $queue->remove( $Hooks[0] ), 0 );

    is( $queue->remove( $Callbacks[0] ), 0 );

}

# remove_all()
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( @Hooks );

    $queue->next;

    $queue->remove_all;

    is_deeply( [ $queue->all ], [] );

    is( $queue->current,      $Callbacks[0] );
    is( $queue->current_hook, $Hooks[0]    );

    is( $queue->next, undef );

}

# remove_all() - empty queue
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->remove_all;

    is_deeply( [ $queue->all ], [] );

    is( $queue->current,      undef );
    is( $queue->current_hook, undef );

    is( $queue->next, undef );

}

# replace_all()
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( @Hooks );

    $queue->next;

    $queue->replace_all;

    is_deeply( [ $queue->all ], [] );

    is( $queue->current,      $Callbacks[0] );
    is( $queue->current_hook, $Hooks[0]    );

    is( $queue->next, undef );

}

# replace_all( $handler )
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( @Hooks );

    $queue->next;

    $queue->replace_all( $Callbacks[1] );

    is_deeply( [ $queue->all ], [ $Callbacks[1] ] );

    is( $queue->current,      $Callbacks[0] );
    is( $queue->current_hook, $Hooks[0]    );

    is( $queue->next, $Callbacks[1] );

}

# skip_to() hook
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( @Hooks );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks ]
    );

    ok( $queue->skip_to( $Hooks[0] ) );
    ok( $queue->skip_to( $Hooks[0] ) );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks ]
    );

    ok( $queue->skip_to( $Hooks[1] ) );
    ok( $queue->skip_to( $Hooks[1] ) );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks[ 1 .. 5 ] ]
    );

    ok( $queue->skip_to( $Hooks[2] ) );
    ok( $queue->skip_to( $Hooks[2] ) );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks[ 3 .. 5 ] ]
    );

    ok( ! $queue->skip_to( $Hooks[0] ) );
    ok( ! $queue->skip_to( $Hooks[1] ) );

    is( $queue->current,      undef );
    is( $queue->current_hook, undef );

}

# skip_to() hook name
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( @Hooks );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks ]
    );

    ok( $queue->skip_to( $Hooks[0]->name ) );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks ]
    );

    ok( $queue->skip_to( $Hooks[1]->name ) );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks[ 1 .. 5 ] ]
    );

    ok( $queue->skip_to( $Hooks[2]->name ) );

    is_deeply(
        [ $queue->all ],
        [ @Callbacks[ 3 .. 5 ] ]
    );

    ok( ! $queue->skip_to( $Hooks[0]->name ) );
    ok( ! $queue->skip_to( $Hooks[1]->name ) );

    is( $queue->current,      undef );
    is( $queue->current_hook, undef );

}

# skip_to() callback
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( @Hooks );

    is_deeply( [ $queue->all ], \@Callbacks );

    my @callbacks = @Callbacks;

    while ( @callbacks ) {

        my $callback = $callbacks[0];

        ok( $queue->skip_to( $callback ) );
        ok( $queue->skip_to( $callback ) );

        is_deeply( [ $queue->all ], \@callbacks );

        is( $queue->current,      undef );
        is( $queue->current_hook, undef );

        shift @callbacks;

    }

}

# skip_to() and next()
{

    my $queue = GX::Callback::Hook::Queue->new;

    my @callbacks = map { GX::Callback->new( code => sub { $_ } ) } ( 0 .. 11 );

    my @hooks = map { GX::Callback::Hook->new( name => $_ ) } ( 0 .. 4 );
    $hooks[0]->add( $callbacks[$_] ) for 0 .. 2;
    $hooks[1]->add( $callbacks[$_] ) for 3 .. 5;
    $hooks[2]->add( $callbacks[$_] ) for 6 .. 8;
    $hooks[3]->add( $callbacks[$_] ) for 9 .. 11;

    $queue->add( @hooks );

    is( $queue->current,      undef );
    is( $queue->current_hook, undef );

    is( $queue->next, $callbacks[0] );

    ok( ! $queue->skip_to( $hooks[0] ) );

    ok( $queue->skip_to( $hooks[1] ) );

    is( $queue->current,      $callbacks[0] );
    is( $queue->current_hook, $hooks[0]     );

    is( $queue->next, $callbacks[3] );

    is( $queue->current,      $callbacks[3] );
    is( $queue->current_hook, $hooks[1]     );

    is( $queue->next, $callbacks[4] );

    ok( $queue->skip_to( $hooks[2] ) );

    is( $queue->current,      $callbacks[4] );
    is( $queue->current_hook, $hooks[1]     );

    is( $queue->next, $callbacks[6] );

    is( $queue->current,      $callbacks[6] );
    is( $queue->current_hook, $hooks[2]     );

    is( $queue->next, $callbacks[7] );

    is( $queue->current,      $callbacks[7] );
    is( $queue->current_hook, $hooks[2]     );

    is( $queue->next, $callbacks[8] );

    ok( $queue->skip_to( $hooks[3] ) );

    is( $queue->current,      $callbacks[8] );
    is( $queue->current_hook, $hooks[2]     );

    is( $queue->next, $callbacks[9] );

    ok( $queue->skip_to( $hooks[4] ) );

    is( $queue->current,      $callbacks[9] );
    is( $queue->current_hook, $hooks[3]     );

    is( $queue->next, undef );

    is( $queue->current,      $callbacks[9] );
    is( $queue->current_hook, $hooks[3]     );

}

# skip_to(), empty queue
{

    my $queue = GX::Callback::Hook::Queue->new;

    ok( ! $queue->skip_to( 'hook_x' ) );

}

# skip_to(), nonexistent hook
{

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( @Hooks );

    ok( ! $queue->skip_to( 'hook_x' ) );

    is_deeply( [ $queue->all ], \@Callbacks );

}

