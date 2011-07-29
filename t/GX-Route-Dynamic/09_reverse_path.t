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


use Test::More tests => 46;


my $Action = GX::Action->new(
    controller => MyApp::Controller::A->new,
    method     => 'action_1'
);


# reverse_path
{

    my @data = (

        [ '/',     '/',     [] ],
        [ '/a',    '/a',    [] ],
        [ '/a/',   '/a/',   [] ],
        [ '/a/b',  '/a/b',  [] ],
        [ '/a/b/', '/a/b/', [] ],

        [ '/{x}',         '/%s',        [ 'x' ]      ],
        [ '/{x}.{y}',     '/%s.%s',     [ 'x', 'y' ] ],
        [ '/{x}/{y}',     '/%s/%s',     [ 'x', 'y' ] ],
        [ '/a/{x}',       '/a/%s',      [ 'x' ]      ],
        [ '/a/{x}/b/{y}', '/a/%s/b/%s', [ 'x', 'y' ] ],

        [ '/{x:\d+}',             '/%s',        [ 'x' ]      ],
        [ '/{x:\d+}.{y:\d+}',     '/%s.%s',     [ 'x', 'y' ] ],
        [ '/{x:\d+}/{y:\d+}',     '/%s/%s',     [ 'x', 'y' ] ],
        [ '/a/{x:\d+}',           '/a/%s',      [ 'x' ]      ],
        [ '/a/{x:\d+}/b/{y:\d+}', '/a/%s/b/%s', [ 'x', 'y' ] ],

        [ '/{x:\d{2}}',             '/%s',    [ 'x' ]      ],
        [ '/{x:\d{2,4}}',           '/%s',    [ 'x' ]      ],
        [ '/{x:\d{2}}/{y:\d{2,4}}', '/%s/%s', [ 'x', 'y' ] ],
        [ '/{x:\d{2,4}}/{y:\d{2}}', '/%s/%s', [ 'x', 'y' ] ],

        [ '/*',     undef, [] ],
        [ '/a/*',   undef, [] ],
        [ '/a/*/b', undef, [] ],
        [ '/*/*',   undef, [] ]

    );

    for ( @data ) {

        my ( $path, $reverse_path, $reverse_path_variables ) = @{$_};

        my $route = GX::Route::Dynamic->new(
            action => $Action,
            path   => $path
        );

        is( $route->reverse_path, $reverse_path, "Reverse path for \"$path\"" );

        is_deeply( [ $route->reverse_path_variables ], $reverse_path_variables, "Reverse path variables for \"$path\"" );

    }

}

