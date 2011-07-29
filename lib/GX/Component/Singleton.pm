# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Component/Singleton.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Component::Singleton;

use GX::Exception;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends qw( GX::Component GX::Class::Singleton );

build;


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { ref $_[0] },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub setup {

    my $self = shift->instance;

    my $class = ref $self;

    eval {
        $class->SUPER::setup( @_ );
    };

    if ( $@ ) {
        complain $@;
    }

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _component_interface {

    return $_[0]->instance;

}

sub _unload {

    my $self = shift;

    $self->destroy;

    return;

}


1;

__END__

=head1 NAME

GX::Component::Singleton - Base class for singleton-based components

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Component::Singleton> class which inherits
directly from L<GX::Component> and L<GX::Class::Singleton>.

=head1 METHODS

See L<GX::Component> and L<GX::Class::Singleton>.

=head1 SUBCLASSES

The following component base classes inherit directly from
L<GX::Component::Singleton>:

=over 4

=item * L<GX::Cache>

=item * L<GX::Controller>

=item * L<GX::Database>

=item * L<GX::Dispatcher>

=item * L<GX::Engine>

=item * L<GX::Logger>

=item * L<GX::Model>

=item * L<GX::Router>

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
