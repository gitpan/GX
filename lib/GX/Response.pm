# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Response.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Response;

use GX::HTTP::Response::Cookies;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends qw( GX::Component GX::HTTP::Response );

has 'cookies' => (
    isa         => 'Scalar',
    initializer => '_initialize_cookies'
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub cookie {

    return shift->cookies->get( @_ );

}

sub has_body {

    return $_[0]->body->length ? 1 : 0;

}

sub has_cookies {

    return $_[0]->cookies->count ? 1 : 0;

}

sub has_headers {

    return $_[0]->headers->count ? 1 : 0;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _initialize_cookies {

    return GX::HTTP::Response::Cookies->new;

}

sub _validate_class_name {

    return $_[1] =~ /^(?:[_a-zA-Z]\w*::)+Response$/;

}


1;

__END__

=head1 NAME

GX::Response - Response component

=head1 SYNOPSIS

    package MyApp::Response;
    
    use GX::Response;
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Response> class which inherits directly from
L<GX::Component> and L<GX::HTTP::Response>.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new response object.

    $response = $class->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<body> ( L<GX::HTTP::Body> object )

A L<GX::HTTP::Body> object encapsulating the response body. Defaults to a
L<GX::HTTP::Body::Scalar> object.

=item * C<cookies> ( L<GX::HTTP::Response::Cookies> object )

A L<GX::HTTP::Response::Cookies> object containing the response cookies.
Initialized on demand.

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

=item * C<$response> ( L<GX::Response> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<add>

Adds the given content to the response body.

    $response->add( @content );

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

This method, which is inherited from L<GX::HTTP::Response|GX::HTTP::Response/"add">,
is a shortcut for calling C<< $response-E<gt>body-E<gt>add() >>.

=head3 C<body>

Returns / sets the L<GX::HTTP::Body> object containing the response body.

    $body = $response->body;
    $body = $response->body( $body );

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

This method is inherited from L<GX::HTTP::Response|GX::HTTP::Response/"body">.

=head3 C<content_encoding>

Returns / sets the value of the "Content-Encoding" response header field.

    $content_encoding = $response->content_encoding;
    $content_encoding = $response->content_encoding( $content_encoding );

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

This method, which is inherited from L<GX::HTTP::Response|GX::HTTP::Response/"content_encoding">,
is a shortcut for calling C<< $response-E<gt>headers-E<gt>content_encoding() >>.

=head3 C<content_length>

Returns / sets the value of the "Content-Length" response header field.

    $content_length = $response->content_length;
    $content_length = $response->content_length( $content_length );

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

This method, which is inherited from L<GX::HTTP::Response|GX::HTTP::Response/"content_length">,
is a shortcut for calling C<< $response-E<gt>headers-E<gt>content_length() >>.

=head3 C<content_type>

Returns / sets the value of the "Content-Type" response header field.

    $content_type = $response->content_type;
    $content_type = $response->content_type( $content_type );

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

This method, which is inherited from L<GX::HTTP::Response|GX::HTTP::Response/"content_type">,
is a shortcut for calling C<< $response-E<gt>headers-E<gt>content_type() >>.

=head3 C<cookie>

Returns all response cookie objects with the given name in the order they were
added to the cookies container.

    @cookies = $response->cookie( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

=back

=item Returns:

=over 4

=item * C<@cookies> ( L<GX::HTTP::Response::Cookie> objects )

=back

=back

In scalar context, the first of those objects is returned.

    $cookie = $response->cookie( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

=back

=item Returns:

=over 4

=item * C<$cookie> ( L<GX::HTTP::Response::Cookie> object | C<undef> )

=back

=back

This method is a shortcut for calling C<$response-E<gt>cookies-E<gt>get()>.

=head3 C<cookies>

Returns / sets the container for the response cookie objects.

    $cookies = $response->cookies;
    $cookies = $response->cookies( $cookies );

=over 4

=item Arguments:

=over 4

=item * C<$cookies> ( L<GX::HTTP::Response::Cookies> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$cookies> ( L<GX::HTTP::Response::Cookies> object )

=back

=back

=head3 C<has_body>

Returns true if the response body is not empty, otherwise false.

    $bool = $response->has_body;

=over 4

=item Returns:

=over 4

=item * C<$bool> ( bool )

=back

=back

=head3 C<has_cookies>

Returns true if the response cookies container is not empty, otherwise false.

    $bool = $response->has_cookies;

=over 4

=item Returns:

=over 4

=item * C<$bool> ( bool )

=back

=back

=head3 C<has_headers>

Returns true if the response headers container is not empty, otherwise false.

    $bool = $response->has_headers;

=over 4

=item Returns:

=over 4

=item * C<$bool> ( bool )

=back

=back

=head3 C<header>

Returns / sets the value of the specified response header field.

    $value = $response->header( $field );
    $value = $response->header( $field, $value );

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

This method is inherited from L<GX::HTTP::Response|GX::HTTP::Response/"header">.

=head3 C<headers>

Returns / sets the container for the response headers.

    $headers = $response->headers;
    $headers = $response->headers( $headers );

=over 4

=item Arguments:

=over 4

=item * C<$headers> ( L<GX::HTTP::Response::Headers> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$headers> ( L<GX::HTTP::Response::Headers> )

=back

=back

This method is inherited from L<GX::HTTP::Response|GX::HTTP::Response/"headers">.

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

This method, which is inherited from L<GX::HTTP::Response|GX::HTTP::Response/"location">,
is a shortcut for calling C<< $response-E<gt>headers-E<gt>location() >>.

=head3 C<protocol>

Returns / sets the HTTP version.

    $protocol = $response->protocol;
    $protocol = $response->protocol( $protocol );

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

This method is inherited from L<GX::HTTP::Response|GX::HTTP::Response/"protocol">.

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

This method is inherited from L<GX::HTTP::Response|GX::HTTP::Response/"status">.

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

This method is inherited from L<GX::HTTP::Response|GX::HTTP::Response/"status_reason">.

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
