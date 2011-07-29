#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Request::Cookie;


use Test::More tests => 2;


# Simple cookie
{

    my $cookie = GX::HTTP::Request::Cookie->new(
        name  => 'Customer',
        value => 'WILE_E_COYOTE'
    );

    is( $cookie->as_string, '$Version=1; Customer="WILE_E_COYOTE"' );

}

# Cookie with version, path, domain and port attributes
{

    my $cookie = GX::HTTP::Request::Cookie->new(
        name    => 'Customer',
        value   => 'WILE_E_COYOTE',
        path    => '/acme',
        domain  => '.acme.com',
        port    => '80',
        version => 1
    );

    my $string = $cookie->as_string;

    is( $string, '$Version=1; Customer="WILE_E_COYOTE"; $Path=/acme; $Domain=.acme.com; $Port="80"' );

}

