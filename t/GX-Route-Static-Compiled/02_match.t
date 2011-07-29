#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Controller::A;
{

    use GX::Controller;

    sub action_1  :Action {}
    sub action_2  :Action {}
    sub action_3  :Action {}
    sub action_4  :Action {}
    sub action_5  :Action {}
    sub action_6  :Action {}
    sub action_7  :Action {}
    sub action_8  :Action {}
    sub action_9  :Action {}
    sub action_10 :Action {}

} 


package main;

use GX::Action;
use GX::Route::Static;
use GX::Route::Static::Compiled;


use Test::More tests => 246;


my @Actions = map {
    GX::Action->new(
        controller => MyApp::Controller::A->instance,
        method     => "action_$_"
    )
} 1 .. 10;


# path => ...
{

    my $route = GX::Route::Static::Compiled->new(
        GX::Route::Static->new( action => $Actions[0], path => '/'     ),
        GX::Route::Static->new( action => $Actions[1], path => '/a'    ),
        GX::Route::Static->new( action => $Actions[2], path => '/a/a'  ),
        GX::Route::Static->new( action => $Actions[3], path => '/b'    ),
        GX::Route::Static->new( action => $Actions[4], path => '/b/a'  ),
        GX::Route::Static->new( action => $Actions[5], path => '/c/'   ),
        GX::Route::Static->new( action => $Actions[6], path => '/c/c/' )
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '',      undef,       undef ],
        [ 'GET', 'http', 'localhost', '/x',    undef,       undef ],
        [ 'GET', 'http', 'localhost', '/',     $Actions[0], undef ],
        [ 'GET', 'http', 'localhost', '/a',    $Actions[1], undef ],
        [ 'GET', 'http', 'localhost', '/a/',   undef,       undef ],
        [ 'GET', 'http', 'localhost', '/a/a',  $Actions[2], undef ],
        [ 'GET', 'http', 'localhost', '/a/a/', undef,       undef ],
        [ 'GET', 'http', 'localhost', '/b',    $Actions[3], undef ],
        [ 'GET', 'http', 'localhost', '/b/a',  $Actions[4], undef ],
        [ 'GET', 'http', 'localhost', '/c',    undef,       undef ],
        [ 'GET', 'http', 'localhost', '/c/',   $Actions[5], undef ],
        [ 'GET', 'http', 'localhost', '/c/c',  undef,       undef ],
        [ 'GET', 'http', 'localhost', '/c/c/', $Actions[6], undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => ..., scheme => ...
{

    my $route = GX::Route::Static::Compiled->new(
        GX::Route::Static->new( action => $Actions[0], path => '/'                    ),
        GX::Route::Static->new( action => $Actions[1], path => '/', scheme => 'http'  ),
        GX::Route::Static->new( action => $Actions[2], path => '/', scheme => 'https' )
    );

    my $i;
    for my $data (
        [ 'GET', undef,   'localhost', '/',   $Actions[0], undef ],
        [ 'GET', '',      'localhost', '/',   $Actions[0], undef ],
        [ 'GET', 'ftp',   'localhost', '/',   $Actions[0], undef ],
        [ 'GET', 'http',  'localhost', '/',   $Actions[1], undef ],
        [ 'GET', 'https', 'localhost', '/',   $Actions[2], undef ],
        [ 'GET', 'http',  'localhost', undef, undef,       undef ],
        [ 'GET', 'http',  'localhost', '',    undef,       undef ],
        [ 'GET', 'http',  'localhost', '/x',  undef,       undef ]

    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => ..., scheme => ..., host => ...
{

    my $route = GX::Route::Static::Compiled->new(
        GX::Route::Static->new( action => $Actions[0], path => '/'                                     ),
        GX::Route::Static->new( action => $Actions[1], path => '/', scheme => 'http'                   ),
        GX::Route::Static->new( action => $Actions[2], path => '/', scheme => 'http',  host => 'host1' ),
        GX::Route::Static->new( action => $Actions[3], path => '/', scheme => 'https'                  ),
        GX::Route::Static->new( action => $Actions[4], path => '/', scheme => 'https', host => 'host1' ),
        GX::Route::Static->new( action => $Actions[5], path => '/', scheme => 'https', host => 'host2' )
    );

    my $i;
    for my $data (
        [ 'GET', undef,   'hostx', '/',   $Actions[0], undef ],
        [ 'GET', '',      'hostx', '/',   $Actions[0], undef ],
        [ 'GET', 'ftp',   'hostx', '/',   $Actions[0], undef ],
        [ 'GET', 'http',  undef,   '/',   $Actions[1], undef ],
        [ 'GET', 'http',  '',      '/',   $Actions[1], undef ],
        [ 'GET', 'http',  'hostx', '/',   $Actions[1], undef ],
        [ 'GET', 'http',  'host1', '/',   $Actions[2], undef ],
        [ 'GET', 'https', undef,   '/',   $Actions[3], undef ],
        [ 'GET', 'https', '',      '/',   $Actions[3], undef ],
        [ 'GET', 'https', 'hostx', '/',   $Actions[3], undef ],
        [ 'GET', 'https', 'host1', '/',   $Actions[4], undef ],
        [ 'GET', 'https', 'host2', '/',   $Actions[5], undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => ..., scheme => ..., host => ..., method => ...
{

    my $route = GX::Route::Static::Compiled->new(
        GX::Route::Static->new( action => $Actions[0], path => '/', scheme => 'http', host => 'host1'                   ),
        GX::Route::Static->new( action => $Actions[1], path => '/', scheme => 'http', host => 'host1', method => 'GET'  ),
        GX::Route::Static->new( action => $Actions[2], path => '/', scheme => 'http', host => 'host1', method => 'POST' ),
    );

    my $i;
    for my $data (
        [ undef,  'http', 'host1', '/', $Actions[0], undef ],
        [ '',     'http', 'host1', '/', $Actions[0], undef ],
        [ 'HEAD', 'http', 'host1', '/', $Actions[0], undef ],
        [ 'GET',  'http', 'host1', '/', $Actions[1], undef ],
        [ 'POST', 'http', 'host1', '/', $Actions[2], undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => ..., host => ...
{

    my $route = GX::Route::Static::Compiled->new(
        GX::Route::Static->new( action => $Actions[0], path => '/'                  ),
        GX::Route::Static->new( action => $Actions[1], path => '/', host => 'host1' ),
        GX::Route::Static->new( action => $Actions[2], path => '/', host => 'host2' )
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'host0', '',   undef,       undef ],
        [ 'GET', 'http', 'host0', '/x', undef,       undef ],
        [ 'GET', 'http', 'host0', '/',  $Actions[0], undef ],
        [ 'GET', 'http', 'host1', '',   undef,       undef ],
        [ 'GET', 'http', 'host1', '/x', undef,       undef ],
        [ 'GET', 'http', 'host1', '/',  $Actions[1], undef ],
        [ 'GET', 'http', 'host2', '',   undef,       undef ],
        [ 'GET', 'http', 'host2', '/x', undef,       undef ],
        [ 'GET', 'http', 'host2', '/',  $Actions[2], undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => ..., method => ...
{

    my $route = GX::Route::Static::Compiled->new(
        GX::Route::Static->new( action => $Actions[0], path => '/'                    ),
        GX::Route::Static->new( action => $Actions[1], path => '/',  method => 'GET'  ),
        GX::Route::Static->new( action => $Actions[2], path => '/',  method => 'POST' ),
        GX::Route::Static->new( action => $Actions[3], path => '/a'                   ),
        GX::Route::Static->new( action => $Actions[4], path => '/a', method => 'GET'  ),
        GX::Route::Static->new( action => $Actions[5], path => '/a', method => 'POST' ),
        GX::Route::Static->new( action => $Actions[6], path => '/b'                   )
    );

    my $i;
    for my $data (
        [ '',     'http', 'localhost', '',   undef,       undef ],
        [ 'GET',  'http', 'localhost', '',   undef,       undef ],
        [ 'GET',  'http', 'localhost', '/x', undef,       undef ],
        [ '',     'http', 'localhost', '/',  $Actions[0], undef ],
        [ 'HEAD', 'http', 'localhost', '/',  $Actions[0], undef ],
        [ 'GET',  'http', 'localhost', '/',  $Actions[1], undef ],
        [ 'POST', 'http', 'localhost', '/',  $Actions[2], undef ],
        [ '',     'http', 'localhost', '/a', $Actions[3], undef ],
        [ 'HEAD', 'http', 'localhost', '/a', $Actions[3], undef ],
        [ 'GET',  'http', 'localhost', '/a', $Actions[4], undef ],
        [ 'POST', 'http', 'localhost', '/a', $Actions[5], undef ],
        [ 'HEAD', 'http', 'localhost', '/b', $Actions[6], undef ],
        [ 'GET',  'http', 'localhost', '/b', $Actions[6], undef ],
        [ 'POST', 'http', 'localhost', '/b', $Actions[6], undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => ..., host => ..., method => ...
{

    my $route = GX::Route::Static::Compiled->new(
        GX::Route::Static->new( action => $Actions[0], path => '/',  host => 'host1'                    ),
        GX::Route::Static->new( action => $Actions[1], path => '/',  host => 'host1',  method => 'GET'  ),
        GX::Route::Static->new( action => $Actions[2], path => '/',  host => 'host1',  method => 'POST' ),
        GX::Route::Static->new( action => $Actions[3], path => '/',  host => 'host2'                    ),
        GX::Route::Static->new( action => $Actions[4], path => '/',  host => 'host2',  method => 'GET'  ),
        GX::Route::Static->new( action => $Actions[5], path => '/',  host => 'host2',  method => 'POST' ),
        GX::Route::Static->new( action => $Actions[6], path => '/a'                                     ),
        GX::Route::Static->new( action => $Actions[7], path => '/b'                                     ),
        GX::Route::Static->new( action => $Actions[8], path => '/b', method => 'GET'                    ),
        GX::Route::Static->new( action => $Actions[9], path => '/b', method => 'POST'                   )
    );

    my $i;
    for my $data (
        [ '',     'http', 'host1', '/',  $Actions[0], undef ],
        [ 'HEAD', 'http', 'host1', '/',  $Actions[0], undef ],
        [ 'GET',  'http', 'host1', '/',  $Actions[1], undef ],
        [ 'POST', 'http', 'host1', '/',  $Actions[2], undef ],
        [ '',     'http', 'host2', '/',  $Actions[3], undef ],
        [ 'HEAD', 'http', 'host2', '/',  $Actions[3], undef ],
        [ 'GET',  'http', 'host2', '/',  $Actions[4], undef ],
        [ 'POST', 'http', 'host2', '/',  $Actions[5], undef ],
        [ '',     'http', '',      '/a', $Actions[6], undef ],
        [ 'HEAD', 'http', 'hostx', '/a', $Actions[6], undef ],
        [ '',     'http', 'hostx', '/b', $Actions[7], undef ],
        [ 'HEAD', 'http', 'hostx', '/b', $Actions[7], undef ],
        [ 'GET',  'http', 'hostx', '/b', $Actions[8], undef ],
        [ 'POST', 'http', 'hostx', '/b', $Actions[9], undef ]
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

