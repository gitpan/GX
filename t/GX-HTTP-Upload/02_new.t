#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Temp;
use GX::HTTP::Upload;


use Test::More tests => 1;


# new()
{

    my $upload = GX::HTTP::Upload->new;

    isa_ok( $upload, 'GX::HTTP::Upload' );

}

