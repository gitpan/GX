# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Route/Static/Compiled.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Route::Static::Compiled;

use GX::Exception;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'routes' => (
    isa        => 'Hash',
    initialize => 1,
    accessor   => undef
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class  = shift;
    my @routes = @_;

    my $self = eval { $class->SUPER::new } || complain( $@ );

    for my $route ( @routes ) {
        
        if ( blessed $route && $route->isa( 'GX::Route::Static' ) ) {
            $self->_add_route( $route );
        }
        else {
            complain "Invalid argument";
        }

    }

    return $self;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub match {

    my $self    = shift;
    my $context = shift;

    my $request = $context->request or return undef;

    my $method = $request->method;
    my $scheme = $request->scheme;
    my $host   = $request->host;
    my $path   = $request->path;

    return undef unless defined $path;

    # Caution: Avoid auto-vivification!

    my @scheme_nodes;

    if ( defined $scheme ) {

        if ( exists $self->{'routes'}{$scheme} ) {
            push @scheme_nodes, $self->{'routes'}{$scheme};
        }

    }

    if ( exists $self->{'routes'}{''} ) {
        push @scheme_nodes, $self->{'routes'}{''};
    }

    for my $scheme_node ( @scheme_nodes ) {

        my @host_nodes;

        if ( defined $host ) {

            if ( exists $scheme_node->{$host} ) {
                push @host_nodes, $scheme_node->{$host};
            }

        }

        if ( exists $scheme_node->{''} ) {
            push @host_nodes, $scheme_node->{''};
        }

        for my $host_node ( @host_nodes ) {

            if ( my $path_node = $host_node->{$path} ) {

                if ( defined $method ) {

                    if ( my $action = $path_node->{$method} ) {
                        return GX::Route::Match->new( action => $action );
                    }

                }

                if ( my $action = $path_node->{''} ) {
                    return GX::Route::Match->new( action => $action );
                }

            }

        }

    }

    return undef;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _add_route {

    my $self  = shift;
    my $route = shift;

    no warnings 'uninitialized';

    $self->{'routes'}{$route->scheme}{$route->host}{$route->path}{$route->method} = $route->action;

    return;

}


1;

__END__

=head1 NAME

GX::Route::Static::Compiled - Static route container class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Route::Static::Compiled> class which extends
the L<GX::Class::Object> class. This class is intended for internal use only.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Route::Static::Compiled> object.

    $route = GX::Route::Static::Compiled->new( @routes );

=over 4

=item Arguments:

=over 4

=item * C<@routes> ( L<GX::Route::Static> objects )

=back

=item Returns:

=over 4

=item * C<$route> ( L<GX::Route::Static::Compiled> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<match>

Returns a L<GX::Route::Match> object if one of the aggregated static routes
matches, otherwise C<undef>.

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

=head1 SEE ALSO

=over 4

=item * L<GX::Route::Static>

=item * L<GX::Route::Match>

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
