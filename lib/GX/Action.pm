# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Action.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Action;

use GX::Exception;
use GX::Meta::Constants qw( REGEX_METHOD_NAME );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Callback';

has 'controller' => (
    isa          => 'Object',
    preprocessor => sub { try { $_ = $_->instance } },
    constraint   => sub { $_->isa( 'GX::Controller' ) },
    required     => 1,
    weaken       => 1,
    accessor     => { type => 'get' }
);

has 'method' => (
    isa        => 'String',
    constraint => sub { $_ =~ REGEX_METHOD_NAME },
    required   => 1,
    accessor   => { type => 'get' }
);

has 'code' => (
    isa         => 'Scalar',
    constraint  => sub { ref eq 'CODE' },
    initialize  => 1,
    initializer => sub { $_->controller->can( $_->method ) },
    accessor    => { type => 'get' }
);

has 'dispatch_code' => (
    isa         => 'Scalar',
    constraint  => sub { ref eq 'CODE' },
    initialize  => 1,
    initializer => sub { $_->controller->can( 'dispatch' ) },
    accessor    => { type => 'get' }
);

has 'id' => (
    isa         => 'String',
    initialize  => 1,
    initializer => sub { $_->controller->name . '.' . $_->name },
    accessor    => { type => 'get' }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub call {

    my $self = shift;

    return $self->{'code'}->( $self->{'controller'}, @_ );

}

sub dispatch {

    my $self    = shift;
    my $context = shift;

    return $self->{'dispatch_code'}->( $self->{'controller'}, $context, $self );

}


# ----------------------------------------------------------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------------------------------------------------------

*name = \&method;


1;

__END__

=head1 NAME

GX::Action - Action class

=head1 SYNOPSIS

    # Load the class
    use GX::Action;
    
    # Create a new action object
    $action = GX::Action->new(
        controller => 'MyApp::Controller::Blog',
        method     => 'show_post'
    );
    
    # Call the action method
    $action->call( $context );
    
    # Dispatch the action
    $action->dispatch( $context );

=head1 DESCRIPTION

This module provides the L<GX::Action> class which extends the
L<GX::Callback> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Action> object.

    $action = GX::Action->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<controller> ( L<GX::Controller> object | string ) [ required ]

The class name or instance of the controller component to which the action
belongs.

=item * C<method> ( string ) [ required ]

The name of the action method.

=back

=item Returns:

=over 4

=item * C<$action> ( L<GX::Action> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<call>

Calls the action method.

    $action->call( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=back

=head3 C<code>

Returns a reference to the action method.

    $code = $action->code;

=over 4

=item Returns:

=over 4

=item * C<$code> ( C<CODE> reference )

=back

=back

=head3 C<controller>

Returns the controller component instance to which the action belongs.

    $controller = $action->controller;

=over 4

=item Returns:

=over 4

=item * C<$controller> ( L<GX::Controller> object )

=back

=back

=head3 C<dispatch>

Dispatches the action using the controller's dispatch mechanism.

    $action->dispatch( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=back

=head3 C<id>

Returns a string identifying the action (not the action object).

    $id = $action->id;

=over 4

=item Returns:

=over 4

=item * C<$id> ( string )

=back

=back

=head3 C<method>

Returns the name of the action.

    $method = $action->method;

=over 4

=item Returns:

=over 4

=item * C<$method> ( string )

=back

=back

=head3 C<name>

An alias for C<< L<method()|/method> >>.

    $name = $action->name;

=over 4

=item Returns:

=over 4

=item * C<$name> ( string )

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Controller>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
