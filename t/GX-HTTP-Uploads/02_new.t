#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Upload;
use GX::HTTP::Uploads;


use Test::More tests => 1;


# new()
{

    my $uploads = GX::HTTP::Uploads->new;

    isa_ok( $uploads, 'GX::HTTP::Uploads' );

}
