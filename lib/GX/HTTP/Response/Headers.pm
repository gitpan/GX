# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Response/Headers.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Response::Headers;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::HTTP::Headers';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Field accessors
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_field_accessors( qw(
    Location
    Set-Cookie
) );


1;

__END__

=head1 NAME

GX::HTTP::Response::Headers - HTTP response headers class

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Response::Headers;
    
    # Create a new headers object
    $headers = GX::HTTP::Response::Headers->new;
    
    # Set the value of a header field
    $headers->set( 'Content-Type' => 'text/plain' );
    
    # Get the value of a header field
    $content_type = $headers->get( 'Content-Type' );
    
    # Print the headers
    print $headers->as_string;

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Response::Headers> class which extends
the L<GX::HTTP::Headers> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Response::Headers> object.

    $headers = GX::HTTP::Response::Headers->new;

=over 4

=item Returns:

=over 4

=item * C<$headers> ( L<GX::HTTP::Response::Headers> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Also see C<< L<parse()|/parse> >>.

=head2 Basic Public API

=head3 C<add>

See L<GX::HTTP::Headers/add>.

=head3 C<as_string>

See L<GX::HTTP::Headers/as_string>.

=head3 C<clear>

See L<GX::HTTP::Headers/clear>.

=head3 C<count>

See L<GX::HTTP::Headers/count>.

=head3 C<field_names>

See L<GX::HTTP::Headers/field_names>.

=head3 C<get>

See L<GX::HTTP::Headers/get>.

=head3 C<parse>

Parses the given message header and adds the resulting header field / value
pairs to the container.

    $headers->parse( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( string )

=back

=back

This method can also be used as a constructor.

    $headers = GX::HTTP::Response::Headers->parse( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( string )

=back

=item Returns:

=over 4

=item * C<$headers> ( L<GX::HTTP::Response::Headers> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<remove>

See L<GX::HTTP::Headers/remove>.

=head3 C<set>

See L<GX::HTTP::Headers/set>.

=head3 C<sorted_field_names>

See L<GX::HTTP::Headers/sorted_field_names>.

=head2 Public Field Accessors

=head3 C<content_disposition>

See L<GX::HTTP::Headers/content_disposition>.

=head3 C<content_encoding>

See L<GX::HTTP::Headers/content_encoding>.

=head3 C<content_language>

See L<GX::HTTP::Headers/content_language>.

=head3 C<content_length>

See L<GX::HTTP::Headers/content_length>.

=head3 C<content_type>

See L<GX::HTTP::Headers/content_type>.

=head3 C<date>

See L<GX::HTTP::Headers/date>.

=head3 C<expires>

See L<GX::HTTP::Headers/expires>.

=head3 C<last_modified>

See L<GX::HTTP::Headers/last_modified>.

=head3 C<location>

Returns / sets the value of the "Location" header field.

    $value = $headers->location;
    $value = $headers->location( $value );

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

See L<RFC 2616, section 14.30|http://tools.ietf.org/html/rfc2616#section-14.30>.

=head3 C<set_cookie>

Returns / sets the value of the "Set-Cookie" header field.

    $value = $headers->set_cookie;
    $value = $headers->set_cookie( $value );

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

See L<RFC 2109, section 4.2.2|http://tools.ietf.org/html/rfc2109>.

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
