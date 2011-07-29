#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Request::Cookie;


use Test::More tests => 4;


# new()
{

    my $cookie = GX::HTTP::Request::Cookie->new;

    isa_ok( $cookie, 'GX::HTTP::Request::Cookie' );

    is_deeply( $cookie, {} );

}

# new( %attributes )
{

    my $cookie = GX::HTTP::Request::Cookie->new(
        name      => 'CUSTOMER',
        value     => 'WILE_E_COYOTE',
        domain    => '.store.acme',
        path      => '/shopping_cart',
        version   => 1
    );

    isa_ok( $cookie, 'GX::HTTP::Request::Cookie' );

    is_deeply(
        $cookie,
        {
            'name'    => 'CUSTOMER',
            'value'   => 'WILE_E_COYOTE',
            'domain'  => '.store.acme',
            'path'    => '/shopping_cart',
            'version' => 1
        }
    );

}

