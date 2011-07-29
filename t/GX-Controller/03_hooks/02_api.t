#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 7;


require_ok( 'MyApp' );

my $MyApp        = MyApp->instance;
my $Controller_A = $MyApp->controller( 'A' );


# filter_hook()
{

    for my $hook_name ( qw( Before Render After ) ) {
        my $hook = $Controller_A->filter_hook( $hook_name );
        isa_ok( $hook, 'GX::Callback::Hook' );
        is( $hook->name, $hook_name );
    }

}

