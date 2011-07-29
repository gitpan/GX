#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Controller::A;

use GX::Controller;


package main;

use Scalar::Util qw( refaddr );


use Test::More tests => 4;


# new()
{

    my $controller = MyApp::Controller::A->new;

    isa_ok( $controller, 'MyApp::Controller::A' );
    isa_ok( $controller, 'GX::Controller' );

    is( refaddr( $controller->new ), refaddr( $controller ) );

    is( $controller->name, 'A' );

}

