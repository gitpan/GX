# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Util.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Util;

use strict;
use warnings;

use GX::Exception;


# ----------------------------------------------------------------------------------------------------------------------
# Data
# ----------------------------------------------------------------------------------------------------------------------

my %URL_ENCODE_MAP = map { chr( $_ ) => sprintf( "%%%02X", $_ ) } 0 .. 255;

# See "Unreserved Characters" in RFC 3986, Section 2.3 
my $REGEX_RESERVED_CHARS_RFC3986 = qr/[^a-zA-Z0-9\-\._~]/;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

use base 'Exporter';

our @EXPORT_OK = qw(
    quote
    url_decode
    url_decode_utf8
    url_encode
    url_encode_utf8
);


# ----------------------------------------------------------------------------------------------------------------------
# Public functions
# ----------------------------------------------------------------------------------------------------------------------

sub quote {

    my $string = $_[0];

    return undef unless defined $string;

    $string =~ s/\\/\\\\/g;
    $string =~ s/"/\\"/g;
    $string = '"' . $string . '"';

    return $string;

}

sub url_decode {

    my $string = shift;

    return undef unless defined $string;

    $string =~ s/%([0-9a-fA-F]{2})/chr( hex $1 )/eg;

    return $string;

}

sub url_decode_utf8 {

    my $string = shift;

    return undef unless defined $string;

    $string =~ s/%([0-9a-fA-F]{2})/chr( hex $1 )/eg;

    if ( ! utf8::decode( $string ) ) {
        complain "Cannot decode string";
    }

    return $string;

}

sub url_encode {

    my $string = shift;

    return undef unless defined $string;

    if ( utf8::is_utf8( $string ) ) {
        complain "Cannot URL-encode wide characters";
    }

    $string =~ s/($REGEX_RESERVED_CHARS_RFC3986)/$URL_ENCODE_MAP{$1}/eg;

    return $string;

}

sub url_encode_utf8 {

    my $string = shift;

    return undef unless defined $string;

    utf8::encode( $string );

    $string =~ s/($REGEX_RESERVED_CHARS_RFC3986)/$URL_ENCODE_MAP{$1}/eg;

    return $string;

}


1;

__END__

=head1 NAME

GX::HTTP::Util - HTTP-related utility functions

=head1 SYNOPSIS

    # Load the module
    use GX::HTTP::Util qw(
        quote
        url_decode
        url_decode_utf8
        url_encode
        url_encode_utf8
    );

=head1 DESCRIPTION

This module provides various utility functions.

=head1 FUNCTIONS

=head2 Public Functions

=head3 C<quote>

Quotes the given string.

    $quoted_string = quote( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( string )

=back

=item Returns:

=over 4

=item * C<$quoted_string> ( string )

=back

=back

See L<RFC 2616, section 2.2|http://tools.ietf.org/html/rfc2616#section-2.2>.

=head3 C<url_decode>

Decodes the given URL encoded string and returns the resulting string.

    $string = url_decode( $encoded_string );

=over 4

=item Arguments:

=over 4

=item * C<$encoded_string> ( byte string )

=back

=item Returns:

=over 4

=item * C<$string> ( byte string )

=back

=back

=head3 C<url_decode_utf8>

Decodes the given UTF-8/URL encoded string and returns the resulting character
string.

    $string = url_decode_utf8( $encoded_string );

=over 4

=item Arguments:

=over 4

=item * C<$encoded_string> ( byte string )

=back

=item Returns:

=over 4

=item * C<$string> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<url_encode>

URL-encodes the given byte string.

    $encoded_string = url_encode( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( byte string )

=back

=item Returns:

=over 4

=item * C<$encoded_string> ( byte string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<url_encode_utf8>

URL-encodes the given character string after encoding it as UTF-8.

    $encoded_string = url_encode_utf8( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( string )

=back

=item Returns:

=over 4

=item * C<$encoded_string> ( byte string )

=back

=back

=head1 SEE ALSO

=over 4

=item * L<RFC 2616|http://tools.ietf.org/html/rfc2616>

=item * L<RFC 3986|http://tools.ietf.org/html/rfc3986>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
