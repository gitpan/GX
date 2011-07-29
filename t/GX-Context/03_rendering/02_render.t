#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 21;


require_ok( 'MyApp' );

my $MyApp  = MyApp->instance;
my $View_A = $MyApp->view( 'A' );


# ----------------------------------------------------------------------------------------------------------------------
# render()
# ----------------------------------------------------------------------------------------------------------------------

# MyApp::Controller::A, action_1
{

    my $context = _fake_context();

    my $callback = sub {
        ok( ! $_[0]->render );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}}, $callback;

    $context->request->path( '/a/action_1' );

    $MyApp->process( $context );

}

# MyApp::Controller::A, action_2
{

    my $context = _fake_context();

    my $callback = sub {
        ok( $_[0]->render );
        is( $_[0]->response->body->as_string, 'MyApp::View::A' );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_2"}}, $callback;

    $context->request->path( '/a/action_2' );

    $MyApp->process( $context );

}

# MyApp::Controller::A, action_3 - undefined format
{

    my $context = _fake_context();

    my $callback = sub {
        ok( ! $_[0]->render );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_3"}}, $callback;

    $context->request->path( '/a/action_3' );

    $MyApp->process( $context );

}

# MyApp::Controller::A, action_3 - format_1
{

    my $context = _fake_context();

    my $callback = sub {
        ok( $_[0]->render );
        is( $_[0]->response->body->as_string, 'MyApp::View::A format => format_1' );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_3"}}, $callback;

    $context->request->path( '/a/action_3' );
    $context->request->format( 'format_1' );

    $MyApp->process( $context );

}

# MyApp::Controller::A, action_3 - format_2
{

    my $context = _fake_context();

    my $callback = sub {
        ok( $_[0]->render );
        is( $_[0]->response->body->as_string, 'MyApp::View::A format => format_2' );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_3"}}, $callback;

    $context->request->path( '/a/action_3' );
    $context->request->format( 'format_2' );

    $MyApp->process( $context );

}


# ----------------------------------------------------------------------------------------------------------------------
# render( ... )
# ----------------------------------------------------------------------------------------------------------------------

# render( $view )
{

    my $context = _fake_context();

    $context->render( $View_A );

    is( $context->response->body->as_string, 'MyApp::View::A' );

}

# render( view => $view )
{

    my $context = _fake_context();

    $context->render( view => $View_A );

    is( $context->response->body->as_string, 'MyApp::View::A' );

}

# render( view => $view, %args )
{

    my $context = _fake_context();

    $context->render( view => $View_A, 'k1' => 'v1', 'k2' => 'v2', 'k3' => 'v3' );

    is( $context->response->body->as_string, 'MyApp::View::A k1 => v1 k2 => v2 k3 => v3' );

}

# render( $view_name )
{

    my $context = _fake_context();

    $context->render( 'A' );

    is( $context->response->body->as_string, 'MyApp::View::A' );

}

# render( view => $view_name )
{

    my $context = _fake_context();

    $context->render( view => 'A' );

    is( $context->response->body->as_string, 'MyApp::View::A' );

}

# render( view => $view_name, %args )
{

    my $context = _fake_context();

    $context->render( view => 'A', 'k1' => 'v1', 'k2' => 'v2', 'k3' => 'v3' );

    is( $context->response->body->as_string, 'MyApp::View::A k1 => v1 k2 => v2 k3 => v3' );

}

# render( $view_class )
{

    my $context = _fake_context();

    $context->render( 'MyApp::View::A' );

    is( $context->response->body->as_string, 'MyApp::View::A' );

}

# render( view => $view_class )
{

    my $context = _fake_context();

    $context->render( view => 'MyApp::View::A' );

    is( $context->response->body->as_string, 'MyApp::View::A' );

}

# render( view => $view_class, %args )
{

    my $context = _fake_context();

    $context->render( view => 'MyApp::View::A', 'k1' => 'v1', 'k2' => 'v2', 'k3' => 'v3' );

    is( $context->response->body->as_string, 'MyApp::View::A k1 => v1 k2 => v2 k3 => v3' );

}

# render( ... ), scalar context
{

    my $context = _fake_context();

    ok( $context->render( 'A' ) );
    ok( ! $context->render( 'X' ) );

}

# render( ... ), void context
{

    my $context = _fake_context();

    {
        local $@;
        eval { $context->render( 'X' ) };
        isa_ok( $@, 'GX::Exception' );
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

