#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;
{

    our @array_1;
    our %hash_1;
    our $scalar_1;

    sub function_1 { 1 }

}

package My::Class::B;
{

    use Symbol qw( geniosym );

    our $scalar_1 = 1;
    our @array_1 = ( 1 );
    our %hash_1 = ( 'k1' => 'v1' );

    sub function_1 { 1 }
    sub function_2 { 2 }
    sub function_3 { 3 }

    our $multislot = 1;
    our @multislot = ( 1 );
    our %multislot = ( 'k1' => 'v1' );
    sub multislot { 1 }

    no warnings 'once';
    *io_1 = geniosym();
    *io_2 = geniosym();

}


package main;

use GX::Meta::Package;


use Test::More tests => 38;


# assign_to_typeglob()
{

    my $package = GX::Meta::Package->new( 'My::Class::A' );

    $package->assign_to_typeglob( 'array_1' => [ 2 ] );
    $package->assign_to_typeglob( 'hash_1' => { 'k2' => 'v2' } );
    $package->assign_to_typeglob( 'scalar_1' => \'2' );
    $package->assign_to_typeglob( 'function_1' => sub { 2 } );

    is_deeply( \@My::Class::A::array_1, [ 2 ] );
    is_deeply( \%My::Class::A::hash_1, { 'k2' => 'v2' } );
    is( $My::Class::A::scalar_1, 2 );
    is( My::Class::A::function_1(), 2 );

    no warnings 'once';

    $package->assign_to_typeglob( 'array_2' => [ 1 ] );
    $package->assign_to_typeglob( 'hash_2' => { 'k1' => 'v1' } );
    $package->assign_to_typeglob( 'scalar_2' => \'1' );
    $package->assign_to_typeglob( 'function_2' => sub { 1 } );

    is_deeply( \@My::Class::A::array_2, [ 1 ] );
    is_deeply( \%My::Class::A::hash_2, { 'k1' => 'v1' } );
    is( $My::Class::A::scalar_2, 1 );
    is( My::Class::A::function_2(), 1 );   

}

# clear_typeglob_slot()
{

    {
        no strict 'refs';
        is( *{'My::Class::B::multislot'}{'PACKAGE'}, 'My::Class::B' );
        ok( *{'My::Class::B::io_1'}{'IO'} );
        ok( *{'My::Class::B::io_2'}{'IO'} );
    }

    my $package = GX::Meta::Package->new( 'My::Class::B' );

    is( $My::Class::B::scalar_1, 1 );
    ok( $package->clear_typeglob_slot( 'scalar_1', 'SCALAR' ) );
    is( $My::Class::B::scalar_1, undef );

    is_deeply( \@My::Class::B::array_1, [ 1 ] );
    ok( $package->clear_typeglob_slot( 'array_1', 'ARRAY' ) );
    is_deeply( \@My::Class::B::array_1, [] );

    is_deeply( \%My::Class::B::hash_1, { 'k1' => 'v1' } );
    ok( $package->clear_typeglob_slot( 'hash_1', 'HASH' ) );
    is_deeply( \%My::Class::B::hash_1, {} );

    ok( My::Class::B->can( 'function_1' ) );
    ok( $package->clear_typeglob_slot( 'function_1', 'CODE' ) );
    ok( ! My::Class::B->can( 'function_1' ) );

    is( $My::Class::B::multislot, 1 );
    ok( $package->clear_typeglob_slot( 'multislot', 'SCALAR' ) );
    is( $My::Class::B::multislot, undef );

    is_deeply( \@My::Class::B::multislot, [ 1 ]);
    ok( $package->clear_typeglob_slot( 'multislot', 'ARRAY' ) );
    is_deeply( \@My::Class::B::multislot, [] );

    is_deeply( \%My::Class::B::multislot, { 'k1' => 'v1' } );
    ok( $package->clear_typeglob_slot( 'multislot', 'HASH' ) );
    is_deeply( \%My::Class::B::multislot, {} );

    ok( My::Class::B->can( 'multislot' ) );
    ok( $package->clear_typeglob_slot( 'multislot', 'CODE' ) );
    ok( ! My::Class::B->can( 'multislot' ) );

    ok( $package->clear_typeglob_slot( 'io_1', 'IO' ) );

    {
        no strict 'refs';
        is( *{'My::Class::B::multislot'}{'PACKAGE'}, 'My::Class::B' );
        ok( *{'My::Class::B::io_2'}{'IO'} );
    }

}

