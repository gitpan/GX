#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Session::ID::Generator::MD5;


use Test::More tests => 6;


# generate_id()
{

    my $generator = GX::Session::ID::Generator::MD5->new;

    like( $generator->generate_id, qr/^[0-9a-fA-F]{32}$/ );

}

# validate_id()
{

    my $generator = GX::Session::ID::Generator::MD5->new;

    ok( $generator->validate_id( 'd23f9e44e3667fe19e3ed38ead87c19e' ) );

    ok( ! $generator->validate_id( undef ) );
    ok( ! $generator->validate_id( '' ) );
    ok( ! $generator->validate_id( 'a' x 33 ) );
    ok( ! $generator->validate_id( 'a' x 31 ) );

}

