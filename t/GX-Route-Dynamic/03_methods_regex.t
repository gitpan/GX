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


use Test::More tests => 3;


my $Action = GX::Action->new(
    controller => MyApp::Controller::A->new,
    method     => 'action_1'
);


# method_regex compilation
{

    my @data = (
        [ [ 'GET' ],         qr/^GET$/      ],
        [ [ 'gEt' ],         qr/^GET$/      ],
        [ [ 'get', 'POST' ], qr/^GET|POST$/ ]
    );

    for ( @data ) {

        my ( $methods, $methods_regex ) = @{$_};

        my $route = GX::Route::Dynamic->new(
            action  => $Action,
            path    => '/a',
            methods => $methods
        );

        is( $route->methods_regex, $methods_regex, "Method regex (@$methods)" );

    }

}

