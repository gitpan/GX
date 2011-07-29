# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/MIME/Util.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::MIME::Util;

use strict;
use warnings;


# ----------------------------------------------------------------------------------------------------------------------
# Data
# ----------------------------------------------------------------------------------------------------------------------

my %FORMAT_TO_MIME_TYPE_MAP = (
    'bin'   => 'application/octet-stream',  # n/a
    'css'   => 'text/css',                  # RFC 2318
    'csv'   => 'text/csv',                  # RFC 4180
    'gif'   => 'image/gif',                 # RFC 2045, RFC 2046
    'html'  => 'text/html',                 # RFC 2854
    'ico'   => 'image/vnd.microsoft.icon',  # n/a
    'jpeg'  => 'image/jpeg',                # RFC 2045, RFC 2046
    'js'    => 'text/javascript',           # RFC 4329
    'json'  => 'application/json',          # RFC 4627
    'pdf'   => 'application/pdf',           # RFC 3778
    'png'   => 'image/png',                 # RFC 2083
    'soap'  => 'application/soap+xml',      # RFC 3902
    'svg'   => 'image/svg+xml',             # SVG Tiny 1.2 Specification Appendix M
    'tiff'  => 'image/tiff',                # RFC 3302
    'txt'   => 'text/plain',                # RFC 2046
    'xhtml' => 'application/xhtml+xml',     # RFC 3236
    'xml'   => 'text/xml'                   # RFC 3023
);


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant REGEX_MIME_TYPE => qr/^[\w\+\-\.]+\/[\w\+\-\.]+$/;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

use base 'Exporter';

our @EXPORT_OK = qw(
    format_to_mime_type
);


# ----------------------------------------------------------------------------------------------------------------------
# Public functions
# ----------------------------------------------------------------------------------------------------------------------

sub format_to_mime_type {

    return $FORMAT_TO_MIME_TYPE_MAP{$_[0]};

}


1;

__END__

=head1 NAME

GX::MIME::Util - MIME-related utility functions

=head1 SYNOPSIS

    # Load the module
    use GX::MIME::Util qw(
        format_to_mime_type
    );

=head1 DESCRIPTION

This module provides various utility functions and constants.

=head1 FUNCTIONS

=head2 Public Functions

=head3 C<format_to_mime_type>

Returns the internet media type (MIME type) for the given format identifier.

    $mime_type = format_to_mime_type( $format );

=over 4

=item Arguments:

=over 4

=item * C<$format> ( string )

=back

=item Returns:

=over 4

=item * C<$mime_type> ( string | C<undef> )

=back

=back

=head1 CONSTANTS

    REGEX_MIME_TYPE

=head1 SEE ALSO

=over 4

=item * L<RFC 2045|http://tools.ietf.org/html/rfc2045>

=item * L<RFC 2046|http://tools.ietf.org/html/rfc2046>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
