#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 82;


require_ok( 'MyApp' );

my $MyApp          = MyApp->instance;
my $Controller_A   = $MyApp->controller( 'A' );
my $Controller_A_A = $MyApp->controller( 'A::A' );
my $Controller_A_B = $MyApp->controller( 'A::B' );
my $Controller_A_C = $MyApp->controller( 'A::C' );


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A
# ----------------------------------------------------------------------------------------------------------------------

# pre_dispatch_filters(), post_dispatch_filters()
{

    my @pre_dispatch_filters  = $Controller_A->pre_dispatch_filters;
    my @post_dispatch_filters = $Controller_A->post_dispatch_filters;

    is( scalar @pre_dispatch_filters, 1 );
    is( scalar @post_dispatch_filters, 6 );

    for my $filter ( @pre_dispatch_filters, @post_dispatch_filters ) {
        isa_ok( $filter, 'GX::Callback::Method' );
        is( $filter->invocant, $Controller_A );
    }

    is( $pre_dispatch_filters[0]->method, 'before_1' );

    is( $post_dispatch_filters[0]->method, 'render_1' );
    is( $post_dispatch_filters[1]->method, 'render_2' );
    is( $post_dispatch_filters[2]->method, '_auto_render_filter' );
    is( $post_dispatch_filters[3]->method, 'after_1' );
    is( $post_dispatch_filters[4]->method, 'after_2' );
    is( $post_dispatch_filters[5]->method, 'after_3' );

}

# filters()
{

    is_deeply(
        [ sort $Controller_A->filters ],
        [ sort $Controller_A->pre_dispatch_filters, $Controller_A->post_dispatch_filters ]
    );

}


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A::A
# ----------------------------------------------------------------------------------------------------------------------

# pre_dispatch_filters(), post_dispatch_filters()
{

    my @pre_dispatch_filters  = $Controller_A_A->pre_dispatch_filters;
    my @post_dispatch_filters = $Controller_A_A->post_dispatch_filters;

    is( scalar @pre_dispatch_filters, 0 );
    is( scalar @post_dispatch_filters, 4 );

    for my $filter ( @pre_dispatch_filters, @post_dispatch_filters ) {
        isa_ok( $filter, 'GX::Callback::Method' );
        is( $filter->invocant, $Controller_A_A );
    }

    is( $post_dispatch_filters[0]->method, 'render_2' );
    is( $post_dispatch_filters[1]->method, '_auto_render_filter' );
    is( $post_dispatch_filters[2]->method, 'after_3' );
    is( $post_dispatch_filters[3]->method, 'after_4' );

}

# filters()
{

    is_deeply(
        [ sort $Controller_A_A->filters ],
        [ sort $Controller_A_A->pre_dispatch_filters, $Controller_A_A->post_dispatch_filters ]
    );

}


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A::B - extends A
# ----------------------------------------------------------------------------------------------------------------------

# pre_dispatch_filters(), post_dispatch_filters()
{

    my @pre_dispatch_filters  = $Controller_A_B->pre_dispatch_filters;
    my @post_dispatch_filters = $Controller_A_B->post_dispatch_filters;

    is( scalar @pre_dispatch_filters, 1 );
    is( scalar @post_dispatch_filters, 7 );

    for my $filter ( @pre_dispatch_filters, @post_dispatch_filters ) {
        isa_ok( $filter, 'GX::Callback::Method' );
        is( $filter->invocant, $Controller_A_B );
    }

    is( $pre_dispatch_filters[0]->method, 'before_1' );

    is( $post_dispatch_filters[0]->method, 'render_1' );
    is( $post_dispatch_filters[1]->method, 'render_2' );
    is( $post_dispatch_filters[2]->method, '_auto_render_filter' );
    is( $post_dispatch_filters[3]->method, 'after_1' );
    is( $post_dispatch_filters[4]->method, 'after_2' );
    is( $post_dispatch_filters[5]->method, 'after_3' );
    is( $post_dispatch_filters[6]->method, 'after_4' );

}

# filters()
{

    is_deeply(
        [ sort $Controller_A_B->filters ],
        [ sort $Controller_A_B->pre_dispatch_filters, $Controller_A_B->post_dispatch_filters ]
    );

}


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::Controller::A::C - extends A, inherit_filters => 0
# ----------------------------------------------------------------------------------------------------------------------

# pre_dispatch_filters(), post_dispatch_filters()
{

    my @pre_dispatch_filters  = $Controller_A_C->pre_dispatch_filters;
    my @post_dispatch_filters = $Controller_A_C->post_dispatch_filters;

    is( scalar @pre_dispatch_filters, 0 );
    is( scalar @post_dispatch_filters, 4 );

    for my $filter ( @pre_dispatch_filters, @post_dispatch_filters ) {
        isa_ok( $filter, 'GX::Callback::Method' );
        is( $filter->invocant, $Controller_A_C );
    }

    is( $post_dispatch_filters[0]->method, 'render_2' );
    is( $post_dispatch_filters[1]->method, '_auto_render_filter' );
    is( $post_dispatch_filters[2]->method, 'after_3' );
    is( $post_dispatch_filters[3]->method, 'after_4' );

}

# filters()
{

    is_deeply(
        [ sort $Controller_A_C->filters ],
        [ sort $Controller_A_C->pre_dispatch_filters, $Controller_A_C->post_dispatch_filters ]
    );

}

