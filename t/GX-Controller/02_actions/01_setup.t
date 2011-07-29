#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 61;


require_ok( 'MyApp' );

my $MyApp          = MyApp->instance;
my $Controller_A   = $MyApp->controller( 'A' );
my $Controller_A_A = $MyApp->controller( 'A::A' );
my $Controller_A_B = $MyApp->controller( 'A::B' );
my $Controller_A_C = $MyApp->controller( 'A::C' );


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A
# ----------------------------------------------------------------------------------------------------------------------

# action()
{

    for my $action_name ( qw( action_1 action_2 action_3 ) ) {

        my $action = $Controller_A->action( $action_name );

        isa_ok( $action, 'GX::Action' );

        is( $action->controller, $Controller_A );
        is( $action->name, $action_name );

    }

}

# actions()
{

    my @actions = $Controller_A->actions;

    is( scalar @actions, 3 );

    for my $action ( @actions ) {
        is( $action, $Controller_A->action( $action->name ) );
    }

}


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A::A
# ----------------------------------------------------------------------------------------------------------------------

# action()
{

    for my $action_name ( qw( action_3 action_4 action_5 ) ) {

        my $action = $Controller_A_A->action( $action_name );

        isa_ok( $action, 'GX::Action' );

        is( $action->controller, $Controller_A_A );
        is( $action->name, $action_name );

    }

}

# actions()
{

    my @actions = $Controller_A_A->actions;

    is( scalar @actions, 3 );

    for my $action ( @actions ) {
        is( $action, $Controller_A_A->action( $action->name ) );
    }

}


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A::B - extends A
# ----------------------------------------------------------------------------------------------------------------------

# action()
{

    for my $action_name ( qw( action_1 action_2 action_3 action_4 action_5 ) ) {

        my $action = $Controller_A_B->action( $action_name );

        isa_ok( $action, 'GX::Action' );

        is( $action->controller, $Controller_A_B );
        is( $action->name, $action_name );

    }

}

# actions()
{

    my @actions = $Controller_A_B->actions;

    is( scalar @actions, 5 );

    for my $action ( @actions ) {
        is( $action, $Controller_A_B->action( $action->name ) );
    }

}


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A::C - extends A, inherit_actions => 0
# ----------------------------------------------------------------------------------------------------------------------

# action()
{

    for my $action_name ( qw( action_3 action_4 action_5 ) ) {

        my $action = $Controller_A_C->action( $action_name );

        isa_ok( $action, 'GX::Action' );

        is( $action->controller, $Controller_A_C );
        is( $action->name, $action_name );

    }

}

# actions()
{

    my @actions = $Controller_A_C->actions;

    is( scalar @actions, 3 );

    for my $action ( @actions ) {
        is( $action, $Controller_A_C->action( $action->name ) );
    }

}

