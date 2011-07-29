#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Module;
use File::Spec ();


use Test::More tests => 12;


{

    my $module = GX::Meta::Module->new( 'File::Spec' );

    is( $module->name, 'File::Spec' );

    ok( $module->is_loaded );
    ok( $module->is_installed );

    is( $module->inc_key, 'File/Spec.pm' );
    is( $module->inc_value, $INC{'File/Spec.pm'} );
    is( $module->inc_file, $INC{'File/Spec.pm'} );

    ok( -f $module->find_file );

}

{

    my $module = GX::Meta::Module->new( 'GX::This::Module::Does::Not::Exist' );

    ok( ! $module->is_loaded );
    ok( ! $module->is_installed );

    is( $module->inc_value, undef );
    is( $module->inc_file, undef );

    is( $module->find_file, undef );

}

