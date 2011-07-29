#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 4;


require_ok( 'MyApp' );

my $MyApp  = MyApp->instance;
my $View_A = $MyApp->view( 'A' );


# ----------------------------------------------------------------------------------------------------------------------
# renderer()
# ----------------------------------------------------------------------------------------------------------------------

# MyApp::Controller::A, action_1
{

    my $context = _fake_context();

    my $callback = sub {
        is( $_[0]->renderer, undef );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}}, $callback;

    $context->request->path( '/a/action_1' );

    $MyApp->process( $context );

}

# MyApp::Controller::A, action_2
{

    my $context = _fake_context();

    my $callback = sub {
        is( $_[0]->renderer, $_[0]->controller->renderer( $_[0]->action ) );
    };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_2"}}, $callback;

    $context->request->path( '/a/action_2' );

    $MyApp->process( $context );

}

# MyApp::Controller::A, action_3
{

    my $context = _fake_context();

    my $callback = sub {
        is( $_[0]->renderer, $_[0]->controller->renderer( $_[0]->action ) );
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

