# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Package.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Package;

use strict;
use warnings;

use GX::Meta::Constants qw( REGEX_PACKAGE_NAME REGEX_SYMBOL_NAME );
use GX::Meta::Exception;
use GX::Meta::Util;


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { $_[0]->name },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;
    my %args  = ( @_ == 1 ) ? ( 'name' => $_[0] ) : @_;

    if ( ! defined $args{'name'} ) {
        complain "Missing argument (\"name\")";
    }

    if ( $args{'name'} !~ REGEX_PACKAGE_NAME ) {
        complain "Invalid argument (\"$args{'name'}\" is not a valid package name)";
    }

    return bless {
        'name'   => $args{'name'},
        'prefix' => $args{'name'} . '::'
    }, $class;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub assign_to_typeglob {

    my $self        = shift;
    my $symbol_name = shift;
    my $reference   = shift;

    if ( @_ ) {
        complain "Invalid number of arguments";
    }

    if ( ! defined $symbol_name ) {
        complain "Invalid argument (undefined symbol name)";
    }

    if ( $symbol_name !~ REGEX_SYMBOL_NAME ) {
        complain "Invalid argument (\"$symbol_name\" is not a valid symbol name)";
    }

    if ( ref $reference !~ /^(?:ARRAY|CODE|HASH|SCALAR)$/ ) {
        complain "Invalid argument (value must be a scalar, array, hash or code reference)";
    }

    {
        no strict 'refs';
        no warnings 'redefine';
        *{ $self->qualify( $symbol_name ) } = $reference;
    }

    return;

}

sub clear_typeglob_slot {

    my $self        = shift;
    my $symbol_name = shift;
    my $slot        = shift;

    if ( @_ ) {
        complain "Invalid number of arguments";
    }

    if ( ! defined $symbol_name ) {
        complain "Invalid argument (undefined symbol name)";
    }

    if ( $symbol_name !~ REGEX_SYMBOL_NAME ) {
        complain "Invalid argument (\"$symbol_name\" is not a valid symbol name)";
    }

    if ( ! defined $slot ) {
        complain "Invalid argument (undefined typeglob slot)";
    }

    if ( $slot !~ /^(?:SCALAR|ARRAY|HASH|CODE|IO)$/ ) {
        complain "Invalid argument (\"$slot\" is not a valid typeglob slot)";
    }

    return unless exists $self->symbol_table->{$symbol_name};

    {

        my $qualified_symbol_name = $self->qualify( $symbol_name );

        no strict 'refs';

        local *old_typeglob = *{$qualified_symbol_name};
        local *new_typeglob;

        for ( qw( SCALAR ARRAY HASH CODE IO ) ) {
            *new_typeglob = *old_typeglob{$_} if defined( *old_typeglob{$_} ) && $_ ne $slot;
        }

        *{$qualified_symbol_name} = *new_typeglob;

    }

    return 1;

}

sub name {

    return $_[0]->{'name'};

}

sub prefix {

    return $_[0]->{'prefix'};

}

sub qualify {

    return $_[0]->{'prefix'} . ( $_[1] // '' );

}

sub symbol_table {

    no strict 'refs';

    return \%{$_[0]->{'prefix'}};

}

sub wipe {

    my $self = shift;

    GX::Meta::Util::wipe_package( $self->{'name'} );

    return;

}


1;

__END__

=head1 NAME

GX::Meta::Package - Package metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Package> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Meta::Package> metaobject.

    $package = GX::Meta::Package->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<name> ( string ) [ required ]

The name of the package, for example "My::Package".

=back

=item Returns:

=over 4

=item * C<$package> ( L<GX::Meta::Package> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

Alternative syntax:

    $package = GX::Meta::Package->new( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

The name of the package, for example "My::Package".

=back

=item Returns:

=over 4

=item * C<$package> ( L<GX::Meta::Package> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head2 Public Methods

=head3 C<assign_to_typeglob>

Performs a typeglob assignment.

    $package->assign_to_typeglob( $symbol, $reference );

=over 4

=item Arguments:

=over 4

=item * C<$symbol> ( string )

A symbol name.

=item * C<$reference> ( reference )

A scalar, array, hash or code reference.

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<clear_typeglob_slot>

Clears the specified typeglob slot.

    $package->clear_typeglob_slot( $symbol, $slot );

=over 4

=item Arguments:

=over 4

=item * C<$symbol> ( string )

A symbol name.

=item * C<$slot> ( string )

Possible values: "SCALAR", "ARRAY", "HASH", "CODE" or "IO".

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<name>

Returns the name of the package, for example "My::Package".

    $name = $package->name;

=over 4

=item Returns:

=over 4

=item * C<$name> ( string )

=back

=back

=head3 C<prefix>

Returns the package prefix, for example "My::Package::".

    $prefix = $package->prefix;

=over 4

=item Returns:

=over 4

=item * C<$prefix> ( string )

=back

=back

=head3 C<qualify>

Prepends the package prefix to the given name and returns the result.

    $qualified_name = $package->qualify( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

=back

=item Returns:

=over 4

=item * C<$qualified_name> ( string )

=back

=back

=head3 C<symbol_table>

Returns a reference to the associated symbol table.

    $symbol_table = $package->symbol_table;

=over 4

=item Returns:

=over 4

=item * C<$symbol_table> ( C<HASH> reference )

=back

=back

=head3 C<wipe>

Undefines every symbol that lives in the associated symbol table. Danger, Will
Robinson!

    $package->wipe;

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
