# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Constants.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Constants;

use strict;
use warnings;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

require Exporter;

our @ISA = qw( Exporter );

{

    my @export_regex = qw(
        REGEX_CLASS_NAME
        REGEX_FULLY_QUALIFIED_NAME
        REGEX_FUNCTION_NAME
        REGEX_IDENTIFIER
        REGEX_METHOD_NAME
        REGEX_MODULE_NAME
        REGEX_NAME
        REGEX_PACKAGE_NAME
        REGEX_SYMBOL_NAME
    );

    our @EXPORT_OK = (
        @export_regex
    );

    our %EXPORT_TAGS = (
        'regex' => \@export_regex
    );

}


# ----------------------------------------------------------------------------------------------------------------------
# Regular expressions
# ----------------------------------------------------------------------------------------------------------------------

use constant {
    REGEX_CLASS_NAME           => qr/^[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)*$/,
    REGEX_FULLY_QUALIFIED_NAME => qr/^[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)+$/,
    REGEX_FUNCTION_NAME        => qr/^[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)*$/,
    REGEX_IDENTIFIER           => qr/^[a-zA-Z_]\w*$/,
    REGEX_METHOD_NAME          => qr/^[a-zA-Z_]\w*$/,
    REGEX_MODULE_NAME          => qr/^[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)*$/,
    REGEX_NAME                 => qr/^[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)*$/,
    REGEX_PACKAGE_NAME         => qr/^[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)*$/,
    REGEX_SYMBOL_NAME          => qr/^[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)*$/
};


1;

__END__

=head1 NAME

GX::Meta::Constants - Various constants

=head1 SYNOPSIS

    # Load the module and import all REGEX_* constants
    use GX::Meta::Constants qw( :regex );

=head1 DESCRIPTION

This module provides various constants.

=head1 CONSTANTS

    REGEX_CLASS_NAME
    REGEX_FULLY_QUALIFIED_NAME
    REGEX_FUNCTION_NAME
    REGEX_IDENTIFIER
    REGEX_METHOD_NAME
    REGEX_MODULE_NAME
    REGEX_NAME
    REGEX_PACKAGE_NAME
    REGEX_SYMBOL_NAME

=head1 SEE ALSO

=over 4

=item * L<GX::Meta>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
