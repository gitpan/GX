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
use Scalar::Util qw( weaken );


use Test::More tests => 12;


my $Controller_A = MyApp::Controller::A->instance;


# new( controller => $controller, ... )
{

    my $action = GX::Action->new(
        controller => $Controller_A,
        method     => 'action_1'
    );

    isa_ok( $action, 'GX::Action' );

    is( $action->controller, $Controller_A );
    is( $action->method, 'action_1' );
    is( $action->name, 'action_1' );
    is( $action->code, $Controller_A->can( 'action_1' ) );

}

# new( controller => $controller_class, ... )
{

    my $action = GX::Action->new(
        controller => 'MyApp::Controller::A',
        method     => 'action_1'
    );

    isa_ok( $action, 'GX::Action' );

    is( $action->controller, $Controller_A );
    is( $action->method, 'action_1' );
    is( $action->name, 'action_1' );
    is( $action->code, $Controller_A->can( 'action_1' ) );

}

# Weak controller reference
{

    my $action = GX::Action->new(
        controller => $Controller_A,
        method     => 'action_1'
    );

    $Controller_A->destroy;
    weaken $Controller_A;
    is( $Controller_A, undef );
    is( $action->controller, undef );

}

