# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Constants.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Constants;

use strict;
use warnings;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

require Exporter;

our @ISA = qw( Exporter );

our @EXPORT_OK = qw(
    CRLF
    CRLFCRLF
    CRLFSP
    REGEX_CRLF
);


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant {
    CRLF       => "\015\012",
    CRLFCRLF   => "\015\012\015\012",
    CRLFSP     => "\015\012\040",
    REGEX_CRLF => qr/\015\012/
};


1;

__END__

=head1 NAME

GX::HTTP::Constants - HTTP-related constants

=head1 SYNOPSIS

    # Load the module
    use GX::HTTP::Constants qw(
        CRLF
        CRLFCRLF
        CRLFSP
        REGEX_CRLF
    );

=head1 DESCRIPTION

This module provides various constants.

=head1 CONSTANTS

    CRLF       => "\015\012"
    CRLFCRLF   => "\015\012\015\012"
    CRLFSP     => "\015\012\040"
    REGEX_CRLF => qr/\015\012/

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
