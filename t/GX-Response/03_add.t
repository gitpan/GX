#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Response;
{

    use GX::Response;

}


package main;


use Test::More tests => 1;


# add()
{

    my $response = MyApp::Response->new;

    $response->add( 'Hello World!' );

    is( $response->body->as_string, 'Hello World!' );

}

