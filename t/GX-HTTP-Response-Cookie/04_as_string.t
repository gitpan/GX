#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Response::Cookie;


use Test::More tests => 2;


# Simple cookie
{

    my $cookie = GX::HTTP::Response::Cookie->new(
        name    => 'Customer',
        value   => 'WILE_E_COYOTE'
    );

    my $string = $cookie->as_string;

    is( $string, 'Customer="WILE_E_COYOTE"; Version=1' );

}

# Cookie with all attributes
{

    my $cookie = GX::HTTP::Response::Cookie->new(
        name        => 'Customer',
        value       => 'WILE_E_COYOTE',
        max_age     => 12345,
        path        => '/acme',
        domain      => '.acme.com',
        port        => 80,
        secure      => 1,
        http_only   => 1,
        discard     => 1,
        comment     => 'shopping_cart',
        comment_url => 'http://acme.com',
        version     => 1
    );

    my $string = $cookie->as_string;

    is(
        $string,
        'Customer="WILE_E_COYOTE"; Comment="shopping_cart"; CommentURL="http://acme.com"; Discard; Domain=.acme.com; HttpOnly; Max-Age=12345; Path=/acme; Port="80"; Secure; Version=1'
    );

}

