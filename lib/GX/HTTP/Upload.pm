# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Upload.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Upload;

use GX::Exception;

use File::Copy ();
use IO::File ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'cleanup' => (
    isa        => 'Bool',
    default    => 1,
    initialize => 1
);

has 'file' => (
    isa => 'Scalar'
);

has 'filename' => (
    isa => 'Scalar'
);

has 'headers' => (
    isa => 'Scalar'
);

has 'name' => (
    isa => 'Scalar'
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $invocant = shift;

    return eval { $invocant->SUPER::new( @_ == 1 ? ( file => $_[0] ) : @_ ) } || complain $@;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub move {

    my $self        = shift;
    my $destination = shift;
    my $overwrite   = shift;

    if ( ! defined $destination ) {
        complain "Missing argument";
    }

    my $file = $self->file;

    if ( ! defined $file ) {
        complain "Undefined file";
    }

    if ( -e $destination && ! $overwrite ) {
        complain "Cannot move file (\"$destination\" already exists)";
    }

    if ( ! File::Copy::move( $file, $destination ) ) {
        GX::Exception->complain(
            message      => "Cannot move upload file",
            subexception => $!
        );
    }

    $self->file( $destination );

    $self->cleanup( 0 );

    return 1;

}

sub open {

    my $self = shift;
    my $mode = shift;

    my $file = $self->file;

    if ( ! defined $file ) {
        complain "Undefined file";
    }

    my $handle = eval { IO::File->new( $file, ( $mode // '<' ) ) };

    if ( ! $handle ) {
        GX::Exception->complain(
            message      => "Cannot open upload file",
            subexception => $@
        );
    }

    return $handle;

}

sub size {

    my $self = shift;

    return -s ( $self->file // return 0 );

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub DESTROY {

    my $self = shift;

    if ( $self->cleanup ) {

        my $file = $self->file;

        if ( defined $file && -f $file ) {
            unlink $file or warn "Cannot unlink file: $!";
        }

    }

    return;

}


1;

__END__

=head1 NAME

GX::HTTP::Upload - HTTP upload class

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Upload;
    
    # Create a new upload object
    $upload = GX::HTTP::Upload->new( '/tmp/0001.jpg' );
    
    # Get the size in bytes of the upload
    $bytes = $upload->size;
    
    # Get the accompanying headers
    $headers = $upload->headers;
    
    # Get the name of the associated HTML form control
    $name = $upload->name;
    
    # Move the uploaded file
    $upload->move( '/myapp/uploads/0001.jpg' );
    
    # Disable file deletion on object destruction
    $upload->cleanup( 0 );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Upload class> which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Upload> object.

    $upload = GX::HTTP::Upload->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<cleanup> ( bool )

A boolean flag indicating whether or not to delete the uploaded file on
destruction of the upload object. Defaults to true.

=item * C<file> ( string )

The path to the uploaded file.

=item * C<filename> ( string )

The client-supplied name of the uploaded file.

=item * C<headers> ( L<GX::HTTP::Headers> object )

A L<GX::HTTP::Headers> object containing the headers that accompanied the
upload.

=item * C<name> ( string )

The name of the HTML form control associated with the upload.

=back

=item Returns:

=over 4

=item * C<$upload> ( L<GX::HTTP::Upload> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Alternative syntax:

    $upload = GX::HTTP::Upload->new( $file );

=over 4

=item Arguments:

=over 4

=item * C<$file> ( string )

The path to the uploaded file.

=back

=item Returns:

=over 4

=item * C<$upload> ( L<GX::HTTP::Upload> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<cleanup>

Returns / sets the cleanup flag.

    $bool = $upload->cleanup;
    $bool = $upload->cleanup( $bool );

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

=head3 C<file>

Returns / sets the path to the uploaded file.

    $file = $upload->file;
    $file = $upload->file( $file );

=over 4

=item Arguments:

=over 4

=item * C<$file> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$file> ( string | C<undef> )

=back

=back

=head3 C<filename>

Returns / sets the client-supplied name of the uploaded file.

    $filename = $upload->filename;
    $filename = $upload->filename( $filename );

=over 4

=item Arguments:

=over 4

=item * C<$filename> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$filename> ( string | C<undef> )

=back

=back

=head3 C<headers>

Returns / sets the container object for the headers that accompanied the
upload.

    $headers = $upload->headers;
    $headers = $upload->headers( $headers );

=over 4

=item Arguments:

=over 4

=item * C<$headers> ( L<GX::HTTP::Headers> object | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$headers> ( L<GX::HTTP::Headers> object | C<undef> )

=back

=back

=head3 C<move>

Moves the uploaded file to the specified destination.

    $upload->move( $destination, $overwrite );

=over 4

=item Arguments:

=over 4

=item * C<$destination> ( string )

=item * C<$overwrite> ( bool ) [ optional ]

Defaults to false.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Calling this method updates the L<file|/file> attribute and sets the
L<cleanup flag|/cleanup> to false.

=head3 C<name>

Returns / sets the name of the HTML form control associated with the upload.

    $name = $upload->name;
    $name = $upload->name( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$name> ( string | C<undef> )

=back

=back

=head3 C<open>

Opens the uploaded file in the specified mode, returning an L<IO::File> object
on success.

    $handle = $upload->open( $mode );

=over 4

=item Arguments:

=over 4

=item * C<$mode> ( string ) [ optional ]

The open mode ("E<gt>", "+E<lt>", etc.). If omitted, the file is opened in
read-only mode.

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

=head3 C<size>

Returns the size of the uploaded file in bytes.

    $size = $upload->size;

=over 4

=item Returns:

=over 4

=item * C<$size> ( integer )

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::HTTP::Uploads>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
