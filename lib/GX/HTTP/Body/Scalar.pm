# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Body/Scalar.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Body::Scalar;

use GX::Exception;

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

has 'content' => (
    isa         => 'Scalar',
    initializer => sub { \( my $string = '' ) },
    accessor    => { type => 'get' }
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

    return eval { $invocant->SUPER::new( ( @_ == 1 ) ? ( content => $_[0] ) : @_ ) } || complain $@;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    my $self = shift;

    if ( $self->readonly ) {
        complain "Cannot add content (message body is readonly)";
    }

    my $content = $self->content;

    for my $data ( @_ ) {

        next unless defined $data;

        if ( ref $data ) {

            if ( blessed $data ) {

                if ( $data->isa( 'IO::Handle' ) ) {

                    while ( $data->read( my $buffer, BUFFER_SIZE ) ) {
                        $$content .= $buffer;
                    }

                }
                else {
                    $$content .= "$data";
                }

            }
            elsif ( ref $data eq 'GLOB' ) {

                while ( $data->read( my $buffer, BUFFER_SIZE ) ) {
                    $$content .= $buffer;
                }

            }
            elsif ( ref $data eq 'SCALAR' ) {
                $$content .= $$data;
            }
            elsif ( ref $data eq 'CODE' ) {
                $$content .= $data->();
            }
            else {
                $$content .= "$data";
            }

        }
        else {
            $$content .= $data;
        }

    }

    if ( ! utf8::downgrade( $$content, 1 ) ) {
        complain "Invalid content";
    }

    return;

}

sub as_string {

    return ${$_[0]->content};

}

sub length {

    return length ${$_[0]->content};

}

sub open {

    my $self = shift;
    my $mode = shift;

    if ( defined $mode ) {

        if ( $mode ne '>>' && $mode ne '>' && $mode ne '<' ) {
            complain "Invalid open mode";
        }

        if ( $self->readonly && $mode ne '<' ) {
            complain "Cannot open in-memory file in \"$mode\" mode";
        }

    }
    else {
        $mode = '<';
    }

    return IO::File->new( $self->content, $mode );

}

sub print_to {

    my $self   = shift;
    my $handle = shift;

    return $handle->print( ${$self->content} );

}


# ----------------------------------------------------------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------------------------------------------------------

*print = \&add;


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub __initialize {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'content'} ) {

        if ( defined $args->{'content'} ) {

            if ( ref $args->{'content'} eq 'SCALAR' ) {
                $self->{'content'} = $args->{'content'} if defined ${$args->{'content'}};
            }
            elsif ( ! ref $args->{'content'} ) {
                ${$self->{'content'}} = $args->{'content'};
            }

        }

        if ( ! $self->{'content'} || ! utf8::downgrade( ${$self->{'content'}}, 1 ) ) {
            throw "Invalid argument (\"content\" must be a byte string)";
        }

    }

    return;

}


1;

__END__

=head1 NAME

GX::HTTP::Body::Scalar - Scalar-based HTTP message body class

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Body::Scalar;
    
    # Create a new body object
    $body = GX::HTTP::Body::Scalar->new;
    
    # Add content
    $body->add( "Hello world!" );
    
    # Get an IO::File handle to read from
    $handle = $body->open;
    
    # Get an IO::File handle to write to
    $handle = $body->open( '>' );
    
    # Print the message body
    $body->print_to( *STDOUT );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Body::Scalar> class which extends the
L<GX::HTTP::Body> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Body::Scalar> object.

    $body = GX::HTTP::Body::Scalar->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<content> ( string | C<SCALAR> reference )

A (reference to a) string of bytes.

=item * C<readonly> ( bool )

If set to true, a L<GX::Exception> will be raised when an attempt is made to
L</add> content to the body or to L</open> the body in-memory file in write or
append mode. Useful for sending static content.

=back

=item Returns:

=over 4

=item * C<$body> ( L<GX::HTTP::Body::Scalar> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Alternative syntax:

    $body = GX::HTTP::Body::Scalar->new( $content );

=over 4

=item Arguments:

=over 4

=item * C<$content> ( string | C<SCALAR> reference )

=back

=item Returns:

=over 4

=item * C<$body> ( L<GX::HTTP::Body::Scalar> object )

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

=item * C<$string> ( byte string )

=back

=back

=head3 C<clear>

Clears the message body.

    $body->clear;

Calling this method also resets the the readonly flag.

=head3 C<content>

Returns a reference to the content string.

    $content = $body->content;

=over 4

=item Returns:

=over 4

=item * C<$content> ( C<SCALAR> reference )

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

Returns an L<IO::File> handle for the content string.

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

Prints the message body to the given filehandle, returning true on success or
false on failure.

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
