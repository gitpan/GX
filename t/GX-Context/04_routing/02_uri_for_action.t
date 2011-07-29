#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 20;


require_ok( 'MyApp' );

my $MyApp        = MyApp->instance;
my $Controller_A = $MyApp->controller( 'A' );


# current action
{

    for my $action_name ( qw( action_1 action_2 action_3 ) ) {

        my $context = _fake_context();
        $context->request->method( 'GET' );
        $context->request->scheme( 'http' );
        $context->request->host( 'localhost' );
        $context->request->path( "/a/$action_name" );

        my $callback = sub {
            is(
                $_[0]->uri_for_action,
                "http://localhost/a/$action_name"
            )
        };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$action_name"}}, $callback;

        $MyApp->process( $context );

    }

}

# current action, scheme => 'https', host => 'somehost'
{

    for my $action_name ( qw( action_1 action_2 action_3 ) ) {

        my $context = _fake_context();
        $context->request->method( 'GET' );
        $context->request->scheme( 'http' );
        $context->request->host( 'localhost' );
        $context->request->path( "/a/$action_name" );

        my $callback = sub {
            is(
                $_[0]->uri_for_action(
                    scheme => 'https',
                    host   => 'somehost'
                ),
                "https://somehost/a/$action_name"
            )
        };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$action_name"}}, $callback;

        $MyApp->process( $context );

    }

}

# action => $action
{

    for my $action_name ( qw( action_1 action_2 action_3 ) ) {

        my $context = _fake_context();
        $context->request->method( 'GET' );
        $context->request->scheme( 'http' );
        $context->request->host( 'localhost' );
        $context->request->path( "/a/$action_name" );

        my $callback = sub {
            is(
                $_[0]->uri_for_action(
                    action => $Controller_A->action( $action_name )
                ),
                "http://localhost/a/$action_name"
            )
        };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$action_name"}}, $callback;

        $MyApp->process( $context );

    }

}

# action => $action, parameters => \%parameters
{

    for my $action_name ( qw( action_4 ) ) {

        my $context = _fake_context();
        $context->request->method( 'GET' );
        $context->request->scheme( 'http' );
        $context->request->host( 'localhost' );
        $context->request->path( "/a/$action_name/v1" );

        my $callback = sub {
            is(
                $_[0]->uri_for_action(
                    action     => $Controller_A->action( $action_name ),
                    parameters => { 'k1' => 'v1' }
                ),
                "http://localhost/a/$action_name/v1"
            )
        };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$action_name"}}, $callback;

        $MyApp->process( $context );

    }

}

# action => $action_name
{

    for my $action_name ( qw( action_1 action_2 action_3 ) ) {

        my $context = _fake_context();
        $context->request->method( 'GET' );
        $context->request->scheme( 'http' );
        $context->request->host( 'localhost' );
        $context->request->path( "/a/$action_name" );

        my $callback = sub {
            is(
                $_[0]->uri_for_action(
                    action => $action_name
                ),
                "http://localhost/a/$action_name"
            )
        };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$action_name"}}, $callback;

        $MyApp->process( $context );

    }

}

# controller => $controller_name, action => $action_name
{

    for my $action_name ( qw( action_1 action_2 action_3 ) ) {

        my $context = _fake_context();
        $context->request->method( 'GET' );
        $context->request->scheme( 'http' );
        $context->request->host( 'localhost' );
        $context->request->path( "/a/$action_name" );

        my $callback = sub {
            is(
                $_[0]->uri_for_action(
                    controller => 'A',
                    action     => $action_name
                ),
                "http://localhost/a/$action_name"
            )
        };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$action_name"}}, $callback;

        $MyApp->process( $context );

    }

}

# controller => $controller_class, action => $action_name
{

    for my $action_name ( qw( action_1 action_2 action_3 ) ) {

        my $context = _fake_context();
        $context->request->method( 'GET' );
        $context->request->scheme( 'http' );
        $context->request->host( 'localhost' );
        $context->request->path( "/a/$action_name" );

        my $callback = sub {
            is(
                $_[0]->uri_for_action(
                    controller => 'MyApp::Controller::A',
                    action     => $action_name
                ),
                "http://localhost/a/$action_name"
            )
        };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$action_name"}}, $callback;

        $MyApp->process( $context );

    }

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

