#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Class;


use Test::More tests => 1;


# "$class"
{

    my $class = GX::Meta::Class->new( 'My::Class' );

    is( "$class", 'My::Class' );

}

