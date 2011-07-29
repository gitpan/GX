# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Serializer.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Serializer;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub serialize {

    # Abstract method

}

sub unserialize {

    # Abstract method

}


1;

__END__

=head1 NAME

GX::Serializer - Base class for serializers

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Serializer> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new serializer object.

    $serializer = $serializer_class->new;

=over 4

=item Returns:

=over 4

=item * C<$serializer> ( L<GX::Serializer> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<serialize>

Serializes the given data.

    $string = $serializer->serialize( $data );

=over 4

=item Arguments:

=over 4

=item * C<$data> ( scalar )

=back

=item Returns:

=over 4

=item * C<$string> ( byte string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<unserialize>

Unserializes the given serialized data.

    $data = $serializer->unserialize( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( byte string )

=back

=item Returns:

=over 4

=item * C<$data> ( scalar )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head1 SUBCLASSES

The following classes inherit directly from L<GX::Serializer>:

=over 4

=item * L<GX::Serializer::JSON>

=item * L<GX::Serializer::Storable>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
