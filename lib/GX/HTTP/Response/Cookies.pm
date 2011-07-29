# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Response/Cookies.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Response::Cookies;

use GX::HTTP::Response::Cookie;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::HTTP::Cookies';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub create {

    my $self = shift;

    my $cookie = eval { $self->_cookie_class->new( @_ ) } or complain $@;

    $self->add( $cookie );

    return $cookie;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _cookie_class {

    return 'GX::HTTP::Response::Cookie';

}


1;

__END__

=head1 NAME

GX::HTTP::Response::Cookies - Container class for GX::HTTP::Response::Cookie objects

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Response::Cookies;
    
    # Create a new container object
    $cookies = GX::HTTP::Response::Cookies->new;
    
    # Add a cookie
    $cookies->add(
        GX::HTTP::Response::Cookie->new(
            name  => 'customer',
            value => 'Wile E. Coyote'
        )
    );
    
    # Same as above
    $cookies->create( name => 'customer', value => 'Wile E. Coyote' );
    
    # Retrieve a cookie
    $cookie = $cookies->get( 'customer' );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Response::Cookies> class which
extends the L<GX::HTTP::Cookies> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Response::Cookies> object.

    $cookies = GX::HTTP::Response::Cookies->new;

=over 4

=item Returns:

=over 4

=item * C<$cookies> ( L<GX::HTTP::Response::Cookies> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<add>

See L<GX::HTTP::Cookies|GX::HTTP::Cookies/add>. Only accepts
L<GX::HTTP::Response::Cookie> cookie objects.

=head3 C<all>

See L<GX::HTTP::Cookies|GX::HTTP::Cookies/all>.

=head3 C<clear>

See L<GX::HTTP::Cookies|GX::HTTP::Cookies/clear>.

=head3 C<count>

See L<GX::HTTP::Cookies|GX::HTTP::Cookies/count>.

=head3 C<create>

Creates a new L<GX::HTTP::Response::Cookie> cookie object with the specified
attributes and adds it to the container.

    $cookie = $cookies->create( %attributes );

=over 4

=item Arguments:

=over 4

=item * C<%attributes> ( named list )

See L<GX::HTTP::Response::Cookie>.

=back

=item Returns:

=over 4

=item * C<$cookie> ( L<GX::HTTP::Response::Cookie> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<get>

See L<GX::HTTP::Cookies|GX::HTTP::Cookies/get>.

=head3 C<names>

See L<GX::HTTP::Cookies|GX::HTTP::Cookies/names>.

=head3 C<remove>

See L<GX::HTTP::Cookies|GX::HTTP::Cookies/remove>.

=head3 C<set>

See L<GX::HTTP::Cookies|GX::HTTP::Cookies/set>. Only accepts
L<GX::HTTP::Response::Cookie> cookie objects.

=head1 SEE ALSO

=over 4

=item * L<GX::HTTP::Request::Cookie>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
