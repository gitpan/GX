# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Message.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Message;

use GX::Exception;
use GX::HTTP::Body::Scalar;
use GX::HTTP::Constants qw( CRLF );
use GX::HTTP::Headers;

use IO::File ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'body' => (
    isa         => 'Scalar',
    initializer => '_initialize_body'
);

has 'headers' => (
    isa         => 'Scalar',
    initializer => '_initialize_headers'
);

has 'protocol' => (
    isa => 'Scalar'
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    my $self = shift;

    return ( $self->body || complain "No body object" )->add( @_ );

}

sub as_string {

    my $self = shift;

    my $string = '';

    eval {
        $self->print_to( IO::File->new( \$string, '>' ) );
    };

    complain $@ if $@;

    return $string;

}

sub header {

    my $self = shift;

    if ( @_ > 1 ) {
        return ( $self->headers || complain "No headers object" )->set( $_[0], $_[1] );
    }
    else {
        return ( $self->headers || return )->get( $_[0] );
    }

}

sub print_to {

    my $self   = shift;
    my $handle = shift;

    my $result = eval {

        if ( my $headers = $self->headers ) {
            $handle->print( $headers->as_string, CRLF ) or return;
        }
        else {
            $handle->print( CRLF ) or return;
        }

        if ( my $body = $self->body ) {
            $body->print_to( $handle ) or return;
        }

        1;

    };

    complain $@ if $@;

    return $result;

}

{

    for ( qw(
        Content-Encoding
        Content-Length
        Content-Type
    ) ) {
        __PACKAGE__->_install_header_accessor( $_ );
    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _initialize_body {

    return GX::HTTP::Body::Scalar->new;

}

sub _initialize_headers {

    return GX::HTTP::Headers->new;

}

sub _install_header_accessor {

    my $class = shift;
    my $field = shift;

    ( my $accessor = lc $field ) =~ tr/-/_/;

    $class->meta->add_method(

        $accessor => sub {

            my $self = shift;

            if ( @_ ) {
                return ( $self->headers || complain "No headers object" )->set( $field, $_[0] );
            }
            else {
                return ( $self->headers || return )->get( $field );
            }

        }

    );

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------------------------------------------------------

*print = \&add;


1;

__END__

=head1 NAME

GX::HTTP::Message - HTTP message base class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Message> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

This class is not meant to be instantiated. See L<GX::HTTP::Request> and
L<GX::HTTP::Response> instead.

=head2 Public Methods

=head3 C<add>

Adds the given content to the message body.

    $message->add( @content );

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

This method is a shortcut for calling C<< $message-E<gt>body-E<gt>add() >>.

=head3 C<as_string>

Returns the message as a string of bytes.

    $string = $message->as_string;

=over 4

=item Returns:

=over 4

=item * C<$string> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<body>

Returns / sets the L<GX::HTTP::Body> object containing the message body.

    $body = $message->body;
    $body = $message->body( $body );

=over 4

=item Arguments:

=over 4

=item * C<$body> ( L<GX::HTTP::Body> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$body> ( L<GX::HTTP::Body> object )

=back

=back

=head3 C<content_encoding>

Returns / sets the value of the "Content-Encoding" message header field.

    $content_encoding = $message->content_encoding;
    $content_encoding = $message->content_encoding( $content_encoding );

=over 4

=item Arguments:

=over 4

=item * C<$content_encoding> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$content_encoding> ( string | C<undef> )

=back

=back

This method is a shortcut for calling C<< $message-E<gt>headers-E<gt>content_encoding() >>.

=head3 C<content_length>

Returns / sets the value of the "Content-Length" message header field.

    $content_length = $message->content_length;
    $content_length = $message->content_length( $content_length );

=over 4

=item Arguments:

=over 4

=item * C<$content_length> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$content_length> ( string | C<undef> )

=back

=back

This method is a shortcut for calling C<< $message-E<gt>headers-E<gt>content_length() >>.

=head3 C<content_type>

Returns / sets the value of the "Content-Type" message header field.

    $content_type = $message->content_type;
    $content_type = $message->content_type( $content_type );

=over 4

=item Arguments:

=over 4

=item * C<$content_type> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$content_type> ( string | C<undef> )

=back

=back

This method is a shortcut for calling C<< $message-E<gt>headers-E<gt>content_type() >>.

=head3 C<header>

Returns / sets the value of the specified message  header field.

    $value = $message->header( $field );
    $value = $message->header( $field, $value );

=over 4

=item Arguments:

=over 4

=item * C<$field> ( string )

=item * C<$value> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

This method is a shortcut for calling C<< $message-E<gt>headers-E<gt>get() >>
and C<< $message-E<gt>headers-E<gt>set() >> respectively.

=head3 C<headers>

Returns / sets the container for the message headers.

    $headers = $message->headers;
    $headers = $message->headers( $headers );

=over 4

=item Arguments:

=over 4

=item * C<$headers> ( L<GX::HTTP::Headers> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$headers> ( L<GX::HTTP::Headers> object )

=back

=back

=head3 C<print>

An alias for the C<< L<add()|/add> >> method.

    $message->print( @content );

=head3 C<print_to>

Prints the message to the specified filehandle, returning true on success and
false on failure.

    $result = $message->print_to( $handle );

=over 4

=item Arguments:

=over 4

=item * C<$handle> ( L<IO::File> object | typeglob | C<GLOB> reference )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<protocol>

Returns / sets the HTTP version.

    $protocol = $message->protocol;
    $protocol = $message->protocol( $protocol );

=over 4

=item Arguments:

=over 4

=item * C<$protocol> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$protocol> ( string | C<undef> )

=back

=back

=head1 SUBCLASSES

The following classes inherit directly from L<GX::HTTP::Message>:

=over 4

=item * L<GX::HTTP::Request>

=item * L<GX::HTTP::Response>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
