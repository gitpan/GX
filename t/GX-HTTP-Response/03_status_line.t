#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Response;


use Test::More tests => 3;


# Default reason phrase
{

    my $response = GX::HTTP::Response->new(
        protocol => 'HTTP/1.1',
        status   => 500
    );

    is( $response->status_line, 'HTTP/1.1 500 Internal Server Error' );

}

# Custom reason phrase
{

    my $response = GX::HTTP::Response->new(
        protocol      => 'HTTP/1.1',
        status        => 500,
        status_reason => 'Ooops'
    );

    is( $response->status_line, 'HTTP/1.1 500 Ooops' );

}

# Custom status code and reason phrase
{

    my $response = GX::HTTP::Response->new(
        protocol      => 'HTTP/1.1',
        status        => 599,
        status_reason => 'On Vacation'
    );

    is( $response->status_line, 'HTTP/1.1 599 On Vacation' );

}

