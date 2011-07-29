#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Response::Cookies;


use Test::More tests => 2;


# new()
{

    my $cookies = GX::HTTP::Response::Cookies->new;

    isa_ok( $cookies, 'GX::HTTP::Response::Cookies' );

    is_deeply( [ $cookies->all ], [] );

}

