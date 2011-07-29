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


# serialize(), unserialize()
{

    my $serializer = GX::Serializer::Storable->new;

    my $data = {
        'k1' => 'v1',
        'k2' => [ 'v21', 'v22' ],
        'k3' => { 'v3k1' => 'v3v1', 'v3k2' => 'v3v2' }
    };

    my $string = $serializer->serialize( $data );

    is_deeply( $serializer->unserialize( $string ), $data );

}

