#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Callback::Hook;


use Test::More tests => 9;


# new()
{

    my $hook = GX::Callback::Hook->new;

    isa_ok( $hook, 'GX::Callback::Hook' );

    is( $hook->name, '' );
    is_deeply( [ $hook->all ], [] );

}

# new( $name )
{

    my $hook = GX::Callback::Hook->new( 'hook_1' );

    isa_ok( $hook, 'GX::Callback::Hook' );

    is( $hook->name, 'hook_1' );
    is_deeply( [ $hook->all ], [] );

}

# new( name => $name )
{

    my $hook = GX::Callback::Hook->new( name => 'hook_1' );

    isa_ok( $hook, 'GX::Callback::Hook' );

    is( $hook->name, 'hook_1' );
    is_deeply( [ $hook->all ], [] );

}

