#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'lib' );
use My::Class::A;

use GX::Meta::Class;
use Scalar::Util qw( refaddr );


use Test::More tests => 4;


# new( $class_name ), instance cache
{

    my $class = GX::Meta::Class->new( 'My::Class::A' );

    isa_ok( $class, 'GX::Meta::Class' );

    is( $class->name, 'My::Class::A' );

    my $refaddr = refaddr( $class );

    is( refaddr( GX::Meta::Class->new( 'My::Class::A' ) ), $refaddr );

    undef $class;

    is( refaddr( GX::Meta::Class->new( 'My::Class::A' ) ), $refaddr );

}

