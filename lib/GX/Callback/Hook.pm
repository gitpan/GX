# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Callback/Hook.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Callback::Hook;

use GX::Exception;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant {
    PRIORITY_HIGHEST => 0,
    PRIORITY_HIGH    => 2,
    PRIORITY_NORMAL  => 4,
    PRIORITY_LOW     => 6,
    PRIORITY_LOWEST  => 8
};


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'name' => (
    isa        => 'String',
    initialize => 1,
    accessor   => { type => 'get' }
);

has 'callbacks' => (
    isa        => 'Array',
    initialize => 1,
    accessor   => undef
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { $_[0]->{'name'} },
    '@{}'      => sub { [ $_[0]->all ] },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;

    return eval { $class->SUPER::new( @_ == 1 ? ( name => $_[0] ) : @_ ) } || complain $@;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    my $self     = shift;
    my $callback = shift;
    my $priority = shift;

    if ( ! blessed $callback || ! $callback->isa( 'GX::Callback' ) ) {
        complain "Invalid argument";
    }

    if ( defined $priority ) {

        if ( $priority !~ /\d+/ ) {
            complain "Invalid argument";
        }

    }
    else {
        $priority = PRIORITY_NORMAL;
    }

    my $callbacks = $self->{'callbacks'};

    my $position;

    if ( ! @$callbacks || $priority < $callbacks->[0][1] ) {
        $position = 0;
    }
    elsif ( $priority >= $callbacks->[-1][1] ) {
        $position = @$callbacks;
    }
    elsif ( @$callbacks == 2 ) {
        $position = 1;
    }
    else {

        my $min = 0;
        my $max = $#$callbacks;

        while ( 1 ) {

            my $mid = int( ( $min + $max ) / 2 );

            if ( $priority < $callbacks->[$mid][1] ) {
                $max = $mid - 1;
            }
            else {
                $min = $mid + 1;
            }

            if ( $max < $min ) {
                $position = $min;
                last;
            }

        }

    }

    splice( @$callbacks, $position, 0, [ $callback, $priority ] );

    return;

}

sub all {

    return map { $_->[0] } @{$_[0]->{'callbacks'}};

}

sub remove {

    my $self     = shift;
    my $callback = shift;

    if ( ! blessed $callback || ! $callback->isa( 'GX::Callback' ) ) {
        complain "Invalid argument";
    }

    my $callbacks = $self->{'callbacks'};

    my $count = @$callbacks;

    @$callbacks = grep { $_->[0] != $callback } @$callbacks;

    return $count - @$callbacks;

}

sub remove_all {

    my $self = shift;

    @{$self->{'callbacks'}} = ();

    return;

}


1;

__END__

=head1 NAME

GX::Callback::Hook - Hook class

=head1 SYNOPSIS

    # Load the class
    use GX::Callback::Hook;
    
    # Create a new hook object
    $hook = GX::Callback::Hook->new;
    
    # Add a callback
    $hook->add( GX::Callback->new( sub { say 'Hello!' } ) );

=head1 DESCRIPTION

This module provides the L<GX::Callback::Hook> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Callback::Hook> object.

    $hook = GX::Callback::Hook->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<name> ( string | C<undef> )

The name of the hook.

=back

=item Returns:

=over 4

=item * C<$hook> ( L<GX::Callback::Hook> object )

=back

=back

Alternative syntax

    $hook = GX::Callback::Hook->new( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string | C<undef> )

The name of the hook.

=back

=item Returns:

=over 4

=item * C<$hook> ( L<GX::Callback::Hook> object )

=back

=back

=head2 Public Methods

=head3 C<add>

Adds a callback object.

    $hook->add( $callback );
    $hook->add( $callback, $priority );

=over 4

=item Arguments:

=over 4

=item * C<$callback> ( L<GX::Callback> object )

=item * C<$priority> ( integer ) [ optional ]

Defaults to C<PRIORITY_NORMAL> (see L</CONSTANTS> below).

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<all>

Returns all callback objects.

    @callbacks = $hook->all;

=over 4

=item Returns:

=over 4

=item * C<@callbacks> ( L<GX::Callback> objects )

=back

=back

=head3 C<name>

Returns the name of the hook.

    $name = $hook->name;

=over 4

=item Returns:

=over 4

=item * C<$name> ( string | C<undef> )

=back

=back

=head3 C<remove>

Removes the given callback object.

    $result = $hook->remove( $callback );

=over 4

=item Arguments:

=over 4

=item * C<$callback> ( L<GX::Callback> object )

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

=head3 C<remove_all>

Removes all callbacks objects.

    $hook->remove_all;

=head1 CONSTANTS

    PRIORITY_HIGHEST => 0
    PRIORITY_HIGH    => 2
    PRIORITY_NORMAL  => 4
    PRIORITY_LOW     => 6
    PRIORITY_LOWEST  => 8

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
