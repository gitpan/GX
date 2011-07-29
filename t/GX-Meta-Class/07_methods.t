#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;


use Test::More tests => 27;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );
my $CLASS_B = GX::Meta::Class->new( 'My::Class::B' );

my @CLASS_A_SUBS = map { sub { "My::Class::A::method_$_" } } 0 .. 2;


# add_method()
{

    $CLASS_B->superclasses( 'My::Class::A' );

    for ( 0 .. 2 ) {

        ok( ! $CLASS_A->has_method( "method_$_" ) );

        $CLASS_A->add_method( "method_$_", $CLASS_A_SUBS[$_] );

        ok( $CLASS_A->has_method( "method_$_" ) );

        is( $CLASS_A->method( "method_$_" )->code, $CLASS_A_SUBS[$_] );

        is_deeply(
            [ sort { $a->name cmp $b->name } $CLASS_A->methods ],
            [ sort { $a->name cmp $b->name } map { $CLASS_A->method( "method_$_" ) } 0 .. $_ ]
        );

        is_deeply(
            [ sort { $a->name cmp $b->name } $CLASS_A->all_methods ],
            [ sort { $a->name cmp $b->name } map { $CLASS_A->method( "method_$_" ) } 0 .. $_ ]
        );

        is_deeply(
            [ sort { $a->name cmp $b->name } $CLASS_B->inherited_methods ],
            [ sort { $a->name cmp $b->name } map { $CLASS_A->method( "method_$_" ) } 0 .. $_ ]
        );

    }

}

# remove_method()
{

    for ( 0 .. 2 ) {

        ok( $CLASS_A->has_method( "method_$_" ) );

        $CLASS_A->remove_method( "method_$_" );

        ok( ! $CLASS_A->remove_method( "method_$_" ) );

    }

    is_deeply(
        [ $CLASS_A->methods ],
        []
    );

    is_deeply(
        [ $CLASS_A->all_methods ],
        []
    );

    is_deeply(
        [ $CLASS_B->inherited_methods ],
        []
    );

}

