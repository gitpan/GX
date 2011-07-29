#!/usr/bin/perl

use strict;
use warnings FATAL => 'all'; no warnings 'once';


package My::Class::A;
{

    our $scalar_1 = 'My::Class::A';
    our @array_1  = ( 0 .. 2 );
    our %hash_1   = ( 'My::Class::A' => 'foo' );

    sub function_1 { 'My::Class::A::function_1' }

    sub constant_1 () { 'My::Class::A::constant_1' }

    use constant constant_2 => 'My::Class::A::constant_2';

    *imported_scalar_1   = \$My::Exporter::scalar_1;
    *imported_array_1    = \@My::Exporter::array_1;
    *imported_hash_1     = \%My::Exporter::hash_1;
    *imported_function_1 = \&My::Exporter::function_1;
}

package My::Class::A::A;
{

    use base qw( My::Class::A );

    our $scalar_1 = 'My::Class::A::A';
    our @array_1  = ( 3 .. 5 );
    our %hash_1   = ( 'My::Class::A::A' => 'foo' );

    sub function_1 { 'My::Class::A::A::function_1' }

    sub constant_1 () { 'My::Class::A::A::constant_1' }

    use constant constant_2 => 'My::Class::A::A::constant_2';

    *imported_scalar_1   = \$My::Exporter::scalar_1;
    *imported_array_1    = \@My::Exporter::array_1;
    *imported_hash_1     = \%My::Exporter::hash_1;
    *imported_function_1 = \&My::Exporter::function_1;

}

package My::Exporter;
{

    our $scalar_1 = 'My::Exporter';
    our @array_1  = ( 6 .. 8 );
    our %hash_1   = ( 'My::Exporter' => 'foo' );

    sub function_1 { 'My::Exporter::function_1' }

}


package main;

use GX::Meta::Package;
use Symbol;


use Test::More tests => 11;


# wipe()
{

    my $package_a   = GX::Meta::Package->new( 'My::Class::A' );
    my $package_a_a = GX::Meta::Package->new( 'My::Class::A::A' );

    $package_a->wipe;

    is_deeply( [ keys %{ $package_a->symbol_table } ], [ 'A::' ] );

    is( My::Class::A::A::function_1(), 'My::Class::A::A::function_1' );
    is( $My::Class::A::A::scalar_1, 'My::Class::A::A' );
    is_deeply( [ @My::Class::A::A::array_1 ], [ 3 .. 5 ] );
    is_deeply( { %My::Class::A::A::hash_1 }, { 'My::Class::A::A' => 'foo' } );

    $package_a_a->wipe;

    is_deeply( [ keys %{ $package_a_a->symbol_table } ], [] );

    is_deeply(
        [ sort keys %{ GX::Meta::Package->new( 'My::Exporter' )->symbol_table } ],
        [ qw( array_1 function_1 hash_1 scalar_1 ) ]
    );

    is( My::Exporter::function_1(), 'My::Exporter::function_1' );
    is( $My::Exporter::scalar_1, 'My::Exporter' );
    is_deeply( [ @My::Exporter::array_1 ], [ 6 .. 8 ] );
    is_deeply( { %My::Exporter::hash_1 }, { 'My::Exporter' => 'foo' } );

}

