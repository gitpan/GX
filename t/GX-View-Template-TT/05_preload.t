#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if( eval { require Template } ) {
        plan tests => 6;
    }
    else {
        plan skip_all => "Template is not installed";
    }

}


use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


require_ok( 'MyApp' );


my $MyApp  = MyApp->instance;
my $View_A = $MyApp->view( 'A' );
my $View_B = $MyApp->view( 'B' );
my $View_C = $MyApp->view( 'C' );
my $View_D = $MyApp->view( 'D' );
my $View_E = $MyApp->view( 'E' );


# MyApp::View::Template::A
{

    is_deeply( [ $View_A->preloaded_templates ], [] );

}

# MyApp::View::Template::B
{

    is_deeply( [ $View_B->preloaded_templates ], [] );

}

# MyApp::View::Template::C
{

    is_deeply( [ $View_C->preloaded_templates ], [] );

}

# MyApp::View::Template::D
{

    is_deeply( [ $View_D->preloaded_templates ], [] );

}

# MyApp::View::Template::E
{

    is_deeply(
        [ sort $View_E->preloaded_templates ],
        [
            sort qw(
                template_1.tt
                template_1.txt.tt
            )
        ]
    );

}

