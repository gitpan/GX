#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More tests => 1;


package My::Package::A;

use GX::SQL::Types qw( :all );

use Test::More;


{

    ok( defined INTEGER );

}

