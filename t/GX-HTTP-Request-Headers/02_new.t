#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Request::Headers;


use Test::More tests => 1;


# new()
{

    my $headers = GX::HTTP::Request::Headers->new;

    isa_ok( $headers, 'GX::HTTP::Request::Headers' );

}

