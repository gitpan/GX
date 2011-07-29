#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 183;


require_ok( 'MyApp' );

my $MyApp  = MyApp->instance;
my $Router = $MyApp->router;


my @Data = (

    [ 'GET', 'http', 'localhost', '',   undef, undef ],
    [ 'GET', 'http', 'localhost', '/',  undef, undef ],
    [ 'GET', 'http', 'localhost', '/x', undef, undef ],

    [ 'GET', 'http', 'localhost', '/a/action_1', $MyApp->action( 'A', 'action_1' ), undef ],
    [ 'GET', 'http', 'localhost', '/a/action_2', $MyApp->action( 'A', 'action_2' ), undef ],
    [ 'GET', 'http', 'localhost', '/a/action_3', $MyApp->action( 'A', 'action_3' ), undef ],

    [ 'GET', 'http', 'localhost', '/a/static_4', $MyApp->action( 'A', 'action_4' ), undef ],
    [ 'GET', 'http', 'localhost', '/a/static_5', $MyApp->action( 'A', 'action_5' ), undef ],
    [ 'GET', 'http', 'localhost', '/a/static_6', $MyApp->action( 'A', 'action_6' ), undef ],
    [ 'GET', 'http', 'localhost', '/a/action_4', undef, undef ],
    [ 'GET', 'http', 'localhost', '/a/action_5', undef, undef ],
    [ 'GET', 'http', 'localhost', '/a/action_6', undef, undef ],

    [ 'GET', 'http', 'localhost', '/a/path_7/v1', $MyApp->action( 'A', 'action_7' ), [ 'k1' => [ 'v1' ] ] ],
    [ 'GET', 'http', 'localhost', '/a/path_8/v1', $MyApp->action( 'A', 'action_8' ), [ 'k1' => [ 'v1' ] ] ],
    [ 'GET', 'http', 'localhost', '/a/path_9/v1', $MyApp->action( 'A', 'action_9' ), [ 'k1' => [ 'v1' ] ] ],
    [ 'GET', 'http', 'localhost', '/a/action_7', undef, undef ],
    [ 'GET', 'http', 'localhost', '/a/action_8', undef, undef ],
    [ 'GET', 'http', 'localhost', '/a/action_9', undef, undef ],

    [ 'GET', 'http', 'localhost', '/b/action_1', $MyApp->action( 'B', 'action_1' ), undef ],
    [ 'GET', 'http', 'localhost', '/b/action_2', $MyApp->action( 'B', 'action_2' ), undef ],
    [ 'GET', 'http', 'localhost', '/b/action_3', $MyApp->action( 'B', 'action_3' ), undef ],

    [ 'GET', 'http', 'localhost', '/b/static_4', $MyApp->action( 'B', 'action_4' ), undef ],
    [ 'GET', 'http', 'localhost', '/b/static_5', $MyApp->action( 'B', 'action_5' ), undef ],
    [ 'GET', 'http', 'localhost', '/b/static_6', $MyApp->action( 'B', 'action_6' ), undef ],
    [ 'GET', 'http', 'localhost', '/b/action_4', undef, undef ],
    [ 'GET', 'http', 'localhost', '/b/action_5', undef, undef ],
    [ 'GET', 'http', 'localhost', '/b/action_6', undef, undef ],

    [ 'GET', 'http', 'localhost', '/b/path_7/v1', $MyApp->action( 'B', 'action_7' ), [ 'k1' => [ 'v1' ] ] ],
    [ 'GET', 'http', 'localhost', '/b/path_8/v1', $MyApp->action( 'B', 'action_8' ), [ 'k1' => [ 'v1' ] ] ],
    [ 'GET', 'http', 'localhost', '/b/path_9/v1', $MyApp->action( 'B', 'action_9' ), [ 'k1' => [ 'v1' ] ] ],
    [ 'GET', 'http', 'localhost', '/b/action_7', undef, undef ],
    [ 'GET', 'http', 'localhost', '/b/action_8', undef, undef ],
    [ 'GET', 'http', 'localhost', '/b/action_9', undef, undef ],

    [ 'GET', 'http', 'localhost', '/c/action_1', $MyApp->action( 'C', 'action_1' ), undef ],
    [ 'GET', 'http', 'localhost', '/c/action_2', $MyApp->action( 'C', 'action_2' ), undef ],
    [ 'GET', 'http', 'localhost', '/c/action_3', $MyApp->action( 'C', 'action_3' ), undef ],

    [ 'GET', 'http', 'localhost', '/router/static_1',  $MyApp->action( 'C', 'action_1' ), undef ],
    [ 'GET', 'http', 'localhost', '/router/path_2/v1', $MyApp->action( 'C', 'action_2' ), [ 'k1' => [ 'v1' ] ] ],

);


# match()
{

    _match( $_ ) for @Data;

}

# resolve()
{

    _resolve( $_ ) for @Data;

}


# ----------------------------------------------------------------------------------------------------------------------

sub _fake_context {

    return MyApp::Context->new(
        request  => MyApp::Request->new,
        response => MyApp::Response->new,
        @_
    );

}

sub _match {

    my ( $data ) = @_;

    my ( $method, $scheme, $host, $path, $action, $parameters ) = @$data;

    my $request = MyApp::Request->new;
    $request->scheme( $scheme );
    $request->host( $host );
    $request->method( $method );
    $request->path( $path );

    my $context = _fake_context( request => $request );

    my $result = $Router->match( $context );

    if ( $action ) {

        ok( $result, "\"$path\" -> match" );

        isa_ok( $result, 'GX::Route::Match' );

        is( $result->action, $action, "\"$path\" -> matched action" );

        if ( $parameters ) {
            isa_ok( $result->parameters, 'GX::HTTP::Parameters' );
            my @parameters = map { ( $_ => [ $result->parameters->get( $_ ) ] ) } $result->parameters->keys;
            is_deeply( \@parameters, $parameters, "\"$path\" -> captured parameters" );
        }
        else {
            is( $result->parameters, undef, "\"$path\" -> no captured parameters" );
        }

    }
    else {
        is( $result, undef, "\"$path\" -> no match" );
    }

}

sub _resolve {

    my ( $data ) = @_;

    my ( $method, $scheme, $host, $path, $action, $parameters ) = @$data;

    my $request = MyApp::Request->new;
    $request->scheme( $scheme );
    $request->host( $host );
    $request->method( $method );
    $request->path( $path );

    my $context = _fake_context( request => $request );

    $Router->resolve( $context );

    if ( $action ) {

        is_deeply( [ $context->action_queue->all ], [ $action ], "\"$path\" -> resolved" );

        my $path_parameters = $context->request->path_parameters;

        if ( $parameters ) {
            isa_ok( $path_parameters, 'GX::HTTP::Parameters' );
            my @parameters = map { ( $_ => [ $path_parameters->get( $_ ) ] ) } $path_parameters->keys;
            is_deeply( \@parameters, $parameters, "\"$path\" -> parameters" );
        }
        else {
            is_deeply( [ $path_parameters->keys ], [], "\"$path\" -> no parameters" );
        }

    }
    else {
        is_deeply( [ $context->action_queue->all ], [ $Router->default_action ], "\"$path\" -> default action" );
    }

}

