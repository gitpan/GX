#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::Scalar;
use GX::HTTP::Parser::Body::MultiPart;


use Test::More tests => 1753;


use constant CRLF => "\015\012";


# No headers
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add(
        join( '',
            'Preamble' . CRLF,
            '--GXBOUNDARY' . CRLF,
            CRLF,
            '--GXBOUNDARY--'
        )
    );

    ok( my $result = _parse( $body ) );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $result );

    my $parts      = $result->{'parts'};
    my $parameters = $result->{'parameters'};
    my $uploads    = $result->{'uploads'};

    is( scalar @$parts, 1 );

    is_deeply( $parts->[0], {} );

    is( $parameters, undef );
    is( $uploads, undef );

}

# Single header field
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add(
        join ( '',
            'Preamble' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_1"' . CRLF,
            CRLF,
            '--GXBOUNDARY--'
        )
    );

    ok( my $result = _parse( $body ) );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $result );

    my $parts      = $result->{'parts'};
    my $parameters = $result->{'parameters'};
    my $uploads    = $result->{'uploads'};

    is( scalar @$parts, 1 );

    isa_ok( $parts->[0]{'headers'}, 'GX::HTTP::Headers' );

    is_deeply(
        [ sort $parts->[0]{'headers'}->field_names ],
        [ sort qw( Content-Disposition ) ]
    );

    is( $parts->[0]{'headers'}->content_disposition, 'form-data; name="key_1"' );

    is( $parameters, undef );
    is( $uploads, undef );

}

# Multiple header fields
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add(
        join ( '',
            'Preamble' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_1"' . CRLF,
            CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_2"' . CRLF,
            'X-Header-1: x1' . CRLF,
            CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_3"' . CRLF,
            'X-Header-1: x1' . CRLF,
            'X-Header-2: x2' . CRLF,
            CRLF,
            '--GXBOUNDARY--'
        )
    );

    ok( my $result = _parse( $body ) );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $result );

    my $parts = $result->{'parts'};

    is( scalar @$parts, 3 );

    is_deeply(
        [ sort $parts->[0]{'headers'}->field_names ],
        [ sort qw( Content-Disposition ) ]
    );

    is( $parts->[0]{'headers'}->content_disposition, 'form-data; name="key_1"' );

    is_deeply(
        [ sort $parts->[1]{'headers'}->field_names ],
        [ sort qw( Content-Disposition X-HEADER-1 ) ]
    );

    is( $parts->[1]{'headers'}->content_disposition, 'form-data; name="key_2"' );
    is( $parts->[1]{'headers'}->get( 'X-Header-1' ), 'x1' );

    is_deeply(
        [ sort $parts->[2]{'headers'}->field_names ],
        [ sort qw( Content-Disposition X-HEADER-1 X-HEADER-2 ) ]
    );

    is( $parts->[2]{'headers'}->content_disposition, 'form-data; name="key_3"' );
    is( $parts->[2]{'headers'}->get( 'X-Header-1' ), 'x1' );
    is( $parts->[2]{'headers'}->get( 'X-Header-2' ), 'x2' );

}

# Parameters
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add(
        join ( '',
            'Preamble' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_1"' . CRLF,
            CRLF,
            'value 1' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_2"' . CRLF,
            CRLF,
            'value 2.1' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_2"' . CRLF,
            CRLF,
            'value 2.2' . CRLF,
            '--GXBOUNDARY--'
        )
    );

    ok( my $result = _parse( $body ) );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $result );

    my $parts      = $result->{'parts'};
    my $parameters = $result->{'parameters'};
    my $uploads    = $result->{'uploads'};

    is( scalar @$parts, 3 );

    is_deeply(
        [ $result->{'parameters'}->keys ],
        [ 'key_1', 'key_2' ]
    );

    is_deeply(
        [ $result->{'parameters'}->get( 'key_1' ) ],
        [ 'value 1' ]
    );

    is_deeply(
        [ $result->{'parameters'}->get( 'key_2' ) ],
        [ 'value 2.1', 'value 2.2' ]
    );

    is( $uploads, undef );

}

# Parameters, trailing CRLF
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add(
        join ( '',
            'Preamble' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_1"' . CRLF,
            CRLF,
            'Line 1' . CRLF,
            'Line 2' . CRLF,
            CRLF,
            '--GXBOUNDARY--'
        )
    );

    ok( my $result = _parse( $body ) );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $result );

    my $parts      = $result->{'parts'};
    my $parameters = $result->{'parameters'};
    my $uploads    = $result->{'uploads'};

    is( scalar @$parts, 1 );

    is_deeply(
        [ $parameters->keys ],
        [ 'key_1' ]
    );

    is_deeply(
        [ $parameters->get( 'key_1' ) ],
        [ 'Line 1' . CRLF . 'Line 2' . CRLF ]
    );

    is( $uploads, undef );

}

# Parameters, no trailing newline
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add(
        join ( '',
            'Preamble' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_1"' . CRLF,
            CRLF,
            'Line 1' . CRLF,
            'Line 2' . CRLF,
            '--GXBOUNDARY--'
        )
    );

    ok( my $result = _parse( $body ) );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $result );

    my $parts      = $result->{'parts'};
    my $parameters = $result->{'parameters'};
    my $uploads    = $result->{'uploads'};

    is( scalar @$parts, 1 );

    is_deeply(
        [ $parameters->keys ],
        [ 'key_1' ]
    );

    is_deeply(
        [ $parameters->get( 'key_1' ) ],
        [ 'Line 1' . CRLF . 'Line 2' ]
    );

    is( $uploads, undef );

}

# Single upload
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add(
        join ( '',
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_1"; filename="filename_1.txt"' . CRLF,
            CRLF,
            'File content' . CRLF,
            '--GXBOUNDARY--'
        )
    );

    ok( my $result = _parse( $body ) );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $result );

    my $parts      = $result->{'parts'};
    my $parameters = $result->{'parameters'};
    my $uploads    = $result->{'uploads'};

    is( scalar @$parts, 1 );

    is( $parameters, undef );

    isa_ok( $uploads, 'GX::HTTP::Uploads' );
    is( @$uploads, 1 );

    isa_ok( $uploads->[0], 'GX::HTTP::Upload' );
    isa_ok( $uploads->[0]->headers, 'GX::HTTP::Headers' );
    is( $uploads->[0]->name, 'file_1' );
    is( $uploads->[0]->filename, 'filename_1.txt' );
    is( $uploads->[0]->size, 12 );

    my $fh = $uploads->[0]->open;
    is( join( '', $fh->getlines ), 'File content' );
    $fh->close;

    my $file = $uploads->[0]->file;

    ok( -f $file );

    undef $result;
    undef $parts;
    undef $parameters;
    undef $uploads;

    ok( ! -f $file );

}

# Single upload (big)
{

    my $body = GX::HTTP::Body::Scalar->new;

    my $data = 'File content' x 8192;

    $body->add(
        join ( '',
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_1"; filename="filename_1.txt"' . CRLF,
            CRLF,
            $data . CRLF,
            '--GXBOUNDARY--'
        )
    );

    ok( my $result = _parse( $body ) );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $result );

    my $parts      = $result->{'parts'};
    my $parameters = $result->{'parameters'};
    my $uploads    = $result->{'uploads'};

    is( scalar @$parts, 1 );

    is( $parameters, undef );

    isa_ok( $uploads, 'GX::HTTP::Uploads' );
    is( @$uploads, 1 );

    isa_ok( $uploads->[0], 'GX::HTTP::Upload' );
    isa_ok( $uploads->[0]->headers, 'GX::HTTP::Headers' );
    is( $uploads->[0]->name, 'file_1' );
    is( $uploads->[0]->filename, 'filename_1.txt' );
    is( $uploads->[0]->size, 12 * 8192 );

    my $fh = $uploads->[0]->open;
    is( join( '', $fh->getlines ), $data );
    $fh->close;

    my $file = $uploads->[0]->file;

    ok( -f $file );

    undef $result;
    undef $parts;
    undef $parameters;
    undef $uploads;

    ok( ! -f $file );

}

# Multiple uploads
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add(
        join ( '',
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_0"; filename="filename_0.txt"' . CRLF,
            CRLF,
            'File content 0' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_1"; filename="filename_1.txt"' . CRLF,
            CRLF,
            'File content 1' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_2"; filename="filename_2.txt"' . CRLF,
            CRLF,
            'File content 2' . CRLF,
            '--GXBOUNDARY--'
        )
    );

    ok( my $result = _parse( $body ) );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $result );

    my $parts      = $result->{'parts'};
    my $parameters = $result->{'parameters'};
    my $uploads    = $result->{'uploads'};

    is( scalar @$parts, 3 );

    is( $parameters, undef );

    isa_ok( $uploads, 'GX::HTTP::Uploads' );
    is( @$uploads, 3 );

    my @files;

    for my $i ( 0 .. 2 ) {

        my $upload = $uploads->[$i];

        isa_ok( $upload, 'GX::HTTP::Upload' );
        isa_ok( $upload->headers, 'GX::HTTP::Headers' );
        is( $upload->name, "file_$i" );
        is( $upload->filename, "filename_$i.txt" );
        is( $upload->size, 14 );

        my $fh = $upload->open;
        is( join( '', $fh->getlines ), "File content $i" );
        $fh->close;

        push @files, $upload->file;

    }

    for my $file ( @files ) {
        ok( -f $file );
    }

    undef $result;
    undef $parts;
    undef $parameters;
    undef $uploads;

    for my $file ( @files ) {
        ok( ! -f $file );
    }

}

# Discard uploads
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add(
        join ( '',
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_0"; filename="filename_0.txt"' . CRLF,
            CRLF,
            'File content 0' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_1"; filename="filename_1.txt"' . CRLF,
            CRLF,
            'File content 1' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_2"; filename="filename_2.txt"' . CRLF,
            CRLF,
            'File content 2' . CRLF,
            '--GXBOUNDARY--'
        )
    );

    my $parser = GX::HTTP::Parser::Body::MultiPart->new(
        content_type    => 'multipart/form-data; boundary=GXBOUNDARY',
        discard_uploads => 1
    );

    ok( my $result = $parser->parse( $body ) );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $result );

    my $parts      = $result->{'parts'};
    my $parameters = $result->{'parameters'};
    my $uploads    = $result->{'uploads'};

    is( scalar @$parts, 3 );

    is( $parameters, undef );

    is( $uploads, undef );

}

# Complex test
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add(
        join ( '',
            'Preamble' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_1"' . CRLF,
            CRLF,
            'value 1' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'X-Header-1: 1' . CRLF,
            CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_2"' . CRLF,
            'X-Header-1: 1' . CRLF,
            CRLF,
            'value 2.1' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_2"' . CRLF,
            'X-Header-1: 1' . CRLF,
            'X-Header-2: 2' . CRLF,
            CRLF,
            'value 2.2' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="file_1"; filename="filename_1.txt"' . CRLF,
            CRLF,
            'File content' . CRLF,
            '--GXBOUNDARY--' . CRLF,
            'Epilogue'
        )
    );

    ok( my $result = _parse( $body ) );

#     require Data::Dumper;
#     warn Data::Dumper::Dumper( $result );

    my $parts      = $result->{'parts'};
    my $parameters = $result->{'parameters'};
    my $uploads    = $result->{'uploads'};

    is( scalar @$parts, 5 );

    is_deeply(
        [ $parameters->keys ],
        [ 'key_1', 'key_2' ]
    );

    is_deeply(
        [ $parameters->get( 'key_1' ) ],
        [ 'value 1' ]
    );

    is_deeply(
        [ $parameters->get( 'key_2' ) ],
        [ 'value 2.1', 'value 2.2' ]
    );

    isa_ok( $uploads, 'GX::HTTP::Uploads' );
    is( @$uploads, 1 );

    isa_ok( $uploads->[0], 'GX::HTTP::Upload' );
    isa_ok( $uploads->[0]->headers, 'GX::HTTP::Headers' );
    is( $uploads->[0]->name, 'file_1' );
    is( $uploads->[0]->filename, 'filename_1.txt' );
    is( $uploads->[0]->size, 12 );

    my $fh = $uploads->[0]->open;
    is( join( '', $fh->getlines ), 'File content' );
    $fh->close;

    my $file = $uploads->[0]->file;

    ok( -f $file );

    undef $result;
    undef $parts;
    undef $parameters;
    undef $uploads;

    ok( ! -f $file );

}

# Chunk size
{

    my $body = GX::HTTP::Body::Scalar->new;

    $body->add(
        join ( '',
            'Preamble' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_1"' . CRLF,
            CRLF,
            'value 1' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'X-Header-1: 1' . CRLF,
            CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_2"' . CRLF,
            'X-Header-1: 1' . CRLF,
            CRLF,
            'value 2.1' . CRLF,
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_2"' . CRLF,
            'X-Header-1: 1' . CRLF,
            'X-Header-2: 2' . CRLF,
            CRLF,
            'value 2.2' . CRLF,
            '--GXBOUNDARY--' . CRLF,
            'Epilogue'
        )
    );

    for my $buffer_size ( 1 .. $body->length ) {

        my $parser = GX::HTTP::Parser::Body::MultiPart->new(
            content_type => 'multipart/form-data; boundary=GXBOUNDARY'
        );

        ok( my $result = $parser->parse( $body, $buffer_size ) );

        my $parts      = $result->{'parts'};
        my $parameters = $result->{'parameters'};
        my $uploads    = $result->{'uploads'};

        is( scalar @$parts, 4 );

        is_deeply(
            [ $parameters->keys ],
            [ 'key_1', 'key_2' ]
        );

        is_deeply(
            [ $parameters->get( 'key_1' ) ],
            [ 'value 1' ]
        );

        is_deeply(
            [ $parameters->get( 'key_2' ) ],
            [ 'value 2.1', 'value 2.2' ]
        );

    }

}

# Malformatted body
{

    my @content = (

        # No content
        '',

        # No end delimiter
        join( '',
            '--GXBOUNDARY' . CRLF,
            CRLF
        ),

        # Invalid end delimiter
        join( '',
            '--GXBOUNDARY' . CRLF,
            CRLF,
            '--GXBOUNDARY'
        ),

        # Invalid end delimiter
        join( '',
            '--GXBOUNDARY' . CRLF,
            'Content-Disposition: form-data; name="key_1"' . CRLF,
            CRLF,
            'value 1' . CRLF,
            '--GXBOUNDARY'
        ),

        # Invalid delimiter
        join( '',
            '--WRONGBOUNDARY' . CRLF,
            CRLF,
            '--WRONGBOUNDARY--'
        ),

    );

    for my $content ( @content ) {

        my $body = GX::HTTP::Body::Scalar->new;

        $body->add( $content );

        ok( ! _parse( $body ) );

    }

}


# --------------------------------------------------------------------------------------------------

sub _parse {

    my $body = shift;

    my $parser = GX::HTTP::Parser::Body::MultiPart->new(
        content_type => 'multipart/form-data; boundary=GXBOUNDARY'
    );

    return $parser->parse( $body );

}

