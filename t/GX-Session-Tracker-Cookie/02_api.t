#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Context;
use GX::Request;
use GX::Response;
use GX::Session::Tracker::Cookie;


use Test::More tests => 20;


# set_id()
{

    my $tracker = GX::Session::Tracker::Cookie->new;

    my $context = _fake_context();

    $tracker->set_id( $context, '12345' );

    ok( my $cookie = $context->response->cookies->get( 'SESSION_ID' ) );

    is( $cookie->value, '12345' );
    is( $cookie->max_age, undef );
    is( $cookie->path, '/' );
    ok( $cookie->http_only );
    ok( ! $cookie->secure );

}

# set_id(), custom cookie attributes
{

    my $tracker = GX::Session::Tracker::Cookie->new(
        cookie_attributes => {
            name    => 'my_session_cookie',
            domain  => 'acme.com',
            path    => '/shop',
            secure  => 1,
            max_age => 3600 
        }
    );

    my $context = _fake_context();

    $tracker->set_id( $context, '12345' );

    ok( my $cookie = $context->response->cookies->get( 'my_session_cookie' ) );

    is( $cookie->value, '12345' );
    is( $cookie->max_age, 3600 );
    is( $cookie->domain, 'acme.com' );
    is( $cookie->path, '/shop' );
    ok( $cookie->http_only );
    ok( $cookie->secure );

}

# unset_id()
{

    my $tracker = GX::Session::Tracker::Cookie->new;

    my $context = _fake_context();

    $tracker->unset_id( $context );

    ok( my $cookie = $context->response->cookies->get( 'SESSION_ID' ) );

    is( $cookie->value, '' );
    is( $cookie->max_age, 0 );
    is( $cookie->path, '/' );
    ok( $cookie->http_only );
    ok( ! $cookie->secure );

}

# get_id()
{

    my $tracker = GX::Session::Tracker::Cookie->new;

    my $context = _fake_context();

    $context->request->cookies->create(
        name  => 'SESSION_ID',
        value => '12345'
    );

    is( $tracker->get_id( $context ), '12345' );

}


# ----------------------------------------------------------------------------------------------------------------------

sub _fake_context {

    return GX::Context->new( request => GX::Request->new, response => GX::Response->new );

}

