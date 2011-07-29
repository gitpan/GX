# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Dispatcher.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Dispatcher;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class ( extends => 'GX::Component::Singleton' );

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Handlers
# ----------------------------------------------------------------------------------------------------------------------

sub dispatch :Handler( DispatchActions ) {

    my $self    = shift;
    my $context = shift;

    if ( my $action_queue = $context->action_queue ) {

        while ( my $action = $action_queue->next ) {
            $action->dispatch( $context );
        }

        $context->action_queue( undef );

    }

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------------------------------------------------------

sub _validate_class_name {

    return $_[1] =~ /^(?:[_a-zA-Z]\w*::)+?Dispatcher$/;

}


1;

__END__

=head1 NAME

GX::Dispatcher - Dispatcher component

=head1 SYNOPSIS

    package MyApp::Dispatcher;
    
    use GX::Dispatcher;
    
    __PACKAGE__->setup;
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Dispatcher> class which extends the
L<GX::Component::Singleton> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the dispatcher instance.

    $dispatcher = $dispatcher_class->new;

=over 4

=item Returns:

=over 4

=item * C<$dispatcher> ( L<GX::Dispatcher> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

All public methods can be called both as instance and class methods.

=head3 C<setup>

Sets up the dispatcher.

    $dispatcher->setup;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Internal Methods

=head3 C<dispatch>

Handler method.

    $dispatcher->dispatch( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=back

This handler is added to the application's C<DispatchActions> hook.

=head1 SEE ALSO

=over 4

=item * L<GX::Application>

=item * L<GX::Component> and L<GX::Component::Singleton>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
