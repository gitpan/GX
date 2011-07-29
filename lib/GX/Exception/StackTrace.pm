# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Exception/StackTrace.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Exception::StackTrace;

use strict;
use warnings;

use GX::Exception::StackTrace::Frame;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { $_[0]->as_string },
    '@{}'      => sub { $_[0]->{'frames'} },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;

    my $self = bless {
        'frames' => []
    }, $class;

    return $self;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    my $self = shift;

    push @{$self->{'frames'}}, grep { blessed $_ && $_->isa( 'GX::Exception::StackTrace::Frame' ) } @_;

    return;

}

sub as_string {

    my $self   = shift;
    my $offset = shift;

    $offset //= 0;

    my $frames = $self->{'frames'};
    my @lines;

    for ( my $i = $offset || 0; $i < @$frames; $i++ ) {
        push @lines, $frames->[$i]->as_string;
    }

    return wantarray ? @lines : join( "\n", @lines ) . "\n";

}

sub build {

    my $self   = shift;
    my $offset = shift;

    $offset //= 1;

    my $level = 0;

    while ( my @info = caller( $offset++ ) ) {
        $self->add( GX::Exception::StackTrace::Frame->new( $level++, @info ) );
    }

    return;

}

sub frames {

    return wantarray ? @{$_[0]->{'frames'}} : $_[0]->{'frames'};

}


1;

__END__

=head1 NAME

GX::Exception::StackTrace - Stack trace class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Exception::StackTrace> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Exception::StackTrace> object.

    $stack_trace = GX::Exception::StackTrace->new;

=over 4

=item Returns:

=over 4

=item * C<$stack_trace> ( L<GX::Exception::StackTrace> object )

=back

=back

=head2 Public Methods

=head3 C<add>

Adds the given stack frame objects to the stack.

    $stack_trace->add( @frames );

=over 4

=item Arguments:

=over 4

=item * C<@frames> ( L<GX::Exception::StackTrace::Frame> objects )

=back

=back

=head3 C<as_string>

Returns a text representation of the stack strace.

    $string = $stack_trace->as_string( $offset );

=over 4

=item Arguments:

=over 4

=item * C<$offset> ( integer ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$string> ( string )

=back

=back

In list context, C<as_string()> returns individual lines of text.

    @strings = $stack_trace->as_string( ... );

=over 4

=item Returns:

=over 4

=item * C<@strings> ( strings )

=back

=back

=head3 C<build>

Builds the stack trace.

    $stack_trace->build( $offset );

=over 4

=item Arguments:

=over 4

=item * C<$offset> ( integer ) [ optional ]

=back

=back

=head3 C<frames>

Returns a list with the individual stack frame objects.

    @frames = $stack_trace->frames;

=over 4

=item Returns:

=over 4

=item * C<@frames> ( L<GX::Exception::StackTrace::Frame> objects )

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Exception>

=item * L<GX::Exception::StackTrace::Frame>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
