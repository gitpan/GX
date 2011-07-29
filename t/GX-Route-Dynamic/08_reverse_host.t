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


use Test::More tests => 88;


my $Action = GX::Action->new(
    controller => MyApp::Controller::A->new,
    method     => 'action_1'
);


# reverse_host
{

    my @data = (

        [ 'a',     'a',     [] ],
        [ 'a.b',   'a.b',   [] ],
        [ 'a.b.c', 'a.b.c', [] ],

        [ '{a}',     '%s',    [ 'a' ]      ],
        [ '{a}.b',   '%s.b',  [ 'a' ]      ],
        [ '{a}.{b}', '%s.%s', [ 'a', 'b' ] ],
        [ 'a.{b}',   'a.%s',  [ 'b' ]      ],

        [ '{a:\d+}',            '%s',    [ 'a' ]      ],
        [ '{a:\d+}.b',          '%s.b',  [ 'a' ]      ],
        [ '{a:\d+}.{b:[a-z]+}', '%s.%s', [ 'a', 'b' ] ],
        [ 'a.{b:\d+}',          'a.%s',  [ 'b' ]      ],

        [ '{a:\d{2}}',                '%s',    [ 'a' ]      ],
        [ '{a:\d{2,4}}.b',            '%s.b',  [ 'a' ]      ],
        [ '{a:\d{2}}.{b:[a-z]{2,4}}', '%s.%s', [ 'a', 'b' ] ],
        [ 'a.{b:\d{2}}',              'a.%s',  [ 'b' ]      ],

        [ '*',         undef, [] ],
        [ '*.b',       undef, [] ],
        [ '*.*',       undef, [] ],
        [ 'a.*',       undef, [] ],
        [ '{a}.*',     undef, [] ],
        [ '{a}.*.b',   undef, [] ],
        [ '{a}.*.{b}', undef, [] ],

        [ 'a:80',     'a:80',     [] ],
        [ 'a.b:80',   'a.b:80',   [] ],
        [ 'a.b.c:80', 'a.b.c:80', [] ],

        [ '{a}:80',     '%s:80',    [ 'a' ]      ],
        [ '{a}.b:80',   '%s.b:80',  [ 'a' ]      ],
        [ '{a}.{b}:80', '%s.%s:80', [ 'a', 'b' ] ],
        [ 'a.{b}:80',   'a.%s:80',  [ 'b' ]      ],

        [ '{a:\d+}:80',            '%s:80',    [ 'a' ]      ],
        [ '{a:\d+}.b:80',          '%s.b:80',  [ 'a' ]      ],
        [ '{a:\d+}.{b:[a-z]+}:80', '%s.%s:80', [ 'a', 'b' ] ],
        [ 'a.{b:\d+}:80',          'a.%s:80',  [ 'b' ]      ],

        [ '{a:\d{2}}:80',                '%s:80',    [ 'a' ]      ],
        [ '{a:\d{2,4}}.b:80',            '%s.b:80',  [ 'a' ]      ],
        [ '{a:\d{2}}.{b:[a-z]{2,4}}:80', '%s.%s:80', [ 'a', 'b' ] ],
        [ 'a.{b:\d{2}}:80',              'a.%s:80',  [ 'b' ]      ],

        [ '*:80',         undef, [] ],
        [ '*.b:80',       undef, [] ],
        [ '*.*:80',       undef, [] ],
        [ 'a.*:80',       undef, [] ],
        [ '{a}.*:80',     undef, [] ],
        [ '{a}.*.b:80',   undef, [] ],
        [ '{a}.*.{b}:80', undef, [] ]

    );

    for ( @data ) {

        my ( $host, $reverse_host, $reverse_host_variables ) = @{$_};

        my $route = GX::Route::Dynamic->new(
            action => $Action,
            host   => $host
        );

        is( $route->reverse_host, $reverse_host, "Reverse host for \"$host\"" );

        is_deeply( [ $route->reverse_host_variables ], $reverse_host_variables, "Reverse host variables for \"$host\"" );

    }

}

