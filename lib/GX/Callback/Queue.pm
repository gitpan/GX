# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Callback/Queue.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Callback::Queue;

use strict;
use warnings;

use GX::Exception;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;

    my $self = bless [ undef ], $class;

    return $self;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    my $self = shift;

    for ( @_ ) {

        if ( ! blessed $_ || ! $_->isa( 'GX::Callback' ) ) {
            complain "Invalid argument";
        }

    }

    push @$self, @_;

    return;

}

sub all {

    my $self = shift;

    return @$self > 1 ? @$self[ 1 .. @$self - 1 ] : ();

}

sub clear {

    my $self = shift;

    @$self = ( undef );

    return;

}

sub clone {

    my $self = shift;

    return bless [ @$self ], ref $self;

}

sub current {

    return $_[0]->[0];

}

sub next {

    my $self = shift;

    if ( @$self > 1 ) {
        shift @$self;
        return $self->[0];
    }
    else {
        return undef;
    }

}

sub remove {

    my $self = shift;

    my $count = @$self;

    for my $callback ( @_ ) {

        if ( ! blessed $callback || ! $callback->isa( 'GX::Callback' ) ) {
            complain "Invalid argument";
        }

        @$self = ( shift( @$self ), grep( { $_ != $callback } @$self ) );

    }

    return $count - @$self;

}

sub remove_all {

    my $self = shift;

    @$self = ( $self->[0] );

    return;

}

sub replace_all {

    my $self = shift;

    $self->remove_all;

    eval {
        $self->add( @_ );
    };

    if ( $@ ) {
        complain $@;
    }

    return;

}


1;

__END__

=head1 NAME

GX::Callback::Queue - Callback queue class

=head1 SYNOPSIS

    # Load the class
    use GX::Callback::Queue;
    
    # Create a new callback queue
    $queue = GX::Callback::Queue->new;
    
    # Add a callback
    $queue->add( GX::Callback->new( sub { say "Hello!" } ) );
    
    # Process
    while ( my $callback = $queue->next ) {
        $callback->call;
    }

=head1 DESCRIPTION

This module provides the L<GX::Callback::Queue> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Callback::Queue> object.

    $queue = GX::Callback::Queue->new;

=over 4

=item Returns:

=over 4

=item * C<$queue> ( L<GX::Callback::Queue> object )

=back

=back

=head2 Public Methods

=head3 C<add>

Adds the given callback objects to the end of the queue.

    $queue->add( @callbacks );

=over 4

=item Arguments:

=over 4

=item * C<@callbacks> ( L<GX::Callback> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<all>

Returns all queued callback objects.

    @callbacks = $queue->all;

=over 4

=item Returns:

=over 4

=item * C<@callbacks> ( L<GX::Callback> objects )

=back

=back

Calling this method does not modify the queue.

=head3 C<clear>

Clears the queue.

    $queue->clear;

=head3 C<clone>

Clones the queue.

    $cloned_queue = $queue->clone;

=over 4

=item Returns:

=over 4

=item * C<$cloned_queue> ( L<GX::Callback::Queue> object )

=back

=back

=head3 C<current>

Returns the current callback object (i.e. the one returned by the last
C<< L<next()|/"next"> >> call).

    $callback = $queue->current;

=over 4

=item Returns:

=over 4

=item * C<$callback> ( L<GX::Callback> object | C<undef> )

=back

=back

=head3 C<next>

Removes the next callback object from the queue and returns it.

    $callback = $queue->next;

=over 4

=item Returns:

=over 4

=item * C<$callback> ( L<GX::Callback> object | C<undef> )

=back

=back

=head3 C<remove>

Removes the given callback objects from the queue.

    $result = $queue->remove( @callbacks );

=over 4

=item Arguments:

=over 4

=item * C<@callbacks> ( L<GX::Callback> objects )

=back

=item Returns:

=over 4

=item * C<$result> ( integer )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<remove_all>

Removes all remaining callback objects from the queue.

    $queue->remove_all;

=head3 C<replace_all>

Replaces the remaining callback objects with the given ones.

    $queue->replace_all( @callbacks );

=over 4

=item Arguments:

=over 4

=item * C<@callbacks> ( L<GX::Callback> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Callback>

=item * L<GX::Callback::Hook::Queue>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
