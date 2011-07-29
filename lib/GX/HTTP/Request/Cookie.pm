# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Request/Cookie.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Request::Cookie;

use GX::HTTP::Util qw( quote url_encode url_decode );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::HTTP::Cookie';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub as_string {

    my $self = shift;

    my $string = '';

    if ( ! defined $self->{'name'} || ! length $self->{'name'} ) {
        return $string;
    }

    if ( defined $self->{'version'} ) {
        $string .= '$Version=' . $self->{'version'} . '; ';
    }
    else {
        $string .= '$Version=1; ';
    }

    $string .= url_encode( $self->{'name'} ) . '=';

    if ( defined $self->{'value'} ) {
        $string .= quote( $self->{'value'} );
    }

    if ( defined $self->{'path'} ) {
        $string .= '; $Path=' . $self->{'path'};
    }

    if ( defined $self->{'domain'} ) {
        $string .= '; $Domain=' . $self->{'domain'};
    }

    if ( defined $self->{'port'} ) {
        # Must be quoted (RFC 2965)
        $string .= '; $Port=' . quote( $self->{'port'} );
    }

    return $string;


}

sub parse {

    my $class  = shift;
    my $string = shift;

    defined $string or return;

    my @parts;

    while ( length $string ) {

        $string =~ s/^\s*([^=;,]+)\s*=\s*// or return;

        push @parts, $1;

        if ( $string =~ s/^"([^"\\]*(?:\\.[^"\\]*)*)"\s*(?:;|,)*// ) {
            my $value = $1;
            $value =~ s/\\"/"/g;
            $value =~ s/\\\\/\\/g;
            push @parts, $value;
        }
        elsif ( $string =~ s/^([^;,]*)\s*(?:;|,)*// ) {
            push @parts, $1;
        }
        else {
            return;
        }

    }

    # See RFC 2109, section 4.4

    my @cookies;
    my $cookie;
    my %attributes;

    while ( @parts ) {

        my $part = shift @parts;

        if ( substr( $part, 0, 1 ) eq '$' ) {

            my $attribute = lc substr( $part, 1 );
            my $value     = shift @parts;

            if ( $cookie ) {

                if ( $attribute eq 'version' ) {
                    $cookie->{'version'} = $value;
                }
                elsif ( $attribute eq 'path' ) {
                    $cookie->{'path'} = $value;
                }
                elsif ( $attribute eq 'domain' ) {
                    $cookie->{'domain'} = $value;
                }
                elsif ( $attribute eq 'port' ) {
                    $cookie->{'port'} = $value;
                }

            }
            else {

                # Global attribute
                $attributes{$attribute} = $value;

            }

        }
        else {

            $cookie = $class->new(
                name    => url_decode( $part ),
                value   => shift( @parts ),
                domain  => $attributes{'domain'},
                path    => $attributes{'path'},
                version => $attributes{'version'}
            );

            push @cookies, $cookie;

        }

    }

    return @cookies;

}


1;

__END__

=head1 NAME

GX::HTTP::Request::Cookie - HTTP request cookie class

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Request::Cookie;
    
    # Create a new cookie
    $cookie = GX::HTTP::Request::Cookie->new(
        name  => 'Customer',
        value => 'Wile E. Coyote',
        path  => '/acme'
    )
    
    # Parse a "Cookie" header
    @cookies = GX::HTTP::Request::Cookie->parse(
        '$Version="1"; Customer="Wile E. Coyote"; $Path="/acme"'
    );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Request::Cookie> class which extends the
L<GX::HTTP::Cookie> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Request::Cookie> object.

    $cookie = GX::HTTP::Request::Cookie->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<domain> ( string )

=item * C<name> ( string )

=item * C<path> ( string )

=item * C<port> ( string )

=item * C<value> ( string )

=item * C<version> ( string )

=back

=item Returns:

=over 4

=item * C<$cookie> ( L<GX::HTTP::Request::Cookie> object )

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
"Cookie" header.

    $string = $cookie->as_string;

=over 4

=item Returns:

=over 4

=item * C<$string> ( string )

=back

=back

=head3 C<domain>

See L<GX::HTTP::Cookie|GX::HTTP::Cookie/domain>.

=head3 C<name>

See L<GX::HTTP::Cookie|GX::HTTP::Cookie/name>.

=head3 C<parse>

Parses the value of a "Cookie" header into a list of
L<GX::HTTP::Request::Cookie> objects.

    @cookies = GX::HTTP::Request::Cookie->parse( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( string )

=back

=item Returns:

=over 4

=item * C<@cookies> ( L<GX::HTTP::Request::Cookie> objects )

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
