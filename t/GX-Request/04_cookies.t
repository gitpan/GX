#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Request;
{

    use GX::Request;

}


package main;


use Test::More tests => 14;


# cookies(), cookie( $name )
{

    my $request = MyApp::Request->new;

    $request->headers->add(
        'Cookie' =>
            '$Version="1";' .
            'Customer="WILE_E_COYOTE"; $Path="/acme";' .
            'Part_Number="Rocket_Launcher_0001"; $Path="/acme/shop";' .
            'Shipping="FedEx"; $Path="/acme/shop"'
    );

    isa_ok( $request->cookies, 'GX::HTTP::Request::Cookies' );

    is( scalar( my @cookies = $request->cookies->all ), 3 );

    is( $request->cookie( 'Customer' ), $cookies[0]  );
    is( $request->cookie( 'Part_Number' ), $cookies[1] );
    is( $request->cookie( 'Shipping' ), $cookies[2] );

    is( $cookies[0]->name, 'Customer' );
    is( $cookies[0]->value, 'WILE_E_COYOTE' );

    is( $cookies[1]->name, 'Part_Number' );
    is( $cookies[1]->value, 'Rocket_Launcher_0001' );

    is( $cookies[2]->name, 'Shipping' );
    is( $cookies[2]->value, 'FedEx' );

}

# cookies(), cookie( $name ) - empty cookies container
{

    my $request = MyApp::Request->new;

    isa_ok( $request->cookies, 'GX::HTTP::Cookies' );

    is( scalar( my @cookies = $request->cookies->all ), 0 );

    is( $request->cookie( 'x' ), undef );

}

