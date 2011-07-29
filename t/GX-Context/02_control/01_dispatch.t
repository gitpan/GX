#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 19;


require_ok( 'MyApp' );


# dispatch( $action )
{

    my $context = _fake_context();
    my $action  = MyApp::Controller::A->instance->action( 'action_1' );

    ok( $context->dispatch( $action ) );

    is_deeply( [ $context->action_queue->all ], [ $action ] );

}

# dispatch( $action_name )
{

    my $context = _fake_context();

    my $callback = sub {
        ok( $_[0]->dispatch( 'action_2' ) );
        is_deeply( [ $_[0]->action_queue->all ], [ MyApp::Controller::A->instance->action( 'action_2' ) ] );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}}, $callback;

    $context->request->path( '/a/action_1' );

    MyApp->instance->process( $context );

}

# dispatch( action => $action )
{

    my $context = _fake_context();
    my $action  = MyApp::Controller::A->instance->action( 'action_1' );

    ok( $context->dispatch( action => $action ) );

    is_deeply( [ $context->action_queue->all ], [ $action ] );

}

# dispatch( action => $action_name )
{

    my $context = _fake_context();

    my $callback = sub {
        ok( $_[0]->dispatch( action => 'action_2' ) );
        is_deeply( [ $_[0]->action_queue->all ], [ MyApp::Controller::A->instance->action( 'action_2' ) ] );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}}, $callback;

    $context->request->path( '/a/action_1' );

    MyApp->instance->process( $context );

}

# dispatch( controller => $controller, action => $action_name )
{

    my $context = _fake_context();
    my $action  = MyApp::Controller::A->instance->action( 'action_1' );

    ok( $context->dispatch( controller => MyApp::Controller::A->instance, action => 'action_1' ) );

    is_deeply( [ $context->action_queue->all ], [ $action ] );

}

# dispatch( controller => $controller_name, action => $action_name )
{

    my $context = _fake_context();
    my $action  = MyApp::Controller::A->instance->action( 'action_1' );

    ok( $context->dispatch( controller => 'A', action => 'action_1' ) );

    is_deeply( [ $context->action_queue->all ], [ $action ] );

}

# dispatch( controller => $controller_class, action => $action_name )
{

    my $context = _fake_context();
    my $action  = MyApp::Controller::A->instance->action( 'action_1' );

    ok( $context->dispatch( controller => 'MyApp::Controller::A', action => 'action_1' ) );

    is_deeply( [ $context->action_queue->all ], [ $action ] );

}

# non-empty action queue
{

    my $context = _fake_context();
    my @actions = map { MyApp::Controller::A->instance->action( $_ ) } qw ( action_1 action_2 action_3 );

    ok( $context->dispatch( $_ ) ) for @actions;

    is_deeply( [ $context->action_queue->all ], \@actions );

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

