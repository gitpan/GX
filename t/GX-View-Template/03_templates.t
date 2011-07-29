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
        file_extensions     => [ qw( a bb ) ],
        templates_directory => $Templates_Directory,
        preload             => 0
    );

}


package main;


use Test::More tests => 1;


# Templates
{

    my $view = MyApp::View::Template->instance;

    is_deeply(
        [ sort $view->templates ],
        [
            sort qw(
                directory_1/template_1.a
                directory_1/template_2.a
                directory_1/template_3.a
                directory_2/directory_1/template_1.a
                directory_2/directory_1/template_2.a
                directory_2/directory_1/template_3.a
                directory_2/template_1.bb
                directory_2/template_2.bb
                directory_2/template_3.bb
                template_1.a
                template_1.format_1.bb
                template_2.a
                template_2.format_1.bb
                template_3.a
                template_3.format_1.bb
            )
        ]
    );

}

