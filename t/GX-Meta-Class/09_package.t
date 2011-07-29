#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;


use Test::More tests => 2;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );


{

    my $package = $CLASS_A->package;

    isa_ok( $package, 'GX::Meta::Package' );
    is( $package->name, 'My::Class::A'  );

}

