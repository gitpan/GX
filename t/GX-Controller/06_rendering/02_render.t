#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Scalar::Util qw( refaddr );

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 62;


require_ok( 'MyApp' );

my $MyApp        = MyApp->instance;
my $Controller_B = $MyApp->controller( 'B' );
my $View_C       = $MyApp->view( 'C' );


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::B
# ----------------------------------------------------------------------------------------------------------------------

# action_1
{

    my $renderer = $Controller_B->renderer( 'action_1' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, {} );
    }

}

# action_2
{

    my $renderer = $Controller_B->renderer( 'action_2' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, {} );
    }

}

# action_3
{

    my $renderer = $Controller_B->renderer( 'action_3' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, {} );
    }

}

# action_4
{

    my $renderer = $Controller_B->renderer( 'action_4' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { 'k1' => 'v1' } );
    }

}

# action_5
{

    my $renderer = $Controller_B->renderer( 'action_5' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { 'k1' => 'v1', 'k2' => 'v2' } );
    }

}

# action_6
{

    my $renderer = $Controller_B->renderer( 'action_6' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { 'k1' => 'v1', 'k2' => 'v2', 'k3' => 'v3' } );
    }

}

# action_7
{

    my $renderer = $Controller_B->renderer( 'action_7' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->code, \&MyApp::Controller::B::action_7_render_code );
        is_deeply( { $handler->arguments }, {} );
    }

}

# action_8
{

    my $renderer = $Controller_B->renderer( 'action_8' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->code, \&MyApp::Controller::B::action_8_render_code );
        is_deeply( { $handler->arguments }, {} );
    }

}

# action_9
{

    my $renderer = $Controller_B->renderer( 'action_9' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $Controller_B );
        is( $handler->method, 'action_9_render_method' );
        is_deeply( { $handler->arguments }, {} );
    }

}

# action_10
{

    my $renderer = $Controller_B->renderer( 'action_10' );

    {
        no warnings 'once';
        is( refaddr( $renderer ), refaddr( $MyApp::Controller::B::Action_10_renderer ) );
    }

}

# action_11
{

    my $renderer = $Controller_B->renderer( 'action_11' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort map { "format_$_" } 1 .. 9  ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, {} );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, {} );
    }

    {
        my $handler = $renderer->handler( 'format_3' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, {} );
    }

    {
        my $handler = $renderer->handler( 'format_4' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { 'k1' => 'v1' } );
    }

    {
        my $handler = $renderer->handler( 'format_5' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { 'k1' => 'v1', 'k2' => 'v2' } );
    }

    {
        my $handler = $renderer->handler( 'format_6' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { 'k1' => 'v1', 'k2' => 'v2', 'k3' => 'v3' } );
    }

    {
        my $handler = $renderer->handler( 'format_7' );
        is( $handler->code, \&MyApp::Controller::B::action_11_format_7_render_code );
        is_deeply( { $handler->arguments }, {} );
    }

    {
        my $handler = $renderer->handler( 'format_8' );
        is( $handler->code, \&MyApp::Controller::B::action_11_format_8_render_code );
        is_deeply( { $handler->arguments }, {} );
    }

    {
        my $handler = $renderer->handler( 'format_9' );
        is( $handler->invocant, $Controller_B );
        is( $handler->method, 'action_11_format_9_render_method' );
        is_deeply( { $handler->arguments }, {} );
    }

}

