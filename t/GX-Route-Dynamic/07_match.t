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
use GX::Route::Dynamic;


use Test::More tests => 151;


my $Action = GX::Action->new(
    controller => MyApp::Controller::A->new,
    method     => 'action_1'
);


# path => '/'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/',   $Action, undef ],
        [ 'GET', 'http', 'localhost', '/x',  undef,   undef ],
        [ 'GET', 'http', 'localhost', undef, undef,   undef ],
        [ 'GET', 'http', 'localhost', '',    undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/a'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/a',  $Action, undef ],
        [ 'GET', 'http', 'localhost', '/a/', undef,   undef ],
        [ 'GET', 'http', 'localhost', '/x',  undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/a/'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a/'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/a/',  $Action, undef ],
        [ 'GET', 'http', 'localhost', '/a',   undef,   undef ],
        [ 'GET', 'http', 'localhost', '/x',   undef,   undef ],
        [ 'GET', 'http', 'localhost', '/a/b', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/{a}'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/{a}'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/x',   $Action, { 'a' => [ 'x' ] } ],
        [ 'GET', 'http', 'localhost', '/x/',  undef,   undef ],
        [ 'GET', 'http', 'localhost', '/x/y', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/{a}/{b}'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/{a}/{b}'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/x/y',  $Action, { 'a' => [ 'x' ], 'b' => [ 'y' ] } ],
        [ 'GET', 'http', 'localhost', '/x/y/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/a/{b:\d+}/{c}'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a/{b:\d+}/{c}'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/a/2/3',   $Action, { 'b' => [ 2 ], 'c' => [ 3 ] } ],
        [ 'GET', 'http', 'localhost', '/a/x/y',   undef,   undef ],
        [ 'GET', 'http', 'localhost', '/a/2/x/y', undef,   undef ],
        [ 'GET', 'http', 'localhost', '/a/2/3/',  undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/a/{b}/{c}', constraints => { 'b' => '\d+' }
{

    my $route = GX::Route::Dynamic->new(
        action      => $Action,
        path        => '/a/{b}/{c}',
        constraints => { 'b' => '\d+' }
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/a/2/3',   $Action, { 'b' => [ 2 ], 'c' => [ 3 ] } ],
        [ 'GET', 'http', 'localhost', '/a/x/y',   undef,   undef ],
        [ 'GET', 'http', 'localhost', '/a/2/x/y', undef,   undef ],
        [ 'GET', 'http', 'localhost', '/a/2/3/',  undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# path => '/{a}.{format}'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/{a}.{format}'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/x.y',   $Action, { 'a' => [ 'x' ], 'format' => [ 'y' ] } ],
    ) {
        my $match = _match( $route, $data, __LINE__ . " " . ++$i );
        is( $match->format, 'y' );
    }

}

# host => 'a'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
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

# host => 'a.b'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        host   => 'a.b'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'a.b',   '/', $Action, undef ],
        [ 'GET', 'http', undef,   '/', undef,   undef ],
        [ 'GET', 'http', '',      '/', undef,   undef ],
        [ 'GET', 'http', 'x',     '/', undef,   undef ],
        [ 'GET', 'http', 'a',     '/', undef,   undef ],
        [ 'GET', 'http', 'a.',    '/', undef,   undef ],
        [ 'GET', 'http', 'a.b.',  '/', undef,   undef ],
        [ 'GET', 'http', 'a.b.c', '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# host => 'a:80'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        host   => 'a:80'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'a:80', '/', $Action, undef ],
        [ 'GET', 'http', undef,  '/', undef,   undef ],
        [ 'GET', 'http', '',     '/', undef,   undef ],
        [ 'GET', 'http', 'a',    '/', undef,   undef ],
        [ 'GET', 'http', 'a:81', '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# host => 'a.b:80'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        host   => 'a.b:80'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'a.b:80', '/', $Action, undef ],
        [ 'GET', 'http', undef,    '/', undef,   undef ],
        [ 'GET', 'http', '',       '/', undef,   undef ],
        [ 'GET', 'http', 'a.b',    '/', undef,   undef ],
        [ 'GET', 'http', 'a.b:81', '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# host => '{a}'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        host   => '{a}'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'x',   '/', $Action, { 'a' => [ 'x' ] } ],
        [ 'GET', 'http', undef, '/', undef,   undef ],
        [ 'GET', 'http', '',    '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# host => '{a}.{b}'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        host   => '{a}.{b}'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'x.y',   '/', $Action, { 'a' => [ 'x' ], 'b' => [ 'y' ] } ],
        [ 'GET', 'http', undef,   '/', undef,   undef ],
        [ 'GET', 'http', '',      '/', undef,   undef ],
        [ 'GET', 'http', 'x',     '/', undef,   undef ],
        [ 'GET', 'http', 'x.y.z', '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# methods => [ 'GET' ]
{

    my $route = GX::Route::Dynamic->new(
        action  => $Action,
        methods => [ 'GET' ]
    );

    my $i;
    for my $data (
        [ 'GET',  'http', 'localhost', '/', $Action, undef ],
        [ undef,  'http', 'localhost', '/', undef,   undef ],
        [ '',     'http', 'localhost', '/', undef,   undef ],
        [ 'POST', 'http', 'localhost', '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# methods => [ 'GET', 'POST' ]
{

    my $route = GX::Route::Dynamic->new(
        action  => $Action,
        methods => [ 'GET', 'POST' ]
    );

    my $i;
    for my $data (
        [ 'GET',  'http', 'localhost', '/', $Action, undef ],
        [ 'POST', 'http', 'localhost', '/', $Action, undef ],
        [ undef,  'http', 'localhost', '/', undef,   undef ],
        [ '',     'http', 'localhost', '/', undef,   undef ],
        [ 'HEAD', 'http', 'localhost', '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# schemes => [ 'http' ]
{

    my $route = GX::Route::Dynamic->new(
        action  => $Action,
        schemes => [ 'http' ]
    );

    my $i;
    for my $data (
        [ 'GET', 'http',  'localhost', '/', $Action, undef ],
        [ 'GET', 'https', 'localhost', '/', undef,   undef ],
        [ 'GET', undef,   'localhost', '/', undef,   undef ],
        [ 'GET', '',      'localhost', '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# schemes => [ 'http', 'https' ]
{

    my $route = GX::Route::Dynamic->new(
        action  => $Action,
        schemes => [ 'http', 'https' ]
    );

    my $i;
    for my $data (
        [ 'GET', 'http',  'localhost', '/', $Action, undef ],
        [ 'GET', 'https', 'localhost', '/', $Action, undef ],
        [ 'GET', 'ftp',   'localhost', '/', undef,   undef ],
        [ 'GET', undef,   'localhost', '/', undef,   undef ],
        [ 'GET', '',      'localhost', '/', undef,   undef ]
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# Defaults
{

    my $route = GX::Route::Dynamic->new(
        action   => $Action,
        path     => '/{a}/{b}',
        defaults => { 'a' => 'a_default', 'c' => 'c_default', 'd' => 'd_default' }
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/1/2',  $Action, { 'a' => [ 1 ], 'b' => [ 2 ], 'c' => [ 'c_default' ], 'd' => [ 'd_default' ] } ],
    ) {
        _match( $route, $data, __LINE__ . " " . ++$i );
    }

}

# URL-encoded captures
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/{a}/{b}/{c}'
    );

    my $i;
    for my $data (
        [ 'GET', 'http', 'localhost', '/%40a%25/b%26/%25c', $Action, { 'a' => [ '@a%' ], 'b' => [ 'b&' ], 'c' => [ '%c' ] } ]
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
            isa_ok( $result->parameters, 'GX::HTTP::Parameters' );
            my %parameters = map { ( $_ => [ $result->parameters->get( $_ ) ] ) } $result->parameters->keys;
            is_deeply( \%parameters, $parameters, "$info - match -> parameters" );
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


