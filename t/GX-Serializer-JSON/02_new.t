#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require JSON } ) {
        plan skip_all => "JSON is not installed";
        exit;
    }

    plan tests => 1;

    require GX::Serializer::JSON;

}


# new()
{

    my $serializer = GX::Serializer::JSON->new;

    isa_ok( $serializer, 'GX::Serializer::JSON' );

}

