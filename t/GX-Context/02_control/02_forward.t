#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 15;


require_ok( 'MyApp' );


# forward( $action )
{

    my $context = _fake_context();
    my $action  = MyApp::Controller::A->instance->action( 'action_1' );

    ok( $context->forward( $action ) );

    is_deeply( [ $context->action_queue->all ], [ $action ] );

}

# forward( $action_name )
{

    my $context = _fake_context();

    my $callback = sub {
        ok( $_[0]->forward( 'action_2' ) );
        is_deeply( [ $_[0]->action_queue->all ], [ MyApp::Controller::A->instance->action( 'action_2' ) ] );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}}, $callback;

    $context->request->path( '/a/action_1' );

    MyApp->instance->process( $context );

}

# forward( action => $action )
{

    my $context = _fake_context();
    my $action  = MyApp::Controller::A->instance->action( 'action_1' );

    ok( $context->forward( action => $action ) );

    is_deeply( [ $context->action_queue->all ], [ $action ] );

}

# forward( action => $action_name )
{

    my $context = _fake_context();

    my $callback = sub {
        ok( $_[0]->forward( action => 'action_2' ) );
        is_deeply( [ $_[0]->action_queue->all ], [ MyApp::Controller::A->instance->action( 'action_2' ) ] );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}}, $callback;

    $context->request->path( '/a/action_1' );

    MyApp->instance->process( $context );

}

# forward( controller => $controller, action => $action_name )
{

    my $context = _fake_context();
    my $action  = MyApp::Controller::A->instance->action( 'action_1' );

    ok( $context->forward( controller => MyApp::Controller::A->instance, action => 'action_1' ) );

    is_deeply( [ $context->action_queue->all ], [ $action ] );

}

# forward( controller => $controller_name, action => $action_name )
{

    my $context = _fake_context();
    my $action  = MyApp::Controller::A->instance->action( 'action_1' );

    ok( $context->forward( controller => 'A', action => 'action_1' ) );

    is_deeply( [ $context->action_queue->all ], [ $action ] );

}

# forward( controller => $controller_class, action => $action_name )
{

    my $context = _fake_context();
    my $action  = MyApp::Controller::A->instance->action( 'action_1' );

    ok( $context->forward( controller => 'MyApp::Controller::A', action => 'action_1' ) );

    is_deeply( [ $context->action_queue->all ], [ $action ] );

}


# ----------------------------------------------------------------------------------------------------------------------

sub _fake_context {

    my $context = MyApp::Context->new(
        request  => MyApp::Request->new,
        response => MyApp::Response->new,
        @_
    );

    return $context;

}

