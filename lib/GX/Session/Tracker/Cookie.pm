# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Session/Tracker/Cookie.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Session::Tracker::Cookie;

use GX::HTTP::Response::Cookie;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Session::Tracker';

has 'cookie_attributes' => (
    isa        => 'Hash',
    initialize => 1,
    accessors  => {
        'cookie_attributes'      => { type => 'get_list' },
        '_get_cookie_attributes' => { type => 'get_reference' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub get_id {

    my $self    = shift;
    my $context = shift;

    my $cookie = $context->request->cookies->get( $self->_get_cookie_attributes->{'name'} );

    return $cookie ? $cookie->value : undef;

}

sub set_id {

    my $self    = shift;
    my $context = shift;
    my $id      = shift;

    my $cookie = $self->_create_session_cookie( value => $id );

    $context->response->cookies->set( $cookie );

    return 1;

}

sub unset_id {

    my $self    = shift;
    my $context = shift;

    my $cookie = $self->_create_session_cookie(
        'value'   => '',
        'max_age' => 0
    );

    $context->response->cookies->set( $cookie );

    return 1;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _create_session_cookie {

    my $self = shift;

    return GX::HTTP::Response::Cookie->new( $self->cookie_attributes, @_ );

}

sub _default_cookie_attributes {

    return {
        'name'      => 'SESSION_ID',
        'path'      => '/',
        'secure'    => 0,
        'http_only' => 1
    };

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub __finalize {

    my $self = shift;

    my $cookie_attributes = $self->_get_cookie_attributes;

    %$cookie_attributes = ( %{$self->_default_cookie_attributes}, %$cookie_attributes );

    return;

}


1;

__END__

=head1 NAME

GX::Session::Tracker::Cookie - Cookie-based session tracker

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Session::Tracker::Cookie> class which extends
the L<GX::Session::Tracker> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Session::Tracker::Cookie> object.

    $tracker = GX::Session::Tracker::Cookie->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<cookie_attributes> ( C<HASH> reference )

Session cookie attributes. Defaults to:

    $cookie_attributes = {
        name      => 'SESSION_ID',
        path      => '/',
        secure    => 0,
        http_only => 1
    };

See L<GX::HTTP::Response::Cookie> for a complete list of possible attributes.

=back

=item Returns:

=over 4

=item * C<$tracker> ( L<GX::Session::Tracker::Cookie> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<cookie_attributes>

Returns the session cookie attributes as a list of key / value pairs.

    %cookie_attributes = $tracker->cookie_attributes;

=over 4

=item Returns:

=over 4

=item * C<%cookie_attributes> ( named list )

=back

=back

=head3 C<get_id>

See L<GX::Session::Tracker|GX::Session::Tracker/"get_id">.

=head3 C<set_id>

See L<GX::Session::Tracker|GX::Session::Tracker/"set_id">.

=head3 C<unset_id>

See L<GX::Session::Tracker|GX::Session::Tracker/"unset_id">.

=head1 SEE ALSO

=over 4

=item * L<GX::Session>

=item * L<GX::HTTP::Response::Cookie>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
