#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 109;


require_ok( 'MyApp' );

my $MyApp        = MyApp->instance;
my $Controller_D = $MyApp->controller( 'D' );
my $View_A       = $MyApp->view( 'A' );
my $View_C       = $MyApp->view( 'C' );


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::D
# ----------------------------------------------------------------------------------------------------------------------

# action_1
{

    my $renderer = $Controller_D->renderer( 'action_1' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort qw( format_1 format_2 format_3 * ) ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_1' } );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_2' } );
    }

    {
        my $handler = $renderer->handler( 'format_3' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_3' } );
    }

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_1', format => '*' } );
    }

}

# action_2
{

    my $renderer = $Controller_D->renderer( 'action_2' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort qw( format_1 format_2 format_3 ) ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_2', format => 'format_1' } );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_2' } );
    }

    {
        my $handler = $renderer->handler( 'format_3' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_3' } );
    }


}

# action_3
{

    my $renderer = $Controller_D->renderer( 'action_3' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort qw( format_1 format_2 format_3 ) ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_3', format => 'format_1' } );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_3', format => 'format_2' } );
    }

    {
        my $handler = $renderer->handler( 'format_3' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_3' } );
    }


}

# action_4
{

    my $renderer = $Controller_D->renderer( 'action_4' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort qw( format_1 format_2 format_3 ) ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_4', format => 'format_1' } );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_4', format => 'format_2' } );
    }

    {
        my $handler = $renderer->handler( 'format_3' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_4', format => 'format_3' } );
    }


}

# action_5
{

    my $renderer = $Controller_D->renderer( 'action_5' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort qw( format_1 format_2 format_3 format_4 ) ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_5', format => 'format_1' } );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_5', format => 'format_2' } );
    }

    {
        my $handler = $renderer->handler( 'format_3' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_5', format => 'format_3' } );
    }

    {
        my $handler = $renderer->handler( 'format_4' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_5', format => 'format_4' } );
    }

}

# action_6
{

    my $renderer = $Controller_D->renderer( 'action_6' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort qw( format_1 format_2 format_3 ) ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_1' } );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_2' } );
    }

    {
        my $handler = $renderer->handler( 'format_3' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_3' } );
    }

}

# action_7
{

    my $renderer = $Controller_D->renderer( 'action_7' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort qw( format_1 format_2 format_3 format_4 ) ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_1' } );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_2' } );
    }

    {
        my $handler = $renderer->handler( 'format_3' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_7', format => 'format_3' } );
    }

    {
        my $handler = $renderer->handler( 'format_4' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render', action => 'action_7', format => 'format_4' } );
    }

}

# action_8
{

    my $renderer = $Controller_D->renderer( 'action_8' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort qw( format_1 format_2 format_3 * ) ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_1' } );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_2' } );
    }

    {
        my $handler = $renderer->handler( 'format_3' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_3' } );
    }

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { template => 'D/action_8.aa' } );
    }

}

# action_9
{

    my $renderer = $Controller_D->renderer( 'action_9' );

    is_deeply(
        [ sort $renderer->formats ],
        [ sort qw( format_1 format_2 format_3 format_4 * ) ]
    );

    {
        my $handler = $renderer->handler( 'format_1' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_1' } );
    }

    {
        my $handler = $renderer->handler( 'format_2' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_2' } );
    }

    {
        my $handler = $renderer->handler( 'format_3' );
        is( $handler->invocant, $View_C );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { option => 'render_all', format => 'format_3' } );
    }

    {
        my $handler = $renderer->handler( 'format_4' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { template => 'D/action_9.format_4.aa' } );
    }

    {
        my $handler = $renderer->handler( '*' );
        is( $handler->invocant, $View_A );
        is( $handler->method, 'render' );
        is_deeply( { $handler->arguments }, { template => 'D/action_9.aa' } );
    }

}

