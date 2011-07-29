#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;


use Test::More tests => 60;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );
my $CLASS_B = GX::Meta::Class->new( 'My::Class::B' );
my $CLASS_C = GX::Meta::Class->new( 'My::Class::C' );
my $CLASS_D = GX::Meta::Class->new( 'My::Class::D' );
my $CLASS_E = GX::Meta::Class->new( 'My::Class::E' );
my $CLASS_F = GX::Meta::Class->new( 'My::Class::F' );


# superclasses(), all_superclasses(), subclasses(), all_subclasses()
{

    is_deeply( [ $CLASS_A->superclasses ], [] );
    is_deeply( [ $CLASS_B->superclasses ], [] );
    is_deeply( [ $CLASS_C->superclasses ], [] );
    is_deeply( [ $CLASS_D->superclasses ], [] );
    is_deeply( [ $CLASS_E->superclasses ], [] );

    is_deeply( [ $CLASS_A->all_superclasses ], [] );
    is_deeply( [ $CLASS_B->all_superclasses ], [] );
    is_deeply( [ $CLASS_C->all_superclasses ], [] );
    is_deeply( [ $CLASS_D->all_superclasses ], [] );
    is_deeply( [ $CLASS_E->all_superclasses ], [] );

    is_deeply( [ $CLASS_A->subclasses ], [] );
    is_deeply( [ $CLASS_B->subclasses ], [] );
    is_deeply( [ $CLASS_C->subclasses ], [] );
    is_deeply( [ $CLASS_D->subclasses ], [] );
    is_deeply( [ $CLASS_E->subclasses ], [] );

    is_deeply( [ $CLASS_A->all_subclasses ], [] );
    is_deeply( [ $CLASS_B->all_subclasses ], [] );
    is_deeply( [ $CLASS_C->all_subclasses ], [] );
    is_deeply( [ $CLASS_D->all_subclasses ], [] );
    is_deeply( [ $CLASS_E->all_subclasses ], [] );

    is_deeply( [ $CLASS_B->superclasses( 'My::Class::A' ) ], [ $CLASS_A ] );
    is_deeply( [ $CLASS_B->superclasses( $CLASS_A ) ], [ $CLASS_A ] );
    is_deeply( [ $CLASS_C->superclasses( $CLASS_A ) ], [ $CLASS_A ] );
    is_deeply( [ $CLASS_D->superclasses( 'My::Class::B', $CLASS_A ) ], [ $CLASS_B, $CLASS_A ] );
    is_deeply( [ $CLASS_E->superclasses( $CLASS_C, 'My::Class::D' ) ], [ $CLASS_C, $CLASS_D ] );

    is_deeply( [ $CLASS_A->superclasses ], [] );
    is_deeply( [ $CLASS_B->superclasses ], [ $CLASS_A ] );
    is_deeply( [ $CLASS_C->superclasses ], [ $CLASS_A ] );
    is_deeply( [ $CLASS_D->superclasses ], [ $CLASS_B, $CLASS_A ] );
    is_deeply( [ $CLASS_E->superclasses ], [ $CLASS_C, $CLASS_D ] );

    is_deeply( [ $CLASS_A->all_superclasses ], [] );
    is_deeply( [ $CLASS_B->all_superclasses ], [ $CLASS_A ] );
    is_deeply( [ $CLASS_C->all_superclasses ], [ $CLASS_A ] );
    is_deeply( [ $CLASS_D->all_superclasses ], [ $CLASS_B, $CLASS_A ] );
    is_deeply( [ $CLASS_E->all_superclasses ], [ $CLASS_C, $CLASS_A, $CLASS_D, $CLASS_B ] );

    is_deeply(
        [ sort { $a->name cmp $b->name } ( $CLASS_A->subclasses ) ],
        [ sort { $a->name cmp $b->name } ( $CLASS_B, $CLASS_C, $CLASS_D ) ]
    );
    is_deeply(
        [ sort { $a->name cmp $b->name } ( $CLASS_B->subclasses ) ],
        [ sort { $a->name cmp $b->name } ( $CLASS_D ) ]
    );
    is_deeply(
        [ sort { $a->name cmp $b->name } ( $CLASS_C->subclasses ) ],
        [ sort { $a->name cmp $b->name } ( $CLASS_E ) ]
    );
    is_deeply(
        [ sort { $a->name cmp $b->name } ( $CLASS_D->subclasses ) ],
        [ sort { $a->name cmp $b->name } ( $CLASS_E ) ]
    );
    is_deeply(
        [ sort { $a->name cmp $b->name } ( $CLASS_E->subclasses ) ],
        []
    );

    is_deeply(
        [ sort { $a->name cmp $b->name } ( $CLASS_A->all_subclasses ) ],
        [ sort { $a->name cmp $b->name } ( $CLASS_B, $CLASS_C, $CLASS_D, $CLASS_E ) ]
    );
    is_deeply(
        [ sort { $a->name cmp $b->name } ( $CLASS_B->all_subclasses ) ],
        [ sort { $a->name cmp $b->name } ( $CLASS_D, $CLASS_E ) ]
    );
    is_deeply(
        [ sort { $a->name cmp $b->name } ( $CLASS_C->all_subclasses ) ],
        [ sort { $a->name cmp $b->name } ( $CLASS_E ) ]
    );
    is_deeply(
        [ sort { $a->name cmp $b->name } ( $CLASS_D->all_subclasses ) ],
        [ sort { $a->name cmp $b->name } ( $CLASS_E ) ]
    );
    is_deeply(
        [ sort { $a->name cmp $b->name } ( $CLASS_E->all_subclasses ) ],
        []
    );

}

# inherit_from()
{

    $CLASS_F->inherit_from( 'My::Class::A' );

    is_deeply( [ $CLASS_F->superclasses ], [ $CLASS_A ] );

    $CLASS_F->inherit_from( 'My::Class::B' );

    is_deeply( [ $CLASS_F->superclasses ], [ $CLASS_B, $CLASS_A ] );

    $CLASS_F->inherit_from( 'My::Class::D', $CLASS_C );

    is_deeply( [ $CLASS_F->superclasses ], [ $CLASS_D, $CLASS_C, $CLASS_B, $CLASS_A ] );

}

# linearized_isa()
{

    is_deeply( [ $CLASS_A->linearized_isa ], [ 'My::Class::A' ] );
    is_deeply( [ $CLASS_B->linearized_isa ], [ 'My::Class::B', 'My::Class::A' ] );
    is_deeply( [ $CLASS_C->linearized_isa ], [ 'My::Class::C', 'My::Class::A' ] );
    is_deeply( [ $CLASS_D->linearized_isa ], [ 'My::Class::D', 'My::Class::B', 'My::Class::A' ] );
    is_deeply( [ $CLASS_E->linearized_isa ], [ 'My::Class::E', 'My::Class::C', 'My::Class::A', 'My::Class::D', 'My::Class::B' ] );
    is_deeply( [ $CLASS_F->linearized_isa ], [ 'My::Class::F', 'My::Class::D', 'My::Class::B', 'My::Class::A', 'My::Class::C' ] );

}

# linearized_isa_classes()
{

    is_deeply( [ $CLASS_A->linearized_isa_classes ], [ $CLASS_A ] );
    is_deeply( [ $CLASS_B->linearized_isa_classes ], [ $CLASS_B, $CLASS_A ] );
    is_deeply( [ $CLASS_C->linearized_isa_classes ], [ $CLASS_C, $CLASS_A ] );
    is_deeply( [ $CLASS_D->linearized_isa_classes ], [ $CLASS_D, $CLASS_B, $CLASS_A ] );
    is_deeply( [ $CLASS_E->linearized_isa_classes ], [ $CLASS_E, $CLASS_C, $CLASS_A, $CLASS_D, $CLASS_B ] );
    is_deeply( [ $CLASS_F->linearized_isa_classes ], [ $CLASS_F, $CLASS_D, $CLASS_B, $CLASS_A, $CLASS_C ] );

}

