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


use Test::More tests => 41;


my $Action = GX::Action->new(
    controller => MyApp::Controller::A->new,
    method     => 'action_1'
);


# new(), attribute slot initialization
{

    my $route = GX::Route::Dynamic->new( action => $Action );

    for ( qw(
        action
        constraints
        defaults
        host
        host_regex
        host_variables
        is_reversible
        methods
        methods_regex
        path
        path_regex
        path_variables
        reverse_host
        reverse_host_variables
        reverse_path
        reverse_path_variables
        reverse_scheme
        schemes
        schemes_regex
    ) ) {
        ok( exists $route->{$_}, "\"$_\" attribute slot" );
    }

    is( scalar keys %$route, 19 );

}

# new(), initialization, accessors
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a/{b}/{c:\d+}'
    );

    isa_ok( $route, 'GX::Route::Dynamic' );

    is( $route->action, $Action );

    is_deeply( { $route->constraints }, {} );

    is_deeply( { $route->defaults }, {} );

    is_deeply( [ $route->methods ], [] );
    is( $route->methods_regex, undef );

    is_deeply( [ $route->schemes ], [] );
    is( $route->schemes_regex, undef );

    is( $route->host, undef );
    is( $route->host_regex, undef );
    is_deeply( [ $route->host_variables ], [] );

    is( $route->path, '/a/{b}/{c:\d+}' );
    is( $route->path_regex, qr!^\/a\/([^/]+)\/(\d+)$! );
    is_deeply( [ $route->path_variables ], [ qw( b c ) ] );

    ok( $route->is_reversible );

    is( $route->reverse_scheme, undef );

    is( $route->reverse_host, undef );
    is_deeply( [ $route->reverse_host_variables ], [] );

    is( $route->reverse_path, '/a/%s/%s' );
    is_deeply( [ $route->reverse_path_variables ], [ qw( b c ) ] );

    is( scalar keys %$route, 19 );

}

