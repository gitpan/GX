# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Component.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Component;

use GX::Callback::Method;
use GX::Exception;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant {
    STATE_RELOADING   => -1,
    STATE_INITIALIZED => 0,
    STATE_SETUP       => 1,
    STATE_DEPLOYED    => 2,
    STATE_RUNNING     => 3
};


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class ( code_attributes => [ 'Handler' ] );

has static 'application' => (
    isa        => 'Scalar',
    weaken     => 1,
    accessors  => {
        'application'      => { type => 'get' },
        '_set_application' => { type => 'set' }
    }
);

has static 'component_state' => (
    isa       => 'Scalar',
    default   => STATE_INITIALIZED,
    accessors => {
        '_get_component_state' => { type => 'get' },
        '_set_component_state' => { type => 'set' }
    }
);

has static 'config' => (
    isa         => 'Hash',
    initializer => '_initialize_config',
    accessors   => {
        '_get_config' => { type => 'get_reference' }
    }
);

has static 'handlers' => (
    isa       => 'Hash',
    accessors => {
        '_get_handlers' => { type => 'get_reference' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub setup {

    my $class = shift;

    if ( ref $class ) {
        complain "setup() is a class method";
    }

    if ( @_ % 2 ) {
        complain "Invalid number of arguments";
    }

    if ( $class->_is_setup ) {
        complain "$class has already been setup";
    }

    eval {
        $class->_component_interface->_setup( { @_ } );
    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "$class setup failed",
            subexception => $@
        );
    }

    $class->_is_setup( 1 );

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub __deploy {

    my $class = shift;

    if ( $class->_is_deployed ) {
         return;
    }

    if ( ! $class->application ) {
        complain "Cannot deploy $class (component has not been registered)";
    }

    eval {
        $class->_component_interface->_deploy;
    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot deploy $class",
            subexception => $@
        );
    }

    $class->_is_deployed( 1 );

    return;

}

sub __register {

    my $class       = shift;
    my $application = shift;

    if ( ! blessed $application || ! $application->isa( 'GX::Application' ) ) {
        complain "Invalid argument";
    }

    if ( $class->application ) {

        if ( $class->application == $application ) {
            return $class->_component_interface;
        }
        else {
            complain "Cannot register $class (already registered)";
        }

    }

    $class->__setup;

    eval {
        $class->_component_interface->_register( $application );
    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot register $class",
            subexception => $@
        );
    }

    return $class->_component_interface;

}

sub __setup {

    my $class  = shift;
    my $config = shift;

    if ( defined $config && ref $config ne 'HASH' ) {
        complain "Invalid argument";
    }

    if ( $class->_is_setup ) {

        if ( defined $config ) {
            complain "$class has already been setup";
        }

        return;

    }

    eval {
        $class->_component_interface->_setup( $config // {} );
    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "$class setup failed",
            subexception => $@
        );
    }

    $class->_is_setup( 1 );

    return;

}

sub __start {

    my $class = shift;

    if ( $class->_is_running ) {
        return;
    }

    if ( ! $class->_is_deployed ) {
        complain "Cannot start $class (component has not been deployed)";
    }

    eval {
        $class->_component_interface->_start;
    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot start $class",
            subexception => $@
        );
    }

    $class->_is_running( 1 );

    return;

}

sub __unload {

    my $class = shift;

    if ( $class->application ) {
        complain "Cannot unload $class (component is still registered)";
    }

    eval { 
        $class->_component_interface->_unload;
    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot unload $class",
            subexception => $@
        );
    }

    return;

}

sub __unregister {

    my $class = shift;

    if ( ! $class->application ) {
        return;
    }

    eval { 
        $class->_component_interface->_unregister;
    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot unregister $class",
            subexception => $@
        );
    }

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _add_handler {

    my $invocant  = shift;
    my $hook_name = shift;
    my $handler   = shift;

    if ( ! defined $hook_name || ! defined $handler ) {
        complain "Missing argument";
    }

    if ( blessed $handler ) {

        if ( ! $handler->isa( 'GX::Callback::Method' ) ) {
            complain "Invalid argument";
        }

    }
    else {
        $handler = $invocant->_create_handler( $handler );
    }

    push @{$invocant->_get_handlers->{$hook_name}}, $handler;

    return;

}

sub _component_interface {

    return ref $_[0] || $_[0];

}

sub _create_handler {

    my $invocant = shift;
    my $method   = shift;

    return GX::Callback::Method->new( invocant => $invocant->_component_interface, method => $method );

}

sub _deploy {

    # Abstract method

}

sub _export_attribute {

    my $invocant  = shift;
    my $importer  = shift;
    my $attribute = shift;

    if ( ! defined $importer || ! defined $attribute ) {
        complain "Missing or invalid argument";
    }

    if ( ! eval { $importer->isa( 'GX::Class' ) } ) {
        complain "Cannot export attribute ($importer is not a GX::Class)";
    }

    eval {

        if ( ref $attribute eq 'HASH' ) {
            $attribute = $importer->meta->add_attribute( %$attribute );
        }
        else {
            $attribute = $importer->meta->add_attribute( $attribute );
        }

        $attribute->install;

        if ( $importer->can( '__build' ) ) {
            $importer->__build;
        }

    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot export attribute",
            subexception => $@
        );
    }

    return;

}

sub _export_method {

    my $invocant = shift;
    my $importer = shift;
    my $method   = shift;
    my $code     = shift;

    if ( ! defined $importer || ! defined $method || ! defined $code ) {
        complain "Missing or invalid argument";
    }

    if ( ! eval { $importer->isa( 'GX::Class' ) } ) {
        complain "Cannot export method ($importer is not a GX::Class)";
    }

    eval {
        $importer->meta->add_method( $method, $code );
    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot export method",
            subexception => $@
        );
    }

    return;

}

sub _initialize_config {

    return {};

}

sub _install_import_method {

    my $class = shift;

    return if $class eq __PACKAGE__;

    $class->meta->add_method(

        'import' => sub {

            my $package = shift;
            my $caller  = caller; 

            return if $package ne $class || $caller eq 'main';

            if ( ! $package->_validate_class_name( $caller ) ) {
                complain "Cannot import $package (\"$caller\" is not a valid class name for a $package component)";
            }

            for my $pragma ( qw( strict warnings ) ) {
                $pragma->import;
            }

            my $meta = GX::Meta::Class->new( $caller );
            $meta->inherit_from( $package );

            return;

        }

    );

    return;

}

sub _is_deployed {

    my $invocant = shift;

    if ( $_[0] ) {
        $invocant->_set_component_state( STATE_DEPLOYED );
        return;
    }

    return $invocant->_get_component_state >= STATE_DEPLOYED;

}

sub _is_initialized {

    my $invocant = shift;

    if ( $_[0] ) {
        $invocant->_set_component_state( STATE_INITIALIZED );
        return;
    }

    return $invocant->_get_component_state >= STATE_INITIALIZED;

}

sub _is_reloading {

    my $invocant = shift;

    if ( $_[0] ) {
        $invocant->_set_component_state( STATE_RELOADING );
        return;
    }

    return $invocant->_get_component_state == STATE_RELOADING;

}

sub _is_running {

    my $invocant = shift;

    if ( $_[0] ) {
        $invocant->_set_component_state( STATE_RUNNING );
        return;
    }

    return $invocant->_get_component_state >= STATE_RUNNING;

}

sub _is_setup {

    my $invocant = shift;

    if ( $_[0] ) {
        $invocant->_set_component_state( STATE_SETUP );
        return;
    }

    return $invocant->_get_component_state >= STATE_SETUP;

}

sub _register {

    my $invocant    = shift;
    my $application = shift;

    $invocant->_set_application( $application );

    $invocant->_register_handlers;

    return;

}

sub _register_handlers {

    my $invocant = shift;

    my $handlers = $invocant->_get_handlers;

    while ( my ( $hook_name, $handlers ) = each %$handlers ) {

        if ( my $hook = $invocant->application->hook( $hook_name ) ) {

            for my $handler ( @$handlers ) {
                $hook->add( $handler );
            }

        }

    }

    return;

}

sub _setup {

    my $invocant = shift;
    my $config   = shift;

    $invocant->_setup_config( $config );

    $invocant->_setup_handlers;

    return;

}

sub _setup_config {

    my $invocant = shift;
    my $config   = shift;

    $invocant->_get_config;  # initialize

    if ( $config && %$config ) {
        throw sprintf( "Unrecognized setup option (\"%s\")", ( sort keys %$config )[0] );
    }

    return;

}

sub _setup_handlers {

    my $invocant = shift;

    $invocant->_get_handlers;  # initialize

    for my $method ( $invocant->meta->all_methods ) {

        for my $attribute ( $method->code_attributes ) {

            if ( $attribute =~ /^Handler\(\s?(\w+?)\s?\)$/ ) {
                $invocant->_add_handler( $1, $method->name );
            }

        }

    }

    return;

}

sub _start {

    # Abstract method

}

sub _unload {

    # Abstract method

}

sub _unregister {

    my $invocant = shift;

    $invocant->_unregister_handlers;

    $invocant->_set_application( undef );

    return;

}

sub _unregister_handlers {

    my $invocant = shift;

    my $handlers = $invocant->_get_handlers;

    while ( my ( $hook_name, $handlers ) = each %$handlers ) {

        if ( my $hook = $invocant->application->hook( $hook_name ) ) {

            for my $handler ( @$handlers ) {
                $hook->remove( $handler );
            }

        }

    }

    return;

}

sub _validate_class_name {

    # Abstract method

}


1;

__END__

=head1 NAME

GX::Component - Base class for components

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Component> class which is the base class for
all components. The L<GX::Component> class itself inherits from L<GX::Class>.

=head1 METHODS

=head2 Public Methods

=head3 C<application>

Returns the application instance to which the component belongs.

    $application = $component->application;

=over 4

=item Returns:

=over 4

=item * C<$application> ( L<GX::Application> object | C<undef> )

=back

=back

=head3 C<setup>

Sets up the component.

    $component->setup( %options );

=over 4

=item Arguments:

=over 4

=item * C<%options> ( named list )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Internal Methods

=head3 C<__deploy>

Internal method.

    $component->__deploy;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<__register>

Internal method.

    $component_interface = $component->__register( $application );

=over 4

=item Arguments:

=over 4

=item * C<$application> ( L<GX::Application> object )

=back

=item Returns:

=over 4

=item * C<$component_interface> ( string | L<GX::Component> object )

The component interface, which can be, depending on the implementation, an
instance of the component class or the component class name.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<__setup>

Internal method.

    $component->__setup( $options );

=over 4

=item Arguments:

=over 4

=item * C<$options> ( C<HASH> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<__start>

Internal method.

    $component->__start;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<__unload>

Internal method.

    $component->__unload;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<__unregister>

Internal method.

    $component->__unregister;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head1 SUBCLASSES

The following component base classes inherit directly or indirectly (through
L<GX::Component::Singleton>) from L<GX::Component>:

=over 4

=item * L<GX::Cache>

=item * L<GX::Context>

=item * L<GX::Controller>

=item * L<GX::Database>

=item * L<GX::Dispatcher>

=item * L<GX::Engine>

=item * L<GX::Logger>

=item * L<GX::Model>

=item * L<GX::Request>

=item * L<GX::Response>

=item * L<GX::Router>

=item * L<GX::Session>

=item * L<GX::View>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
