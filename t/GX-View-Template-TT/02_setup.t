#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if( eval { require Template } ) {
        plan tests => 16;
    }
    else {
        plan skip_all => "Template is not installed";
        exit;
    }

}


use File::Spec ();
use FindBin qw( $Bin );


our $Templates_Directory = File::Spec->catdir( $Bin, 'data', 'templates' );


package MyApp::View::Template::A;
{

    use GX::View::Template::TT;

}

package MyApp::View::Template::B;
{

    use GX::View::Template::TT;

    __PACKAGE__->setup(
        default_content_type => 'text/html',
        default_encoding     => 'utf-8',
        file_extensions      => [ qw( tmpl ttmpl ) ],
        options              => { TRIM => 1 },
        templates_directory  => $Templates_Directory,
        template_encoding    => 'ISO-8859-1'
    );

}


package main;

# MyApp::View::Template::A
{

    my $view = MyApp::View::Template::A->instance;

    isa_ok( $view, 'MyApp::View::Template::A' );
    isa_ok( $view, 'GX::View::Template::TT' );

    is( $view->default_content_type, undef );
    is( $view->default_encoding, undef );
    is_deeply( [ $view->file_extensions ], [ qw( tt ) ] );
    is_deeply(
        { $view->options },
        {
            'ABSOLUTE'  => 1,
            'EVAL_PERL' => 0,
            'RELATIVE'  => 0,
            'STAT_TTL'  => 31536000
        }
    );
    is( $view->templates_directory, undef );
    is( $view->template_encoding, undef );

}

# MyApp::View::Template::B
{

    my $view = MyApp::View::Template::B->instance;

    isa_ok( $view, 'MyApp::View::Template::B' );
    isa_ok( $view, 'GX::View::Template::TT' );

    is( $view->default_content_type, 'text/html' );
    is( $view->default_encoding, 'utf-8-strict' );
    is_deeply( [ $view->file_extensions ], [ qw( tmpl ttmpl ) ] );
    is_deeply(
        { $view->options },
        {
            'ABSOLUTE'  => 1,
            'EVAL_PERL' => 0,
            'RELATIVE'  => 0,
            'STAT_TTL'  => 31536000,
            'TRIM'      => 1
        }
    );
    is( $view->templates_directory, $Templates_Directory );
    is( $view->template_encoding, 'iso-8859-1' );

}

