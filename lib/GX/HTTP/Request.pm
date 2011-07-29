# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Request.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Request;

use GX::Exception;
use GX::HTTP::Constants qw( CRLF );
use GX::HTTP::Request::Headers;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::HTTP::Message';

has 'method' => (
    isa => 'Scalar'
);

has 'uri' => (
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
        $handle->print( $self->request_line, CRLF ) && $self->SUPER::print_to( $handle );
    };

    complain $@ if $@;

    return $result;

}

sub request_line {

    my $self = shift;

    my $method = $self->method;

    if ( ! defined $method ) {
        complain "Undefined request method";
    }

    my $uri = $self->uri;

    if ( ! defined $uri ) {
        complain "Undefined request URI";
    }

    my $protocol = $self->protocol;

    if ( ! defined $protocol ) {
        complain "Undefined protocol version";
    }

    return join( ' ', $method, $uri, $protocol );

}

{

    for ( qw(
        Referer
        User-Agent
    ) ) {
        __PACKAGE__->_install_header_accessor( $_ );
    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _initialize_headers {

    return GX::HTTP::Request::Headers->new;

}


1;

__END__

=head1 NAME

GX::HTTP::Request - HTTP request class

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Request;
    
    # Create a new request object
    $request = GX::HTTP::Request->new(
        protocol => 'HTTP/1.1',
        method   => 'GET',
        uri      => 'http://www.gxframework.org/'
    );
    
    # Print the request
    $request->print_to( *STDOUT );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Request> class which extends the
L<GX::HTTP::Message> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Request> object.

    $request = GX::HTTP::Request->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<body> ( L<GX::HTTP::Body> object )

A L<GX::HTTP::Body> object encapsulating the request body. Defaults to a
L<GX::HTTP::Body::Scalar> object.

=item * C<headers> ( L<GX::HTTP::Request::Headers> object )

A L<GX::HTTP::Request::Headers> object containing the request headers.
Initialized on demand.

=item * C<method> ( string | C<undef> )

A string identifying the HTTP request method (for example "GET", "POST" or
"HEAD") or C<undef> if the method is unknown.

=item * C<protocol> ( string | C<undef> )

A string identifying the HTTP version (for example "HTTP/1.1") or C<undef> if
the protocol version is unknown.

=item * C<uri> ( string | C<undef> )

A string with the request URI or C<undef> if the URI is unknown.

=back

=item Returns:

=over 4

=item * C<$request> ( L<GX::HTTP::Request> object )

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

=head3 C<method>

Returns / sets the request method.

    $method = $request->method;
    $method = $request->method( $method );

=over 4

=item Arguments:

=over 4

=item * C<$method> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$method> ( string | C<undef> )

=back

=back

See L<RFC 2616, section 5.1.1|http://tools.ietf.org/html/rfc2616#section-5.1.1>
for a list of all HTTP/1.1 request methods.

=head3 C<print>

See L<GX::HTTP::Message|GX::HTTP::Message/"print">.

=head3 C<print_to>

See L<GX::HTTP::Message|GX::HTTP::Message/"print_to">.

=head3 C<protocol>

See L<GX::HTTP::Message|GX::HTTP::Message/"protocol">.

=head3 C<referer>

Returns / sets the value of the "Referer" header field.

    $referer = $request->referer;
    $referer = $request->referer( $referer );

=over 4

=item Arguments:

=over 4

=item * C<$referer> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$referer> ( string | C<undef> )

=back

=back

This method is a shortcut for calling C<< $request-E<gt>headers-E<gt>referer() >>.

=head3 C<request_line>

Constructs the request line and returns it.

    $request_line = $request->request_line;

=over 4

=item Returns:

=over 4

=item * C<$request_line> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

See L<RFC 2616, section 5.1|http://tools.ietf.org/html/rfc2616#section-5.1>.

=head3 C<uri>

Returns / sets the request URI.

    $uri = $request->uri;
    $uri = $request->uri( $uri );

=over 4

=item Arguments:

=over 4

=item * C<$uri> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$uri> ( string | C<undef> )

=back

=back

See L<RFC 2616, section 5.1.2|http://tools.ietf.org/html/rfc2616#section-5.1.2>.

=head3 C<user_agent>

Returns / sets the value of the "User-Agent" request header field.

    $user_agent = $request->user_agent;
    $user_agent = $request->user_agent( $user_agent );

=over 4

=item Arguments:

=over 4

=item * C<$user_agent> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$user_agent> ( string | C<undef> )

=back

=back

This method is a shortcut for calling C<< $request-E<gt>headers-E<gt>user_agent() >>.

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
