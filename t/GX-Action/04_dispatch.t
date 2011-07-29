#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Controller::A;
{

    use GX::Controller;

    sub action_1 :Action { @_ }

    sub dispatch { @_ }

}


package main;

use GX::Action;


use Test::More tests => 1;


# dispatch()
{


    my $controller = MyApp::Controller::A->new;

    my $action = GX::Action->new(
        controller => $controller,
        method     => 'action_1'
    );

    my $context = bless {}, 'MyApp::Context';

    is_deeply( [ $action->dispatch( $context ) ], [ $controller, $context, $action ] );

}

