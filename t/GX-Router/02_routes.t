#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Controller::A;
{

    use GX::Controller;

    sub action_0 :Action {}
    sub action_1 :Action {}
    sub action_2 :Action {}
    sub action_3 :Action {}
    sub action_4 :Action {}
    sub action_5 :Action {}
    sub action_6 :Action {}
    sub action_7 :Action {}
    sub action_8 :Action {}
    sub action_9 :Action {}

} 

package MyApp::Router;
{

    use GX::Router;

    __PACKAGE__->setup;

}


package main;

use GX::Action;
use GX::Route::Static;


use Test::More tests => 73;


my $Router = MyApp::Router->instance;

my @Actions = map {
    GX::Action->new(
        controller => MyApp::Controller::A->instance,
        method     => "action_$_"
    )
} 0 .. 9;

my @Routes = map {
    GX::Route::Static->new(
        action => $Actions[$_],
        path   => "/action_$_"
    )
} 0 .. 9;


# add_route
{

    is_deeply( [ $Router->routes ], [] );

    for ( 0 .. 9 ) {

        $Router->add_route( $Routes[$_] );

        is_deeply( [ $Router->routes ], [ @Routes[ 0 .. $_ ] ] );

        is( $Router->path_for_action( $Actions[$_] ), "/action_$_" );
        is( $Router->uri_for_action( action => $Actions[$_], host => 'myhost' ), "http://myhost/action_$_" );

    }

    is_deeply( [ $Router->routes ], \@Routes );

}

# remove_route
{

    for ( reverse 0 .. 9 ) {

        is_deeply( [ $Router->routes ], [ @Routes[ 0 .. $_ ] ] );

        ok( $Router->remove_route( $Routes[$_] ) );

        is( $Router->path_for_action( $Actions[$_] ), undef );
        is( $Router->uri_for_action( $Actions[$_] ), undef );

    }

    is_deeply( [ $Router->routes ], [] );

}

