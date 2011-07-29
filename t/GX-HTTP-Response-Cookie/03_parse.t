#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Response::Cookie;


use Test::More tests => 90;


# Simple cookie
{

    my $string = 'Customer=WILE_E_COYOTE; Version=1';

    my @cookies = GX::HTTP::Response::Cookie->parse( $string );

    is( @cookies, 1 );

    my $cookie = $cookies[0];

    isa_ok( $cookie, 'GX::HTTP::Response::Cookie' );

    is( $cookie->name, 'Customer' );
    is( $cookie->value, 'WILE_E_COYOTE' );
    is( $cookie->max_age, undef );
    is( $cookie->domain, undef );
    is( $cookie->expires, undef );
    is( $cookie->path, undef );
    is( $cookie->port, undef );
    is( $cookie->comment, undef );
    is( $cookie->comment_url, undef );
    is( $cookie->version, '1' );
    ok( ! $cookie->secure );
    ok( ! $cookie->http_only );
    ok( ! $cookie->discard );

}

# Complex cookie
{

    my $string = 'Customer=WILE_E_COYOTE; Comment=shopping_cart; CommentURL="http://acme.com"; Discard; Domain=.acme.com; HttpOnly; Max-Age=12345; Path=/acme; Port="80"; Secure; Version=1';

    my @cookies = GX::HTTP::Response::Cookie->parse( $string );

    is( @cookies, 1 );

    my $cookie = $cookies[0];

    isa_ok( $cookie, 'GX::HTTP::Response::Cookie' );

    is( $cookie->name, 'Customer' );
    is( $cookie->value, 'WILE_E_COYOTE' );
    is( $cookie->max_age, '12345' );
    is( $cookie->domain, '.acme.com' );
    is( $cookie->expires, undef );
    is( $cookie->path, '/acme' );
    is( $cookie->port, 80 );
    is( $cookie->comment, 'shopping_cart' );
    is( $cookie->comment_url, 'http://acme.com' );
    is( $cookie->version, '1' );
    ok( $cookie->secure );
    ok( $cookie->http_only );
    ok( $cookie->discard );

}

# Old Netscape cookie
{

    my @strings = (
        'CUSTOMER=WILE_E_COYOTE; path=/; expires=Wednesday, 09-Nov-99 23:12:40 GMT',
        'CUSTOMER=WILE_E_COYOTE; path=/; expires=Wednesday, 09-Nov-99 23:12:40 GMT;',
        'CUSTOMER=WILE_E_COYOTE; expires=Wednesday, 09-Nov-99 23:12:40 GMT; path=/',
        'CUSTOMER=WILE_E_COYOTE; expires=Wednesday, 09-Nov-99 23:12:40 GMT; path=/;'
    );

    for my $string ( @strings ) {

        my @cookies = GX::HTTP::Response::Cookie->parse( $string );

        is( @cookies, 1 );

        my $cookie = $cookies[0];

        isa_ok( $cookie, 'GX::HTTP::Response::Cookie' );

        is( $cookie->name, 'CUSTOMER' );
        is( $cookie->value, 'WILE_E_COYOTE' );
        is( $cookie->max_age, undef );
        is( $cookie->domain, undef );
        is( $cookie->expires, 'Wednesday, 09-Nov-99 23:12:40 GMT' );
        is( $cookie->path, '/' );
        is( $cookie->port, undef );
        is( $cookie->comment, undef );
        is( $cookie->comment_url, undef );
        is( $cookie->version, undef );
        ok( ! $cookie->secure );
        ok( ! $cookie->http_only );
        ok( ! $cookie->discard );

    }

}

