#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Module;


use Test::More tests => 4;


# new( $module_name )
{

    my $module = GX::Meta::Module->new( 'My::Module' );

    isa_ok( $module, 'GX::Meta::Module' );

    is( $module->name, 'My::Module' );

}

# new( name => $module_name )
{

    my $module = GX::Meta::Module->new( name => 'My::Module' );

    isa_ok( $module, 'GX::Meta::Module' );

    is( $module->name, 'My::Module' );

}

