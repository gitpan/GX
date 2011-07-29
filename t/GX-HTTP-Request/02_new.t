#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Request;


use Test::More tests => 3;


# new()
{

    my $request = GX::HTTP::Request->new;

    isa_ok( $request, 'GX::HTTP::Request' );

    isa_ok( $request->headers, 'GX::HTTP::Request::Headers' );

    isa_ok( $request->body, 'GX::HTTP::Body::Scalar' );

}

