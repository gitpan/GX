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


use Test::More tests => 23;


my $Action = GX::Action->new(
    controller => MyApp::Controller::A->new,
    method     => 'action_1'
);


# path => '/a'
{

    my $route = GX::Route::Dynamic->new( action => $Action, path => '/a' );

    for my $data (
        [ {},             '/a' ],
        [ { 'x' => 'y' }, '/a' ],
    ) {
        is( $route->construct_path( %{$data->[0]} ), $data->[1] );
    }

}

# path => '/{a}'
{

    my $route = GX::Route::Dynamic->new( action => $Action, path => '/{a}' );

    for my $data (
        [ { 'a' => 'v1' },             '/v1' ],
        [ { 'a' => 'v1', 'x' => 'y' }, '/v1' ],
    ) {
        is( $route->construct_path( %{$data->[0]} ), $data->[1] );
    }

}

# path => '/{a}', with defaults
{

    my $route = GX::Route::Dynamic->new(
        action   => $Action,
        path     => '/{a}',
        defaults => { 'a' => 'v1' }
    );

    for my $data (
        [ {},                          '/v1' ],
        [ { 'a' => 'v2' },             '/v2' ],
        [ { 'x' => 'y' },              '/v1' ],
        [ { 'a' => 'v2', 'x' => 'y' }, '/v2' ],
    ) {
        is( $route->construct_path( %{$data->[0]} ), $data->[1] );
    }

}

# path => '/{a}', missing value
{

    my $route = GX::Route::Dynamic->new( action => $Action, path => '/{a}' );

    local $@;

    eval { $route->construct_path() };

    isa_ok( $@, 'GX::Exception' );

}

# path => '/{a:\d+}'
{

    my $route = GX::Route::Dynamic->new( action => $Action, path => '/{a:\d+}' );

    for my $data (
        [ { 'a' => 'v1' }, '/v1' ],
    ) {
        is( $route->construct_path( %{$data->[0]} ), $data->[1] );
    }

}

# path => '/{a:\d+}', with defaults
{

    my $route = GX::Route::Dynamic->new(
        action   => $Action,
        path     => '/{a:\d+}',
        defaults => { 'a' => 'va' }
    );

    for my $data (
        [ {},              '/va' ],
        [ { 'a' => 'v2' }, '/v2' ],
    ) {
        is( $route->construct_path( %{$data->[0]} ), $data->[1] );
    }

}

# path => '/a/{b}/c/{d:\d+}'
{

    my $route = GX::Route::Dynamic->new( action => $Action, path => '/a/{b}/c/{d:\d+}' );

    for my $data (
        [ { 'b' => 'v2', 'd' => 'v4' },             '/a/v2/c/v4' ],
        [ { 'b' => 'v2', 'd' => 'v4', 'x' => 'y' }, '/a/v2/c/v4' ],
    ) {
        is( $route->construct_path( %{$data->[0]} ), $data->[1] );
    }

}

# path => '/a/{b}/c/{d:\d+}', with defaults
{

    my $route = GX::Route::Dynamic->new(
        action   => $Action,
        path     => '/a/{b}/c/{d:\d+}',
        defaults => { 'b' => 'vb', 'd' => 'vd' }
    );

    for my $data (
        [ {},                                       '/a/vb/c/vd' ],
        [ { 'b' => 'v2' },                          '/a/v2/c/vd' ],
        [ { 'd' => 'v4' },                          '/a/vb/c/v4' ],
        [ { 'b' => 'v2', 'd' => 'v4' },             '/a/v2/c/v4' ],
        [ { 'x' => 'y' },                           '/a/vb/c/vd' ],
        [ { 'b' => 'v2', 'd' => 'v4', 'x' => 'y' }, '/a/v2/c/v4' ],
    ) {
        is( $route->construct_path( %{$data->[0]} ), $data->[1] );
    }

}

# URL-encoding
{

    my $route = GX::Route::Dynamic->new( action => $Action, path => '/{a}' );

    for my $data (
        [ { 'a' => '%' }, '/%25' ]
    ) {
        is( $route->construct_path( %{$data->[0]} ), $data->[1] );
    }

}

# URL-encoding, wide character exception
{

    my $route = GX::Route::Dynamic->new( action => $Action, path => '/{a}' );

    for my $data (
        [ { 'a' => "\x{263a}" } ],
    ) {
        local $@;
        eval { $route->construct_path( %{$data->[0]} ) };
        isa_ok( $@, 'GX::Exception' );
    }

}

# path => '/a/*'
{

    my $route = GX::Route::Dynamic->new( action => $Action, path => '/a/*' );

    local $@;

    eval { $route->construct_path() };

    isa_ok( $@, 'GX::Exception' );

}

