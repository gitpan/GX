#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Response;


use Test::More tests => 3;


# GX::HTTP::Response->new
{

    my $response = GX::HTTP::Response->new;

    isa_ok( $response, 'GX::HTTP::Response' );

    isa_ok( $response->headers, 'GX::HTTP::Response::Headers' );

    isa_ok( $response->body, 'GX::HTTP::Body::Scalar' );

}

