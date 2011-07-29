#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Headers;


use Test::More tests => 5;


my $CRLF = "\015\012";


# no fields
{

    my $headers = GX::HTTP::Headers->new;

    is( $headers->as_string, '' );

}

# field order
{

    my $headers = GX::HTTP::Headers->new;

    # custom headers
    $headers->set( 'X-Foo' => 'foo' );

    # entity headers
    $headers->set( 'Allow' => 'GET' );
    $headers->set( 'Content-Type' => 'text/html' );
    $headers->set( 'Content-MD5' => 'dummy' );
    $headers->set( 'Content-Encoding' => 'gzip' );
    $headers->set( 'Last-Modified' => 'yesterday' );
    $headers->set( 'Expires' => 'tomorrow' );

    # response headers
    $headers->set( 'ETag' => '123' );

    # general headers
    $headers->set( 'Date' => 'today' );

    my $string = $headers->as_string;

    is(
        $string,
        'Date: today'              . $CRLF .
        'ETag: 123'                . $CRLF .
        'Allow: GET'               . $CRLF .
        'Content-Encoding: gzip'   . $CRLF .
        'Content-MD5: dummy'       . $CRLF .
        'Content-Type: text/html'  . $CRLF .
        'Expires: tomorrow'        . $CRLF .
        'Last-Modified: yesterday' . $CRLF .
        'X-FOO: foo'               . $CRLF
    );

    is_deeply( GX::HTTP::Headers->parse( $string ), $headers );

}

# field values with embedded newlines
{

    my $headers = GX::HTTP::Headers->new;

    $headers->set( 'a' => "foo\nbar" );
    $headers->set( 'b' => "foo\nbar\n baz" );

    my $string = $headers->as_string;

    is(
        $string,
        'A: foo' . $CRLF .
        ' bar'   . $CRLF .
        'B: foo' . $CRLF .
        ' bar'   . $CRLF .
        '  baz'  . $CRLF
    );

    is_deeply( GX::HTTP::Headers->parse( $string ), $headers );

}

