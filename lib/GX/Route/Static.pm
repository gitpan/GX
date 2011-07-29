# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Route/Static.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Route::Static;

use GX::Exception;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Route';

has 'action' => (
    isa        => 'Object',
    required   => 1,
    constraint => sub { $_->isa( 'GX::Action' ) },
    accessor   => { type => 'get' }
);

has 'host' => (
    isa        => 'Scalar',
    initialize => 1,
    constraint => sub { defined && length },
    accessor   => { type => 'get' }
);

has 'is_reversible' => (
    isa        => 'Bool',
    initialize => 1,
    default    => 1,    
    accessor   => { type => 'get' }
);

has 'method' => (
    isa        => 'Scalar',
    initialize => 1,
    constraint => sub { defined && length },
    processor  => sub { $_ = uc },
    accessor   => { type => 'get' }
);

has 'path' => (
    isa        => 'String',
    required   => 1,
    constraint => sub { /^\// },
    accessor   => { type => 'get' }
);

has 'scheme' => (
    isa        => 'Scalar',
    initialize => 1,
    constraint => sub { defined && length },
    processor  => sub { $_ = lc },
    accessor   => { type => 'get' }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub construct_path {

    my $self = shift;

    if ( ! $self->{'is_reversible'} ) {
        complain "Route is not reversible";
    }

    return $self->{'path'};

}

sub construct_uri {

    my $self = shift;
    my %args = @_;

    if ( ! $self->{'is_reversible'} ) {
        complain "Route is not reversible";
    }

    if ( defined $self->{'scheme'} ) {
        $args{'scheme'} = $self->{'scheme'};
    }

    if ( defined $self->{'host'} ) {
        $args{'host'} = $self->{'host'};
    }

    $args{'path'} = $self->{'path'};

    my $uri = eval { $self->_construct_uri( %args ) };

    if ( $@ ) {
        complain $@;
    }

    return $uri;

}

sub match {

    my $self    = shift;
    my $context = shift;

    my $request = $context->request or return undef;

    no warnings 'uninitialized';

    if ( defined $self->{'method'} ) {
        return undef if $request->method ne $self->{'method'};
    }

    if ( defined $self->{'scheme'} ) {
        return undef if $request->scheme ne $self->{'scheme'};
    }

    if ( defined $self->{'host'} ) {
        return undef if $request->host ne $self->{'host'};
    }

    return undef if $request->path ne $self->{'path'};

    return GX::Route::Match->new( action => $self->{'action'} );

}


1;

__END__

=head1 NAME

GX::Route::Static - Static route class

=head1 SYNOPSIS

    # Load the class
    use GX::Route::Static;
    
    # Create a route object
    $route = GX::Route::Static->new(
        action => $application->action( 'Blog', 'search' ),
        method => 'POST',
        scheme => 'http',
        host   => 'myblog.com',
        path   => '/blog/search'
    );

=head1 DESCRIPTION

This module provides the L<GX::Route::Static> class which extends the
L<GX::Route> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Route::Static> object.

    $route = GX::Route::Static->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<action> ( L<GX::Action> object ) [ required ]

The associated action.

=item * C<host> ( string )

The hostname to bind the route to. If omitted, the route will match any
hostname.

=item * C<is_reversible> ( bool )

A boolean flag indicating whether the route is reversible or not. Defaults to
true.

=item * C<method> ( string )

The name of the HTTP method to bind the route to. If omitted, the route will
match any method.

=item * C<path> ( string ) [ required ]

The path to bind the route to. Trailing slashes are significant.

=item * C<scheme> ( string )

The URI scheme to bind the route to. If omitted, the route will match any
scheme.

=back

=item Returns:

=over 4

=item * C<$route> ( L<GX::Route::Static> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<action>

Returns the associated action.

    $action = $route->action;

=over 4

=item Returns:

=over 4

=item * C<$action> ( L<GX::Action> object )

=back

=back

=head3 C<construct_path>

Returns the path.

    $path = $route->construct_path;

=over 4

=item Returns:

=over 4

=item * C<$path> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<construct_uri>

Constructs an URI that would match the route.

    $uri = $route->construct_uri( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<fragment> ( string )

The fragment identifier of the URI.

=item * C<host> ( string )

The hostname to use as the authority component of the URI. Ignored if the
C<host> attribute is defined, required otherwise.

=item * C<port> ( integer )

The port number to append to the hostname.

=item * C<query> ( string )

The query component of the URI.

=item * C<scheme> ( string )

The scheme part of the URI. Ignored if the C<scheme> attribute is defined.
Defaults to "http".

=back

=item Returns:

=over 4

=item * C<$uri> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<is_reversible>

Returns true if the route is reversible, otherwise false.

    $result = $route->is_reversible;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<match>

Returns a L<GX::Route::Match> object if the route matches, otherwise C<undef>.

    $result = $route->match( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=item Returns:

=over 4

=item * C<$result> ( L<GX::Route::Match> object | C<undef> )

=back

=back

=head2 Internal Methods

=head3 C<host>

Internal method.

    $host = $route->host;

=over 4

=item Returns:

=over 4

=item * C<$host> ( string )

=back

=back

=head3 C<method>

Internal method.

    $method = $route->method;

=over 4

=item Returns:

=over 4

=item * C<$method> ( string )

=back

=back

=head3 C<path>

Internal method.

    $path = $route->path;

=over 4

=item Returns:

=over 4

=item * C<$path> ( string )

=back

=back

=head3 C<scheme>

Internal method.

    $scheme = $route->scheme;

=over 4

=item Returns:

=over 4

=item * C<$scheme> ( string )

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Route::Match>

=item * L<GX::Route::Static::Compiled>

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
