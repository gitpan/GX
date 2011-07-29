#!/usr/bin/perl

# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: Makefile.PL
# ----------------------------------------------------------------------------------------------------------------------

use strict;
use warnings;

use ExtUtils::MakeMaker;


# ----------------------------------------------------------------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------------------------------------------------------------

my %PREREQ_PM = (
    'Config'              => 0,
    'Cwd'                 => 0,
    'Digest::MD5'         => 0,
    'Encode'              => 0,
    'Exporter'            => 0,
    'ExtUtils::MakeMaker' => 0,
    'File::Basename'      => 0,
    'File::Copy'          => 0,
    'File::Find'          => 0,
    'File::Spec'          => 0,
    'File::Spec::Unix'    => 0,
    'File::Temp'          => 0,
    'FindBin'             => 0,
    'Getopt::Long'        => 0,
    'IO::File'            => 0,
    'IO::Handle'          => 0,
    'List::Util'          => 0,
    'Scalar::Util'        => 0,
    'Storable'            => 0,
    'Test::Harness'       => 0,
    'Test::More'          => 0,
    'Tie::Hash'           => 0
);


# ----------------------------------------------------------------------------------------------------------------------
# Write the Makefile
# ----------------------------------------------------------------------------------------------------------------------

WriteMakefile(
    NAME             => 'GX',
    MIN_PERL_VERSION => '5.10.0',
    PREREQ_PM        => \%PREREQ_PM,
    PMLIBDIRS        => [ 'lib' ],
    EXE_FILES        => [ 'script/gx-build' ],
    VERSION_FROM     => 'lib/GX.pm',
    ABSTRACT_FROM    => 'lib/GX.pm',
    AUTHOR           => "J\x{c3}\x{b6}rg A. Uzarek <uzarek\@runlevelnull.de>",
    LICENSE          => 'GPL_3'
);


# ----------------------------------------------------------------------------------------------------------------------
# ExtUtils::MakeMaker customization
# ----------------------------------------------------------------------------------------------------------------------

package MY;

use File::Spec ();
use FindBin ();

sub test {

    my $mm = shift;

    my $script = $mm->quote_literal( File::Spec->rel2abs( File::Spec->catfile( 't', 'test.pl' ), $FindBin::Bin ) );

return <<EOT
test :
\t\$(FULLPERL) -I\$(INST_ARCHLIB) -I\$(INST_LIB) $script
EOT

}

