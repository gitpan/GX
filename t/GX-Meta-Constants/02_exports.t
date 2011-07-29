#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Package::A;

use GX::Meta::Constants;


package My::Package::B;

use GX::Meta::Constants qw(
    REGEX_CLASS_NAME
    REGEX_FULLY_QUALIFIED_NAME
    REGEX_FUNCTION_NAME
    REGEX_IDENTIFIER
    REGEX_METHOD_NAME
    REGEX_MODULE_NAME
    REGEX_NAME
    REGEX_PACKAGE_NAME
    REGEX_SYMBOL_NAME
);


package My::Package::C;

use GX::Meta::Constants qw( :regex );


package main;


use Test::More tests => 45;


# My::Package::A
{

    for ( qw(
        REGEX_CLASS_NAME
        REGEX_FULLY_QUALIFIED_NAME
        REGEX_FUNCTION_NAME
        REGEX_IDENTIFIER
        REGEX_METHOD_NAME
        REGEX_MODULE_NAME
        REGEX_NAME
        REGEX_PACKAGE_NAME
        REGEX_SYMBOL_NAME
    ) ) {
        ok( ! defined &{"My::Package::A::$_"} );
    }

}

# My::Package::B
{

    for ( qw(
        REGEX_CLASS_NAME
        REGEX_FULLY_QUALIFIED_NAME
        REGEX_FUNCTION_NAME
        REGEX_IDENTIFIER
        REGEX_METHOD_NAME
        REGEX_MODULE_NAME
        REGEX_NAME
        REGEX_PACKAGE_NAME
        REGEX_SYMBOL_NAME
    ) ) {
        ok( defined &{"My::Package::B::$_"} );
        no strict 'refs';
        is( ref &{"My::Package::B::$_"}, 'Regexp' );
    }

}

# My::Package::C
{

    for ( qw(
        REGEX_CLASS_NAME
        REGEX_FULLY_QUALIFIED_NAME
        REGEX_FUNCTION_NAME
        REGEX_IDENTIFIER
        REGEX_METHOD_NAME
        REGEX_MODULE_NAME
        REGEX_NAME
        REGEX_PACKAGE_NAME
        REGEX_SYMBOL_NAME
    ) ) {
        ok( defined &{"My::Package::C::$_"} );
        no strict 'refs';
        is( ref &{"My::Package::C::$_"}, 'Regexp' );
    }

}

