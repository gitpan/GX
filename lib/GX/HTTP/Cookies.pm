# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Cookies.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Cookies;

use GX::Exception;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'cookies' => (
    isa       => 'Array',
    accessors => {
        '_cookies' => { type => 'get_reference' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    '@{}'      => sub { $_[0]->_cookies },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    my $self = shift;

    for ( @_ ) {

        if ( ! blessed $_ || ! $_->isa( $self->_cookie_class ) ) {
            complain "Invalid argument";
        }

    }

    push @{$self->_cookies}, @_;

    return;

}

sub all {

    return @{$_[0]->_cookies};

}

sub count {

    return scalar @{$_[0]->_cookies};

}

sub get {

    my $self = shift;

    return if ! @_;

    my $name = shift;

    if ( wantarray ) {

        if ( defined $name ) {
            return grep { defined $_->name && $_->name eq $name } @{$self->_cookies};
        }
        else {
            return grep { ! defined $_->name } @{$self->_cookies};
        }

    }
    else {

        if ( defined $name ) {
            defined $_->name && $_->name eq $name && return $_ for @{$self->_cookies};
        }
        else {
            defined $_->name or return $_ for @{$self->_cookies};
        }

        return undef;

    }

}

sub names {

    my $self = shift;

    my @names;

    my %seen;

    for my $cookie ( @{$self->_cookies} ) {
        my $name = $cookie->name;
        next if ! defined $name || $seen{$name};
        push @names, $name;
        $seen{$name} = 1;
    }

    return @names;

}

sub remove {

    my $self = shift;

    my $cookies = $self->_cookies;

    my $count = @$cookies;

    for my $name ( @_ ) {

        if ( defined $name ) {
            @$cookies = grep { ! defined $_->name || $_->name ne $name } @$cookies;
        }
        else {
            @$cookies = grep { defined $_->name } @$cookies;
        }

    }

    return $count - @$cookies;

}

sub set {

    my $self = shift;

    for ( @_ ) {

        if ( ! blessed $_ || ! $_->isa( $self->_cookie_class ) ) {
            complain "Invalid argument";
        }

    }

    $self->remove( map { $_->name } @_ );

    push @{$self->_cookies}, @_;

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _cookie_class {

    return 'GX::HTTP::Cookie';

}


1;

__END__

=head1 NAME

GX::HTTP::Cookies - Container class for GX::HTTP::Cookie objects

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Cookies;
    
    # Create a new container object
    $cookies = GX::HTTP::Cookies->new;
    
    # Add a cookie
    $cookies->add(
        GX::HTTP::Request::Cookie->new(
            name  => 'customer',
            value => 'Wile E. Coyote'
        )
    );
    
    # Retrieve a cookie
    $cookie = $cookies->get( 'customer' );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Cookies> class which extends
the L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Cookies> object.

    $cookies = GX::HTTP::Cookies->new;

=over 4

=item Returns:

=over 4

=item * C<$cookies> ( L<GX::HTTP::Cookies> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Also see L<GX::HTTP::Request::Cookies> and L<GX::HTTP::Response::Cookies>.

=head2 Public Methods

=head3 C<add>

Adds the given cookie objects to the container.

    $cookies->add( @cookies );

=over 4

=item Arguments:

=over 4

=item * C<@cookies> ( L<GX::HTTP::Cookie> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<all>

Returns all cookie objects in the order they were added.

    @cookies = $cookies->all;

=over 4

=item Returns:

=over 4

=item * C<@cookies> ( L<GX::HTTP::Cookie> objects )

=back

=back

=head3 C<clear>

Empties the container.

    $cookies->clear;

=head3 C<count>

Returns the number of cookies currently in the container.

    $count = $cookies->count;

=over 4

=item Returns:

=over 4

=item * C<$count> ( integer )

=back

=back

=head3 C<get>

Returns all cookie objects with the specified name in the order they were
added. 

    @cookies = $cookies->get( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

=back

=item Returns:

=over 4

=item * C<@cookies> ( L<GX::HTTP::Cookie> objects )

=back

=back

In scalar context, the first of those cookies is returned.

    $cookie = $cookies->get( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

=back

=item Returns:

=over 4

=item * C<$cookie> ( L<GX::HTTP::Cookie> object | C<undef> )

=back

=back

=head3 C<names>

Returns a list with the names of the cookies.

    @names = $cookies->names;

=over 4

=item Returns:

=over 4

=item * C<@names> ( strings )

=back

=back

=head3 C<remove>

Removes all cookies with the specified name(s) from the container.

    $result = $cookies->remove( @names );

=over 4

=item Arguments:

=over 4

=item * C<@names> ( strings )

=back

=item Returns:

=over 4

=item * C<$result> ( integer )

The number of cookies that were removed.

=back

=back

=head3 C<set>

Adds the given cookie objects to the container, replacing any previously
added cookies with the same name attribute.

    $cookies->set( @cookies );

=over 4

=item Arguments:

=over 4

=item * C<@cookies> ( L<GX::HTTP::Cookie> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head1 SUBCLASSES

The following classes inherit directly from L<GX::HTTP::Cookies>:

=over 4

=item * L<GX::HTTP::Request::Cookies>

=item * L<GX::HTTP::Response::Cookies>

=back

=head1 SEE ALSO

=over 4

=item * L<GX::HTTP::Cookie>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
