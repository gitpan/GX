# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Response/Cookie.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Response::Cookie;

use GX::HTTP::Util qw( quote url_encode url_decode );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::HTTP::Cookie';

# RFC 2109, RFC 2965
has 'comment' => (
    isa => 'Scalar'
);

# RFC 2965
has 'comment_url' => (
    isa => 'Scalar'
);

# RFC 2965
has 'discard' => (
    isa => 'Bool'
);

# Netscape
has 'expires' => (
    isa => 'Scalar'
);

# RFC 2965
has 'http_only' => (
    isa => 'Bool'
);

# RFC 2109, RFC 2965
has 'max_age' => (
    isa => 'Scalar'
);

# RFC 2109, RFC 2965
has 'secure' => (
    isa => 'Bool'
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub as_string {

    my $self = shift;

    # Note: Some user agents (e.g. IE, LWP::UserAgent) have problems with quoted attribute values

    my $string = '';

    if ( ! defined $self->{'name'} || ! length $self->{'name'} ) {
        return $string;
    }

    $string .= url_encode( $self->{'name'} ) . '=';

    if ( defined $self->{'value'} ) {
        $string .= quote( $self->{'value'} );
    }

    if ( defined $self->{'comment'} ) {
        $string .= '; Comment=' . quote( $self->{'comment'} );
    }

    if ( defined $self->{'comment_url'} ) {
        # Must be quoted (RFC 2965)
        $string .= '; CommentURL=' . quote( $self->{'comment_url'} );
    }

    if ( $self->{'discard'} ) {
        $string .= '; Discard';
    }

    if ( defined $self->{'domain'} ) {
        $string .= '; Domain=' . $self->{'domain'};
    }

    if ( defined $self->{'expires'} ) {
        $string .= '; Expires=' . $self->{'expires'};
    }

    if ( $self->{'http_only'} ) {
        $string .= '; HttpOnly';
    }

    if ( defined $self->{'max_age'} ) {
        $string .= '; Max-Age=' . $self->{'max_age'};
    }

    if ( defined $self->{'path'} ) {
        $string .= '; Path=' . $self->{'path'};
    }

    if ( defined $self->{'port'} ) {
        # Must be quoted (RFC 2965)
        $string .= '; Port=' . quote( $self->{'port'} );
    }

    if ( $self->{'secure'} ) {
        $string .= '; Secure';
    }

    if ( defined $self->{'version'} ) {
        $string .= '; Version=' . $self->{'version'};
    }
    else {
        $string .= '; Version=1';
    }

    return $string;

}

sub parse {

    my $class  = shift;
    my $string = shift;

    defined $string or return;

    my @parts;

    while ( length $string ) {

        $string =~ s/^\s*([^=;,]+)\s*=?\s*// or return;
        my $key = $1;

        push @parts, $key;

        if ( $key =~ /^expires$/i ) {

            # Attribute format: Wdy, DD-Mon-YYYY HH:MM:SS GMT
            if ( $string =~ s/^([^;,]+,+[^;,]+)\s*(?:;|,)*// ) {
                push @parts, $1;
            }

        }
        else {

            if ( $string =~ s/^"([^"\\]*(?:\\.[^"\\]*)*)"\s*(?:;|,)*// ) {
                my $value = $1;
                $value =~ s/\\"/"/g;
                $value =~ s/\\\\/\\/g;
                push @parts, $value;
            }
            elsif ( $string =~ s/^([^;,]*)\s*(?:;|,)*// ) {
                push @parts, $1;
            }

        }

    }

    my $cookie;
    my @cookies;

    while ( @parts ) {

        my $part = shift @parts;

        if ( $cookie ) {

            my $key = lc $part;

            if ( $key eq 'version' ) {
                $cookie->{'version'} = shift @parts;
                next;
            }

            if ( $key eq 'max-age' ) {
                $cookie->{'max_age'} = shift @parts;
                next;
            }

            if ( $key eq 'domain' ) {
                $cookie->{'domain'} = shift @parts;
                next;
            }

            if ( $key eq 'path' ) {
                $cookie->{'path'} = shift @parts;
                next;
            }

            if ( $key eq 'secure' ) {
                shift @parts;
                $cookie->{'secure'} = 1;
                next;
            }

            if ( $key eq 'httponly' ) {
                shift @parts;
                $cookie->{'http_only'} = 1;
                next;
            }

            if ( $key eq 'discard' ) {
                shift @parts;
                $cookie->{'discard'} = 1;
                next;
            }

            if ( $key eq 'port' ) {
                $cookie->{'port'} = shift @parts;
                next;
            }

            if ( $key eq 'expires' ) {
                $cookie->{'expires'} = shift @parts;
                next;
            }

            if ( $key eq 'comment' ) {
                $cookie->{'comment'} = shift @parts;
                next;
            }

            if ( $key eq 'commenturl' ) {
                $cookie->{'comment_url'} = shift @parts;
                next;
            }

        }

        $cookie = $class->new(
            name  => url_decode( $part ),
            value => shift( @parts )
        );

        push @cookies, $cookie;

    }

    return @cookies;

}


1;

__END__

=head1 NAME

GX::HTTP::Response::Cookie - HTTP response cookie class

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Response::Cookie;
    
    # Create a new cookie object
    $cookie = GX::HTTP::Response::Cookie->new(
        name  => 'Customer',
        value => 'Wile E. Coyote',
        path  => '/acme'
    )
    
    # Parse a "Set-Cookie" header
    @cookies = GX::HTTP::Response::Cookie->parse(
        'Customer="Wile E. Coyote"; Path="/acme"; Version="1"'
    );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Response::Cookie> class which extends
the L<GX::HTTP::Cookie> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Response::Cookie> object.

    $cookie = GX::HTTP::Response::Cookie->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<comment> ( string )

=item * C<comment_url> ( string )

=item * C<discard> ( bool )

=item * C<domain> ( string )

=item * C<expires> ( string )

The given value must be in the "Wdy, DD-Mon-YYYY HH:MM:SS GMT" format.

=item * C<http_only> ( bool )

=item * C<max_age> ( string )

=item * C<name> ( string )

=item * C<path> ( string )

=item * C<port> ( string )

=item * C<secure> ( bool )

=item * C<value> ( string )

=item * C<version> ( string )

=back

=item Returns:

=over 4

=item * C<$cookie> ( L<GX::HTTP::Response::Cookie> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Also see C<< L<parse()|/parse> >>.

=head2 Public Methods

=head3 C<as_string>

Returns a string representation of the cookie, suitable for inclusion in a
"Set-Cookie" or "Set-Cookie2" header.

    $string = $cookie->as_string;

=over 4

=item Returns:

=over 4

=item * C<$string> ( string )

=back

=back

=head3 C<comment>

Returns / sets the value of the cookie's "Comment" attribute.

    $comment = $cookie->comment;
    $comment = $cookie->comment( $comment );

=over 4

=item Arguments:

=over 4

=item * C<$comment> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$comment> ( string | C<undef> )

=back

=back

=head3 C<comment_url>

Returns / sets the value of the cookie's "CommentURL" attribute.

    $comment_url = $cookie->comment_url;
    $comment_url = $cookie->comment_url( $comment_url );

=over 4

=item Arguments:

=over 4

=item * C<$comment_url> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$comment_url> ( string | C<undef> )

=back

=back

=head3 C<discard>

Returns / sets the cookie's "Discard" flag.

    $bool = $cookie->discard;
    $bool = $cookie->discard( $bool );

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

=head3 C<domain>

See L<GX::HTTP::Cookie|GX::HTTP::Cookie/domain>.

=head3 C<expires>

Returns / sets the value of the cookie's "Expires" attribute.

    $expires = $cookie->expires;
    $expires = $cookie->expires( $expires );

=over 4

=item Arguments:

=over 4

=item * C<$expires> ( string | C<undef> ) [ optional ]

The given value must be in the "Wdy, DD-Mon-YYYY HH:MM:SS GMT" format.

=back

=item Returns:

=over 4

=item * C<$expires> ( string | C<undef> )

=back

=back

=head3 C<http_only>

Returns / sets the cookie's "HttpOnly" flag.

    $bool = $cookie->http_only;
    $bool = $cookie->http_only( $bool );

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

=head3 C<max_age>

Returns / sets the value of the cookie's "Max-Age" attribute.

    $max_age = $cookie->max_age;
    $max_age = $cookie->max_age( $max_age );

=over 4

=item Arguments:

=over 4

=item * C<$max_age> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$max_age> ( string | C<undef> )

=back

=back

=head3 C<name>

See L<GX::HTTP::Cookie|GX::HTTP::Cookie/name>.

=head3 C<parse>

Parses the value of a "Set-Cookie" (or "Set-Cookie2") header into a list of
L<GX::HTTP::Response::Cookie> objects.

    @cookies = GX::HTTP::Response::Cookie->parse( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( string )

=back

=item Returns:

=over 4

=item * C<@cookies> ( L<GX::HTTP::Response::Cookie> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<path>

See L<GX::HTTP::Cookie|GX::HTTP::Cookie/path>.

=head3 C<port>

See L<GX::HTTP::Cookie|GX::HTTP::Cookie/port>.

=head3 C<secure>

Returns / sets the cookie's "Secure" flag.

    $bool = $cookie->secure;
    $bool = $cookie->secure( $bool );

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

=head3 C<value>

See L<GX::HTTP::Cookie|GX::HTTP::Cookie/value>.

=head3 C<version>

See L<GX::HTTP::Cookie|GX::HTTP::Cookie/version>.

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
