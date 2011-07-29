#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::File;
use File::Temp ();


use Test::More tests => 5;


# add()
{

    my $file;

    ( undef, $file ) = File::Temp::tempfile();

    my $body = GX::HTTP::Body::File->new( file => $file, readonly => 1 );

    local $@;

    eval { $body->add( 'xxx' ) };

    isa_ok( $@, 'GX::Exception' );

    unlink $file or warn "$!";

}

# open()
{

    my $file;

    ( undef, $file ) = File::Temp::tempfile();

    my $body = GX::HTTP::Body::File->new( file => $file, readonly => 1 );

    isa_ok( $body->open, 'IO::File' );

    unlink $file or warn "$!";

}

# open( '<' )
{

    my $file;

    ( undef, $file ) = File::Temp::tempfile();

    my $body = GX::HTTP::Body::File->new( file => $file, readonly => 1 );

    isa_ok( $body->open( '<' ), 'IO::File' );

    unlink $file or warn "$!";

}

# open( '>' ), open( '>>' )
{

    my $file;

    ( undef, $file ) = File::Temp::tempfile();

    my $body = GX::HTTP::Body::File->new( file => $file, readonly => 1 );

    for my $mode ( qw( > >> ) ) {
        local $@;
        eval { $body->open( $mode ) };
        isa_ok( $@, 'GX::Exception' );
    }

    unlink $file or warn "$!";

}

