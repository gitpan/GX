# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/SQL/Builder/Pg.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::SQL::Builder::Pg;

use GX::Exception;

use DBD::Pg ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class ( extends => 'GX::SQL::Builder' );

build;


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _build_limit_clause {

    my ( $self, $limit, $offset, $sql, @bind ) = @_;

    if ( defined $limit ) {
        $limit =~ /^\d+$/ or throw "Invalid argument (\"limit\" must be a number)";
    }
    else {
        return;
    }

    if ( defined $offset ) {
        $offset =~ /^\d+$/ or throw "Invalid argument (\"offset\" must be a number)";
    }
    else {
        $offset = 0;
    }

    # Postgres limit syntax:
    # "ORDER BY $order LIMIT $limit"
    # "ORDER BY $order LIMIT $limit OFFSET $offset"

    $$sql .= ' LIMIT '  . $limit;
    $$sql .= ' OFFSET ' . $offset if $offset;

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Attribute initializers
# ----------------------------------------------------------------------------------------------------------------------

sub _initialize_bind_type_map {

    return {

        %{ $_[0]->SUPER::_initialize_bind_type_map },

        GX::SQL::Types::BINARY => { pg_type => DBD::Pg::PG_BYTEA }
        
    };

}


1;

__END__

=head1 NAME

GX::SQL::Builder::Pg - PostgreSQL-specific SQL builder class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

See L<GX::SQL::Builder>.

=head1 METHODS

See L<GX::SQL::Builder>.

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
