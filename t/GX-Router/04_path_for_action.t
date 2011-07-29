#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 22;


require_ok( 'MyApp' );

my $MyApp  = MyApp->instance;
my $Router = $MyApp->router;


my @Data = (

    [ $MyApp->action( 'A', 'action_1' ),  undef,            '/a/action_1'  ],
    [ $MyApp->action( 'A', 'action_2' ),  undef,            '/a/action_2'  ],
    [ $MyApp->action( 'A', 'action_3' ),  undef,            '/a/action_3'  ],
    [ $MyApp->action( 'A', 'action_4' ),  undef,            '/a/static_4'  ],
    [ $MyApp->action( 'A', 'action_5' ),  undef,            '/a/static_5'  ],
    [ $MyApp->action( 'A', 'action_6' ),  undef,            '/a/static_6'  ],
    [ $MyApp->action( 'A', 'action_7' ),  { 'k1' => 'v1' }, '/a/path_7/v1' ],
    [ $MyApp->action( 'A', 'action_8' ),  { 'k1' => 'v1' }, '/a/path_8/v1' ],
    [ $MyApp->action( 'A', 'action_9' ),  { 'k1' => 'v1' }, '/a/path_9/v1' ],

    [ $MyApp->action( 'B', 'action_1' ),  undef,            '/b/action_1'  ],
    [ $MyApp->action( 'B', 'action_2' ),  undef,            '/b/action_2'  ],
    [ $MyApp->action( 'B', 'action_3' ),  undef,            '/b/action_3'  ],
    [ $MyApp->action( 'B', 'action_4' ),  undef,            '/b/static_4'  ],
    [ $MyApp->action( 'B', 'action_5' ),  undef,            '/b/static_5'  ],
    [ $MyApp->action( 'B', 'action_6' ),  undef,            '/b/static_6'  ],
    [ $MyApp->action( 'B', 'action_7' ),  { 'k1' => 'v1' }, '/b/path_7/v1' ],
    [ $MyApp->action( 'B', 'action_8' ),  { 'k1' => 'v1' }, '/b/path_8/v1' ],
    [ $MyApp->action( 'B', 'action_9' ),  { 'k1' => 'v1' }, '/b/path_9/v1' ],

    [ $MyApp->action( 'C', 'action_1' ),  undef,            '/router/static_1'  ],
    [ $MyApp->action( 'C', 'action_2' ),  { 'k1' => 'v1' }, '/router/path_2/v1' ],
    [ $MyApp->action( 'C', 'action_3' ),  undef,            '/c/action_3'       ],

);


# path_for_action
{

    for my $data ( @Data ) {

        my ( $action, $parameters, $path ) = @$data;

        my $reverse_path = $Router->path_for_action(
            action => $action,
            ( $parameters ? ( parameters => $parameters ) : () )
        );

        if ( $path ) {
            is( $reverse_path, $path, $path );
        }
        else {
            is( $reverse_path, undef, $path );
        }

    }

}

