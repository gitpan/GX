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
        [ [ 'http' ],          qr/^http$/       ],
        [ [ 'hTTp' ],          qr/^http$/       ],
        [ [ 'HTTP', 'https' ], qr/^http|https$/ ]
    );

    for ( @data ) {

        my ( $schemes, $schemes_regex ) = @{$_};

        my $route = GX::Route::Dynamic->new(
            action  => $Action,
            schemes => $schemes
        );

        is( $route->schemes_regex, $schemes_regex, "Schemes regex (@$schemes)" );

    }

}

