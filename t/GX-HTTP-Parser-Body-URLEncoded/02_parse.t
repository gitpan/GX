#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::Scalar;
use GX::HTTP::Util qw( url_encode );
use GX::HTTP::Parser::Body::URLEncoded;


use Test::More tests => 10;


# Empty body
{

    my $body = GX::HTTP::Body::Scalar->new;

    my $result = _parse( $body );

    is_deeply(
        [ $result->{'parameters'}->keys ],
        []
    );

}

# No value
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add( 'k1' );

    my $result = _parse( $body );

    is_deeply(
        [ $result->{'parameters'}->keys ],
        [ qw( k1 ) ]
    );

    is_deeply(
        [ $result->{'parameters'}->get( 'k1' ) ],
        [ '' ]
    );

}

# Multiple keys / values
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add( 'k0&k1=v11&k2=v21&k2=v22&k3=v31&k3=v32&k3=v33' );

    my $result = _parse( $body );

    is_deeply(
        [ $result->{'parameters'}->keys ],
        [ qw( k0 k1 k2 k3 ) ]
    );

    is_deeply(
        [ $result->{'parameters'}->get( 'k0' ) ],
        [ '' ]
    );

    is_deeply(
        [ $result->{'parameters'}->get( 'k1' ) ],
        [ qw( v11 ) ]
    );

    is_deeply(
        [ $result->{'parameters'}->get( 'k2' ) ],
        [ qw( v21 v22 ) ]
    );

    is_deeply(
        [ $result->{'parameters'}->get( 'k3' ) ],
        [ qw( v31 v32 v33 ) ]
    );

}

# URL-encoding
{

    my $content = join( '', map { url_encode( chr $_ ) } 0 .. 255 );

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add( 'k1=' . $content );

    my $result = _parse( $body );

    is_deeply(
        [ $result->{'parameters'}->keys ],
        [ qw( k1 ) ]
    );

    is_deeply(
        [ $result->{'parameters'}->get( 'k1' ) ],
        [ join( '', map { chr $_ } 0 .. 255 ) ]
    );

}


# ----------------------------------------------------------------------------------------------------------------------

sub _parse {

    my $body = shift;

    my $parser = GX::HTTP::Parser::Body::URLEncoded->new(
        content_type => 'application/x-www-form-urlencoded'
    );

    return $parser->parse( $body );

}

