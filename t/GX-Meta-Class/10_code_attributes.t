#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;


use Test::More tests => 12;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );
my $CLASS_B = GX::Meta::Class->new( 'My::Class::B' );

$CLASS_B->inherit_from( $CLASS_A );


{

    $CLASS_A->add_code_attribute( 'CodeAttribute1' );

    is_deeply(
        [ sort $CLASS_A->code_attributes ],
        [ sort qw( CodeAttribute1 ) ]
    );

    is_deeply(
        [ sort $CLASS_A->all_code_attributes ],
        [ sort qw( CodeAttribute1 ) ]
    );

    is_deeply(
        [ sort $CLASS_B->code_attributes ],
        []
    );

    is_deeply(
        [ sort $CLASS_B->all_code_attributes ],
        [ sort qw( CodeAttribute1 ) ]
    );

    $CLASS_A->add_code_attribute( 'CodeAttribute2' );

    is_deeply(
        [ sort $CLASS_A->code_attributes ],
        [ sort qw( CodeAttribute1 CodeAttribute2 ) ]
    );

    is_deeply(
        [ sort $CLASS_A->all_code_attributes ],
        [ sort qw( CodeAttribute1 CodeAttribute2 ) ]
    );

    is_deeply(
        [ sort $CLASS_B->code_attributes ],
        []
    );

    is_deeply(
        [ sort $CLASS_B->all_code_attributes ],
        [ sort qw( CodeAttribute1 CodeAttribute2 ) ]
    );


    $CLASS_B->add_code_attribute( 'CodeAttribute3' );

    is_deeply(
        [ sort $CLASS_A->code_attributes ],
        [ sort qw( CodeAttribute1 CodeAttribute2 ) ]
    );

    is_deeply(
        [ sort $CLASS_A->all_code_attributes ],
        [ sort qw( CodeAttribute1 CodeAttribute2 ) ]
    );

    is_deeply(
        [ sort $CLASS_B->code_attributes ],
        [ sort qw( CodeAttribute3 ) ]
    );

    is_deeply(
        [ sort $CLASS_B->all_code_attributes ],
        [ sort qw( CodeAttribute1 CodeAttribute2 CodeAttribute3 ) ]
    );

}

