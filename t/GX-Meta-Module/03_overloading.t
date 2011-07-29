#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Meta::Module;


use Test::More tests => 1;


# "$module"
{

    my $module = GX::Meta::Module->new( 'My::Module' );

    is( "$module", 'My::Module' );

}

