#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::Scalar;


use Test::More tests => 1;


# content()
{

    my $string = "Hello World!\nThis is GX.\n";

    my $body = GX::HTTP::Body::Scalar->new( \$string );

    is( $body->content, \$string );

}

