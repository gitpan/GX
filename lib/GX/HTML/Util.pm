# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTML/Util.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTML::Util;

use strict;
use warnings;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

use base 'Exporter';

our @EXPORT_OK = qw( escape_html );


# ----------------------------------------------------------------------------------------------------------------------
# Public functions
# ----------------------------------------------------------------------------------------------------------------------

sub escape_html {

    my $string = shift;

    if ( defined $string ) {
        $string =~ s/&/&amp;/g;
        $string =~ s/</&lt;/g;
        $string =~ s/>/&gt;/g;
        $string =~ s/"/&quot;/g;
        $string =~ s/'/&apos;/g;
    }

    return $string;

}


1;

__END__

=head1 NAME

GX::HTML::Util - Utility functions

=head1 SYNOPSIS

    use GX::HTML::Util qw( escape_html );

=head1 DESCRIPTION

This module provides utility functions for dealing with (X)HTML.

=head1 FUNCTIONS

=head2 Public Functions

=head3 C<escape_html>

Replaces all special (X)HTML characters in the given string with their entity
representation.

    $escaped_string = escape_html( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( string )

=back

=item Returns:

=over 4

=item * C<$escaped_string> ( string )

=back

=back

The following characters are replaced:

    & => &amp;
    < => &lt;
    > => &gt;
    " => &quot;
    ' => &apos;

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
