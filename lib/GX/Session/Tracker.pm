# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Session/Tracker.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Session::Tracker;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub get_id {

    # Abstract method

}

sub set_id {

    # Abstract method

}

sub unset_id {

    # Abstract method

}


1;

__END__

=head1 NAME

GX::Session::Tracker - Base class for session trackers

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Session::Tracker> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new session tracker object.

    $tracker = $tracker_class->new;

=over 4

=item Returns:

=over 4

=item * C<$tracker> ( L<GX::Session::Tracker> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<get_id>

Returns the current session identifier.

    $session_id = $tracker->get_id( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=item Returns:

=over 4

=item * C<$session_id> ( string | C<undef> )

=back

=back

=head3 C<set_id>

Sets the current session identifier.

    $tracker->set_id( $context, $session_id );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=item * C<$session_id> ( string )

=back

=back

=head3 C<unset_id>

Unsets the current session identifier.

    $tracker->unset_id( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=back

=head1 SUBCLASSES

The following classes inherit directly from L<GX::Session::Tracker>:

=over 4

=item * L<GX::Session::Tracker::Cookie>

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
