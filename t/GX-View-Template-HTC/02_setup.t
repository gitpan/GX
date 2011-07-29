#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if( eval { require HTML::Template::Compiled } ) {
        plan tests => 16;
    }
    else {
        plan skip_all => "HTML::Template::Compiled is not installed";
        exit;
    }

}


use File::Spec ();
use FindBin qw( $Bin );


our $Templates_Directory = File::Spec->catdir( $Bin, 'data', 'templates' );


package MyApp::View::Template::A;
{

    use GX::View::Template::HTC;

}

package MyApp::View::Template::B;
{

    use GX::View::Template::HTC;

    __PACKAGE__->setup(
        default_content_type => 'text/html',
        default_encoding     => 'utf-8',
        file_extensions      => [ qw( tmpl ht ) ],
        options              => { default_escape => 'HTML' },
        templates_directory  => $Templates_Directory,
        template_encoding    => 'ISO-8859-1'
    );

}


package main;

# MyApp::View::Template::A
{

    my $view = MyApp::View::Template::A->instance;

    isa_ok( $view, 'MyApp::View::Template::A' );
    isa_ok( $view, 'GX::View::Template::HTC' );

    is( $view->default_content_type, undef );
    is( $view->default_encoding, undef );
    is_deeply( [ $view->file_extensions ], [ qw( htc ) ] );
    is_deeply( { $view->options }, { cache => 1 } );
    is( $view->templates_directory, undef );
    is( $view->template_encoding, undef );

}

# MyApp::View::Template::B
{

    my $view = MyApp::View::Template::B->instance;

    isa_ok( $view, 'MyApp::View::Template::B' );
    isa_ok( $view, 'GX::View::Template::HTC' );

    is( $view->default_content_type, 'text/html' );
    is( $view->default_encoding, 'utf-8-strict' );
    is_deeply( [ $view->file_extensions ], [ qw( tmpl ht ) ] );
    is_deeply( { $view->options }, { default_escape => 'HTML', cache => 1 } );
    is( $view->templates_directory, $Templates_Directory );
    is( $view->template_encoding, 'iso-8859-1' );

}

