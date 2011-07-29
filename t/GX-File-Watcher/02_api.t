#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Path qw( rmtree );
use File::Temp qw( tempdir tempfile );

use GX::File::Watcher;


use Test::More tests => 41;


# new()
{

    my $watcher = GX::File::Watcher->new;

    isa_ok( $watcher, 'GX::File::Watcher' );

    is_deeply( [ $watcher->directories ], [] );
    is_deeply( [ $watcher->files ], [] );

    is( scalar $watcher->find_changes, 0 );
    is_deeply( [ $watcher->find_changes ], [] );

}

# watch(), directories(), files()
{

    my $watcher = GX::File::Watcher->new;

    my $directory       = tempdir();
    my ( undef, $file ) = tempfile( DIR => $directory );

    $watcher->watch( $directory );

    is_deeply( [ $watcher->directories ], [ $directory ] );
    is_deeply( [ $watcher->files ],[ $file ] );

    rmtree( $directory );

}

# find_changes(), changed file
{

    my $watcher = GX::File::Watcher->new;

    my $directory         = tempdir();
    my ( $fh_1, $file_1 ) = tempfile( DIR => $directory );
    my ( $fh_2, $file_2 ) = tempfile( DIR => $directory );

    $watcher->watch( $directory );

    is_deeply( [ $watcher->directories ], [ $directory ] );
    is_deeply( [ sort( $watcher->files ) ], [ sort( $file_1, $file_2 ) ] );

    is( scalar $watcher->find_changes, 0 );
    is_deeply( [ $watcher->find_changes ], [] );

    $fh_1->printflush( 'a' );

    is( scalar $watcher->find_changes, 1 );
    is_deeply( [ sort( $watcher->find_changes ) ], [ sort( $file_1 ) ] );

    $fh_2->printflush( 'b' );

    is( scalar $watcher->find_changes, 1 );
    is_deeply( [ sort( $watcher->find_changes ) ], [ sort( $file_1, $file_2 ) ] );

    undef $fh_1;
    undef $fh_2;

    rmtree( $directory );

}

# find_changes(), new file
{

    my $watcher = GX::File::Watcher->new;

    my $directory = tempdir();

    $watcher->watch( $directory );

    is_deeply( [ $watcher->directories ], [ $directory ] );
    is_deeply( [ $watcher->files ], [] );

    is( scalar $watcher->find_changes, 0 );
    is_deeply( [ $watcher->find_changes ], [] );

    my ( undef, $file_1 ) = tempfile( DIR => $directory );

    is( scalar $watcher->find_changes, 1 );
    is_deeply( [ $watcher->find_changes ], [ $directory ] );

    rmtree( $directory );

}

# find_changes(), new directory
{

    my $watcher = GX::File::Watcher->new;

    my $directory_1 = tempdir();

    $watcher->watch( $directory_1 );

    is_deeply( [ $watcher->directories ], [ $directory_1 ] );
    is_deeply( [ $watcher->files ], [] );

    is( scalar $watcher->find_changes, 0 );
    is_deeply( [ $watcher->find_changes ], [] );

    my $directory_2 = tempdir( DIR => $directory_1 );

    is( scalar $watcher->find_changes, 1 );
    is_deeply( [ $watcher->find_changes ], [ $directory_1 ] );

    rmtree( $directory_1 );

}

# find_changes(), deleted file
{

    my $watcher = GX::File::Watcher->new;

    my $directory         = tempdir();
    my ( undef, $file_1 ) = tempfile( DIR => $directory );
    my ( undef, $file_2 ) = tempfile( DIR => $directory );

    $watcher->watch( $directory );

    is_deeply( [ $watcher->directories ], [ $directory ] );
    is_deeply( [ sort( $watcher->files ) ], [ sort( $file_1, $file_2 ) ] );

    is( scalar $watcher->find_changes, 0 );
    is_deeply( [ $watcher->find_changes ], [] );

    unlink( $file_1 ) or die $!;

    is( scalar $watcher->find_changes, 1 );
    is_deeply( [ sort( $watcher->find_changes ) ], [ sort( $directory, $file_1 ) ] );

    unlink( $file_2 ) or die $!;

    is( scalar $watcher->find_changes, 1 );
    is_deeply( [ sort( $watcher->find_changes ) ], [ sort( $directory, $file_1, $file_2 ) ] );

    rmtree( $directory );

}

# find_changes(), deleted directory
{

    my $watcher = GX::File::Watcher->new;

    my $directory         = tempdir();
    my ( undef, $file_1 ) = tempfile( DIR => $directory );
    my ( undef, $file_2 ) = tempfile( DIR => $directory );

    $watcher->watch( $directory );

    is_deeply( [ $watcher->directories ], [ $directory ] );
    is_deeply( [ sort( $watcher->files ) ], [ sort( $file_1, $file_2 ) ] );

    is( scalar $watcher->find_changes, 0 );
    is_deeply( [ $watcher->find_changes ], [] );

    rmtree( $directory );

    is( scalar $watcher->find_changes, 1 );
    is_deeply( [ sort( $watcher->find_changes ) ], [ sort( $directory, $file_1, $file_2 ) ] );

}

