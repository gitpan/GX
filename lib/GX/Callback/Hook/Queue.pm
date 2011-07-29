# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Callback/Hook/Queue.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Callback::Hook::Queue;

use strict;
use warnings;

use GX::Exception;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;

    my $self = bless [ [ undef ] ], $class;

    return $self;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    my $self = shift;

    for ( @_ ) {

        if ( ! blessed $_ ) {
            complain "Invalid argument";
        }

        if ( $_->isa( 'GX::Callback' ) ) {
            my $callback = $_;
            push @$self, [ $callback ];
        }
        elsif ( $_->isa( 'GX::Callback::Hook' ) ) {
            my $hook      = $_;
            my $hook_name = $hook->name;
            my @callbacks = $hook->all;
            push @$self, map { [ $_, $hook, $hook_name ] } ( @callbacks ? @callbacks : ( undef ) );
        }
        else {
            complain "Invalid argument";
        }

    };

    return;

}

sub clear {

    my $self = shift;

    @$self = ( [ undef ] );

    return;

}

sub clone {

    my $self = shift;

    return bless [ @$self ], ref $self;

}

sub current {

    return ( $_[0]->[0] || return )->[0];

}

sub current_hook {

    return ( $_[0]->[0] || return )->[1];

}

sub next {

    my $self = shift;

    my $current = shift @$self;

    while ( @$self ) {
        return $self->[0][0] || shift( @$self ) && next;
    }

    @$self = ( $current );

    return;

}

sub all {

    my $self = shift;

    if ( @$self > 1 ) {
        return grep { defined } map { $_->[0] } @$self[ 1 .. $#$self ];
    }
    else {
        return;
    }

}

sub remove {

    my $self = shift;

    my $count = @$self;

    for ( @_ ) {

        if ( ! defined $_ ) {
            complain "Invalid argument";
        }

        if ( blessed $_ ) {

            if ( $_->isa( 'GX::Callback' ) ) {
                my $callback = $_;
                @$self = ( shift( @$self ), grep( { $_->[0] != $callback } @$self ) );
            }
            elsif ( $_->isa( 'GX::Callback::Hook' ) ) {
                my $hook = $_;
                @$self = ( shift( @$self ), grep( { $_->[1] != $hook } @$self ) );
            }
            else {
                complain "Invalid argument";
            }

        }
        else {
            my $hook_name = $_;
            no warnings 'uninitialized';
            @$self = ( shift( @$self ), grep( { $_->[2] ne $hook_name } @$self ) );
        }

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

sub skip_to {

    my $self = shift;

    if ( @_ != 1 ) {
        complain "Invalid number of arguments";
    }

    my $position;

    if ( blessed $_[0] ) {

        if ( $_[0]->isa( 'GX::Callback' ) ) {

            my $callback = $_[0];

            my $i = 0;

            for ( @$self ) {
                $position = $i, last if defined( $_->[0] ) && $_->[0] == $callback;
                $i++;
            }

        }
        elsif ( $_[0]->isa( 'GX::Callback::Hook' ) ) {

            my $hook = $_[0];

            my $i = 0;

            for ( @$self ) {
                $position = $i, last if defined( $_->[1] ) && $_->[1] == $hook;
                $i++;
            }

        }
        else {
            complain "Invalid argument";
        }

    }
    elsif ( defined $_[0] ) {

        my $hook_name = $_[0];

        my $i = 0;

        for ( @$self ) {
            no warnings 'uninitialized';
            $position = $i, last if $_->[2] eq $hook_name;
            $i++;
        }

    }
    else {
        complain "Invalid argument";
    }

    if ( $position ) {

        if ( $position > 1 ) {
            splice( @$self, 1, $position - 1 );
        }

        return 1;

    }

    return;

}


1;

__END__

=head1 NAME

GX::Callback::Hook::Queue - Callback queue class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Callback::Hook::Queue> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Callback::Hook::Queue> object.

    $queue = GX::Callback::Hook::Queue->new;

=over 4

=item Returns:

=over 4

=item * C<$queue> ( L<GX::Callback::Hook::Queue> object )

=back

=back

=head2 Public Methods

=head3 C<add>

Adds the given callback objects / the callback objects attached to the given
hook objects to the queue.

    $queue->add( @arguments );

=over 4

=item Arguments:

=over 4

=item * C<@arguments> ( L<GX::Callback> or L<GX::Callback::Hook> objects )

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

=item * C<$cloned_queue> ( L<GX::Callback::Hook::Queue> object )

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

=head3 C<current_hook>

Returns the hook object the current callback is associated with.

    $hook = $queue->current_hook;

=over 4

=item Returns:

=over 4

=item * C<$hook> ( L<GX::Callback::Hook> object | C<undef> )

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

Removes the given callback object(s) / the callback objects associated with
the specified hook(s) from the queue.

    $result = $queue->remove( @arguments );

=over 4

=item Arguments:

=over 4

=item * C<@arguments> ( L<GX::Callback> objects | L<GX::Callback::Hook> objects | strings )

Callback objects, hook objects and / or hook names. 

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

Replaces the remaining callback objects with the given callback object(s) /
the callback objects attached to the given hook object(s).

    $queue->replace_all( @arguments );

=over 4

=item Arguments:

=over 4

=item * C<@arguments> ( L<GX::Callback> or L<GX::Callback::Hook> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<skip_to>

Skips all remaining callbacks up to the specified callback / the next callback
associated with the specified hook.

    $result = $queue->skip_to( $argument );

=over 4

=item Arguments:

=over 4

=item * C<$argument> ( L<GX::Callback> object | L<GX::Callback::Hook> object | string )

Callback object, hook object or hook name. 

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Callback>

=item * L<GX::Callback::Hook>

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
