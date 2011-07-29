#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Parser::Body;


use Test::More tests => 4;


# Content type: multipart/form-data
{

    my $content_type = 'multipart/form-data; boundary=GXBOUNDARY';

    {
        my $parser = GX::HTTP::Parser::Body->new( $content_type );
        isa_ok( $parser, 'GX::HTTP::Parser::Body::MultiPart' );
    }

    {
        my $parser = GX::HTTP::Parser::Body->new( content_type => $content_type );
        isa_ok( $parser, 'GX::HTTP::Parser::Body::MultiPart' );
    }

}

# Content type: application/x-www-form-urlencoded
{

    my $content_type = 'application/x-www-form-urlencoded';

    {
        my $parser = GX::HTTP::Parser::Body->new( $content_type );
        isa_ok( $parser, 'GX::HTTP::Parser::Body::URLEncoded' );
    }

    {
        my $parser = GX::HTTP::Parser::Body->new( content_type => $content_type );
        isa_ok( $parser, 'GX::HTTP::Parser::Body::URLEncoded' );
    }

}

