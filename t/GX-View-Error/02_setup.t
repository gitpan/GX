#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::View::Error::A;
{

    use GX::View::Error;

    __PACKAGE__->setup;

}

package MyApp::View::Error::B;
{

    use GX::View::Error;

    __PACKAGE__->setup(
        default_encoding => 'iso-8859-1',
        default_format   => 'html'
    );

}


package main;


use Test::More tests => 8;


# MyApp::View::Error::A
{

    my $view = MyApp::View::Error::A->instance;

    isa_ok( $view, 'MyApp::View::Error::A' );
    isa_ok( $view, 'GX::View::Error' );

    is( $view->default_encoding, undef );
    is( $view->default_format, 'html' );

}

# MyApp::View::Error::B
{

    my $view = MyApp::View::Error::B->instance;

    isa_ok( $view, 'MyApp::View::Error::B' );
    isa_ok( $view, 'GX::View::Error' );

    is( $view->default_encoding, 'iso-8859-1' );
    is( $view->default_format, 'html' );

}

