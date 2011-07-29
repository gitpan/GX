# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Router.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Router;

use GX::Exception;
use GX::Meta::Constants qw( REGEX_CLASS_NAME );
use GX::Route::Dynamic;
use GX::Route::Static;
use GX::Route::Static::Compiled;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class ( extends => 'GX::Component::Singleton' );

has 'compiled_routes' => (
    isa         => 'Scalar',
    initialize  => 0,
    initializer => '_compile_routes',
    accessors   => {
        '_get_compiled_routes'   => { type => 'get' },
        '_set_compiled_routes'   => { type => 'set' },
        '_clear_compiled_routes' => { type => 'clear' }
    }
);

has 'default_action' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_default_action' => { type => 'get' },
        '_set_default_action' => { type => 'set' }
    }
);

has 'reversible_routes' => (
    isa        => 'Hash',
    initialize => 1,
    accessors  => {
        '_get_reversible_routes' => { type => 'get_reference' }
    }
);

has 'routes' => (
    isa        => 'Array',
    initialize => 1,
    accessors  => {
        '_get_routes' => { type => 'get_reference' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add_route {

    my $self  = shift->instance;
    my $route = shift;

    if ( ! defined $route ) {
        complain "Missing argument";
    }

    if ( ! blessed $route || ! $route->isa( 'GX::Route' ) ) {
        complain "Invalid argument";
    }

    $self->_add_route( $route );

    $self->_clear_compiled_routes;

    return;

}

sub default_action {

    return $_[0]->instance->_get_default_action;

}

sub match {

    my $self    = shift->instance;
    my $context = shift;

    for my $route ( @{$self->_get_compiled_routes} ) {
        return $route->match( $context ) // next;
    }

    return undef;

}

sub path_for_action {

    my $self = shift->instance;
    my %args = ( @_ == 1 ) ? ( 'action' => $_[0] ) : @_;

    if ( ! defined $args{'action'} ) {
        complain "Missing argument (\"action\")";
    }

    if ( ! blessed $args{'action'} || ! $args{'action'}->isa( 'GX::Action' ) ) {
        complain "Invalid argument (\"action\" must be a GX::Action object)";
    }

    if ( defined $args{'parameters'} ) {

        if ( ref $args{'parameters'} ne 'HASH' ) {
            complain "Invalid argument (\"parameters\" must be a hash reference)";
        }

    }

    my $route = $self->_reversible_route_for_action( $args{'action'} );

    if ( ! $route ) {
        return undef;
    }

    my $path = eval {
        $route->construct_path( $args{'parameters'} ? %{$args{'parameters'}} : () );
    };

    if ( $@ ) {
        complain $@;
    }

    return $path;

}

sub remove_route {

    my $self  = shift->instance;
    my $route = shift;

    if ( ! defined $route ) {
        complain "Missing argument";
    }

    if ( ! blessed $route || ! $route->isa( 'GX::Route' ) ) {
        complain "Invalid argument";
    }

    $self->_remove_route( $route ) or return;

    $self->_clear_compiled_routes;

    return 1;

}

sub routes {

    return @{$_[0]->instance->_get_routes};

}

sub uri_for_action {

    my $self = shift->instance;
    my %args = ( @_ == 1 ) ? ( 'action' => $_[0] ) : @_;

    my $action = delete $args{'action'};

    if ( ! defined $action ) {
        complain "Missing argument (\"action\")";
    }

    if ( ! blessed $action || ! $action->isa( 'GX::Action' ) ) {
        complain "Invalid argument (\"action\" must be a GX::Action object)";
    }

    my $route = $self->_reversible_route_for_action( $action );

    if ( ! $route ) {
        return undef;
    }

    my $uri = eval {
        $route->construct_uri( %args );
    };

    if ( $@ ) {
        complain $@;
    }

    return $uri;

}


# ----------------------------------------------------------------------------------------------------------------------
# Handlers
# ----------------------------------------------------------------------------------------------------------------------

sub resolve :Handler( ResolveActions ) {

    my $self    = shift;
    my $context = shift;

    my $action;

    if ( my $match = $self->match( $context ) ) {

        $action = $match->action;

        if ( my $parameters = $match->parameters ) {
            $context->request->path_parameters( $parameters );
        }

        if ( defined( my $format = $match->format ) ) {
            $context->request->format( $format );
        }

    }
    else {
        $action = $self->_get_default_action;
    }

    if ( $action ) {

        if ( my $action_queue = $context->action_queue ) {
            $action_queue->add( $action );
        }

    }
    else {
        $context->send_response( status => 404 );
    }

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _add_route {

    my $self  = shift;
    my $route = shift;

    push @{$self->_get_routes}, $route;

    if ( $route->is_reversible ) {
        push @{$self->_get_reversible_routes->{$route->action->id}}, $route;
    }

    return;

}

sub _compile_routes {

    my $self = shift;

    my @compiled_routes;
    my @static_routes;

    for my $route ( @{$self->_get_routes} ) {

        if ( $route->isa( 'GX::Route::Static' ) ) {
            push @static_routes, $route;
        }
        else {
            push @compiled_routes, $route;
        }

    }

    if ( @static_routes ) {
        unshift @compiled_routes, GX::Route::Static::Compiled->new( reverse @static_routes );
    }

    return \@compiled_routes;

}

sub _create_route {

    my $self = shift;
    my %args = @_;

    my $action;

    if ( exists $args{'action'} ) {

        if ( exists $args{'controller'} ) {

            if ( $self->application ) {
                $action = $self->application->action( delete $args{'controller'}, delete $args{'action'} );
            }

        }
        else {

            if ( ref $args{'action'} eq 'ARRAY' ) {

                if ( $self->application ) {
                    $action = $self->application->action( @{ delete $args{'action'} } );
                }

            }
            elsif ( blessed $args{'action'} && $args{'action'}->isa( 'GX::Action' ) ) {
                $action = delete $args{'action'};
            }

        }

    }

    if ( ! $action ) {
        complain "Unknown action";
    }

    my $route_class;

    if ( exists $args{'class'} ) {

        if ( ! defined $args{'class'} || $args{'class'} !~ REGEX_CLASS_NAME ) {
            complain "Invalid argument (\"class\")";
        }

        $route_class = delete $args{'class'};

    }
    else {

        if (
            ( defined $args{'path'} && $args{'path'} =~ /[*{}]+/ ) ||
            ( defined $args{'host'} && $args{'host'} =~ /[*{}]+/ ) ||
            exists $args{'methods'} ||
            exists $args{'schemes'}
        ) {
            $route_class = 'GX::Route::Dynamic';
        }
        else {
            $route_class = 'GX::Route::Static';
        }

    }

    my $route = eval {
        $route_class->new( %args, action => $action );
    };

    if ( $@ ) {
        complain $@;
    }

    return $route;

}

sub _deploy {

    my $self = shift;

    $self->_deploy_default_action;
    $self->_deploy_routes;

    return;

}

sub _deploy_default_action {

    my $self = shift;

    if ( my $action = $self->_get_config->{'default_action'} ) {

        if ( ref $action eq 'ARRAY' ) {

            $action = $self->application->action( @$action );

            if ( ! $action ) {
                throw "Unknown default action";
            }

        }

        $self->_set_default_action( $action );

    }

    return;

}

sub _deploy_routes {

    my $self = shift;

    if ( $self->_get_config->{'routes'} ) {

        for my $route ( @{$self->_get_config->{'routes'}} ) {

            if ( ref $route eq 'HASH' ) {

                $route = eval {
                    $self->_create_route( %$route );
                };

                if ( $@ ) {
                    GX::Exception->throw(
                        message      => "Cannot create route",
                        subexception => $@
                    );
                }

                $self->_add_route( $route );

            }
            elsif ( blessed $route && $route->isa( 'GX::Route' ) ) {
                $self->_add_route( $route );
            }
            else {
                throw "Invalid route definition";
            }

        }

    }

    for my $controller ( $self->application->controllers ) {

        for my $route ( $controller->routes ) {
            $self->_add_route( $route );
        }

    }

    $self->_clear_compiled_routes;

    return;

}

sub _remove_route {

    my $self  = shift;
    my $route = shift;

    my $routes       = $self->_get_routes;
    my $routes_count = @$routes;

    @$routes = grep { $_ != $route } @$routes;

    $routes_count - @$routes or return;

    if ( $route->is_reversible ) {

        my $reversible_routes = $self->_get_reversible_routes->{$route->action->id};

        @$reversible_routes = grep { $_ != $route } @$reversible_routes;

        if ( ! @$reversible_routes ) {
            delete $self->_get_reversible_routes->{$route->action->id};
        }

    }

    return 1;

}

sub _reversible_route_for_action {

    my $self   = shift;
    my $action = shift;

    return ( $self->_get_reversible_routes->{$action->id} || return undef )->[0];

}

sub _setup_config {

    my $self = shift;
    my $args = shift;

    my $config = $self->_get_config;

    if ( exists $args->{'default_action'} ) {

        my $action = delete $args->{'default_action'};

        if ( defined $action ) {

            if ( ref $action eq 'ARRAY' || ( blessed $action && $action->isa( 'GX::Action' ) ) ) {
                $config->{'default_action'} = $action;
            }
            else {
                throw "Invalid option (\"default_action\" must be an array reference or a GX::Action object)";
            }

        }

    }

    if ( exists $args->{'routes'} ) {

        my $routes = delete $args->{'routes'};

        if ( defined $routes ) {

            if ( ref $routes eq 'ARRAY' ) {
                $config->{'routes'} = $routes;
            }
            else {
                throw "Invalid option (\"routes\" must be an array reference)";
            }

        }

    }

    return;

}

sub _start {

    my $self = shift;

    $self->SUPER::_start;

    $self->_set_compiled_routes( $self->_compile_routes );

    return;

}

sub _validate_class_name {

    return $_[1] =~ /^(?:[_a-zA-Z]\w*::)+?Router$/;

}


1;

__END__

=head1 NAME

GX::Router - Router component

=head1 SYNOPSIS

    package MyApp::Router;
    
    use GX::Router;
    
    __PACKAGE__->setup(
    
        routes => [
            {
                controller => 'Blog',
                action     => 'show_latest',
                path       => '/blog/latest'
            },
            {
                controller => 'Blog',
                action     => 'show_post',
                path       => '/blog/posts/{id}'
            }
        ],
    
        default_action => [ 'Error', 'page_not_found' ]
    
    );
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Router> class which extends the
L<GX::Component::Singleton> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the router component instance.

    $router = $router_class->new;

=over 4

=item Returns:

=over 4

=item * C<$router> ( L<GX::Router> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

All public methods can be called both as instance and class methods.

=head3 C<add_route>

Registers the given route.

    $router->add_route( $route );

=over 4

=item Arguments:

=over 4

=item * C<$route> ( L<GX::Route> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<default_action>

Returns the default action.

    $action = $router->default_action;

=over 4

=item Returns:

=over 4

=item * C<$action> ( L<GX::Action> object | C<undef> )

=back

=back

=head3 C<match>

Returns a L<GX::Route::Match> object if one of the registered routes matches
the request, otherwise C<undef>.

    $result = $router->match( $context );

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

=head3 C<path_for_action>

Returns the path portion of an URI that would be routed to the specified
action.

    $path = $router->path_for_action( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<action> ( L<GX::Action> object ) [ required ]

The action for which to construct the path.

=item * C<parameters> ( C<HASH> reference )

A reference to a hash with values for the dynamic parts of the path.

=back

=item Returns:

=over 4

=item * C<$path> ( string | C<undef> )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

If no reversible routes are associated with the given action, C<undef> is
returned. If the path cannot be constructed (for example if required path
parameters are missing), a L<GX::Exception> will be thrown.

Alternative syntax:

    $path = $router->path_for_action( $action );

=over 4

=item Arguments:

=over 4

=item * C<$action> ( L<GX::Action> object )

=back

=item Returns:

=over 4

=item * C<$path> ( string | C<undef> )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<remove_route>

Unregisters the specified route.

    $router->remove_route( $route );

=over 4

=item Arguments:

=over 4

=item * C<$route> ( L<GX::Route> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<routes>

Returns the registered routes.

    @routes = $router->routes;

=over 4

=item Returns:

=over 4

=item * C<@routes> ( L<GX::Route> objects )

=back

=back

=head3 C<setup>

Sets up the component.

    $router->setup( %options );

=over 4

=item Options:

=over 4

=item * C<default_action> ( L<GX::Action> object | C<ARRAY> reference )

A default action.

=item * C<routes> ( C<ARRAY> reference )

A reference to an array with route definitions. Routes defined here have the
highest priority.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<uri_for_action>

Constructs an URI that would be routed to the specified action.

    $uri = $router->uri_for_action( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<action> ( L<GX::Action> object ) [ required ]

The action for which to construct the URI.

=back

=item Additional, route-dependent arguments:

=over 4

=item * C<fragment> ( string )

The fragment identifier of the URI.

=item * C<host> ( string )

The hostname to use as the authority component of the URI.

=item * C<parameters> ( C<HASH> reference )

A reference to a hash with values for the dynamic parts of the URI.

=item * C<path> ( string )

The path portion of the URI.

=item * C<port> ( integer )

The port number to append to the hostname.

=item * C<query> ( string )

The query component of the URI.

=item * C<scheme> ( string )

The scheme part of the URI. Defaults to "http".

=back

=item Returns:

=over 4

=item * C<$uri> ( string | C<undef> )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

If no reversible routes are associated with the specified action, C<undef> is
returned. If the URI cannot be constructed (for example if required path
parameters are missing), a L<GX::Exception> will be thrown.

Alternative syntax:

    $uri = $router->uri_for_action( $action );

=over 4

=item Arguments:

=over 4

=item * C<$action> ( L<GX::Action> object )

=back

=item Returns:

=over 4

=item * C<$uri> ( string | C<undef> )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Internal Methods

=head3 C<resolve>

Handler.

    $router->resolve( $context );


=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Route>

=item * L<GX::Route::Match>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
