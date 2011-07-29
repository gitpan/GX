# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Route/Match.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Route::Match;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'action' => (
    isa => 'Scalar'
);

has 'format' => (
    isa => 'Scalar'
);

has 'parameters' => (
    isa => 'Scalar'
);

build;


1;

__END__

=head1 NAME

GX::Route::Match - Route match class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Route::Match> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Route::Match> object.

    $match = GX::Route::Match->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<action> ( L<GX::Action> object | C<undef> )

The matched action.

=item * C<format> ( string | C<undef> )

The requested response format.

=item * C<parameters> ( L<GX::HTTP::Parameters> object | C<undef> )

A L<GX::HTTP::Parameters> object containing the captured parameters.

=back

=item Returns:

=over 4

=item * C<$match> ( L<GX::Route::Match> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<action>

Returns / sets the matched action.

    $action = $match->action;
    $action = $match->action( $action );

=over 4

=item Arguments:

=over 4

=item * C<$action> ( L<GX::Action> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$action> ( L<GX::Action> object )

=back

=back

=head3 C<format>

Returns / sets the requested response format.

    $format = $match->format;
    $format = $match->format( $format );

=over 4

=item Arguments:

=over 4

=item * C<$format> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$format> ( string | C<undef> )

=back

=back

=head3 C<parameters>

Returns / sets the captured parameters.

    $parameters = $match->parameters;
    $parameters = $match->parameters( $parameters );

=over 4

=item Arguments:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object | C<undef> )

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Route>

=item * L<GX::Router>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
