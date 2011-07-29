#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

use base qw( GX::Class );


package My::Class::B;

use base qw( My::Class::A );


package My::Class::C;

use GX::Class;


package My::Class::D;

use GX::Meta;

our $META;

BEGIN {
    $META = GX::Meta::Class->new( __PACKAGE__ );
    GX::Meta::Class::Registry->remove( __PACKAGE__ );
}

use GX::Class meta => $META;


package main;

use Scalar::Util qw( refaddr );


use Test::More tests => 16;


{

    ok( my $meta = My::Class::A->meta );
    isa_ok( $meta, 'GX::Meta::Class' );
    is( $meta->name, 'My::Class::A' );
    is( refaddr( My::Class::A->meta ), refaddr( $meta ) );

}

{

    ok( my $meta = My::Class::B->meta );
    isa_ok( $meta, 'GX::Meta::Class' );
    is( $meta->name, 'My::Class::B' );
    is( refaddr( My::Class::B->meta ), refaddr( $meta ) );

}

{

    ok( my $meta = My::Class::C->meta );
    isa_ok( $meta, 'GX::Meta::Class' );
    is( $meta->name, 'My::Class::C' );
    is( refaddr( My::Class::C->meta ), refaddr( $meta ) );

}

{

    ok( my $meta = My::Class::D->meta );
    isa_ok( $meta, 'GX::Meta::Class' );
    is( $meta->name, 'My::Class::D' );
    is( refaddr( My::Class::D->meta ), refaddr( $My::Class::D::META ) );

}

