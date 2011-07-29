#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 51;


my $MyApp;


# ----------------------------------------------------------------------------------------------------------------------
# Load the application
# ----------------------------------------------------------------------------------------------------------------------

{

    require_ok( 'MyApp' );

    $MyApp = MyApp->instance;

}


# ----------------------------------------------------------------------------------------------------------------------
# Response construction
# ----------------------------------------------------------------------------------------------------------------------

# status
{

    for my $status ( 200, 404, 500 ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
            sub {
                $_[0]->send_response( status => $status );
            };


        $MyApp->process( $context );

        my $response = $context->response;
        is( $response->status, $status );
        is( $response->content_type, undef );
        is( $response->body->as_string, '' );

    }

}

# headers, hash
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            $_[0]->send_response(
                headers => {
                    'Content-Type' => 'text/plain',
                    'X-GX-Header'  => 'GX rocks!'
                }
            );
        };


    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->header( 'Content-Type' ), 'text/plain' );
    is( $response->header( 'X-GX-Header' ), 'GX rocks!' );
    is( $response->body->as_string, '' );

}

# headers, object
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            my $headers = GX::HTTP::Response::Headers->new;
            $headers->set( 'Content-Type' => 'text/plain' );
            $headers->set( 'X-GX-Header'  => 'GX rocks!' );
            $_[0]->send_response( headers => $headers );
        };


    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->header( 'Content-Type' ), 'text/plain' );
    is( $response->header( 'X-GX-Header' ), 'GX rocks!' );
    is( $response->body->as_string, '' );

}

# body, object
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            my $body = GX::HTTP::Body::Scalar->new;
            $body->add( 'Hello World!' );
            $_[0]->send_response( body => $body );
        };


    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->content_type, undef );
    is( $response->body->as_string, 'Hello World!' );

}

# file, relative path
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            $_[0]->send_response( file => 'test.txt' );
        };

    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->content_type, undef );
    is( $response->body->as_string, 'test.txt' );

}

# file, non-existent file
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            local $@;
            eval { $_[0]->send_response( file => 'xxx' ) };
            isa_ok( $@, 'GX::Exception' );
        };

}

# render, qualified view name
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            $_[0]->send_response( render => 'MyApp::View::A' );
        };

    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->content_type, undef );
    is( $response->body->as_string, 'MyApp::View::A' );

}

# render, unqualified view name
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            $_[0]->send_response( render => 'A' );
        };

    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->content_type, undef );
    is( $response->body->as_string, 'MyApp::View::A' );

}

# render, array
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            $_[0]->send_response( render => [ view => 'A', foo => 'bar' ] );
        };

    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->content_type, undef );
    is( $response->body->as_string, 'MyApp::View::A foo => bar' );

}

# render, hash
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            $_[0]->send_response( render => { view => 'A', foo => 'bar' } );
        };

    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->content_type, undef );
    is( $response->body->as_string, 'MyApp::View::A foo => bar' );

}

# render, non-existent view
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            local $@;
            $_[0]->send_response( render => 'XXX' );
            isa_ok( $@, 'GX::Exception' );
        };

}

# render_hint, qualified view name
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            $_[0]->send_response( render_hint => 'MyApp::View::A' );
        };

    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->content_type, undef );
    is( $response->body->as_string, 'MyApp::View::A' );

}

# render_hint, unqualified view name
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            $_[0]->send_response( render_hint => 'A' );
        };

    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->content_type, undef );
    is( $response->body->as_string, 'MyApp::View::A' );

}

# render_hint, array
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            $_[0]->send_response( render_hint => [ view => 'A', foo => 'bar' ] );
        };

    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->content_type, undef );
    is( $response->body->as_string, 'MyApp::View::A foo => bar' );

}

# render_hint, hash
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            $_[0]->send_response( render_hint => { view => 'A', foo => 'bar' } );
        };

    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->content_type, undef );
    is( $response->body->as_string, 'MyApp::View::A foo => bar' );

}

# render_hint, non-existent view
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'}},
        sub {
            $_[0]->send_response( render_hint => 'XXX' );
        };

    $MyApp->process( $context );

    my $response = $context->response;
    is( $response->status, 200 );
    is( $response->content_type, undef );
    is( $response->body->as_string, '' );

}


# ----------------------------------------------------------------------------------------------------------------------

sub _fake_context {

    my $context = MyApp::Context->new(
        request  => MyApp::Request->new,
        response => MyApp::Response->new,
        @_
    );

    $context->request->path( '/' );
    $context->request->host( 'localhost' );
    $context->request->method( 'GET' );

    return $context;

}

