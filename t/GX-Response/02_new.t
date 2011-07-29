#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Response;
{

    use GX::Response;

}


package main;


use Test::More tests => 4;


# new()
{

    my $response = MyApp::Response->new;

    isa_ok( $response, 'GX::Response' );

    isa_ok( $response->headers, 'GX::HTTP::Response::Headers' );
    isa_ok( $response->cookies, 'GX::HTTP::Response::Cookies' );
    isa_ok( $response->body, 'GX::HTTP::Body::Scalar' );

}

