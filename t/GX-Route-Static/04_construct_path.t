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


use Test::More tests => 1;


my $Action = GX::Action->new(
    controller => MyApp::Controller::A->instance,
    method     => 'action_1'
);


# construct_path()
{

    my $route = GX::Route::Static->new( action => $Action, path => '/a' );

    is( $route->construct_path, '/a' );

}

