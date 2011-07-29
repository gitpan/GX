#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Package;


use Test::More tests => 1;


# "$package"
{

    my $package = GX::Meta::Package->new( 'My::Class' );

    is( "$package", 'My::Class' );

}

