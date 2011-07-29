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


use Test::More tests => 42;


my $Action = GX::Action->new(
    controller => MyApp::Controller::A->new,
    method     => 'action_1'
);


# path_regex compilation
{

    my @data = (

        [ '/',    qr!^\/$!,     [] ],
        [ '/a',   qr!^\/a$!,    [] ],
        [ '/a/b', qr!^\/a\/b$!, [] ],

        [ '/{x}',         qr!^\/([^/]+)$!,                [ 'x' ]      ],
        [ '/{x}.{y}',     qr!^\/([^/]+)\.([^/]+)$!,       [ 'x', 'y' ] ],
        [ '/{x}/{y}',     qr!^\/([^/]+)\/([^/]+)$!,       [ 'x', 'y' ] ],
        [ '/a/{x}',       qr!^\/a\/([^/]+)$!,             [ 'x' ]      ],
        [ '/a/{x}/b/{y}', qr!^\/a\/([^/]+)\/b\/([^/]+)$!, [ 'x', 'y' ] ],

        [ '/{x:\d+}',             qr!^\/(\d+)$!,              [ 'x' ]      ],
        [ '/{x:\d+}.{y:\d+}',     qr!^\/(\d+)\.(\d+)$!,       [ 'x', 'y' ] ],
        [ '/{x:\d+}/{y:\d+}',     qr!^\/(\d+)\/(\d+)$!,       [ 'x', 'y' ] ],
        [ '/a/{x:\d+}',           qr!^\/a\/(\d+)$!,           [ 'x' ]      ],
        [ '/a/{x:\d+}/b/{y:\d+}', qr!^\/a\/(\d+)\/b\/(\d+)$!, [ 'x', 'y' ] ],

        [ '/{x:\d{2}}',             qr!^\/(\d{2})$!,            [ 'x' ]      ],
        [ '/{x:\d{2,4}}',           qr!^\/(\d{2,4})$!,          [ 'x' ]      ],
        [ '/{x:\d{2}}/{y:\d{2,4}}', qr!^\/(\d{2})\/(\d{2,4})$!, [ 'x', 'y' ] ],
        [ '/{x:\d{2,4}}/{y:\d{2}}', qr!^\/(\d{2,4})\/(\d{2})$!, [ 'x', 'y' ] ],

        [ '/*',     qr!^\/(?:[^/]+)$!,          [] ],
        [ '/a/*',   qr!^\/a\/(?:[^/]+)$!,       [] ],
        [ '/a/*/b', qr!^\/a\/(?:[^/]+)\/b$!,    [] ],
        [ '/*/*',   qr!^\/(?:[^/]+)\/(?:[^/]+)$!,  [] ],

    );

    for ( @data ) {

        my ( $path, $path_regex, $path_variables ) = @{$_};

        my $route = GX::Route::Dynamic->new(
            action => $Action,
            path   => $path
        );

        is( $route->path_regex, $path_regex, "Path regex for \"$path\"" );

        is_deeply( [ $route->path_variables ], $path_variables, "Path variables for \"$path\"" );

    }

}

