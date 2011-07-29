#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Response::Cookies;


use Test::More tests => 12;


# create( %cookie_attributes )
{

    my $cookies = GX::HTTP::Response::Cookies->new;

    my @cookies;

    for my $i ( 1 .. 3 ) {

        my $cookie = $cookies->create(
            name  => 'name_1',
            value => "value_1_$i"
        );

        isa_ok( $cookie, 'GX::HTTP::Response::Cookie' );

        is( $cookie->name, 'name_1' );
        is( $cookie->value, "value_1_$i" );

        push @cookies, $cookie;

        is_deeply( [ $cookies->all ], \@cookies );

    }

}

