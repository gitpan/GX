#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Upload;
use GX::HTTP::Uploads;


use Test::More tests => 1;


my @UPLOADS = (
    GX::HTTP::Upload->new( name => "upload_1" ),
    GX::HTTP::Upload->new( name => "upload_2" ),
    GX::HTTP::Upload->new( name => "upload_2" ),
    GX::HTTP::Upload->new( name => "upload_3" ),
    GX::HTTP::Upload->new( name => "upload_3" ),
    GX::HTTP::Upload->new( name => "upload_3" )
);


# @$uploads
{

    my $uploads = GX::HTTP::Uploads->new;

    $uploads->add( @UPLOADS );

    is_deeply( [ @$uploads ], \@UPLOADS );

}

