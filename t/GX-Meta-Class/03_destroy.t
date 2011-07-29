#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'lib' );
use My::Class::A;
use My::Class::A::A;
use My::Class::A::B;
use My::Class::B;
use My::Class::C;

use GX::Meta::Class;
use Scalar::Util qw( weaken );


use Test::More tests => 10;


# Destroy
{

    my @CLASSES = qw(
        My::Class::A
        My::Class::A::A
        My::Class::A::B
        My::Class::B
        My::Class::C
    );

    for my $class_name ( @CLASSES ) {

        my $class = GX::Meta::Class->new( $class_name );

        for my $method ( qw(
            all_attributes
            all_methods
            all_subclasses
            all_superclasses
            attributes
            linearized_isa
            linearized_isa_classes
            methods
            package
            subclasses
            superclasses
        ) ) {
            $class->$method;
        }

    }

    for my $class_name ( @CLASSES ) {
        ok( my $class = GX::Meta::Class::Registry->remove( $class_name ) );
        weaken $class;
        ok( ! $class );
    }

}

