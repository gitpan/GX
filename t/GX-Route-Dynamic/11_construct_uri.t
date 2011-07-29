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


use Test::More tests => 24;


my $Action = GX::Action->new(
    controller => MyApp::Controller::A->instance,
    method     => 'action_1'
);


# path => '/a'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a'
    );

    is(
        $route->construct_uri(
            host => 'hostname.tld'
        ),
        'http://hostname.tld/a'
    );

}

# path => '/a/'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a/'
    );

    is(
        $route->construct_uri(
            host => 'hostname.tld'
        ),
        'http://hostname.tld/a/'
    );

}


# path => '/a/{b}'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a/{b}'
    );

    is(
        $route->construct_uri(
            host       => 'hostname.tld',
            parameters => { 'b' => 'y' }
        ),
        'http://hostname.tld/a/y'
    );

}

# path => '/a/{b}/'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a/{b}/'
    );

    is(
        $route->construct_uri(
            host       => 'hostname.tld',
            parameters => { 'b' => 'y' }
        ),
        'http://hostname.tld/a/y/'
    );

}

# path => '/a/{b}/' - missing parameter
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a/{b}/'
    );

    local $@;

    eval {
        $route->construct_uri(
            host       => 'hostname.tld',
            parameters => {}
        );
    };

    isa_ok( $@, 'GX::Exception' );

}


# path => '/a' - no host specified
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a'
    );

    local $@;

    eval {
        $route->construct_uri;
    };

    isa_ok( $@, 'GX::Exception' );

}

# path => '/a', host => 'hostname.tld'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        host   => 'hostname.tld',
        path   => '/a'
    );

    is(
        $route->construct_uri,
        'http://hostname.tld/a'
    );

}

# path => '/a', host => 'hostname.tld' - specified host
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        host   => 'hostname.tld',
        path   => '/a'
    );

    is(
        $route->construct_uri(
            host => 'custom.hostname.tld'
        ),
        'http://custom.hostname.tld/a'
    );

}

# path => '/a', reverse_host => 'hostname.tld'
{

    my $route = GX::Route::Dynamic->new(
        action       => $Action,
        path         => '/a',
        reverse_host => 'hostname.tld'
    );

    is(
        $route->construct_uri,
        'http://hostname.tld/a'
    );

}

# path => '/a', reverse_host => 'hostname.tld' - specified host
{

    my $route = GX::Route::Dynamic->new(
        action       => $Action,
        path         => '/a',
        reverse_host => 'hostname.tld'
    );

    is(
        $route->construct_uri(
            host => 'custom.hostname.tld'
        ),
        'http://custom.hostname.tld/a'
    );

}


# path => '/a', host => 'hostname.tld', schemes => [ 'https' ]
{

    my $route = GX::Route::Dynamic->new(
        action  => $Action,
        schemes => [ 'https' ],
        host    => 'hostname.tld',
        path    => '/a'
    );

    is(
        $route->construct_uri,
        'https://hostname.tld/a'
    );

}

# path => '/a', host => 'hostname.tld', schemes => [ 'https' ] - specified scheme
{

    my $route = GX::Route::Dynamic->new(
        action  => $Action,
        schemes => [ 'https' ],
        host    => 'hostname.tld',
        path    => '/a'
    );

    is(
        $route->construct_uri(
            scheme => 'http'
        ),
        'http://hostname.tld/a'
    );

}

# path => '/a', host => 'hostname.tld', reverse_scheme => 'https'
{

    my $route = GX::Route::Dynamic->new(
        action         => $Action,
        host           => 'hostname.tld',
        path           => '/a',
        reverse_scheme => 'https',
    );

    is(
        $route->construct_uri,
        'https://hostname.tld/a'
    );

}

# path => '/a', host => 'hostname.tld', reverse_scheme => 'https' - specified scheme
{

    my $route = GX::Route::Dynamic->new(
        action         => $Action,
        host           => 'hostname.tld',
        path           => '/a',
        reverse_scheme => 'https',
    );

    is(
        $route->construct_uri(
            scheme => 'http'
        ),
        'http://hostname.tld/a'
    );

}


# *-Route
{

    my $route = GX::Route::Dynamic->new(
        action => $Action
    );

    is(
        $route->construct_uri(
            host => 'hostname.tld',
            path => '/a'
        ),
        'http://hostname.tld/a'
    );

}

# host => 'hostname.tld'
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        host   => 'hostname.tld'
    );

    is(
        $route->construct_uri(
            path => '/a'
        ),
        'http://hostname.tld/a'
    );

}

# schemes => [ 'https' ]
{

    my $route = GX::Route::Dynamic->new(
        action  => $Action,
        schemes => [ 'https' ]
    );

    is(
        $route->construct_uri(
            path => '/a',
            host => 'hostname.tld'
        ),
        'https://hostname.tld/a'
    );

}


# path => '/a' - query
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a'
    );

    is(
        $route->construct_uri(
            host  => 'hostname.tld',
            query => 'k1=v1'
        ),
        'http://hostname.tld/a?k1=v1'
    );

}

# path => '/a' - query + fragment
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a'
    );

    is(
        $route->construct_uri(
            host     => 'hostname.tld',
            query    => 'k1=v1',
            fragment => 'f1'
        ),
        'http://hostname.tld/a?k1=v1#f1'
    );

}


# Specified port
{

    my $route = GX::Route::Dynamic->new(
        action => $Action,
        path   => '/a'
    );

    is(
        $route->construct_uri(
            host => 'hostname.tld',
            port => 80
        ),
        'http://hostname.tld/a'
    );

    is(
        $route->construct_uri(
            scheme => 'http',
            host   => 'hostname.tld',
            port   => 80
        ),
        'http://hostname.tld/a'
    );

    is(
        $route->construct_uri(
            host => 'hostname.tld',
            port => 81
        ),
        'http://hostname.tld:81/a'
    );

    is(
        $route->construct_uri(
            scheme => 'https',
            host   => 'hostname.tld',
            port   => 443
        ),
        'https://hostname.tld/a'
    );

    is(
        $route->construct_uri(
            scheme => 'https',
            host   => 'hostname.tld',
            port   => 8080
        ),
        'https://hostname.tld:8080/a'
    );

}

