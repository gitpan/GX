# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Callback.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Callback;

use GX::Exception;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'arguments' => (
    isa => 'Array'
);

has 'code' => (
    isa        => 'Scalar',
    constraint => sub { ref eq 'CODE' },
    required   => 1,
    accessor   => { type => 'get' }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    return eval { shift->SUPER::new( ( @_ == 1 ) ? ( code => $_[0] ) : @_ ) } || complain $@;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub arguments {

    return @{ $_[0]->{'arguments'} || return };

}

sub call {

    my $self = shift;

    return $self->{'code'}->( ( $self->{'arguments'} ? @{$self->{'arguments'}} : () ), @_ );

}


1;

__END__

=head1 NAME

GX::Callback - Callback class 

=head1 SYNOPSIS

    # Load the class
    use GX::Callback;
    
    # Create a new callback object
    $callback = GX::Callback->new( sub { say @_ } );
    
    # Execute the callback
    $callback->call( "Hello world!" );


=head1 DESCRIPTION

This module provides the L<GX::Callback> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Callback> object.

    $callback = GX::Callback->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<arguments> ( C<ARRAY> reference )

A reference to an array with arguments to pass to the callback subroutine when
it is called.

=item * C<code> ( C<CODE> reference ) [ required ]

A reference to the callback subroutine.

=back

=item Returns:

=over 4

=item * C<$callback> ( L<GX::Callback> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Alternative syntax:

    $callback = GX::Callback->new( $code );

=over 4

=item Arguments:

=over 4

=item * C<$code> ( C<CODE> reference )

A reference to the callback subroutine.

=back

=item Returns:

=over 4

=item * C<$callback> ( L<GX::Callback> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<arguments>

Returns the callback subroutine arguments.

    @arguments = $callback->arguments;

=over 4

=item Returns:

=over 4

=item * C<@arguments> ( scalars )

=back

=back

=head3 C<call>

Calls the callback subroutine.

    $callback->call( @arguments );

=over 4

=item Arguments:

=over 4

=item * C<@arguments> ( scalars )

Additional arguments to pass to the callback subroutine.

=back

=back

=head3 C<code>

Returns a reference to the callback subroutine.

    $code = $callback->code;

=over 4

=item Returns:

=over 4

=item * C<$code> ( C<CODE> reference )

=back

=back

=head1 SUBCLASSES

The following classes inherit directly from L<GX::Callback>:

=over 4

=item * L<GX::Action>

=item * L<GX::Callback::Method>

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Callback::Hook>

=item * L<GX::Callback::Hook::Queue>

=item * L<GX::Callback::Queue>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
