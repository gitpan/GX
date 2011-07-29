#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Response::Headers;


use Test::More tests => 1;


# new()
{

    my $headers = GX::HTTP::Response::Headers->new;

    isa_ok( $headers, 'GX::HTTP::Response::Headers' );

}

