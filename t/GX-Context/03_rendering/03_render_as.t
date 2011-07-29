#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 17;


require_ok( 'MyApp' );

my $MyApp  = MyApp->instance;
my $View_A = $MyApp->view( 'A' );


# ----------------------------------------------------------------------------------------------------------------------
# render_as( ... )
# ----------------------------------------------------------------------------------------------------------------------

# MyApp::Controller::A, action_1
{

    my $context = _fake_context();

    my $callback = sub {

        ok( ! $_[0]->render_as( '*' ) );

        ok( ! $_[0]->render_as( 'format_x' ) );

        {
            local $@;
            eval { $_[0]->render_as( '*' ) };
            isa_ok( $@, 'GX::Exception' );
        }

        {
            local $@;
            eval { $_[0]->render_as( 'format_x' ) };
            isa_ok( $@, 'GX::Exception' );
        }

        is( $_[0]->response->body->as_string, '' );

    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}}, $callback;

    $context->request->path( '/a/action_1' );

    $MyApp->process( $context );

}

# MyApp::Controller::A, action_2 - "*"-format
{

    my $context = _fake_context();

    my $callback = sub {
        ok( $_[0]->render_as( '*' ) );
        is( $_[0]->response->body->as_string, 'MyApp::View::A' );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_2"}}, $callback;

    $context->request->path( '/a/action_2' );

    $MyApp->process( $context );

}

# MyApp::Controller::A, action_2 - "format_x"-format
{

    my $context = _fake_context();

    my $callback = sub {
        ok( $_[0]->render_as( 'format_x' ) );
        is( $_[0]->response->body->as_string, 'MyApp::View::A' );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_2"}}, $callback;

    $context->request->path( '/a/action_2' );

    $MyApp->process( $context );

}

# MyApp::Controller::A, action_3 - "*"-format, "format_x"-format
{

    my $context = _fake_context();

    my $callback = sub {
        ok( ! $_[0]->render_as( '*' ) );
        ok( ! $_[0]->render_as( 'format_x' ) );
        is( $_[0]->response->body->as_string, '' );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_3"}}, $callback;

    $context->request->path( '/a/action_3' );

    $MyApp->process( $context );

}

# MyApp::Controller::A, action_3 - "format_1"-format
{

    my $context = _fake_context();

    my $callback = sub {
        ok( $_[0]->render_as( 'format_1' ) );
        is( $_[0]->response->body->as_string, 'MyApp::View::A format => format_1' );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_3"}}, $callback;

    $context->request->path( '/a/action_3' );

    $MyApp->process( $context );

}

# MyApp::Controller::A, action_3 - "format_2"-format
{

    my $context = _fake_context();

    my $callback = sub {
        ok( $_[0]->render_as( 'format_2' ) );
        is( $_[0]->response->body->as_string, 'MyApp::View::A format => format_2' );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_3"}}, $callback;

    $context->request->path( '/a/action_3' );

    $MyApp->process( $context );

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

