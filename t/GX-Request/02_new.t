#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Request;
{

    use GX::Request;

}


package main;


use Test::More tests => 10;


# new()
{

    my $request = MyApp::Request->new;

    isa_ok( $request, 'GX::Request' );

    isa_ok( $request->headers, 'GX::HTTP::Request::Headers' );
    isa_ok( $request->cookies, 'GX::HTTP::Request::Cookies' );
    isa_ok( $request->body, 'GX::HTTP::Body::Scalar' );
    isa_ok( $request->parameters, 'GX::HTTP::Parameters' );
    isa_ok( $request->body_parameters, 'GX::HTTP::Parameters' );
    isa_ok( $request->path_parameters, 'GX::HTTP::Parameters' );
    isa_ok( $request->query_parameters, 'GX::HTTP::Parameters' );
    isa_ok( $request->uploads, 'GX::HTTP::Uploads' );

    is( $request->body_parser, undef );

}

