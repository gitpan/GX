#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Request::Cookie;


use Test::More tests => 35;


# Simple cookie with path attribute
{

    my @cookies = GX::HTTP::Request::Cookie->parse(
        '$Version=1; foo=bar; $Path="/path"'
    );

    is( scalar @cookies, 1 );

    is( $cookies[0]->name, 'foo' );
    is( $cookies[0]->value, 'bar' );
    is( $cookies[0]->path, '/path' );
    is( $cookies[0]->domain, undef );
    is( $cookies[0]->version, '1' );

}

# Simple cookie with path, domain and port attributes
{

    my @cookies = GX::HTTP::Request::Cookie->parse(
        '$Version=1; foo="bar"; $Path="/path"; $Domain=".acme"; $Port="80"'
    );

    is( scalar @cookies, 1 );

    is( $cookies[0]->name, 'foo' );
    is( $cookies[0]->value, 'bar' );
    is( $cookies[0]->path, '/path' );
    is( $cookies[0]->domain, '.acme' );
    is( $cookies[0]->port, '80' );
    is( $cookies[0]->version, '1' );

}

# Quoted value
{

    my $string = '$Version=1; foo="b a\" r\"\\\"; $Path="/path"';

    my @cookies = GX::HTTP::Request::Cookie->parse( $string );

    is( scalar @cookies, 1 );

    is( $cookies[0]->name, 'foo' );
    is( $cookies[0]->value, 'b a" r"\\' );
    is( $cookies[0]->domain, undef );
    is( $cookies[0]->path, '/path' );
    is( $cookies[0]->version, '1' );

}

# Multiple cookies
{

    my $string =
        '$Version="1";' .
        'Customer="WILE_E_COYOTE"; $Path="/acme";' .
        'Part_Number="Rocket_Launcher_0001"; $Path="/acme/shop";' .
        'Shipping="FedEx"; $Path="/acme/shop"';

    my @cookies = GX::HTTP::Request::Cookie->parse( $string );

    is( scalar @cookies, 3 );

    is( $cookies[0]->name, 'Customer' );
    is( $cookies[0]->value, 'WILE_E_COYOTE' );
    is( $cookies[0]->domain, undef );
    is( $cookies[0]->path, '/acme' );
    is( $cookies[0]->version, '1' );

    is( $cookies[1]->name, 'Part_Number' );
    is( $cookies[1]->value, 'Rocket_Launcher_0001' );
    is( $cookies[1]->domain, undef );
    is( $cookies[1]->path, '/acme/shop' );
    is( $cookies[1]->version, '1' );

    is( $cookies[2]->name, 'Shipping' );
    is( $cookies[2]->value, 'FedEx' );
    is( $cookies[2]->domain, undef );
    is( $cookies[2]->path, '/acme/shop' );
    is( $cookies[2]->version, '1' );

}

