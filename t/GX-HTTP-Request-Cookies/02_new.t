#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Request::Cookies;


use Test::More tests => 2;


# new()
{

    my $cookies = GX::HTTP::Request::Cookies->new;

    isa_ok( $cookies, 'GX::HTTP::Request::Cookies' );

    is_deeply( [ $cookies->all ], [] );

}

