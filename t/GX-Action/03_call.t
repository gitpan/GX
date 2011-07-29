#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Controller::A;
{

    use GX::Controller;

    sub action_1 :Action { @_ }

}


package main;

use GX::Action;


use Test::More tests => 3;


# call()
{


    my $controller = MyApp::Controller::A->new;

    my $action = GX::Action->new(
        controller => $controller,
        method     => 'action_1'
    );

    is_deeply( [ $action->call ],           [ $controller ] );
    is_deeply( [ $action->call( 1 ) ],      [ $controller, 1 ] );
    is_deeply( [ $action->call( 1 .. 3 ) ], [ $controller, 1 .. 3 ] );

}

