#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Temp;
use GX::HTTP::Upload;


use Test::More tests => 32;


# size(), no file
{

    my $upload = GX::HTTP::Upload->new;

    is( $upload->size, 0 );

}

# move(), no file
{

    my ( undef, $destination ) = File::Temp::tempfile( UNLINK => 0 );

    my $upload = GX::HTTP::Upload->new;

    local $@;

    eval { $upload->move( $destination, 1 ) };

    isa_ok( $@, 'GX::Exception' );

    unlink $destination;

    ok( ! -f $destination );

}

# open(), no file
{

    my $upload = GX::HTTP::Upload->new;

    local $@;

    eval { $upload->open };

    isa_ok( $@, 'GX::Exception' );

}

# open(), size(), cleanup
{

    my ( $fh, $filename ) = File::Temp::tempfile( UNLINK => 0 );

    undef $fh;

    my $upload = GX::HTTP::Upload->new( $filename );

    is( $upload->file, $filename );

    ok( -f $upload->file );

    is( $upload->size, 0 );

    ok( $fh = $upload->open( '>' ) );
    ok( $fh->print( 123 ) );
    ok( $fh->close );

    is( $upload->size, 3 );

    ok( $fh = $upload->open );
    is( <$fh>, '123' );
    ok( $fh->close );

    undef $upload;

    ok( ! -f $filename );

}

# move()
{

    my ( undef, $filename_1 ) = File::Temp::tempfile( UNLINK => 0 );
    my ( undef, $filename_2 ) = File::Temp::tempfile( UNLINK => 0 );

    ok( -f $filename_1 );
    ok( -f $filename_2 );

    my $upload = GX::HTTP::Upload->new( $filename_1 );

    {
        local $@;
        eval { $upload->move( $filename_2 ) };
        isa_ok( $@, 'GX::Exception' );
    }

    unlink $filename_2;

    ok( -f $filename_1 );
    ok( ! -f $filename_2 );

    is( $upload->file, $filename_1 );
    is( $upload->cleanup, 1 );

    ok( $upload->move( $filename_2 ) );

    is( $upload->file, $filename_2 );
    is( $upload->cleanup, 0 );

    ok( ! -f $filename_1 );
    ok( -f $filename_2 );

    unlink $filename_2;

    ok( ! -f $filename_1 );
    ok( ! -f $filename_2 );

}

# cleanup( 0 )
{

    my ( undef, $filename ) = File::Temp::tempfile( UNLINK => 0 );

    my $upload = GX::HTTP::Upload->new( $filename );

    ok( -f $filename );

    $upload->cleanup( 0 );

    undef $upload;

    ok( -f $filename );

    unlink $filename;

    ok( ! -f $filename );

}

