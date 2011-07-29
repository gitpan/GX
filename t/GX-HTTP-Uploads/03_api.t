#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Upload;
use GX::HTTP::Uploads;


use Test::More tests => 68;


my @UPLOADS = (
    GX::HTTP::Upload->new( name => "upload_1" ),
    GX::HTTP::Upload->new( name => "upload_2" ),
    GX::HTTP::Upload->new( name => "upload_2" ),
    GX::HTTP::Upload->new( name => "upload_3" ),
    GX::HTTP::Upload->new( name => "upload_3" ),
    GX::HTTP::Upload->new( name => "upload_3" )
);

my @NAMELESS_UPLOADS = (
    GX::HTTP::Upload->new(),
    GX::HTTP::Upload->new(),
    GX::HTTP::Upload->new()
);


# add( $upload ), add( @uploads )
{

    my $uploads = GX::HTTP::Uploads->new;

    $uploads->add( $UPLOADS[0] );

    is_deeply( [ $uploads->all ], [ $UPLOADS[0] ] );
    is_deeply( [ $uploads->get( 'upload_1' ) ], [ $UPLOADS[0] ] );

    $uploads->add( $UPLOADS[1] );

    is_deeply( [ $uploads->all ], [ @UPLOADS[0,1] ] );
    is_deeply( [ $uploads->get( 'upload_1' ) ], [ $UPLOADS[0] ] );
    is_deeply( [ $uploads->get( 'upload_2' ) ], [ $UPLOADS[1] ] );

    $uploads->add( @UPLOADS[2 .. 5] );

    is_deeply( [ $uploads->all ], \@UPLOADS );
    is_deeply( [ $uploads->get( 'upload_1' ) ], [ $UPLOADS[0] ] );
    is_deeply( [ $uploads->get( 'upload_2' ) ], [ @UPLOADS[1,2] ] );
    is_deeply( [ $uploads->get( 'upload_3' ) ], [ @UPLOADS[3,4,5] ] );

}

# all()
{

    my $uploads = GX::HTTP::Uploads->new;

    $uploads->add( @UPLOADS );

    is_deeply( [ $uploads->all ], \@UPLOADS );

}

# all(), scalar context
{

    my $uploads = GX::HTTP::Uploads->new;

    is( scalar $uploads->all, 0 );

    $uploads->add( @UPLOADS );

    is( scalar $uploads->all, 6 );

}

# clear()
{

    my $uploads = GX::HTTP::Uploads->new;

    $uploads->add( @UPLOADS );

    $uploads->clear;

    is_deeply( [ $uploads->all ], [] );

    for ( 0 .. 2 ) {
        is( $uploads->get( "upload_$_" ), undef );
        is_deeply( [ $uploads->get( "upload_$_" ) ], [] );
    }

}

# count(), empty container
{

    my $uploads = GX::HTTP::Uploads->new;

    is( $uploads->count, 0 );

}

# count()
{

    my $uploads = GX::HTTP::Uploads->new;

    $uploads->add( @UPLOADS );

    is( $uploads->count, 6 );

}

# get(), scalar context
{

    my $uploads = GX::HTTP::Uploads->new;

    $uploads->add( @UPLOADS );

    is( $uploads->get( 'upload_x' ), undef );
    is( $uploads->get( 'upload_1' ), $UPLOADS[0] );
    is( $uploads->get( 'upload_2' ), $UPLOADS[1] );
    is( $uploads->get( 'upload_3' ), $UPLOADS[3] );

}

# get(), list context
{

    my $uploads = GX::HTTP::Uploads->new;

    $uploads->add( @UPLOADS );

    is_deeply( [ $uploads->get( 'upload_x' ) ], [] );
    is_deeply( [ $uploads->get( 'upload_1' ) ], [ $UPLOADS[0] ] );
    is_deeply( [ $uploads->get( 'upload_2' ) ], [ @UPLOADS[1,2] ] );
    is_deeply( [ $uploads->get( 'upload_3' ) ], [ @UPLOADS[3,4,5] ] );

}

# names()
{

    my $uploads = GX::HTTP::Uploads->new;

    $uploads->add( @UPLOADS );

    is_deeply( [ $uploads->names ], [ qw( upload_1 upload_2 upload_3 ) ] );

}

# remove( $name )
{

    my $uploads = GX::HTTP::Uploads->new;

    $uploads->add( @UPLOADS );

    ok( ! $uploads->remove( 'upload_x' ) );

    is_deeply( [ $uploads->all ], \@UPLOADS );

    is( $uploads->remove( 'upload_1' ), 1 );

    is_deeply( [ $uploads->all ], [ @UPLOADS[1 .. 5] ] );

    is( $uploads->remove( 'upload_2' ), 2 );

    is_deeply( [ $uploads->all ], [ @UPLOADS[3 .. 5] ] );

    is ( $uploads->remove( 'upload_3' ), 3 );

    is_deeply( [ $uploads->all ], [] );

}

# remove( @names )
{

    my $uploads = GX::HTTP::Uploads->new;

    $uploads->add( @UPLOADS );

    is( $uploads->remove( 'upload_x', 'upload_1' ), 1 );

    is_deeply( [ $uploads->all ], [ @UPLOADS[1 .. 5] ] );

    is( $uploads->remove( 'upload_2', 'upload_3' ), 5 );

    is_deeply( [ $uploads->all ], [] );

}

# set( $upload ), set( @uploads )
{


    my $uploads = GX::HTTP::Uploads->new;

    $uploads->set( $UPLOADS[0] );

    is_deeply( [ $uploads->all ], [ $UPLOADS[0] ] );
    is_deeply( [ $uploads->get( 'upload_1' ) ], [ $UPLOADS[0] ] );

    $uploads->set( $UPLOADS[1], $UPLOADS[3] );

    is_deeply( [ $uploads->all ], [ @UPLOADS[0,1,3] ] );
    is_deeply( [ $uploads->get( 'upload_1' ) ], [ $UPLOADS[0] ] );
    is_deeply( [ $uploads->get( 'upload_2' ) ], [ $UPLOADS[1] ] );
    is_deeply( [ $uploads->get( 'upload_3' ) ], [ $UPLOADS[3] ] );

    $uploads->set( @UPLOADS[2,4,5] );

    is_deeply( [ $uploads->all ], [ @UPLOADS[0,2,4,5] ] );
    is_deeply( [ $uploads->get( 'upload_1' ) ], [ $UPLOADS[0] ] );
    is_deeply( [ $uploads->get( 'upload_2' ) ], [ $UPLOADS[2] ] );
    is_deeply( [ $uploads->get( 'upload_3' ) ], [ @UPLOADS[4,5] ] );

}

# undefined upload name
{

    my $uploads = GX::HTTP::Uploads->new;

    $uploads->add( $NAMELESS_UPLOADS[0], $UPLOADS[0] );

    is_deeply( [ $uploads->all ], [ $NAMELESS_UPLOADS[0], $UPLOADS[0] ] );

    is_deeply( [ $uploads->names ], [ qw( upload_1 ) ] );

    is( scalar $uploads->get( undef ), $NAMELESS_UPLOADS[0] );

    is_deeply( [ $uploads->get( undef ) ], [ $NAMELESS_UPLOADS[0] ] );

    $uploads->add( $NAMELESS_UPLOADS[1] );

    is_deeply( [ $uploads->all ], [ $NAMELESS_UPLOADS[0], $UPLOADS[0], $NAMELESS_UPLOADS[1] ] );

    is_deeply( [ $uploads->names ], [ qw( upload_1 ) ] );

    is( scalar $uploads->get( undef ), $NAMELESS_UPLOADS[0] );

    is_deeply( [ $uploads->get( undef ) ], [ $NAMELESS_UPLOADS[0], $NAMELESS_UPLOADS[1] ] );

    $uploads->set( $NAMELESS_UPLOADS[2] );

    is_deeply( [ $uploads->all ], [ $UPLOADS[0], $NAMELESS_UPLOADS[2] ] );

    is_deeply( [ $uploads->names ], [ qw( upload_1 ) ] );

    is( scalar $uploads->get( undef ), $NAMELESS_UPLOADS[2] );

    is_deeply( [ $uploads->get( undef ) ], [ $NAMELESS_UPLOADS[2] ] );

    is( $uploads->remove( undef ), 1 );

    is_deeply( [ $uploads->names ], [ qw( upload_1 ) ] );

    is( scalar $uploads->get( undef ), undef );

    is_deeply( [ $uploads->get( undef ) ], [] );

}

