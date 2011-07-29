#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 120;


require_ok( 'MyApp' );

my $MyApp = MyApp->instance;


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A
# ----------------------------------------------------------------------------------------------------------------------

{

    my $controller = $MyApp->controller( 'A' );

    my @routes = sort { $a->action->name cmp $b->action->name } $controller->routes;

    is( scalar @routes, 3 );

    for my $i ( 0 .. 2 ) {

        my $route = $routes[$i];

        isa_ok( $route, 'GX::Route::Static' );

        is( $route->action->controller, $controller );
        is( $route->action->name, "action_" . ( $i + 1 ) );
        is( $route->path, "/a/action_" . ( $i + 1 ) );

    }

}


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A::A
# ----------------------------------------------------------------------------------------------------------------------

{

    my $controller = $MyApp->controller( 'A::A' );

    my @routes = sort { $a->action->name cmp $b->action->name } $controller->routes;

    is( scalar @routes, 5 );

    for my $i ( 0 .. 4 ) {

        my $route = $routes[$i];

        isa_ok( $route, 'GX::Route::Static' );

        is( $route->action->controller, $controller );
        is( $route->action->name, "action_" . ( $i + 1 ) );
        is( $route->path, "/a/a/action_" . ( $i + 1 ) );

    }

}


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::B
# ----------------------------------------------------------------------------------------------------------------------

{

    my $controller = $MyApp->controller( 'B' );

    my @routes = $controller->routes;

    is( scalar @routes, 21 );

    isa_ok( $routes[0], 'GX::Route::Static' );
    is( $routes[0]->action->controller, $controller );
    is( $routes[0]->action->name, 'action_1' );
    is( $routes[0]->path, '/b/action_1/custom' );

    isa_ok( $routes[1], 'GX::Route::Static' );
    is( $routes[1]->action->controller, $controller );
    is( $routes[1]->action->name, 'action_2' );
    is( $routes[1]->path, '/b/action_2/custom' );

    isa_ok( $routes[2], 'GX::Route::Static' );
    is( $routes[2]->action->controller, $controller );
    is( $routes[2]->action->name, 'action_3' );
    is( $routes[2]->path, '/b/action_3/custom' );

    isa_ok( $routes[3], 'GX::Route::Dynamic' );
    is( $routes[3]->action->controller, $controller );
    is( $routes[3]->action->name, 'action_4' );
    is( $routes[3]->path, '/b/action_4/custom/{parameter_1}' );

    isa_ok( $routes[4], 'GX::Route::Dynamic' );
    is( $routes[4]->action->controller, $controller );
    is( $routes[4]->action->name, 'action_5' );
    is( $routes[4]->path, '/b/action_5/custom/{parameter_1}' );

    isa_ok( $routes[5], 'GX::Route::Dynamic' );
    is( $routes[5]->action->controller, $controller );
    is( $routes[5]->action->name, 'action_6' );
    is( $routes[5]->path, '/b/action_6/custom/{parameter_1}' );

    isa_ok( $routes[6], 'GX::Route::Static' );
    is( $routes[6]->action->controller, $controller );
    is( $routes[6]->action->name, 'action_7' );
    is( $routes[6]->path, '/b/action_7/custom' );

    isa_ok( $routes[7], 'GX::Route::Dynamic' );
    is( $routes[7]->action->controller, $controller );
    is( $routes[7]->action->name, 'action_7' );
    is( $routes[7]->path, '/b/action_7/custom/{parameter_1}' );

    isa_ok( $routes[8], 'GX::Route::Static' );
    is( $routes[8]->action->controller, $controller );
    is( $routes[8]->action->name, 'action_8' );
    is( $routes[8]->path, '/b/action_8/custom/1' );

    isa_ok( $routes[9], 'GX::Route::Static' );
    is( $routes[9]->action->controller, $controller );
    is( $routes[9]->action->name, 'action_8' );
    is( $routes[9]->path, '/b/action_8/custom/2' );

    isa_ok( $routes[10], 'GX::Route::Static' );
    is( $routes[10]->action->controller, $controller );
    is( $routes[10]->action->name, 'action_9' );
    is( $routes[10]->path, '/b/action_9/custom' );

    isa_ok( $routes[11], 'GX::Route::Static' );
    is( $routes[11]->action->controller, $controller );
    is( $routes[11]->action->name, 'action_10' );
    is( $routes[11]->path, '/b/action_10/custom' );

    isa_ok( $routes[12], 'GX::Route::Static' );
    is( $routes[12]->action->controller, $controller );
    is( $routes[12]->action->name, 'action_11' );
    is( $routes[12]->path, '/b/action_11/custom' );

    isa_ok( $routes[13], 'GX::Route::Dynamic' );
    is( $routes[13]->action->controller, $controller );
    is( $routes[13]->action->name, 'action_12' );
    is( $routes[13]->path, '/b/action_12/custom/{parameter_1}' );

    isa_ok( $routes[14], 'GX::Route::Dynamic' );
    is( $routes[14]->action->controller, $controller );
    is( $routes[14]->action->name, 'action_13' );
    is( $routes[14]->path, '/b/action_13/custom/{parameter_1}' );

    isa_ok( $routes[15], 'GX::Route::Dynamic' );
    is( $routes[15]->action->controller, $controller );
    is( $routes[15]->action->name, 'action_14' );
    is( $routes[15]->path, '/b/action_14/custom/{parameter_1}' );

    isa_ok( $routes[16], 'GX::Route::Static' );
    is( $routes[16]->action->controller, $controller );
    is( $routes[16]->action->name, 'action_15' );
    is( $routes[16]->path, '/b/action_15/custom/1' );

    isa_ok( $routes[17], 'GX::Route::Static' );
    is( $routes[17]->action->controller, $controller );
    is( $routes[17]->action->name, 'action_15' );
    is( $routes[17]->path, '/b/action_15/custom/2' );

    isa_ok( $routes[18], 'GX::Route::Static' );
    is( $routes[18]->action->controller, $controller );
    is( $routes[18]->action->name, 'action_16' );
    is( $routes[18]->path, '/b/action_16/custom' );

    isa_ok( $routes[19], 'GX::Route::Dynamic' );
    is( $routes[19]->action->controller, $controller );
    is( $routes[19]->action->name, 'action_17' );
    is( $routes[19]->path, '/b/action_17/custom/{parameter_1}' );

    isa_ok( $routes[20], 'GX::Route::Static' );
    is( $routes[20]->action->controller, $controller );
    is( $routes[20]->action->name, 'action_19' );
    is( $routes[20]->path, '/b/action_19' );

}

