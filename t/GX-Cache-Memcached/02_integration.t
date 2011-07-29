#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require Cache::Memcached } ) {
        plan skip_all => "Cache::Memcached is not installed";
        exit;
    }

    plan tests => 4;

}


use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'MyApp', 'lib' );

require_ok( 'MyApp' );


# $application->cache( $name )
{

    my $cache = MyApp->instance->cache( 'Memcached' );

    is( ref $cache, 'MyApp::Cache::Memcached' );

    isa_ok( $cache, 'GX::Cache::Memcached' );

}

# $application->cache()
{

    is( MyApp->instance->cache, MyApp->instance->cache( 'Memcached' ) );

}

