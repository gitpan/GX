#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 923;


my $MyApp;
my $Controller_A;
my $Controller_B;
my $Action_A_1;
my $Action_A_2;
my $Action_A_3;
my $Action_B_1;
my $Action_B_2;
my $Action_B_3;
my $Hook_DispatchActions;
my $Handler_dispatch;

my @Hook_sequence = qw(
    Initialize
    ProcessConnection
    ProcessRequest
    ProcessRequestQuery
    ProcessRequestHeaders
    ProcessRequestCookies
    ProcessRequestBody
    ProcessSessions
    ResolveActions
    DispatchActions
    FinalizeSessions
    FinalizeResponse
    FinalizeResponseBody
    FinalizeResponseCookies
    FinalizeResponseHeaders
    FinalizeResponseStatus
    SendResponse
    Cleanup
);


# ----------------------------------------------------------------------------------------------------------------------
# Load the application
# ----------------------------------------------------------------------------------------------------------------------

{

    require_ok( 'MyApp' );

    $MyApp = MyApp->instance;

    $Controller_A = $MyApp->controller( 'A' );
    $Controller_B = $MyApp->controller( 'B' );

    $Action_A_1 = $Controller_A->action( 'action_1' );
    $Action_A_2 = $Controller_A->action( 'action_2' );
    $Action_A_3 = $Controller_A->action( 'action_3' );
    $Action_B_1 = $Controller_B->action( 'action_1' );
    $Action_B_2 = $Controller_B->action( 'action_2' );
    $Action_B_3 = $Controller_B->action( 'action_3' );
    
    $Hook_DispatchActions = $MyApp->hook( 'DispatchActions' );

    $Handler_dispatch = ( $Hook_DispatchActions->all )[0];

    @Hook_sequence = map { $_->name } $MyApp->hooks;

}


# ----------------------------------------------------------------------------------------------------------------------
# Flow control, handlers
# ----------------------------------------------------------------------------------------------------------------------

# bail_out()
{

    my @called_hooks;

    for my $hook_name ( @Hook_sequence ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{$hook_name}},
            sub {
                is( $_[0]->handler, ( $MyApp->hook( $hook_name )->all )[-1] );
                is( $_[0]->hook, $MyApp->hook( $hook_name ) );
                $_[0]->bail_out;
                is( $_[0]->handler, ( $MyApp->hook( $hook_name )->all )[-1] );
                is( $_[0]->hook, $MyApp->hook( $hook_name ) );
            };

        push @called_hooks, $hook_name;

        $MyApp->process( $context );

        is_deeply( $context->stash->{'_test_hook_trace'}, \@called_hooks );

    }

}

# send_response()
{

    my @hook_sequence = qw(
        Initialize
        ProcessConnection
        ProcessRequest
        ProcessRequestQuery
        ProcessRequestHeaders
        ProcessRequestCookies
        ProcessRequestBody
        ProcessSessions
        ResolveActions
        DispatchActions
    );

    my @called_hooks;

    for my $hook_name ( @hook_sequence ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{$hook_name}},
            sub {
                is( $_[0]->handler, ( $MyApp->hook( $hook_name )->all )[-1] );
                is( $_[0]->hook, $MyApp->hook( $hook_name ) );
                $_[0]->send_response;
                is( $_[0]->handler, ( $MyApp->hook( $hook_name )->all )[-1] );
                is( $_[0]->hook, $MyApp->hook( $hook_name ) );
            };

        push @called_hooks, $hook_name;

        $MyApp->process( $context );

        is_deeply(
            $context->stash->{'_test_hook_trace'},
            [
                @called_hooks,
                qw(
                    FinalizeResponse
                    FinalizeResponseBody
                    FinalizeResponseCookies
                    FinalizeResponseHeaders
                    FinalizeResponseStatus
                    SendResponse
                    Cleanup
                )
            ]
        );

    }

}

# send_response(), but too late
{

    my @hook_sequence = qw(
        FinalizeResponse
        FinalizeResponseBody
        FinalizeResponseCookies
        FinalizeResponseHeaders
        FinalizeResponseStatus
        SendResponse
        Cleanup
    );

    my @called_hooks;

    for my $hook_name ( @hook_sequence ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{$hook_name}},
            sub {
                is( $_[0]->handler, ( $MyApp->hook( $hook_name )->all )[-1] );
                is( $_[0]->hook, $MyApp->hook( $hook_name ) );
                local $@;
                eval { $_[0]->send_response };
                isa_ok( $@, 'GX::Exception' );
                is( $_[0]->handler, ( $MyApp->hook( $hook_name )->all )[-1] );
                is( $_[0]->hook, $MyApp->hook( $hook_name ) );
            };

        push @called_hooks, $hook_name;

        $MyApp->process( $context );

        is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Flow control, dispatch phase
# ----------------------------------------------------------------------------------------------------------------------

# abort()
{

    my @dispatch_callbacks = qw(
        before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
    );

    my @dispatched;

    for my $dispatch_callback ( @dispatch_callbacks ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::before_1"}},
            sub { $_[0]->dispatch( controller => 'B', action => 'action_1' ) };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$dispatch_callback"}},
            sub {
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
                $_[0]->abort;
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
            };

        push @dispatched, "MyApp::Controller::A::$dispatch_callback";

        $MyApp->process( $context );

        is_deeply( $context->stash->{'_test_dispatch_trace'}, \@dispatched );

        is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

    }

}

# bail_out()
{

    my @dispatch_callbacks = qw(
        before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
    );

    my @dispatched;

    for my $dispatch_callback ( @dispatch_callbacks ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::before_1"}},
            sub { $_[0]->dispatch( controller => 'B', action => 'action_1' ) };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$dispatch_callback"}},
            sub {
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
                is( $_[0]->handler, $Handler_dispatch );
                is( $_[0]->hook, $Hook_DispatchActions );
                $_[0]->bail_out;
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
                is( $_[0]->handler, $Handler_dispatch );
                is( $_[0]->hook, $Hook_DispatchActions );
            };

        push @dispatched, "MyApp::Controller::A::$dispatch_callback";

        $MyApp->process( $context );

        is_deeply( $context->stash->{'_test_dispatch_trace'}, \@dispatched );

        is_deeply(
            $context->stash->{'_test_hook_trace'}, 
            [ qw(
                Initialize
                ProcessConnection
                ProcessRequest
                ProcessRequestQuery
                ProcessRequestHeaders
                ProcessRequestCookies
                ProcessRequestBody
                ProcessSessions
                ResolveActions
            ) ] 
        );

    }

}

# dispatch( $action )
{

    my @dispatch_callbacks = qw(
        before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
    );

    for my $dispatch_callback ( @dispatch_callbacks ) {

        my $context = _fake_context();

        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$dispatch_callback"}},
            sub {
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
                $_[0]->dispatch( $Action_B_1 );
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
            };

        $MyApp->process( $context );

        is_deeply(
            $context->stash->{'_test_dispatch_trace'},
            [
                map( { "MyApp::Controller::A::$_" } @dispatch_callbacks ),
                map( { "MyApp::Controller::B::$_" } @dispatch_callbacks )
            ]
        );

        is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

    }

}

# dispatch( $action_name )
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
        sub { $_[0]->dispatch( 'action_2' ) };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [ map { "MyApp::Controller::A::$_" } qw(
            before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
            before_1 before_2 before_3 action_2 render_1 render_2 render_3 after_1 after_2 after_3
        ) ]
    );

    is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

}

# dispatch( controller => $controller_name, action => $action_name )
{

    my @dispatch_callbacks = qw(
        before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
    );

    for my $dispatch_callback ( @dispatch_callbacks ) {

        my $context = _fake_context();

        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$dispatch_callback"}},
            sub { $_[0]->dispatch( controller => 'B', action => 'action_1' ) };

        $MyApp->process( $context );

        is_deeply(
            $context->stash->{'_test_dispatch_trace'},
            [
                map( { "MyApp::Controller::A::$_" } @dispatch_callbacks ),
                map( { "MyApp::Controller::B::$_" } @dispatch_callbacks )
            ]
        );

        is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

    }

}

# done()
{

    my @dispatch_callbacks = qw(
        before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
    );

    for my $dispatch_callback ( @dispatch_callbacks ) {

        my $context = _fake_context();

        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::before_1"}},
            sub { $_[0]->dispatch( controller => 'B', action => 'action_1' ) };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$dispatch_callback"}},
            sub {
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
                $_[0]->done;
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
            };

        $MyApp->process( $context );

        is_deeply(
            $context->stash->{'_test_dispatch_trace'},
            [
                map( { "MyApp::Controller::A::$_" } @dispatch_callbacks )
            ]
        );

        is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

    }

}

# forward(), no next action
{

    my @dispatch_callbacks = qw(
        before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
    );

    my @dispatched;

    for my $dispatch_callback ( @dispatch_callbacks ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$dispatch_callback"}},
            sub {
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
                $_[0]->forward;
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
            };

        push @dispatched, "MyApp::Controller::A::$dispatch_callback";

        $MyApp->process( $context );

        is_deeply( $context->stash->{'_test_dispatch_trace'}, \@dispatched );

        is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

    }

}

# forward() to next action
{

    my @dispatch_callbacks = qw(
        before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
    );

    my @dispatched;

    for my $dispatch_callback ( @dispatch_callbacks ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::before_1"}},
            sub { $_[0]->dispatch( controller => 'B', action => 'action_1' ) };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$dispatch_callback"}},
            sub {
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
                $_[0]->forward;
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
            };

        push @dispatched, $dispatch_callback;

        $MyApp->process( $context );

        is_deeply(
            $context->stash->{'_test_dispatch_trace'},
            [
                map( { "MyApp::Controller::A::$_" } @dispatched ),
                map( { "MyApp::Controller::B::$_" } @dispatch_callbacks )
            ]
        );

        is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

    }

}

# forward( $action )
{

    my @dispatch_callbacks = qw(
        before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
    );

    my @dispatched;

    for my $dispatch_callback ( @dispatch_callbacks ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$dispatch_callback"}},
            sub {
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
                $_[0]->forward( $Action_B_1 );
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
            };

        push @dispatched, $dispatch_callback;

        $MyApp->process( $context );

        is_deeply(
            $context->stash->{'_test_dispatch_trace'},
            [
                map( { "MyApp::Controller::A::$_" } @dispatched ),
                map( { "MyApp::Controller::B::$_" } @dispatch_callbacks )
            ]
        );

        is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

    }

}

# forward( $action_name )
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
        sub { $_[0]->forward( 'action_2' ) };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [ map { "MyApp::Controller::A::$_" } qw(
            before_1 before_2 before_3 action_1
            before_1 before_2 before_3 action_2 render_1 render_2 render_3 after_1 after_2 after_3
        ) ]
    );

    is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

}

# forward( controller => $controller_name, action => $action_name )
{

    my @dispatch_callbacks = qw(
        before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
    );

    my @dispatched;

    for my $dispatch_callback ( @dispatch_callbacks ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$dispatch_callback"}},
            sub { $_[0]->forward( controller => 'B', action => 'action_1' ) };

        push @dispatched, $dispatch_callback;

        $MyApp->process( $context );

        is_deeply(
            $context->stash->{'_test_dispatch_trace'},
            [
                map( { "MyApp::Controller::A::$_" } @dispatched ),
                map( { "MyApp::Controller::B::$_" } @dispatch_callbacks )
            ]
        );

        is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

    }

}

# redirect( $uri )
{

    my @dispatch_callbacks = qw(
        before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
    );

    my @dispatched;

    for my $dispatch_callback ( @dispatch_callbacks ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::before_1"}},
            sub { $_[0]->dispatch( controller => 'B', action => 'action_1' ) };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$dispatch_callback"}},
            sub {
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
                $_[0]->redirect( 'http://gxframework.org' );
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
            };

        push @dispatched, "MyApp::Controller::A::$dispatch_callback";

        $MyApp->process( $context );

        is_deeply( $context->stash->{'_test_dispatch_trace'}, \@dispatched );

        is_deeply(
            $context->stash->{'_test_hook_trace'}, 
            [ qw(
                Initialize
                ProcessConnection
                ProcessRequest
                ProcessRequestQuery
                ProcessRequestHeaders
                ProcessRequestCookies
                ProcessRequestBody
                ProcessSessions
                ResolveActions
                FinalizeResponse
                FinalizeResponseBody
                FinalizeResponseCookies
                FinalizeResponseHeaders
                FinalizeResponseStatus
                SendResponse
                Cleanup
            ) ] 
        );

        is( $context->response->location, 'http://gxframework.org' );
        is( $context->response->status, 302 );

    }

}

# send_response()
{

    my @dispatch_callbacks = qw(
        before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3
    );

    my @dispatched;

    for my $dispatch_callback ( @dispatch_callbacks ) {

        my $context = _fake_context();
        $context->request->path( '/a/action_1' );

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::before_1"}},
            sub { $_[0]->dispatch( controller => 'B', action => 'action_1' ) };

        push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::$dispatch_callback"}},
            sub {
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
                $_[0]->send_response;
                is( $_[0]->action, $Action_A_1 );
                is( $_[0]->controller, $Controller_A );
            };

        push @dispatched, "MyApp::Controller::A::$dispatch_callback";

        $MyApp->process( $context );

        is_deeply( $context->stash->{'_test_dispatch_trace'}, \@dispatched );

        is_deeply(
            $context->stash->{'_test_hook_trace'}, 
            [ qw(
                Initialize
                ProcessConnection
                ProcessRequest
                ProcessRequestQuery
                ProcessRequestHeaders
                ProcessRequestCookies
                ProcessRequestBody
                ProcessSessions
                ResolveActions
                FinalizeResponse
                FinalizeResponseBody
                FinalizeResponseCookies
                FinalizeResponseHeaders
                FinalizeResponseStatus
                SendResponse
                Cleanup
            ) ] 
        );

    }

}

# nested dispatch
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
        sub {
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
            $Controller_B->dispatch( $_[0], $Action_B_1 );
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
        };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::B::action_1"}},
        sub {
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
        };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [
            map( { "MyApp::Controller::A::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3 ) ),
            map( { "MyApp::Controller::A::$_" } qw( render_1 render_2 render_3 after_1 after_2 after_3 ) )
        ]
    );

    is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

}

# nested dispatch, $action->dispatch
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
        sub {
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
            $Action_B_1->dispatch( $_[0] );
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
        };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::B::action_1"}},
        sub {
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
        };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [
            map( { "MyApp::Controller::A::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3 ) ),
            map( { "MyApp::Controller::A::$_" } qw( render_1 render_2 render_3 after_1 after_2 after_3 ) )
        ]
    );

    is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

}

# nested dispatch, abort()
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::before_1"}},
        sub { $_[0]->dispatch( $Action_B_2 ) };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
        sub {
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
            $Controller_B->dispatch( $_[0], $Action_B_1 );
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
        };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::B::action_1"}},
        sub {
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
            $_[0]->abort;
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
        };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [
            map( { "MyApp::Controller::A::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_1 ) )
        ]
    );

    is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

}

# nested dispatch, bail_out()
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::before_1"}},
        sub { $_[0]->dispatch( $Action_B_2 ) };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
        sub {
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
            $Controller_B->dispatch( $_[0], $Action_B_1 );
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
        };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::B::action_1"}},
        sub {
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
            $_[0]->bail_out;
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
        };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [
            map( { "MyApp::Controller::A::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_1 ) )
        ]
    );

    is_deeply(
        $context->stash->{'_test_hook_trace'}, 
        [ qw(
            Initialize
            ProcessConnection
            ProcessRequest
            ProcessRequestQuery
            ProcessRequestHeaders
            ProcessRequestCookies
            ProcessRequestBody
            ProcessSessions
            ResolveActions
        ) ] 
    );

}

# nested dispatch, dispatch( $action );
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
        sub {
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
            $Controller_B->dispatch( $_[0], $Action_B_1 );
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
        };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::B::action_1"}},
        sub {
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
            $_[0]->dispatch( $Action_B_2 );
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
        };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [
            map( { "MyApp::Controller::A::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3 ) ),
            map( { "MyApp::Controller::A::$_" } qw( render_1 render_2 render_3 after_1 after_2 after_3 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_2 render_1 render_2 render_3 after_1 after_2 after_3 ) )
        ]
    );

    is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

}

# nested dispatch, done()
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::before_1"}},
        sub { $_[0]->dispatch( $Action_B_2 ) };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
         sub {
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
            $Controller_B->dispatch( $_[0], $Action_B_1 );
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
        };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::B::action_1"}},
        sub {
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
            $_[0]->done;
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
        };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [
            map( { "MyApp::Controller::A::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_1 render_1 render_2 render_3 after_1 after_2 after_3 ) ),
            map( { "MyApp::Controller::A::$_" } qw( render_1 render_2 render_3 after_1 after_2 after_3 ) )
        ]
    );

    is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

}

# nested dispatch, forward()
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
        sub {
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
            $Controller_B->dispatch( $_[0], $Action_B_1 );
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
        };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::B::action_1"}},
        sub {
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
            $_[0]->forward;
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
        };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [
            map( { "MyApp::Controller::A::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_1 ) )
        ]
    );

    is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

}

# nested dispatch, forward() to next action
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::before_1"}},
        sub { $_[0]->dispatch( $Action_B_2 ) };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
        sub {
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
            $Controller_B->dispatch( $_[0], $Action_B_1 );
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
        };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::B::action_1"}},
        sub {
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
            $_[0]->forward;
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
        };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [
            map( { "MyApp::Controller::A::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_2 render_1 render_2 render_3 after_1 after_2 after_3 ) )
        ]
    );

    is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

}

# nested dispatch, forward( $action )
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
        sub {
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
            $Controller_B->dispatch( $_[0], $Action_B_1 );
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
        };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::B::action_1"}},
        sub {
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
            $_[0]->forward( $Action_B_2 );
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
        };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [
            map( { "MyApp::Controller::A::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_2 render_1 render_2 render_3 after_1 after_2 after_3 ) )
        ]
    );

    is_deeply( $context->stash->{'_test_hook_trace'}, \@Hook_sequence );

}

# nested dispatch, send_response()
{

    my $context = _fake_context();
    $context->request->path( '/a/action_1' );

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::before_1"}},
        sub { $_[0]->dispatch( $Action_B_2 ) };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::A::action_1"}},
        sub {
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
            $Controller_B->dispatch( $_[0], $Action_B_1 );
            is( $_[0]->action, $Action_A_1 );
            is( $_[0]->controller, $Controller_A );
        };

    push @{$context->stash->{'_test_callbacks'}{"MyApp::Controller::B::action_1"}},
        sub {
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
            $_[0]->send_response;
            is( $_[0]->action, $Action_B_1 );
            is( $_[0]->controller, $Controller_B );
        };

    $MyApp->process( $context );

    is_deeply(
        $context->stash->{'_test_dispatch_trace'},
        [
            map( { "MyApp::Controller::A::$_" } qw( before_1 before_2 before_3 action_1 ) ),
            map( { "MyApp::Controller::B::$_" } qw( before_1 before_2 before_3 action_1 ) )
        ]
    );

    is_deeply(
        $context->stash->{'_test_hook_trace'}, 
        [ qw(
            Initialize
            ProcessConnection
            ProcessRequest
            ProcessRequestQuery
            ProcessRequestHeaders
            ProcessRequestCookies
            ProcessRequestBody
            ProcessSessions
            ResolveActions
            FinalizeResponse
            FinalizeResponseBody
            FinalizeResponseCookies
            FinalizeResponseHeaders
            FinalizeResponseStatus
            SendResponse
            Cleanup
        ) ] 
    );

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

