#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 20;


require_ok( 'MyApp' );


# data()
{

    my $context = _fake_context();
    my $session = MyApp::Session::A->new( context => $context );

    is_deeply( $session->data, {} );

    $session->data( 'k1' => 'v11' );

    is_deeply( $session->data, { 'k1' => 'v11' } );

    $session->data( 'k1' => 'v12', 'k2' => 'v21' );

    is_deeply( $session->data, { 'k1' => 'v12', 'k2' => 'v21' } );

}

# get_data()
{

    my $context = _fake_context();
    my $session = MyApp::Session::A->new( context => $context );

    $session->data( 'k1' => 'v11', 'k2' => 'v21' );

    is( $session->get_data( 'kx' ), undef );
    is( $session->get_data( 'k1' ), 'v11' );
    is( $session->get_data( 'k2' ), 'v21' );

}

# set_data()
{

    my $context = _fake_context();
    my $session = MyApp::Session::A->new( context => $context );

    $session->set_data( 'k1' => 'v11' );

    is_deeply( $session->data, { 'k1' => 'v11' } );

    $session->set_data( 'k1' => 'v12' );
    $session->set_data( 'k2' => 'v21' );

    is_deeply( $session->data, { 'k1' => 'v12', 'k2' => 'v21' } );

}

# delete_data()
{

    my $context = _fake_context();
    my $session = MyApp::Session::A->new( context => $context );

    $session->data( 'k1' => 'v11', 'k2' => 'v21' );

    ok( ! $session->delete_data( 'kx' ) );

    is_deeply( $session->data, { 'k1' => 'v11', 'k2' => 'v21' } );

    ok( $session->delete_data( 'k1' ) );

    is_deeply( $session->data, { 'k2' => 'v21' } );

    ok( $session->delete_data( 'k2' ) );

    is_deeply( $session->data, {} );

    ok( ! $session->delete_data( 'kx' ) );

    is_deeply( $session->data, {} );

}

# clear()
{

    my $context = _fake_context();
    my $session = MyApp::Session::A->new( context => $context );

    $session->data( 'k1' => 'v11', 'k2' => 'v21' );

    $session->clear;

    is_deeply( $session->data, {} );

}

# variables()
{

    my $context = _fake_context();
    my $session = MyApp::Session::A->new( context => $context );

    $session->set_data( 'k1' => 'v11' );

    is_deeply( [ sort $session->variables ], [ sort qw( k1 ) ] );

    $session->set_data( 'k1' => 'v12' );
    $session->set_data( 'k2' => 'v21' );

    is_deeply( [ sort $session->variables ], [ sort qw( k1 k2 ) ] );

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

