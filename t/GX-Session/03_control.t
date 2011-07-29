#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 193;


our $TIME           = time();
our $REMOTE_ADDRESS = '123.123.123.123';

our $Session_ID;


require_ok( 'MyApp' );


# new()
{

    my $context = _fake_context();

    my $session = MyApp::Session::A->new( context => $context );

    isa_ok( $session, 'MyApp::Session::A' );

    is( $session->id, undef );
    is( $session->remote_address, undef );

    is( $session->expires_at, undef );
    is( $session->started_at, undef );
    is( $session->updated_at, undef );

    ok( ! $session->is_active );
    ok( ! $session->is_expired );
    ok( ! $session->is_invalid );
    ok( ! $session->is_new );
    ok( ! $session->is_resumed );
    ok( ! $session->is_stored );

    is_deeply( $session->data, {} );

}

# Start a new session
{

    my $context = _fake_context();

    my $session = MyApp::Session::A->new( context => $context );

    is( keys %{$session->store->data}, 0 );

    ok( $session->start );

    is( keys %{$session->store->data}, 1 );

    ok( $Session_ID = $session->id );
    is( $session->remote_address, $REMOTE_ADDRESS );

    is( $session->expires_at, $TIME + 3600 );
    is( $session->started_at, $TIME );
    is( $session->updated_at, undef );

    ok( $session->is_active );
    ok( ! $session->is_expired );
    ok( ! $session->is_invalid );
    ok( $session->is_new );
    ok( ! $session->is_resumed );
    ok( $session->is_stored );

    is_deeply( $session->data, {} );

    ok( my $cookie = $context->response->cookie( 'A_SESSION_ID' ) );
    is( $cookie->value, $Session_ID );

}

# Resume the session
{

    for ( 1 .. 3 ) {

        my $context = _fake_context();
        $context->request->cookies->create( name => 'A_SESSION_ID', value => $Session_ID );

        my $session = MyApp::Session::A->new( context => $context );

        ok( $session->resume );

        is( $session->id, $Session_ID );
        is( $session->remote_address, $REMOTE_ADDRESS );

        is( $session->expires_at, $TIME + 3600 );
        is( $session->started_at, $TIME );
        is( $session->updated_at, undef );

        ok( $session->is_active );
        ok( ! $session->is_expired );
        ok( ! $session->is_invalid );
        ok( ! $session->is_new );
        ok( $session->is_resumed );
        ok( $session->is_stored );

        is_deeply( $session->data, {} );

    }

}

# Resume the session by ID
{

    my $context = _fake_context();

    my $session = MyApp::Session::A->new( context => $context );

    ok( $session->resume( $Session_ID ) );

    is( $session->id, $Session_ID );

}

# Resume the session, add some session data and save it
{

    my $context = _fake_context( time => $TIME + 1 );
    $context->request->cookies->create( name => 'A_SESSION_ID', value => $Session_ID );

    my $session = MyApp::Session::A->new( context => $context );

    ok( $session->resume );

    is( $session->id, $Session_ID );
    is( $session->remote_address, $REMOTE_ADDRESS );

    is( $session->expires_at, $TIME + 3600 );
    is( $session->started_at, $TIME );
    is( $session->updated_at, undef );

    ok( $session->is_active );
    ok( ! $session->is_expired );
    ok( ! $session->is_invalid );
    ok( ! $session->is_new );
    ok( $session->is_resumed );
    ok( $session->is_stored );

    is_deeply( $session->data, {} );

    $session->set_data( 'k1' => 'v1_1' );
    $session->set_data( 'k2' => 'v2_1' );

    is_deeply( $session->data, { 'k1' => 'v1_1', 'k2' => 'v2_1' } );

    ok( $session->save );

    is( $session->expires_at, $TIME + 1 + 3600 );
    is( $session->started_at, $TIME );
    is( $session->updated_at, $TIME + 1 );

    ok( $session->is_active );
    ok( ! $session->is_expired );
    ok( ! $session->is_invalid );
    ok( ! $session->is_new );
    ok( $session->is_resumed );
    ok( $session->is_stored );

}

# Resume the session, update the session data and save it
{

    my $context = _fake_context( time => $TIME + 2 );
    $context->request->cookies->create( name => 'A_SESSION_ID', value => $Session_ID );

    my $session = MyApp::Session::A->new( context => $context );

    ok( $session->resume );

    is( $session->id, $Session_ID );
    is( $session->remote_address, $REMOTE_ADDRESS );

    is( $session->expires_at, $TIME + 1 + 3600 );
    is( $session->started_at, $TIME );
    is( $session->updated_at, $TIME + 1 );

    ok( $session->is_active );
    ok( ! $session->is_expired );
    ok( ! $session->is_invalid );
    ok( ! $session->is_new );
    ok( $session->is_resumed );
    ok( $session->is_stored );

    is_deeply( $session->data, { 'k1' => 'v1_1', 'k2' => 'v2_1' } );

    $session->set_data( 'k1' => 'v1_2' );
    $session->set_data( 'k2' => 'v2_2' );
    $session->set_data( 'k3' => 'v3_2' );

    is_deeply( $session->data, { 'k1' => 'v1_2', 'k2' => 'v2_2', 'k3' => 'v3_2' } );

    ok( $session->save );

    is( $session->expires_at, $TIME + 2 + 3600 );
    is( $session->started_at, $TIME );
    is( $session->updated_at, $TIME + 2 );

    ok( $session->is_active );
    ok( ! $session->is_expired );
    ok( ! $session->is_invalid );
    ok( ! $session->is_new );
    ok( $session->is_resumed );
    ok( $session->is_stored );

}

# Resume the session and end it
{

    my $context = _fake_context( time => $TIME + 3 );
    $context->request->cookies->create( name => 'A_SESSION_ID', value => $Session_ID );

    my $session = MyApp::Session::A->new( context => $context );

    ok( $session->resume );

    is( $session->id, $Session_ID );
    is( $session->remote_address, $REMOTE_ADDRESS );

    is( $session->expires_at, $TIME + 2 + 3600 );
    is( $session->started_at, $TIME );
    is( $session->updated_at, $TIME + 2 );

    ok( $session->is_active );
    ok( ! $session->is_expired );
    ok( ! $session->is_invalid );
    ok( ! $session->is_new );
    ok( $session->is_resumed );
    ok( $session->is_stored );

    is_deeply( $session->data, { 'k1' => 'v1_2', 'k2' => 'v2_2', 'k3' => 'v3_2' } );

    is( keys %{$session->store->data}, 1 );

    ok( $session->end );

    is( keys %{$session->store->data}, 0 );

    is( $session->id, undef );
    is( $session->remote_address, undef );

    is( $session->expires_at, undef );
    is( $session->started_at, undef );
    is( $session->updated_at, undef );

    ok( ! $session->is_active );
    ok( ! $session->is_expired );
    ok( ! $session->is_invalid );
    ok( ! $session->is_new );
    ok( ! $session->is_resumed );
    ok( ! $session->is_stored );

    is_deeply( $session->data, {} );

    ok( my $cookie = $context->response->cookie( 'A_SESSION_ID' ) );
    is( $cookie->max_age, 0 );

    undef $Session_ID;

}

# Session timeout
{

    local $Session_ID;

    %{MyApp::Session::A->store->data} = ();

    {

        my $context = _fake_context( time => $TIME );

        my $session = MyApp::Session::A->new( context => $context );

        ok( $session->start );

        $Session_ID = $session->id;

    }

    {

        my $context = _fake_context( time => $TIME + ( 3600 - 1 ) );
        $context->request->cookies->create( name => 'A_SESSION_ID', value => $Session_ID );

        my $session = MyApp::Session::A->new( context => $context );

        ok( $session->resume );

    }

    {

        my $context = _fake_context( time => $TIME + 3600 );
        $context->request->cookies->create( name => 'A_SESSION_ID', value => $Session_ID );

        my $session = MyApp::Session::A->new( context => $context );

        ok( ! $session->resume );

        is( $session->id, undef );
        is( $session->remote_address, undef );

        is( $session->expires_at, undef );
        is( $session->started_at, undef );
        is( $session->updated_at, undef );

        ok( ! $session->is_active );
        ok( $session->is_expired );
        ok( ! $session->is_invalid );
        ok( ! $session->is_new );
        ok( ! $session->is_resumed );
        ok( ! $session->is_stored );

        is_deeply( $session->data, {} );

    }

    %{MyApp::Session::A->store->data} = ();

}

# Remote address mismatch
{

    local $Session_ID;

    %{MyApp::Session::A->store->data} = ();

    {

        my $context = _fake_context( time => $TIME );

        my $session = MyApp::Session::A->new( context => $context );

        ok( $session->start );

        $Session_ID = $session->id;

    }

    {

        my $context = _fake_context( time => $TIME + 1 );
        $context->request->cookies->create( name => 'A_SESSION_ID', value => $Session_ID );
        $context->request->remote_address( '1.1.1.1' );

        my $session = MyApp::Session::A->new( context => $context );

        ok( ! $session->resume );

        is( $session->id, undef );
        is( $session->remote_address, undef );

        is( $session->expires_at, undef );
        is( $session->started_at, undef );
        is( $session->updated_at, undef );

        ok( ! $session->is_active );
        ok( ! $session->is_expired );
        ok( $session->is_invalid );
        ok( ! $session->is_new );
        ok( ! $session->is_resumed );
        ok( ! $session->is_stored );

        is_deeply( $session->data, {} );

    }

    %{MyApp::Session::A->store->data} = ();

}

# Invalid session ID
{

    local $Session_ID;

    %{MyApp::Session::A->store->data} = ();

    {

        my $context = _fake_context( time => $TIME );

        my $session = MyApp::Session::A->new( context => $context );

        ok( $session->start );

        $Session_ID = $session->id;

    }

    {

        my $context = _fake_context( time => $TIME + 1 );
        $context->request->cookies->create( name => 'A_SESSION_ID', value => 'XXX' );

        my $session = MyApp::Session::A->new( context => $context );

        ok( ! $session->resume );

        is( $session->id, undef );
        is( $session->remote_address, undef );

        is( $session->expires_at, undef );
        is( $session->started_at, undef );
        is( $session->updated_at, undef );

        ok( ! $session->is_active );
        ok( ! $session->is_expired );
        ok( $session->is_invalid );
        ok( ! $session->is_new );
        ok( ! $session->is_resumed );
        ok( ! $session->is_stored );

        is_deeply( $session->data, {} );

    }

    %{MyApp::Session::A->store->data} = ();

}


# ----------------------------------------------------------------------------------------------------------------------

sub _fake_context {

    my $context = MyApp::Context->new(
        request  => MyApp::Request->new,
        response => MyApp::Response->new,
        time     => $TIME,
        @_
    );

    $context->request->remote_address( $REMOTE_ADDRESS );

    return $context;

}

