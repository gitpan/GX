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


use Test::More tests => 7;


my $Action = GX::Action->new(
    controller => MyApp::Controller::A->instance,
    method     => 'action_1'
);


# new
{

    my $route = GX::Route::Static->new(
        action => $Action,
        path   => '/a'
    );

    isa_ok( $route, 'GX::Route::Static' );

    is( $route->action, $Action );
    is( $route->method, undef );
    is( $route->scheme, undef );
    is( $route->host, undef );
    is( $route->path, '/a' );
    ok( $route->is_reversible );

}

