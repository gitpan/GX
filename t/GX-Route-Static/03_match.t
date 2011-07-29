#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Controller::A;
{

    use GX::Controller;

    sub action_1 :Action {}

} 


package main;

use GX::Action;
use GX::Route::Static;


use Test::More tests => 43;


my $Action = GX::Action->new(
    controller => MyApp::Controller::A->instance,
    method     => 'action_1'
);


# path => '/'
{

    my $route = GX::Route::Static->new(
        action => $Action,
        path   => '/'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/',  $Action, undef ],
        [ 'GET', 'http', 'localhost', '',   undef,   undef ],
        [ 'GET', 'http', 'localhost', '/x', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/a'
{

    my $route = GX::Route::Static->new(
        action => $Action,
        path   => '/a'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/a',  $Action, undef ],
        [ 'GET', 'http', 'localhost', '',    undef,   undef ],
        [ 'GET', 'http', 'localhost', '/',   undef,   undef ],
        [ 'GET', 'http', 'localhost', '/x',  undef,   undef ],
        [ 'GET', 'http', 'localhost', '/a/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/a/'
{

    my $route = GX::Route::Static->new(
        action => $Action,
        path   => '/a/'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/a/', $Action, undef ],
        [ 'GET', 'http', 'localhost', '',    undef,   undef ],
        [ 'GET', 'http', 'localhost', '/',   undef,   undef ],
        [ 'GET', 'http', 'localhost', '/x',  undef,   undef ],
        [ 'GET', 'http', 'localhost', '/a',  undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/', method => 'GET'
{

    my $route = GX::Route::Static->new(
        action => $Action,
        path   => '/',
        method => 'GET'
    );

    my $i;
    for my $data (
        [ 'GET',  'http', 'localhost', '/', $Action, undef ],
        [ undef,  'http', 'localhost', '/', undef,   undef ],
        [ '',     'http', 'localhost', '/', undef,   undef ],
        [ 'HEAD', 'http', 'localhost', '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/', scheme => 'https'
{

    my $route = GX::Route::Static->new(
        action => $Action,
        path   => '/',
        scheme => 'https'
    );

    my $i;
    for my $data (
        [ 'GET', 'https', 'localhost', '/', $Action, undef ],
        [ 'GET', undef,   'localhost', '/', undef,   undef ],
        [ 'GET', '',      'localhost', '/', undef,   undef ],
        [ 'GET', 'http',  'localhost', '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/', host => 'a'
{

    my $route = GX::Route::Static->new(
        action => $Action,
        path   => '/',
        host   => 'a'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'a',   '/', $Action, undef ],
        [ 'GET', 'http', undef, '/', undef,   undef ],
        [ 'GET', 'http', '',    '/', undef,   undef ],
        [ 'GET', 'http', 'x',   '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}


# ----------------------------------------------------------------------------------------------------------------------

sub _match {

    my ( $route, $data, $info ) = @_;

    my ( $method, $scheme, $host, $path, $action, $parameters ) = @$data;

    my $request = MyApp::Request->new;
    $request->scheme( $scheme );
    $request->host( $host );
    $request->method( $method );
    $request->path( $path );

    my $context = MyApp::Context->new( request => $request );

    my $result = $route->match( $context );

    if ( $action ) {

        ok( $result, "$info - match" );

        isa_ok( $result, 'GX::Route::Match' );

        is( $result->action, $action, "$info - match -> action" );

        if ( $parameters ) {
            is_deeply( $result->parameters, $parameters, "$info - match -> parameters" );
        }
        else {
            is( $result->parameters, undef, "$info - match -> no parameters" );
        }

    }
    else {
        is( $result, undef, "$info - no match" );
    }

    return $result;

}


# ----------------------------------------------------------------------------------------------------------------------

package MyApp::Context;

use GX::Context;

package MyApp::Request;

use GX::Request;

