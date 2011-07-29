# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Session/ID/Generator.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Session::ID::Generator;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub generate_id {

    # Abstract method

}

sub validate_id {

    # Abstract method

}


1;

__END__

=head1 NAME

GX::Session::ID::Generator - Base class for session ID generators

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Session::ID::Generator> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new session generator object.

    $generator = $generator_class->new;

=over 4

=item Returns:

=over 4

=item * C<$generator> ( L<GX::Session::ID::Generator> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<generate_id>

Generates a random session ID string.

    $session_id = $generator->generate_id;

=over 4

=item Returns:

=over 4

=item * C<$session_id> ( string )

=back

=back

=head3 C<validate_id>

Returns true if the given string is a valid session ID, otherwise false.

    $result = $generator->validate_id( $session_id );

=over 4

=item Arguments:

=over 4

=item * C<$session_id> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head1 SUBCLASSES

The following classes inherit directly from L<GX::Session::ID::Generator>:

=over 4

=item * L<GX::Session::ID::Generator::MD5>

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
