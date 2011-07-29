# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Session/Store.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Session::Store;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'serializer' => (
    isa         => 'Object',
    constraint  => sub { $_->isa( 'GX::Serializer' ) },
    initialize  => 1,
    initializer => '_initialize_serializer',
    accessor    => { type => 'get' }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub delete {

    # Abstract method

}

sub load {

    # Abstract method

}

sub save {

    # Abstract method

}

sub update {

    # Abstract method

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _initialize_serializer {

    require GX::Serializer::Storable;

    return GX::Serializer::Storable->new;

}


1;

__END__

=head1 NAME

GX::Session::Store - Base class for session stores

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Session::Store> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new session store object.

    $store = $store_class->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<serializer> ( L<GX::Serializer> object )

The serializer to use. Defaults to a L<GX::Serializer::Storable> instance.

=back

=item Returns:

=over 4

=item * C<$store> ( L<GX::Session::Store> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<delete>

Deletes the specified session.

    $store->delete( $session_id );

=over 4

=item Arguments:

=over 4

=item * C<$session_id> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<load>

Loads the specified session.

    ( $session_info, $session_data ) = $store->load( $session_id );

=over 4

=item Arguments:

=over 4

=item * C<$session_id> ( string )

=back

=item Returns:

=over 4

=item * C<$session_info> ( C<HASH> reference )

=item * C<$session_data> ( C<HASH> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<save>

Saves the given session.

    $store->save( $session_id, $session_info, $session_data );

=over 4

=item Arguments:

=over 4

=item * C<$session_id> ( string )

=item * C<$session_info> ( C<HASH> reference )

=item * C<$session_data> ( C<HASH> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<serializer>

Returns the serializer.

    $serializer = $store->serializer;

=over 4

=item Returns:

=over 4

=item * C<$serializer> ( L<GX::Serializer> object )

=back

=back

=head3 C<update>

Updates the specified session.

    $store->update( $session_id, $session_info, $session_data );

=over 4

=item Arguments:

=over 4

=item * C<$session_id> ( string )

=item * C<$session_info> ( C<HASH> reference )

=item * C<$session_data> ( C<HASH> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head1 SUBCLASSES

The following classes inherit directly from L<GX::Session::Store>:

=over 4

=item * L<GX::Session::Store::Cache>

=item * L<GX::Session::Store::Database>

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Session>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
