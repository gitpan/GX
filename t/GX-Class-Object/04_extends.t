#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;
our $VERSION = 1;

package My::Class::B;
BEGIN { our @ISA = qw( My::Class::A ) };
use GX::Class::Object;

package My::Class::C;
use GX::Class::Object;
extends 'My::Class::B';

package My::Class::D;
use GX::Class::Object;
extends qw( My::Class::A My::Class::B My::Class::C );

package My::Class::E;
use GX::Class::Object;
use base qw( My::Class::A );

package My::Class::F;
use base qw( My::Class::A );
use GX::Class::Object;

package My::Class::G;
use GX::Class::Object superclass => 'My::Class::A';

package My::Class::H;
use GX::Class::Object extends => 'My::Class::A';

package My::Class::I;
use GX::Class::Object extends => [ qw( My::Class::A My::Class::B ) ];

package My::Class::J;
use GX::Class::Object superclass => 'My::Class::C', extends => [ qw( My::Class::A My::Class::B ) ];


package main;


use Test::More tests => 18;


# Compile time
{

    BEGIN {

        is_deeply( \@My::Class::B::ISA, [ qw( GX::Class::Object My::Class::A ) ] );
        is_deeply( \@My::Class::C::ISA, [ qw( GX::Class::Object ) ] );
        is_deeply( \@My::Class::D::ISA, [ qw( GX::Class::Object ) ] );
        is_deeply( \@My::Class::E::ISA, [ qw( GX::Class::Object My::Class::A ) ] );
        is_deeply( \@My::Class::F::ISA, [ qw( GX::Class::Object My::Class::A ) ] );
        is_deeply( \@My::Class::G::ISA, [ qw( My::Class::A ) ] );
        is_deeply( \@My::Class::H::ISA, [ qw( My::Class::A GX::Class::Object ) ] );
        is_deeply( \@My::Class::I::ISA, [ qw( My::Class::A My::Class::B GX::Class::Object ) ] );
        is_deeply( \@My::Class::J::ISA, [ qw( My::Class::A My::Class::B My::Class::C ) ] );

    }

}

# Runtime
{

    is_deeply( \@My::Class::B::ISA, [ qw( GX::Class::Object My::Class::A ) ] );
    is_deeply( \@My::Class::C::ISA, [ qw( My::Class::B GX::Class::Object ) ] );
    is_deeply( \@My::Class::D::ISA, [ qw( My::Class::A My::Class::B My::Class::C GX::Class::Object ) ] );
    is_deeply( \@My::Class::E::ISA, [ qw( GX::Class::Object My::Class::A ) ] );
    is_deeply( \@My::Class::F::ISA, [ qw( GX::Class::Object My::Class::A ) ] );
    is_deeply( \@My::Class::G::ISA, [ qw( My::Class::A ) ] );
    is_deeply( \@My::Class::H::ISA, [ qw( My::Class::A GX::Class::Object ) ] );
    is_deeply( \@My::Class::I::ISA, [ qw( My::Class::A My::Class::B GX::Class::Object ) ] );
    is_deeply( \@My::Class::J::ISA, [ qw( My::Class::A My::Class::B My::Class::C ) ] );

}

