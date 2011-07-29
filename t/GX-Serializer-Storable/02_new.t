#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require Storable } ) {
        plan skip_all => "Storable is not installed";
        exit;
    }

    plan tests => 1;

    require GX::Serializer::Storable;

}


# new()
{

    my $serializer = GX::Serializer::Storable->new;

    isa_ok( $serializer, 'GX::Serializer::Storable' );

}

