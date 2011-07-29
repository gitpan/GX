#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 54;


require_ok( 'MyApp' );

my $MyApp          = MyApp->instance;
my $Controller_A   = $MyApp->controller( 'A' );
my $Controller_A_A = $MyApp->controller( 'A::A' );
my $View_A         = $MyApp->view( 'A' );
my $View_B         = $MyApp->view( 'B' );


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A
# ----------------------------------------------------------------------------------------------------------------------

# action_1
{

    my $renderer = $Controller_A->renderer( 'action_1' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_1.aa' ] );
    }

}

# action_2
{

    my $renderer = $Controller_A->renderer( 'action_2' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort 'format_1' ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_2.format_1.aa' ] );
    }

}

# action_3
{

    my $renderer = $Controller_A->renderer( 'action_3' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*', 'format_1', 'format_2' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_3.aa' ] );
    }

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_3.format_1.aa' ] );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_3.format_2.aa' ] );
    }

}

# action_4
{

    my $renderer = $Controller_A->renderer( 'action_4' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_B );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_4.bb' ] );
    }

}

# action_5
{

    my $renderer = $Controller_A->renderer( 'action_5' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort 'format_1' ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_B );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_5.format_1.bb' ] );
    }

}

# action_6
{

    my $renderer = $Controller_A->renderer( 'action_6' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*', 'format_1', 'format_2' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_B );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_6.bb' ] );
    }

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_B );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_6.format_1.bb' ] );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_B );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_6.format_2.bb' ] );
    }

}

# action_7
{

    my $renderer = $Controller_A->renderer( 'action_7' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort 'format_1', 'format_2' ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_7.format_1.aa' ] );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_B );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/action_7.format_2.bb' ] );
    }

}


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A::A
# ----------------------------------------------------------------------------------------------------------------------

# action_1
{

    my $renderer = $Controller_A_A->renderer( 'action_1' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort '*', 'format_1', 'format_2' ]
    );

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/A/action_1.aa' ] );
    }

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/A/action_1.format_1.aa' ] );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( [ $handler->arguments ], [ template => 'A/A/action_1.format_2.aa' ] );
    }

}

