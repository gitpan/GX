#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Headers;


use Test::More tests => 6;


my $CRLF = "\015\012";


# parse()
{

    my $string =
        'Content-Encoding: gzip'   . $CRLF .
        'CONTENT-TYPE: text/html'  . $CRLF .
        'X-Header: foo'            . $CRLF .
        'X-HeAdEr: bar'            . $CRLF;

    my $headers = GX::HTTP::Headers->parse( $string . $CRLF );

    isa_ok( $headers, 'GX::HTTP::Headers' );

    is_deeply(
        scalar $headers->_headers,
        {
            'CONTENT-TYPE'     => [ 'text/html' ],
            'CONTENT-ENCODING' => [ 'gzip' ],
            'X-HEADER'         => [ qw( foo bar ) ]
        }
    );

}

# parse(), multi-line
{

    my $string =
        'Content-Encoding: gzip'   . $CRLF .
        'Content-Type: text/html'  . $CRLF .
        'X-Header: line 1'         . $CRLF .
        ' line 2'                  . $CRLF .
        '  line 3'                 . $CRLF;

    my $headers = GX::HTTP::Headers->parse( $string. $CRLF );

    isa_ok( $headers, 'GX::HTTP::Headers' );

    is_deeply(
        scalar $headers->_headers,
        {
            'CONTENT-TYPE'     => [ 'text/html' ],
            'CONTENT-ENCODING' => [ 'gzip' ],
            'X-HEADER'         => [ "line 1\nline 2\n line 3" ]
        }
    );

}

# parse(), empty string
{

    my $string = '';

    my $headers = GX::HTTP::Headers->parse( $string );

    isa_ok( $headers, 'GX::HTTP::Headers' );

    is_deeply( scalar $headers->_headers, {} );

}

