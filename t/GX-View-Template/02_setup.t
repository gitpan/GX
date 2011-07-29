#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );


our $Templates_Directory = File::Spec->catdir( $Bin, 'data', 'templates' );


package MyApp::View::Template;
{

    use GX::View::Template;

    __PACKAGE__->setup(
        default_content_type => 'text/html',
        default_encoding     => 'utf-8',
        file_extensions      => [ undef, qw( a bb .c .dd ) ],
        options              => { option_1 => 1 },
        preload              => 0,
        templates_directory  => $Templates_Directory,
        template_encoding    => 'utf-8'
    );

}


package main;


use Test::More tests => 8;


# Inheritance
{

    my $view = MyApp::View::Template->instance;

    isa_ok( $view, 'MyApp::View::Template' );
    isa_ok( $view, 'GX::View::Template' );

}

# Configuration
{

    my $view = MyApp::View::Template->instance;

    is( $view->default_content_type, 'text/html' );
    is( $view->default_encoding, 'utf-8-strict' );
    is_deeply( [ $view->file_extensions ], [ qw( a bb c dd ) ] );
    is_deeply( { $view->options }, { option_1 => 1 } );
    is( $view->templates_directory, $Templates_Directory );
    is( $view->template_encoding, 'utf-8-strict' );

}

