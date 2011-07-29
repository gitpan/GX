#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Exception ();


use Test::More tests => 1;


{

    my $exception = GX::Exception->new;

    isa_ok( $exception, 'GX::Exception' );

}

