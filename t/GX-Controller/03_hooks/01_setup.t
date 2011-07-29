#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 13;


require_ok( 'MyApp' );

my $MyApp        = MyApp->instance;
my $Controller_A = $MyApp->controller( 'A' );


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A
# ----------------------------------------------------------------------------------------------------------------------

# hooks()
{

    my @hooks = $Controller_A->filter_hooks;

    is( scalar @hooks, 3 );

    for my $hook ( @hooks ) {
        isa_ok( $hook, 'GX::Callback::Hook' );
    }

    is_deeply(
        [ sort map { $_->name } @hooks ],
        [ sort qw( Before Render After ) ]
    );

}

# pre_dispatch_hooks()
{

    my @hooks = $Controller_A->pre_dispatch_filter_hooks;

    is( scalar @hooks, 1 );

    for my $hook ( @hooks ) {
        isa_ok( $hook, 'GX::Callback::Hook' );
    }

    is_deeply(
        [ map { $_->name } @hooks ],
        [ qw( Before ) ]
    );

}

# post_dispatch_hooks()
{

    my @hooks = $Controller_A->post_dispatch_filter_hooks;

    is( scalar @hooks, 2 );

    for my $hook ( @hooks ) {
        isa_ok( $hook, 'GX::Callback::Hook' );
    }

    is_deeply(
        [ map { $_->name } @hooks ],
        [ qw( Render After ) ]
    );

}

