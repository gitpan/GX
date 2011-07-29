#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::File;


use Test::More tests => 1;


# new()
{

    my $body = GX::HTTP::Body::File->new;

    isa_ok( $body, 'GX::HTTP::Body::File' );

}

