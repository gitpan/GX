# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Cookie.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Cookie;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

# RFC 2109, RFC 2965
has 'domain' => (
    isa => 'Scalar'
);

has 'name' => (
    isa => 'Scalar'
);

# RFC 2109, RFC 2965
has 'path' => (
    isa => 'Scalar'
);

# RFC 2965
has 'port' => (
    isa => 'Scalar'
);

has 'value' => (
    isa => 'Scalar'
);

# RFC 2109, RFC 2965
has 'version' => (
    isa => 'Scalar'
);

build;


1;

__END__

=head1 NAME

GX::HTTP::Cookie - HTTP cookie base class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Cookie> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

This class is not meant to be instantiated. See L<GX::HTTP::Request::Cookie>
and L<GX::HTTP::Response::Cookie> instead.

=head2 Public Methods

=head3 C<domain>

Returns / sets the value of the cookie's "Domain" attribute.

    $domain = $cookie->domain;
    $domain = $cookie->domain( $domain );

=over 4

=item Arguments:

=over 4

=item * C<$domain> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$domain> ( string | C<undef> )

=back

=back

=head3 C<name>

Returns / sets the name of the cookie.

    $name = $cookie->name;
    $name = $cookie->name( $name );

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

=head3 C<path>

Returns / sets the value of the cookie's "Path" attribute.

    $path = $cookie->path;
    $path = $cookie->path( $path );

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

=head3 C<port>

Returns / sets the value of the cookie's "Port" attribute.

    $port = $cookie->port;
    $port = $cookie->port( $port );

=over 4

=item Arguments:

=over 4

=item * C<$port> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$port> ( string | C<undef> )

=back

=back

=head3 C<value>

Returns / sets the cookie value.

    $value = $cookie->value;
    $value = $cookie->value( $value );

=over 4

=item Arguments:

=over 4

=item * C<$value> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

=head3 C<version>

Returns / sets the value of the cookie's "Version" attribute.

    $version = $cookie->version;
    $version = $cookie->version( $version );

=over 4

=item Arguments:

=over 4

=item * C<$version> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$version> ( string | C<undef> )

=back

=back

=head1 SUBCLASSES

The following classes inherit directly from L<GX::HTTP::Cookie>:

=over 4

=item * L<GX::HTTP::Request::Cookie>

=item * L<GX::HTTP::Response::Cookie>

=back

=head1 SEE ALSO

=over 4

=item * L<RFC 2109|http://tools.ietf.org/html/rfc2109>

=item * L<RFC 2965|http://tools.ietf.org/html/rfc2965>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
