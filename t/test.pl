#!/usr/bin/perl

use strict;
use warnings;

use File::Find ();
use File::Spec::Functions qw( :ALL );
use FindBin qw( $Bin );
use Getopt::Long;
use Test::Harness;


run();


sub run {

    my $verbose = 0;

    GetOptions( verbose => \$verbose );

    $Test::Harness::verbose = $verbose;

    fix_inc();

    runtests( sort( find_tests( @ARGV ) ) );

    return;

}

sub find_tests {

    my @files;

    if ( @_ ) {

        for ( @_ ) {

            if ( /\.t$/ ) {

                my $file = file_name_is_absolute( $_ ) ? $_ : rel2abs( $_, $Bin );

                next unless -f $file;

                push @files, $file;

            }
            else {

                my $path = file_name_is_absolute( $_ ) ? $_ : rel2abs( $_, $Bin );

                next unless -d $path;

                File::Find::find(
                    {
                        'no_chdir' => 1,
                        'wanted'   => sub { push @files, $_ if /\.t$/ }
                    },
                    ( $path )
                );

            }

        }

    }
    else {

        File::Find::find(
            {
                'no_chdir' => 1,
                'wanted'   => sub { push @files, $_ if /\.t$/ }
            },
            ( $Bin )
        );

    }

    return @files;

}

sub fix_inc {

    my ( $vol, $dirs, $file ) = splitpath( canonpath( $Bin ) );

    my @dirs = splitdir( canonpath( $dirs ) );

    while ( @dirs ) {

        my $path_lib = catpath( $vol, catdir( @dirs, 'lib' ), undef );

        if ( -d $path_lib ) {

            my $path_blib_lib  = catpath( $vol, catdir( @dirs, 'blib', 'lib' ),  undef );
            my $path_blib_arch = catpath( $vol, catdir( @dirs, 'blib', 'arch' ), undef );

            for ( $path_blib_lib, $path_blib_arch ) {
                -d or die "Cannot find \"$_\". Did you run \"make\" first?\n";
            }

            unshift( @INC, $path_blib_lib, $path_blib_arch );

            return;

        }

        pop @dirs;

    }

    die "Cannot find the distribution's \"lib\" directory. Did you move this script?\n";

}

