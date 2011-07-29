#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Response::Cookie;


use Test::More tests => 4;


# new()
{

    my $cookie = GX::HTTP::Response::Cookie->new;

    isa_ok( $cookie, 'GX::HTTP::Response::Cookie' );

    is_deeply( $cookie, {} );

}

# new( %attributes )
{

    my $cookie = GX::HTTP::Response::Cookie->new(
        name        => 'CUSTOMER',
        value       => 'WILE_E_COYOTE',
        max_age     => 12345,
        domain      => '.store.acme',
        path        => '/shopping_cart',
        secure      => 1,
        http_only   => 1,
        discard     => 1,
        comment     => 'Some comment',
        comment_url => 'http://acme.com/',
        version     => 1
    );

    isa_ok( $cookie, 'GX::HTTP::Response::Cookie' );

    is_deeply(
        $cookie,
        {
            'name'        => 'CUSTOMER',
            'value'       => 'WILE_E_COYOTE',
            'max_age'     => 12345,
            'domain'      => '.store.acme',
            'path'        => '/shopping_cart',
            'secure'      => 1,
            'http_only'   => 1,
            'discard'     => 1,
            'comment'     => 'Some comment',
            'comment_url' => 'http://acme.com/',
            'version'     => 1
        }
    );

}

