#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::File;
use File::Temp ();


use Test::More tests => 25;


# Temporary file
{

    my $body = GX::HTTP::Body::File->new;

    ok( ! $body->file );

    $body->add( "Hello World" );

    my $file = $body->file;

    ok( -f $file );

    undef $body;

    ok( ! -f $file );

}

# Temporary file, cleanup( 0 )
{

    my $body = GX::HTTP::Body::File->new;

    ok( ! $body->file );

    $body->add( "Hello World" );

    my $file = $body->file;

    ok( -f $file );

    $body->cleanup( 0 );

    undef $body;

    ok( -f $file );

    unlink $file or warn "$!";

}

# Temporary file, cleanup( 1 )
{

    my $body = GX::HTTP::Body::File->new;

    ok( ! $body->file );

    $body->add( "Hello World" );

    my $file = $body->file;

    ok( -f $file );

    $body->cleanup( 1 );

    undef $body;

    ok( ! -f $file );

}

# Temporary file, new( cleanup => 0 )
{

    my $body = GX::HTTP::Body::File->new( cleanup => 0 );

    ok( ! $body->file );

    $body->add( "Hello World" );

    my $file = $body->file;

    ok( -f $file );

    undef $body;

    ok( -f $file );

    unlink $file or warn "$!";

}

# Temporary file, new( cleanup => 1 )
{

    my $body = GX::HTTP::Body::File->new( cleanup => 1 );

    ok( ! $body->file );

    $body->add( "Hello World" );

    my $file = $body->file;

    ok( -f $file );

    undef $body;

    ok( ! -f $file );

}

# Existing file
{

    my $file;

    ( undef, $file ) = File::Temp::tempfile();

    my $body = GX::HTTP::Body::File->new( $file );

    ok( -f $body->file );

    undef $body;

    ok( -f $file );

    unlink $file or warn "$!";

}

# Existing file, cleanup( 0 )
{

    my $file;

    ( undef, $file ) = File::Temp::tempfile();

    my $body = GX::HTTP::Body::File->new( $file );

    ok( -f $body->file );

    $body->cleanup( 0 );

    undef $body;

    ok( -f $file );

    unlink $file or warn "$!";

}

# Existing file, cleanup( 1 )
{

    my $file;

    ( undef, $file ) = File::Temp::tempfile();

    my $body = GX::HTTP::Body::File->new( $file );

    ok( -f $body->file );

    $body->cleanup( 1 );

    undef $body;

    ok( ! -f $file );

}

# Existing file, new( cleanup => 0 )
{

    my $file;

    ( undef, $file ) = File::Temp::tempfile();

    my $body = GX::HTTP::Body::File->new( file => $file, cleanup => 0 );

    ok( -f $body->file );

    undef $body;

    ok( -f $file );

    unlink $file or warn "$!";

}

# Existing file, new( cleanup => 1 )
{

    my $file;

    ( undef, $file ) = File::Temp::tempfile();

    my $body = GX::HTTP::Body::File->new( file => $file, cleanup => 1 );

    ok( -f $body->file );

    undef $body;

    ok( ! -f $file );

}

