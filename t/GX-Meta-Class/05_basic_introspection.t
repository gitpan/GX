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
use Scalar::Util qw( refaddr );


use Test::More tests => 105;


my $CLASS_A   = GX::Meta::Class->new( 'My::Class::A' );
my $CLASS_A_A = GX::Meta::Class->new( 'My::Class::A::A' );
my $CLASS_A_B = GX::Meta::Class->new( 'My::Class::A::B' );
my $CLASS_B   = GX::Meta::Class->new( 'My::Class::B' );
my $CLASS_C   = GX::Meta::Class->new( 'My::Class::C' );


# My::Class::A, inheritance
{

    is_deeply(
        [ $CLASS_A->superclasses ],
        []
    );

    is_deeply(
        [ $CLASS_A->all_superclasses ],
        []
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A->subclasses ],
        [ sort { $a->name cmp $b->name } ( $CLASS_A_A, $CLASS_A_B ) ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A->all_subclasses ],
        [ sort { $a->name cmp $b->name } ( $CLASS_A_A, $CLASS_A_B, $CLASS_B, $CLASS_C ) ]
    );

    is_deeply(
        [ $CLASS_A->linearized_isa ],
        [ qw( My::Class::A ) ]
    );

    is_deeply(
        [ $CLASS_A->linearized_isa_classes ],
        [ $CLASS_A ]
    );

}

# My::Class::A, methods
{

    is_deeply(
        [ sort $CLASS_A->method_names ],
        [ map { "method_$_" } 1 .. 3 ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A->methods ],
        [ map { $CLASS_A->method( "method_$_" ) } 1 .. 3 ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A->all_methods ],
        [ map { $CLASS_A->method( "method_$_" ) } 1 .. 3 ]
    );

    is_deeply(
        [ $CLASS_A->inherited_methods ],
        []
    );

    for my $method_name ( map { "method_$_" } 1 .. 3 ) {

        ok( $CLASS_A->has_method( $method_name ) );

        ok( my $method = $CLASS_A->method( $method_name ) );

        isa_ok( $method, 'GX::Meta::Method' );

        is( $method->name, $method_name );
        is( $method->class, $CLASS_A );
        is( $method->code, \&{"My::Class::A::$method_name"} );

        is( refaddr( $CLASS_A->method( $method_name ) ), refaddr( $method ) );

    }

}

# My::Class::A::A, inheritance
{

    is_deeply(
        [ $CLASS_A_A->superclasses ],
        [ qw( My::Class::A ) ]
    );

    is_deeply(
        [ $CLASS_A_A->all_superclasses ],
        [ qw( My::Class::A ) ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A_A->subclasses ],
        [ sort { $a->name cmp $b->name } ( $CLASS_B, $CLASS_C ) ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A_A->all_subclasses ],
        [ sort { $a->name cmp $b->name } ( $CLASS_B, $CLASS_C ) ]
    );

    is_deeply(
        [ $CLASS_A_A->linearized_isa ],
        [ qw( My::Class::A::A My::Class::A ) ]
    );

    is_deeply(
        [ $CLASS_A_A->linearized_isa_classes ],
        [ $CLASS_A_A, $CLASS_A ]
    );

}

# My::Class::A::A, methods
{

    is_deeply(
        [ sort $CLASS_A_A->method_names ],
        [ map { "method_$_" } 2 .. 4 ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A_A->methods ],
        [ map { $CLASS_A_A->method( "method_$_" ) } 2 .. 4 ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A_A->all_methods ],
        [
            ( map { $CLASS_A->method( "method_$_" )   } 1 .. 1 ),
            ( map { $CLASS_A_A->method( "method_$_" ) } 2 .. 4 )
        ]
    );

    is_deeply(
        [ $CLASS_A_A->inherited_methods ],
        [ map { $CLASS_A->method( "method_$_" ) } 1 .. 1 ]
    );

    for my $method_name ( map { "method_$_" } 2 .. 4 ) {

        ok( $CLASS_A_A->has_method( $method_name ) );

        ok( my $method = $CLASS_A_A->method( $method_name ) );

        isa_ok( $method, 'GX::Meta::Method' );

        is( $method->name, $method_name );
        is( $method->class, $CLASS_A_A );
        is( $method->code, \&{"My::Class::A::A::$method_name"} );

        is( refaddr( $CLASS_A_A->method( $method_name ) ), refaddr( $method ) );

    }

}

# My::Class::A::B, inheritance
{

    is_deeply(
        [ $CLASS_A_B->superclasses ],
        [ qw( My::Class::A ) ]
    );

    is_deeply(
        [ $CLASS_A_B->all_superclasses ],
        [ qw( My::Class::A ) ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A_B->subclasses ],
        [ sort { $a->name cmp $b->name } ( $CLASS_B, $CLASS_C ) ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A_B->all_subclasses ],
        [ sort { $a->name cmp $b->name } ( $CLASS_B, $CLASS_C ) ]
    );

    is_deeply(
        [ $CLASS_A_B->linearized_isa ],
        [ qw( My::Class::A::B My::Class::A ) ]
    );

    is_deeply(
        [ $CLASS_A_B->linearized_isa_classes ],
        [ $CLASS_A_B, $CLASS_A ]
    );

}

# My::Class::A::B, methods
{

    is_deeply(
        [ sort $CLASS_A_B->method_names ],
        [ map { "method_$_" } 3 .. 5 ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A_B->methods ],
        [ map { $CLASS_A_B->method( "method_$_" ) } 3 .. 5 ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_A_B->all_methods ],
        [
            ( map { $CLASS_A->method( "method_$_" )   } 1 .. 2 ),
            ( map { $CLASS_A_B->method( "method_$_" ) } 3 .. 5 )
        ]
    );

    is_deeply(
        [ $CLASS_A_B->inherited_methods ],
        [ map { $CLASS_A->method( "method_$_" ) } 1 .. 2 ]
    );

    for my $method_name ( map { "method_$_" } 3 .. 5 ) {

        ok( $CLASS_A_B->has_method( $method_name ) );

        ok( my $method = $CLASS_A_B->method( $method_name ) );

        isa_ok( $method, 'GX::Meta::Method' );

        is( $method->name, $method_name );
        is( $method->class, $CLASS_A_B );
        is( $method->code, \&{"My::Class::A::B::$method_name"} );

        is( refaddr( $CLASS_A_B->method( $method_name ) ), refaddr( $method ) );

    }

}

# My::Class::B, inheritance
{

    is_deeply(
        [ $CLASS_B->superclasses ],
        [ $CLASS_A_A, $CLASS_A_B ]
    );

    is_deeply(
        [ $CLASS_B->all_superclasses ],
        [ $CLASS_A_A, $CLASS_A, $CLASS_A_B ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_B->subclasses ],
        []
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_B->all_subclasses ],
        []
    );

    is_deeply(
        [ $CLASS_B->linearized_isa ],
        [ qw( My::Class::B My::Class::A::A My::Class::A My::Class::A::B ) ]
    );

    is_deeply(
        [ $CLASS_B->linearized_isa_classes ],
        [ $CLASS_B, $CLASS_A_A, $CLASS_A, $CLASS_A_B ]
    );

}

# My::Class::C, inheritance
{

    is_deeply(
        [ $CLASS_C->superclasses ],
        [ $CLASS_A_B, $CLASS_A_A ]
    );

    is_deeply(
        [ $CLASS_C->all_superclasses ],
        [ $CLASS_A_B, $CLASS_A, $CLASS_A_A ]
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_C->subclasses ],
        []
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } $CLASS_C->all_subclasses ],
        []
    );

    is_deeply(
        [ $CLASS_C->linearized_isa ],
        [ qw( My::Class::C My::Class::A::B My::Class::A My::Class::A::A ) ]
    );

    is_deeply(
        [ $CLASS_C->linearized_isa_classes ],
        [ $CLASS_C, $CLASS_A_B, $CLASS_A, $CLASS_A_A ]
    );

}

