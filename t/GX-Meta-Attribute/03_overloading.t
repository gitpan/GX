#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;
use GX::Meta::Attribute;


use Test::More tests => 1;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );


# "$attribute"
{

    my $attribute = GX::Meta::Attribute->new(
        class => $CLASS_A,
        name  => 'attribute_1'
    );

    is( "$attribute", 'attribute_1' );

}

