#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Headers;


use Test::More tests => 1;


# new()
{

    my $headers = GX::HTTP::Headers->new;

    isa_ok( $headers, 'GX::HTTP::Headers' );

}

