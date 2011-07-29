#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Scalar::Util qw( refaddr );

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 14;


require_ok( 'MyApp' );

my $MyApp        = MyApp->instance;
my $Controller_C = $MyApp->controller( 'C' );
my $View_C       = $MyApp->view( 'C' );


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::C
# ----------------------------------------------------------------------------------------------------------------------

# action_1
{

    my $renderer = $Controller_C->renderer( 'action_1' );

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

    my $renderer = $Controller_C->renderer( 'action_2' );

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

    my $renderer = $Controller_C->renderer( 'action_3' );

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

# Distinct renderers
{

    my @renderers    = map { $Controller_C->renderer( "action_$_" ) } 1 .. 3;
    my %refaddresses = map { ( refaddr( $_ ) => 1 ) } @renderers;

    is( scalar( keys %refaddresses ), 3 );

}

