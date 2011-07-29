# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Script.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Script;

use Cwd ();
use File::Basename ();
use File::Path ();
use File::Spec ();
use Getopt::Long ();
use IO::File ();

use GX::Meta::Constants qw( REGEX_CLASS_NAME );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'application_class' => (
    isa        => 'String',
    constraint => sub { ! ref && $_ =~ REGEX_CLASS_NAME }
);

has 'application_path' => (
    isa         => 'Scalar',
    initializer => '_initialize_application_path'
);

has 'cwd' => (
    isa         => 'String',
    initialize  => 1,
    initializer => sub { Cwd::cwd() }
);

has 'options' => (
    isa         => 'Hash',
    initialize  => 1,
    initializer => '_initialize_options',
    accessor    => { type => 'get_reference' }
);

has 'script_name' => (
    isa         => 'String',
    initialize  => 1,
    initializer => sub { File::Basename::basename( $_[0]->script_path ) }
);

has 'script_path' => (
    isa         => 'String',
    initialize  => 1,
    initializer => sub { File::Spec->file_name_is_absolute( $0 ) ? $0 : File::Spec->rel2abs( $0 ) }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub chmod_file {

    my $self = shift;
    my $file = shift;
    my $mode = shift;

    if ( ! File::Spec->file_name_is_absolute( $file ) ) {
        $file = $self->construct_path( $file );
    }

    chmod( $mode, $file ) or die "Cannot chmod() file \"$file\": $!";

    $self->print_message( sprintf( "  [+] $file -> chmod %o", $mode ) );

    return;

}

sub construct_path {

    my $self = shift;
    my @path = @_;

    my $base_path = $self->application_path or die "Cannot construct path";

    return File::Spec->rel2abs( File::Spec->catfile( @path ), $base_path );

}

sub create_directory {

    my $self      = shift;
    my $directory = shift;

    if ( ! File::Spec->file_name_is_absolute( $directory ) ) {
        $directory = $self->construct_path( $directory );
    }

    if ( -e $directory ) {
        $self->print_message( "  [-] $directory" );
        return;
    }

    File::Path::mkpath( $directory ) or die "Cannot create directory \"$directory\": $!";

    $self->print_message( "  [+] $directory" );

    return 1;

}

sub create_file {

    my $self    = shift;
    my $file    = shift;
    my $content = shift;

    if ( ! File::Spec->file_name_is_absolute( $file ) ) {
        $file = $self->construct_path( $file );
    }

    if ( -e $file ) {
        $self->print_message( "  [-] $file" );
        return;
    }

    my @path      = File::Spec->splitpath( $file );
    my $directory = File::Spec->catpath( $path[0], File::Spec->canonpath( $path[1] ), '' );

    if ( ! -e $directory ) {
        File::Path::mkpath( $directory ) or die "Cannot create directory \"$directory\": $!";
    }

    my $fh = IO::File->new( "> $file" ) or die "$!\n";
    $fh->print( $content ) if defined $content;
    $fh->close;

    $self->print_message( "  [+] $file" );

    return 1;

}

sub exit {

    my $self   = shift;
    my $status = shift;

    CORE::exit( defined $status ? $status : 0 );

}

sub load_application {

    my $self = shift;

    my $application_class = $self->application_class or die "No application specified";

    eval "require $application_class" or die $@;

    return;

}

sub print_error {

    my $self = shift;

    print join( "\n", @_ ) . "\n";

    return;

}

sub print_message {

    my $self = shift;

    print join( "\n", @_ ) . "\n";

    return;

}

sub run {

    # Abstract method

}

sub show_copyright {

    my $self = shift;

    $self->print_message( <<EOT );
Copyright (c) 2009-2010 Jörg A. Uzarek.

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the Free
Software Foundation.

See the GNU General Public License for more details.
EOT

    return;

}

sub show_help {

    my $self = shift;

    $self->print_message( "Sorry, no help available." );

    return;

}

sub show_version {

    my $self = shift;

    my $class   = ref $self;
    my $version = do { no strict 'refs'; ${"${class}::VERSION"} };

    $self->print_message( "$class version $version" );

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _argv_options {

    return (
        'copyright',
        'help|?',
        'version'
    );

}

sub _initialize_application_path {

    my $self = shift;

    my ( $volume, $dirs, $file ) = File::Spec->splitpath( $self->script_path );

    my @dirs = File::Spec->splitdir( File::Spec->canonpath( $dirs ) );

    while ( @dirs ) {
        my $path = File::Spec->catpath( $volume, File::Spec->catdir( @dirs ), '' );
        return $path if -d File::Spec->rel2abs( 'script', $path );
        pop @dirs;
    }

    return undef;

}

sub _initialize_options {

    return {};

}

sub _process_argv {

    my $self = shift;
    my @argv = @_ ? @_ : @ARGV;

    my %argv;

    if ( ! Getopt::Long::GetOptionsFromArray( \@argv, \%argv, $self->_argv_options ) ) {
        $self->show_help;
        $self->exit( 1 );
    }

    if ( $argv{'help'} ) {
        $self->show_help;
        $self->exit;
    }

    if ( $argv{'version'} ) {
        $self->show_version;
        $self->exit;
    }

    if ( $argv{'copyright'} ) {
        $self->show_copyright;
        $self->exit;
    }

    %{$self->options} = ( %{$self->options}, %argv );

    return @argv;

}

sub _set_inc {

    my $self = shift;

    if ( $self->application_path ) {

        my $lib_path = $self->construct_path( 'lib' );

        if ( -d $lib_path ) {
            unshift @INC, $lib_path;
        }

    }

    return;

}


1;

__END__

=head1 NAME

GX::Script - Base class for scripts

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Script> class which extends the
L<GX::Class::Object> class.

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
