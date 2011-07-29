#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Callback;
use GX::Callback::Hook;


use Test::More tests => 2;


# "$hook"
{

    my $hook = GX::Callback::Hook->new( 'hook_1' );

    is( "$hook", 'hook_1' );

}

# @$hook
{

    my $hook = GX::Callback::Hook->new;

    my @callbacks = map { GX::Callback->new( code => sub { $_ } ) } 0 .. 2;

    $hook->add( $_ ) for @callbacks;

    is_deeply( [ @$hook ], [ @callbacks[ 0 .. 2 ] ] );

}

