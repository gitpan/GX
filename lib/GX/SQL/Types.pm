# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/SQL/Types.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::SQL::Types;

use strict;
use warnings;

use Exporter ();

our @ISA = qw( Exporter );


# ----------------------------------------------------------------------------------------------------------------------
# Data types
# ----------------------------------------------------------------------------------------------------------------------

my @TYPES = qw(
    BIGINT
    BINARY
    BIT
    BLOB
    BOOLEAN
    CHAR
    DATE
    DATETIME
    DECIMAL
    DOUBLE
    FLOAT
    INTEGER
    LONGVARCHAR
    NUMERIC
    REAL
    SMALLINT
    TIME
    TIMESTAMP
    TINYINT
    VARCHAR
);


# ----------------------------------------------------------------------------------------------------------------------
# Exports
# ----------------------------------------------------------------------------------------------------------------------

our @EXPORT      = ();
our @EXPORT_OK   = @TYPES;
our %EXPORT_TAGS = ( all => [ @TYPES ] );


# ----------------------------------------------------------------------------------------------------------------------
# Data type constants
# ----------------------------------------------------------------------------------------------------------------------

{

    my $value = 1;

    for my $type ( @TYPES ) {
        eval "*$type = sub () { $value }";
        $value++;
    }

}


1;

__END__

=head1 NAME

GX::SQL::Types - SQL data type constants

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides constants respresenting the various SQL data types.

=head1 CONSTANTS

    BIGINT
    BINARY
    BIT
    BLOB
    BOOLEAN
    CHAR
    DATE
    DATETIME
    DECIMAL
    DOUBLE
    FLOAT
    INTEGER
    LONGVARCHAR
    NUMERIC
    REAL
    SMALLINT
    TIME
    TIMESTAMP
    TINYINT
    VARCHAR

Note: These constants are not identical to the type constants defined by L<DBI>.  

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut

