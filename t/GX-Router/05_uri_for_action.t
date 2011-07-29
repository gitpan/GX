#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 9;


require_ok( 'MyApp' );

my $MyApp  = MyApp->instance;
my $Router = $MyApp->router;


my @Data = (
    [
        { 
            action => $MyApp->action( 'A', 'action_1' ),
            host   => 'myhost'
        },
        'http://myhost/a/action_1'
    ],
    [
        { 
            action => $MyApp->action( 'A', 'action_1' ),
            host   => 'myhost.com'
        },
        'http://myhost.com/a/action_1'
    ],
    [
        { 
            action => $MyApp->action( 'A', 'action_1' ),
            host   => 'myhost.com:80'
        },
        'http://myhost.com:80/a/action_1'
    ],
    [
        { 
            action => $MyApp->action( 'A', 'action_1' ),
            host   => 'myhost',
            scheme => 'https'
        },
        'https://myhost/a/action_1'
    ],
    [
        { 
            action => $MyApp->action( 'A', 'action_1' ),
            host   => 'myhost',
            query  => 'k1=v1'
        },
        'http://myhost/a/action_1?k1=v1'
    ],
    [
        { 
            action   => $MyApp->action( 'A', 'action_1' ),
            host     => 'myhost',
            fragment => 'f1'
        },
        'http://myhost/a/action_1#f1'
    ],
    [
        { 
            action   => $MyApp->action( 'A', 'action_1' ),
            host     => 'myhost',
            query    => 'k1=v1',
            fragment => 'f1'
        },
        'http://myhost/a/action_1?k1=v1#f1'
    ],
    [
        { 
            action     => $MyApp->action( 'A', 'action_7' ),
            host       => 'myhost',
            parameters => { 'k1' => 'v1' }
        },
        'http://myhost/a/path_7/v1'
    ]
);


# uri_for_action
{

    for my $data ( @Data ) {

        my ( $arguments, $expected_uri ) = @$data;

        my $uri = $Router->uri_for_action( %$arguments );

        is( $uri, $expected_uri, $expected_uri );

    }

}

