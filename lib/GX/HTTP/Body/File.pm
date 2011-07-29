# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Body/File.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Body::File;

use GX::Exception;

use File::Temp ();
use IO::File ();
use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant BUFFER_SIZE => 8192;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::HTTP::Body';

has 'file' => (
    isa => 'Scalar'
);

has 'cleanup' => (
    isa => 'Bool'
);

has 'readonly' => (
    isa => 'Bool'
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $invocant = shift;

    return eval { $invocant->SUPER::new( ( @_ == 1 ) ? ( file => $_[0] ) : @_ ) } || complain $@;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    my $self = shift;

    if ( $self->readonly ) {
        complain "Cannot add content (message body is readonly)";
    }

    my $fh = eval { $self->open( '>>' ) } or complain $@;

    for my $data ( @_ ) {

        next unless defined $data;

        if ( ref $data ) {

            if ( blessed $data ) {

                if ( $data->isa( 'IO::Handle' ) ) {

                    while ( $data->read( my $buffer, BUFFER_SIZE ) ) {
                        $fh->print( $buffer ) or last;
                    }

                }
                else {
                    $fh->print( "$data" );
                }

            }
            elsif ( ref $data eq 'GLOB' ) {

                while ( $data->read( my $buffer, BUFFER_SIZE ) ) {
                    $fh->print( $buffer ) or last;
                }

            }
            elsif ( ref $data eq 'SCALAR' ) {
                $fh->print( $$data );
            }
            elsif ( ref $data eq 'CODE' ) {
                $fh->print( $data->() );
            }
            else {
                $fh->print( "$data" );
            }

        }
        else {
            $fh->print( $data );
        }

    }

    return 1;

}

sub as_string {

    my $self = shift;

    my $fh = $self->open or return;

    return join( '', <$fh> );

}

sub clear {

    my $self = shift;

    $self->_cleanup;

    $self->SUPER::clear;

    return;

}

sub length {

    my $self = shift;

    return defined( $self->file ) ? -s $self->file : 0;

}

sub open {

    my $self = shift;
    my $mode = shift;

    if ( defined $mode ) {

        if ( $mode ne '>>' && $mode ne '>' && $mode ne '<' ) {
            complain "Invalid open mode";
        }

        if ( $self->readonly && $mode ne '<' ) {
            complain "Cannot open file in \"$mode\" mode";
        }

    }
    else {
        $mode = '<';
    }

    if ( ! defined $self->file ) {

        my ( $fh, $file ) = File::Temp::tempfile();

        $self->file( $file );
        $self->cleanup( 1 ) unless defined $self->cleanup;

        $fh->close;

    }

    my $fh = IO::File->new( $self->file, $mode );

    if ( ! $fh ) {
        GX::Exception->complain(
            message      => "Cannot open file in \"$mode\" mode",
            subexception => $!
        );
    }

    $fh->binmode or complain $!;

    return $fh;

}

sub print_to {

    my $self   = shift;
    my $handle = shift;

    my $fh = $self->open;

    my $result;

    while ( $result = $fh->read( my $buffer, BUFFER_SIZE ) ) {
        $handle->print( $buffer ) or return;
    }

    return defined $result;

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub DESTROY {

    my $self = shift;

    $self->_cleanup;

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _cleanup {

    my $self = shift;

    if ( $self->cleanup && ! $self->readonly ) {

        my $file = $self->file;

        if ( defined $file && -f $file ) {
            unlink $file or warn "Cannot unlink file: $!";
        }

    }

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------------------------------------------------------

*print = \&add;


1;

__END__

=head1 NAME

GX::HTTP::Body::File - File-based HTTP message body class

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Body::File;
    
    # Create a new body object
    $body = GX::HTTP::Body::File->new( '/tmp/body.content' );
    
    # Add content
    $body->add( "Hello world!" );
    
    # Get an IO::File handle to read from
    $handle = $body->open;
    
    # Get an IO::File handle to write to
    $handle = $body->open( '>' );
    
    # Print the message body
    $body->print_to( *STDOUT );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Body::File> class which extends the
L<GX::HTTP::Body> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Body::File> object.

    $body = GX::HTTP::Body::File->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<cleanup> ( bool )

A boolean flag indicating whether or not to delete the associated file when
the body object is L<cleared|/clear> or destroyed. False by default, but
automatically set to true (unless specified otherwise) when a temporary body
file is created. Ignored if the C<readonly> flag is set to true.

=item * C<file> ( string )

A path to the file that is used to store the message body. If omitted, a
temporary file will be used instead.

=item * C<readonly> ( bool )

If set to true, a L<GX::Exception> will be raised when an attempt is made to
L</add> content to the body or to L</open> the body file in write or append
mode. Useful for preventing accidental modifications when sending static
files.

=back

=item Returns:

=over 4

=item * C<$body> ( L<GX::HTTP::Body::File> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Alternative syntax:

    $body = GX::HTTP::Body::File->new( $file );

=over 4

=item Arguments:

=over 4

=item * C<$file> ( string ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$body> ( L<GX::HTTP::Body::File> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<add>

Adds the given content to the message body.

    $body->add( @content );

=over 4

=item Arguments:

=over 4

=item * C<@content> ( scalars )

=over 4

=item * byte strings

=item * references to byte strings

=item * references to subroutines returning byte strings

=item * L<IO::Handle> objects / C<GLOB> references to C<read()> bytes from

=back

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<as_string>

Returns the message body as a byte string.

    $string = $body->as_string;

=over 4

=item Returns:

=over 4

=item * C<$string> ( byte string | C<undef> )

=back

=back

=head3 C<cleanup>

Returns / sets the cleanup flag.

    $bool = $body->cleanup;
    $bool = $body->cleanup( $bool );

=over 4

=item Arguments:

=over 4

=item * C<$bool> ( bool ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$bool> ( bool )

=back

=back

Unless set explicitly, the cleanup flag is automatically set to true when a
temporary body file is created.

=head3 C<clear>

Clears the message body.

    $body->clear;

Calling this method resets the cleanup flag, the readonly flag and the file
attribute. Additionally, the associated file is deleted if the cleanup flag
had been set to true and the file was not marked as read-only.

=head3 C<file>

Returns / sets the path to the associated file.

    $file = $body->file;
    $file = $body->file( $file );

=over 4

=item Arguments:

=over 4

=item * C<$file> ( string ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$file> ( string )

=back

=back

=head3 C<length>

Returns the size of the message body in bytes.

    $length = $body->length;


=over 4

=item Returns:

=over 4

=item * C<$length> ( integer )

=back

=back

=head3 C<open>

Returns an opened L<IO::File> handle for the associated file.

    $handle = $body->open( $mode );

=over 4

=item Arguments:

=over 4

=item * C<$mode> ( string ) [ optional ]

Supported modes: "E<lt>", "E<gt>" and "E<gt>E<gt>". Defaults to "E<lt>".

=back

=item Returns:

=over 4

=item * C<$handle> ( L<IO::File> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<print>

An alias for C<< L<add()|/add> >>.

    $body->print( @content );

=head3 C<print_to>

Prints the message body to the specified filehandle, returning true on success
or false on failure.

    $result = $body->print_to( $handle );

=over 4

=item Arguments:

=over 4

=item * C<$handle> ( L<IO::File> object | typeglob | C<GLOB> reference )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<readonly>

Returns / sets the readonly flag.

    $bool = $body->readonly;
    $bool = $body->readonly( $bool );

=over 4

=item Arguments:

=over 4

=item * C<$bool> ( bool ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$bool> ( bool )

=back

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
