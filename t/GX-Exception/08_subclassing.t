#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Exception;

use base 'GX::Exception';


package My::Package::A;

BEGIN { My::Exception->import }

sub throw_1 {

    my $package = shift;

    throw "$package\::throw_1";

}


package main;


use Test::More tests => 7;


{

    ok( defined &My::Package::A::complain );
    ok( defined &My::Package::A::throw );
    ok( defined &My::Package::A::try );
    ok( defined &My::Package::A::catch );

}

{

    eval { My::Exception->throw };

    isa_ok( $@, 'My::Exception' );

}

{

    eval { My::Package::A->throw_1 };

    isa_ok( $@, 'My::Exception' );
    is( $@->message, 'My::Package::A::throw_1' );

}

