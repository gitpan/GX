#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if( eval { require HTML::Template::Compiled } ) {
        plan tests => 31;
    }
    else {
        plan skip_all => "HTML::Template::Compiled is not installed";
    }

}


use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


require_ok( 'MyApp' );


# MyApp::View::A
{

    my $view = MyApp->instance->view( 'A' );

    isa_ok( $view, 'MyApp::View::A' );
    isa_ok( $view, 'GX::View::Template::HTC' );

    is( $view->default_content_type, undef );
    is( $view->default_encoding, 'utf-8-strict' );
    is( $view->templates_directory, File::Spec->catdir( $Bin, 'data', 'myapp', 'templates' ) );
    is( $view->template_encoding, 'utf-8-strict' );

}

# MyApp::View::B
{

    my $view = MyApp->instance->view( 'B' );

    isa_ok( $view, 'MyApp::View::B' );
    isa_ok( $view, 'GX::View::Template::HTC' );

    is( $view->default_content_type, undef );
    is( $view->default_encoding, 'iso-8859-1' );
    is( $view->templates_directory, File::Spec->catdir( $Bin, 'data', 'myapp', 'templates' ) );
    is( $view->template_encoding, 'iso-8859-1' );

}

# MyApp::View::C
{

    my $view = MyApp->instance->view( 'C' );

    isa_ok( $view, 'MyApp::View::C' );
    isa_ok( $view, 'GX::View::Template::HTC' );

    is( $view->default_content_type, undef );
    is( $view->default_encoding, 'cp1252' );
    is( $view->templates_directory, File::Spec->catdir( $Bin, 'data', 'myapp', 'templates' ) );
    is( $view->template_encoding, 'cp1252' );

}

# MyApp::View::D
{

    my $view = MyApp->instance->view( 'D' );

    isa_ok( $view, 'MyApp::View::D' );
    isa_ok( $view, 'GX::View::Template::HTC' );

    is( $view->default_content_type, 'text/plain' );
    is( $view->default_encoding, 'utf-8-strict' );
    is( $view->templates_directory, File::Spec->catdir( $Bin, 'data', 'myapp', 'templates' ) );
    is( $view->template_encoding, 'utf-8-strict' );

}

# MyApp::View::E
{

    my $view = MyApp->instance->view( 'E' );

    isa_ok( $view, 'MyApp::View::E' );
    isa_ok( $view, 'GX::View::Template::HTC' );

    is( $view->default_content_type, undef );
    is( $view->default_encoding, 'utf-8-strict' );
    is( $view->templates_directory, File::Spec->catdir( $Bin, 'data', 'myapp', 'templates', 'E' ) );
    is( $view->template_encoding, 'utf-8-strict' );

}

