#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More tests => 1;


{

    require_ok( 'GX::Session::ID::Generator::MD5' );

}

