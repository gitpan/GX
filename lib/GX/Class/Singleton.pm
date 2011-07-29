# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Class/Singleton.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Class::Singleton;

use strict;
use warnings;

use base 'GX::Class::Object';

use GX::Exception ();


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

sub import {

    my $package = shift;

    return unless $package eq __PACKAGE__;

    unshift( @_, 'GX::Class::Object', superclass => $package );

    goto &GX::Class::Object::import;

}


# ----------------------------------------------------------------------------------------------------------------------
# Object registry
# ----------------------------------------------------------------------------------------------------------------------

my %OBJECTS;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    return $_[0] if ref $_[0];

    my $class = shift;

    if ( $OBJECTS{$class} ) {

        if ( @_ ) {
            GX::Exception->complain( "$class has already been instantiated" );
        }

        return $OBJECTS{$class};

    }

    return $OBJECTS{$class} = eval { $class->SUPER::new( @_ ) } || GX::Exception->complain( $@ );

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub clear {

    return shift->instance->clear;

}

sub destroy {

    return delete $OBJECTS{ ref $_[0] || $_[0] };

}

sub dump {

    return shift->instance->dump;

}

sub instance {

    return $_[0] if ref $_[0];

    return $OBJECTS{$_[0]} if defined $OBJECTS{$_[0]};

    return eval { $_[0]->new } || GX::Exception->complain( $@ );

}


1;

__END__

=head1 NAME

GX::Class::Singleton - Universal base class for singletons

=head1 SYNOPSIS

    package My::ENV;
    
    use GX::Class::Singleton;
    
    has '_env' => (
        isa         => 'Hash',
        initializer => sub { \%ENV },
        accessors   => {
            'get' => { type => 'get_value' },
            'set' => { type => 'set_value' }
        }
    );
    
    build;
    
    my $env = My::ENV->new;
    
    say "Hello " . $env->get( 'USER' ) . "!";

=head1 DESCRIPTION

This module provides the L<GX::Class::Singleton> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Creates the singleton instance and returns it.

    $object = $class->new( %attributes );

=over 4

=item Arguments:

=over 4

=item * C<%attributes> ( named list )

=back

=item Returns:

=over 4

=item * C<$object> ( L<GX::Class::Singleton> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Subsequent calls to C<new()> without arguments return the singleton instance.

=head2 Public Methods

All public methods can be called both as instance and class methods.

=head3 C<clear>

Resets the singleton instance's attributes to their uninitialized state. See
L<GX::Class::Object|GX::Class::Object/clear>.

    $singleton->clear;

=head3 C<destroy>

Destroys the singleton instance.

    $singleton->destroy;

=head3 C<dump>

Stringifies the singleton instance. See L<GX::Class::Object|GX::Class::Object/dump>.

    $string = $singleton->dump;

=head3 C<instance>

Returns the singleton instance.

    $object = $singleton->instance;

=over 4

=item Returns:

=over 4

=item * C<$object> ( L<GX::Class::Singleton> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Implicitly calls C<< L<new()|/"new"> >>, if necessary.

=head3 C<meta>

See L<GX::Class::Object|GX::Class::Object/meta>.

    $meta = $singleton->meta;

=head2 Internal Methods

See L<GX::Class::Object|GX::Class::Object/"Internal Methods">.

=head1 EXPORTS

See L<GX::Class::Object|GX::Class::Object/"EXPORTS">.

=head1 SEE ALSO

=over 4

=item * L<GX::Class>

=item * L<GX::Meta>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
