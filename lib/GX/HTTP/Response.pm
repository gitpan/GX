# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Response.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Response;

use GX::Exception;
use GX::HTTP::Constants qw( CRLF );
use GX::HTTP::Response::Headers;
use GX::HTTP::Status;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::HTTP::Message';

has 'status' => (
    isa => 'Scalar'
);

has 'status_reason' => (
    isa => 'Scalar'
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub print_to {

    my $self   = shift;
    my $handle = shift;

    my $result = eval {
        $handle->print( $self->status_line, CRLF ) && $self->SUPER::print_to( $handle );
    };

    complain $@ if $@;

    return $result;

}

sub status_line {

    my $self = shift;

    my $protocol = $self->protocol;

    if ( ! defined $protocol ) {
        complain "Undefined protocol version";
    }

    my $status = $self->status;

    if ( ! defined $status ) {
        complain "Undefined response status";
    }

    my $line = $protocol . ' ' . $status;

    my $reason = $self->status_reason;

    if ( ! defined $reason ) {
        $reason = GX::HTTP::Status::reason_phrase( $status );
    }

    if ( defined $reason ) {
        $line .= ' '. $reason;
    }

    return $line;

}

{

    for ( qw(
        Location
    ) ) {
        __PACKAGE__->_install_header_accessor( $_ );
    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _initialize_headers {

    return GX::HTTP::Response::Headers->new;

}


1;

__END__

=head1 NAME

GX::HTTP::Response - HTTP response class

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Response;
    
    # Create a new response object
    $response = GX::HTTP::Response->new(
        protocol => 'HTTP/1.1',
        status   => 200
    );
    
    # Add content
    $response->add( 'Hello world!' );
    
    # Print the response
    $response->print_to( *STDOUT );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Response> class which extends the
L<GX::HTTP::Message> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Response> object.

    $response = GX::HTTP::Response->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<body> ( L<GX::HTTP::Body> object )

A L<GX::HTTP::Body> object encapsulating the response body. Defaults to a
L<GX::HTTP::Body::Scalar> object.

=item * C<headers> ( L<GX::HTTP::Response::Headers> object )

A L<GX::HTTP::Response::Headers> object containing the response headers.
Initialized on demand.

=item * C<protocol> ( string | C<undef> )

A string identifying the HTTP version (for example "HTTP/1.1") or C<undef> if
the protocol version is unknown.

=item * C<status> ( integer | C<undef> )

A HTTP status code (for example "200" or "404") or C<undef> if the status is
unknown.

=item * C<status_reason> ( string | C<undef> )

A string with the status reason phrase or C<undef> if the reason phrase is
undefined.

=back

=item Returns:

=over 4

=item * C<$response> ( L<GX::HTTP::Response> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<add>

See L<GX::HTTP::Message|GX::HTTP::Message/"add">.

=head3 C<as_string>

See L<GX::HTTP::Message|GX::HTTP::Message/"as_string">.

=head3 C<body>

See L<GX::HTTP::Message|GX::HTTP::Message/"body">.

=head3 C<content_encoding>

See L<GX::HTTP::Message|GX::HTTP::Message/"content_encoding">.

=head3 C<content_length>

See L<GX::HTTP::Message|GX::HTTP::Message/"content_length">.

=head3 C<content_type>

See L<GX::HTTP::Message|GX::HTTP::Message/"content_type">.

=head3 C<header>

See L<GX::HTTP::Message|GX::HTTP::Message/"header">.

=head3 C<headers>

See L<GX::HTTP::Message|GX::HTTP::Message/"headers">.

=head3 C<location>

Returns / sets the value of the "Location" response header field.

    $location = $response->location;
    $location = $response->location( $location );

=over 4

=item Arguments:

=over 4

=item * C<$location> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$location> ( string | C<undef> )

=back

=back

This method is a shortcut for calling C<< $response-E<gt>headers-E<gt>location() >>.

=head3 C<print>

See L<GX::HTTP::Message|GX::HTTP::Message/"print">.

=head3 C<print_to>

See L<GX::HTTP::Message|GX::HTTP::Message/"print_to">.

=head3 C<protocol>

See L<GX::HTTP::Message|GX::HTTP::Message/"protocol">.

=head3 C<status>

Returns / sets the status code of the response.

    $status = $response->status;
    $status = $response->status( $status );

=over 4

=item Arguments:

=over 4

=item * C<$status> ( integer | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$status> ( integer | C<undef> )

=back

=back

See L<RFC 2616, section 6.1.1|http://tools.ietf.org/html/rfc2616#section-6.1.1>

=head3 C<status_line>

Constructs the status line and returns it.

    $status_line = $response->status_line;

=over 4

=item Returns:

=over 4

=item * C<$status_line> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

See L<RFC 2616, section 6.1|http://tools.ietf.org/html/rfc2616#section-6.1>

=head3 C<status_reason>

Returns / sets the status reason phrase.

    $status_reason = $response->status_reason;
    $status_reason = $response->status_reason( $status_reason );

=over 4

=item Arguments:

=over 4

=item * C<$status_reason> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$status_reason> ( string | C<undef> )

=back

=back

See L<RFC 2616, section 6.1.1|http://tools.ietf.org/html/rfc2616#section-6.1.1>

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
