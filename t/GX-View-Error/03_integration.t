#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 5;


require_ok( 'MyApp' );


# MyApp::View::A
{

    my $view = MyApp->instance->view( 'A' );

    isa_ok( $view, 'MyApp::View::A' );
    isa_ok( $view, 'GX::View::Error' );

    is( $view->default_encoding, 'utf-8-strict' );
    is( $view->default_format, 'html' );

}

