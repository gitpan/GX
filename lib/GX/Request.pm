# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Request.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Request;

use GX::HTTP::Parameters;
use GX::HTTP::Parser::Body;
use GX::HTTP::Request::Cookie;
use GX::HTTP::Request::Cookies;
use GX::HTTP::Uploads;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends qw( GX::Component GX::HTTP::Request );

has 'body_parameters' => (
    isa         => 'Scalar',
    initializer => '_initialize_body_parameters'
);

has 'body_parser' => (
    isa         => 'Scalar',
    initializer => '_initialize_body_parser'
);

has 'cookies' => (
    isa         => 'Scalar',
    initializer => '_initialize_cookies'
);

has 'format' => (
    isa => 'Scalar'
);

has 'host' => (
    isa => 'Scalar'
);

has 'parameters' => (
    isa         => 'Scalar',
    initializer => '_initialize_parameters'
);

has 'parsed_body' => (
    isa       => 'Scalar',
    accessors => {
        '_get_parsed_body' => { type => 'get' },
        '_set_parsed_body' => { type => 'set' }
    }
);

has 'path' => (
    isa => 'Scalar'
);

has 'path_parameters' => (
    isa         => 'Scalar',
    initializer => '_initialize_path_parameters'
);

has 'port' => (
    isa => 'Scalar'
);

has 'query' => (
    isa => 'Scalar'
);

has 'query_parameters' => (
    isa         => 'Scalar',
    initializer => '_initialize_query_parameters'
);

has 'read_callback' => (
    isa => 'Scalar'
);

has 'remote_address' => (
    isa => 'Scalar'
);

has 'scheme' => (
    isa => 'Scalar'
);

has 'uploads' => (
    isa         => 'Scalar',
    initializer => '_initialize_uploads'
);

has static 'tmp_dir' => (
    isa       => 'Scalar',
    accessors => {
        '_get_tmp_dir' => { type => 'get' },
        '_set_tmp_dir' => { type => 'set' }
    }
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

sub has_parameters {

    return $_[0]->parameters->count ? 1 : 0;

}

sub has_uploads {

    return $_[0]->uploads->count ? 1 : 0;

}

sub parameter {

    return shift->parameters->get( @_ );

}

sub upload {

    return shift->uploads->get( @_ );

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _initialize_body_parameters {

    return $_[0]->_parse_body->{'parameters'} // GX::HTTP::Parameters->new;

}

sub _initialize_body_parser {

    my $self = shift;

    my $content_type = $self->content_type;

    if ( ! defined $content_type ) {
        return undef;
    }

    return GX::HTTP::Parser::Body->new(
        content_type => $content_type,
        tmp_dir      => $self->_get_tmp_dir
    );

}

sub _initialize_cookies {

    my $self = shift;

    my $cookies = GX::HTTP::Request::Cookies->new;

    $cookies->add( map { GX::HTTP::Request::Cookie->parse( $_ ) } $self->headers->cookie );

    return $cookies;

}

sub _initialize_parameters {

    my $self = shift;

    return GX::HTTP::Parameters->merge(
        $self->path_parameters,
        $self->query_parameters,
        $self->body_parameters
    );

}

sub _initialize_path_parameters {

    return GX::HTTP::Parameters->new;

}

sub _initialize_query_parameters {

    return GX::HTTP::Parameters->parse( $_[0]->query );

}

sub _initialize_uploads {

    return $_[0]->_parse_body->{'uploads'} // GX::HTTP::Uploads->new;

}

sub _parse_body {

    my $self = shift;

    my $parsed_body = $self->_get_parsed_body;

    if ( ! $parsed_body ) {

        my $body = $self->body;

        if ( $body->length > 0 ) {

            my $parser = $self->body_parser;

            if ( $parser ) {
                $parsed_body = $parser->parse( $body );
            }

        }

        $parsed_body //= {};

        $self->_set_parsed_body( $parsed_body );

    }

    return $parsed_body;

}

sub _register {

    my $class       = shift;
    my $application = shift;

    $class->SUPER::_register( $application );

    if ( ! defined $class->_get_tmp_dir ) {
        $class->_set_tmp_dir( $application->path( 'tmp' ) );
    }

    return;

}

sub _validate_class_name {

    return $_[1] =~ /^(?:[_a-zA-Z]\w*::)+Request$/;

}


1;

__END__

=head1 NAME

GX::Request - Request component

=head1 SYNOPSIS

    package MyApp::Request;
    
    use GX::Request;
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Request> class which inherits directly from
L<GX::Component> and L<GX::HTTP::Request>.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new request object.

    $request = $class->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<body> ( L<GX::HTTP::Body> object )

A L<GX::HTTP::Body> object encapsulating the request body. Defaults to a
L<GX::HTTP::Body::Scalar> object.

=item * C<body_parameters> ( L<GX::HTTP::Parameters> object )

A L<GX::HTTP::Parameters> object containing the request body parameters.
Unless set explicitly, this attribute is initialized on-demand, which triggers
the parsing of the request body.

=item * C<body_parser> ( L<GX::HTTP::Parser::Body> object | C<undef> )

A L<GX::HTTP::Parser::Body> instance that should be used for parsing the
request body. This attribute is initialized on demand. Setting it to C<undef>
disables the (on-demand) parsing of the request body.

=item * C<cookies> ( L<GX::HTTP::Request::Cookies> object )

A L<GX::HTTP::Request::Cookies> object containing the cookies that were sent
with the request. Unless set explicitly, this attribute is initialized
on-demand, which triggers the parsing of the request headers.

=item * C<format> ( string | C<undef> )

A string identifying the requested response format (for example "html" or
"xml") or C<undef> if a response format has not been specified.

=item * C<headers> ( L<GX::HTTP::Request::Headers> object )

A L<GX::HTTP::Request::Headers> object containing the request headers.
Initialized on demand.

=item * C<host> ( string | C<undef> )

A string with the name of the host or C<undef> if the name is unknown.

=item * C<method> ( string | C<undef> )

A string identifying the HTTP request method (for example "GET", "POST" or
"HEAD") or C<undef> if the method is unknown.

=item * C<parameters> ( L<GX::HTTP::Parameters> object )

A L<GX::HTTP::Parameters> object containing the merged path, query and body
parameters. Unless set explicitly, this attribute is initialized on-demand,
which triggers the parsing of both the request body and the query string
portion of the request URI.

=item * C<path> ( string | C<undef> )

A string with the path portion of the request URI or C<undef> if the path is
not determinable.

=item * C<path_parameters> ( L<GX::HTTP::Parameters> object )

A L<GX::HTTP::Parameters> object containing the path parameters. Initialized
on demand.

=item * C<port> ( integer | C<undef> )

The TCP/IP port number on which the request was received from the client or
C<undef> if the port number is unknown.

=item * C<protocol> ( string | C<undef> )

A string identifying the HTTP version (for example "HTTP/1.1") or C<undef> if
the protocol version is unknown.

=item * C<query> ( string | C<undef> )

A string with the query portion of the request URI or C<undef> if the query
string is not determinable.

=item * C<query_parameters> ( L<GX::HTTP::Parameters> object )

A L<GX::HTTP::Parameters> object containing the query parameters. Unless set
explicitly, this attribute is initialized on-demand, which triggers the
parsing of the query portion of the request URI.

=item * C<read_callback> ( C<CODE> reference | C<undef> )

A read progress callback.

=item * C<remote_address> ( string | C<undef> )

A string with the IP address of the client or C<undef> if the address is
unknown.

=item * C<scheme> ( string | C<undef> )

A string with the scheme portion of the request URI (for example "http" or
"https") or C<undef> if the scheme is not determinable.

=item * C<uploads> ( L<GX::HTTP::Uploads> object )

A L<GX::HTTP::Uploads> object containing the uploads that were sent with the
request. Unless set explicitly, this attribute is initialized on-demand, which
triggers the parsing of the request body.

=item * C<uri> ( string | C<undef> )

A string with the request URI as sent by the client or C<undef> if the URI is
unknown.

=back

=item Returns:

=over 4

=item * C<$request> ( L<GX::Request> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<body>

Returns / sets the L<GX::HTTP::Body> object containing the request body.

    $body = $request->body;
    $body = $request->body( $body );

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

This method is inherited from L<GX::HTTP::Request|GX::HTTP::Request/"body">.

=head3 C<body_parameters>

Returns / sets the container for the request body parameters.

    $parameters = $request->body_parameters;
    $parameters = $request->body_parameters( $parameters );

=over 4

=item Arguments:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object )

=back

=back

=head3 C<body_parser>

Returns / sets the L<GX::HTTP::Parser::Body> instance that is used for parsing
the request body.

    $parser = $request->body_parser;
    $parser = $request->body_parser( $parser );

=over 4

=item Arguments:

=over 4

=item * C<$parser> ( L<GX::HTTP::Parser::Body> object | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$parser> ( L<GX::HTTP::Parser::Body> object | C<undef> )

Passing C<undef> disables the (on-demand) parsing of the request body.

=back

=back

=head3 C<content_encoding>

Returns / sets the value of the "Content-Encoding" request header field.

    $content_encoding = $request->content_encoding;
    $content_encoding = $request->content_encoding( $content_encoding );

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

This method, which is inherited from L<GX::HTTP::Request|GX::HTTP::Request/"content_encoding">,
is a shortcut for calling C<< $request-E<gt>headers-E<gt>content_encoding() >>. 

=head3 C<content_length>

Returns / sets the value of the "Content-Length" request header field.

    $content_length = $request->content_length;
    $content_length = $request->content_length( $content_length );

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

This method, which is inherited from L<GX::HTTP::Request|GX::HTTP::Request/"content_encoding">,
is a shortcut for calling C<< $request-E<gt>headers-E<gt>content_length() >>. 

=head3 C<content_type>

Returns / sets the value of the "Content-Type" request header field.

    $content_type = $request->content_type;
    $content_type = $request->content_type( $content_type );

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

This method, which is inherited from L<GX::HTTP::Request|GX::HTTP::Request/"content_encoding">,
is a shortcut for calling C<< $request-E<gt>headers-E<gt>content_type() >>. 

=head3 C<cookie>

Returns all request cookie objects with the given name in the order they were
added to the cookies container.

    @cookies = $request->cookie( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

=back

=item Returns:

=over 4

=item * C<@cookies> ( L<GX::HTTP::Request::Cookie> objects )

=back

=back

In scalar context, the first of those objects is returned.

    $cookie = $request->cookie( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

=back

=item Returns:

=over 4

=item * C<$cookie> ( L<GX::HTTP::Request::Cookie> object | C<undef> )

=back

=back

This method is a shortcut for calling C<$request-E<gt>cookies-E<gt>get()>.

=head3 C<cookies>

Returns / sets the container for the request cookie objects.

    $cookies = $request->cookies;
    $cookies = $request->cookies( $cookies );

=over 4

=item Arguments:

=over 4

=item * C<$cookies> ( L<GX::HTTP::Request::Cookies> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$cookies> ( L<GX::HTTP::Request::Cookies> object )

=back

=back

=head3 C<format>

Returns / sets the string identifying the requested response format.

    $format = $request->format;
    $format = $request->format( $format );

=over 4

=item Arguments:

=over 4

=item * C<$format> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$format> ( string | C<undef> )

=back

=back

=head3 C<has_body>

Returns true if the request body is not empty, otherwise false.

    $bool = $request->has_body;

=over 4

=item Returns:

=over 4

=item * C<$bool> ( bool )

=back

=back

=head3 C<has_cookies>

Returns true if the request cookies container is not empty, otherwise false.

    $bool = $request->has_cookies;

=over 4

=item Returns:

=over 4

=item * C<$bool> ( bool )

=back

=back

=head3 C<has_headers>

Returns true if the request headers container is not empty, otherwise false.

    $bool = $request->has_headers;

=over 4

=item Returns:

=over 4

=item * C<$bool> ( bool )

=back

=back 

=head3 C<has_parameters>

Returns true if the parameters container is not empty, otherwise false.

    $bool = $request->has_parameters;

=over 4

=item Returns:

=over 4

=item * C<$bool> ( bool )

=back

=back

=head3 C<has_uploads>

Returns true if the uploads container is not empty, otherwise false.

    $bool = $request->has_uploads;

=over 4

=item Returns:

=over 4

=item * C<$bool> ( bool )

=back

=back

=head3 C<header>

Returns / sets the value of the specified request header field.

    $value = $request->header( $field );
    $value = $request->header( $field, $value );

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

This method is inherited from L<GX::HTTP::Request|GX::HTTP::Request/"header">.

=head3 C<headers>

Returns / sets the container for the request headers.

    $headers = $request->headers;
    $headers = $request->headers( $headers );

=over 4

=item Arguments:

=over 4

=item * C<$headers> ( L<GX::HTTP::Request::Headers> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$headers> ( L<GX::HTTP::Request::Headers> )

=back

=back

This method is inherited from L<GX::HTTP::Request|GX::HTTP::Request/"headers">.

=head3 C<host>

Returns / sets the hostname.

    $host = $request->host;
    $host = $request->host( $host );

=over 4

=item Arguments:

=over 4

=item * C<$host> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$host> ( string | C<undef> )

=back

=back

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

This method is inherited from L<GX::HTTP::Request|GX::HTTP::Request/"method">.

=head3 C<parameter>

Returns the values associated with the given parameter key in the order they
were added to the parameters container.

    @values = $request->parameter( $key );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=back

=item Returns:

=over 4

=item * C<@values> ( strings )

=back

=back

In scalar context, the first of those values is returned.

    $value = $request->parameter( $key );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

This method is a shortcut for calling C<$request-E<gt>parameters-E<gt>get()>.

=head3 C<parameters>

Returns / sets the container for the merged path, query and body parameters.

    $parameters = $request->parameters;
    $parameters = $request->parameters( $parameters );

=over 4

=item Arguments:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object )

=back

=back

=head3 C<path>

Returns / sets the requested path.

    $path = $request->path;
    $path = $request->path( $path );

=over 4

=item Arguments:

=over 4

=item * C<$path> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$path> ( string | C<undef> )

=back

=back

=head3 C<path_parameters>

Returns / sets the container for the path parameters.

    $parameters = $request->path_parameters;
    $parameters = $request->path_parameters( $parameters );

=over 4

=item Arguments:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object )

=back

=back

=head3 C<port>

Returns / sets the port number on which the request was received from the
client.

    $port = $request->port;
    $port = $request->port( $port );

=over 4

=item Arguments:

=over 4

=item * C<$port> ( integer | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$port> ( integer | C<undef> )

=back

=back

=head3 C<protocol>

Returns / sets the HTTP version.

    $protocol = $request->protocol;
    $protocol = $request->protocol( $protocol );

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

This method is inherited from L<GX::HTTP::Request|GX::HTTP::Request/"protocol">.

=head3 C<query>

Returns / sets the query string.

    $query = $request->query;
    $query = $request->query( $query );

=over 4

=item Arguments:

=over 4

=item * C<$query> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$query> ( string | C<undef> )

=back

=back

=head3 C<query_parameters>

Returns / sets the container for the query parameters.

    $parameters = $request->query_parameters;
    $parameters = $request->query_parameters( $parameters );

=over 4

=item Arguments:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object )

=back

=back

=head3 C<read_callback>

Returns / sets the read progress callback.

    $code = $request->read_callback;
    $code = $request->read_callback( $code );

=over 4

=item Arguments:

=over 4

=item * C<$code> ( C<CODE> reference | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$code> ( C<CODE> reference | C<undef> )

=back

=back

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

This method, which is inherited from L<GX::HTTP::Request|GX::HTTP::Request/"referer">,
is a shortcut for calling C<< $request-E<gt>headers-E<gt>referer() >>. 

=head3 C<remote_address>

Returns / sets the IP address of the client.

    $address = $request->remote_address;
    $address = $request->remote_address( $address );

=over 4

=item Arguments:

=over 4

=item * C<$address> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$address> ( string | C<undef> )

=back

=back

=head3 C<scheme>

Returns / sets the request scheme.

    $scheme = $request->scheme;
    $scheme = $request->scheme( $scheme );

=over 4

=item Arguments:

=over 4

=item * C<$scheme> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$scheme> ( string | C<undef> )

=back

=back

=head3 C<upload>

Returns all upload objects with the given name in the order they were added
to the uploads container.

    @uploads = $request->upload( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

=back

=item Returns:

=over 4

=item * C<@uploads> ( L<GX::HTTP::Upload> objects )

=back

=back

In scalar context, the first of those objects is returned.

    $upload = $request->upload( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

=back

=item Returns:

=over 4

=item * C<$upload> ( L<GX::HTTP::Upload> object | C<undef> )

=back

=back

This method is a shortcut for calling C<$request-E<gt>uploads-E<gt>get()>.

=head3 C<uploads>

Returns / sets the container for the upload objects.

    $uploads = $request->uploads;
    $uploads = $request->uploads( $uploads );

=over 4

=item Arguments:

=over 4

=item * C<$uploads> ( L<GX::HTTP::Uploads> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$uploads> ( L<GX::HTTP::Uploads> object )

=back

=back

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

This method is inherited from L<GX::HTTP::Request|GX::HTTP::Request/"uri">.

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

This method, which is inherited from L<GX::HTTP::Request|GX::HTTP::Request/"user_agent">,
is a shortcut for calling C<< $request-E<gt>headers-E<gt>user_agent() >>. 

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
