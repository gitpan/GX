# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Exception/StackTrace/Frame.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Exception::StackTrace::Frame;

use strict;
use warnings;


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant FIELDS => qw(
    package
    filename
    line
    subroutine
    hasargs
    wantarray
    evaltext
    is_require
    hints
    bitmask
    hinthash
);


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { $_[0]->as_string },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;

    my $self = bless {}, $class;

    if ( @_ ) {

        if ( @_ != 12 ) {
            warn "Invalid number of arguments";
        }

        $self->{'level'} = shift;
        $self->{'info'}  = [ @_ ];

    }

    return $self;

}


# ----------------------------------------------------------------------------------------------------------------------
# Caller info accessors
# ----------------------------------------------------------------------------------------------------------------------

{

    no strict 'refs';

    my $i = 0;

    for ( FIELDS ) {
        *{ __PACKAGE__ . '::' . $_ } = eval "sub { \$_[0]->{'info'}[$i] }";
        $i++;
    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub as_string {

    my $self = shift;

    my $string;

    if ( $self->subroutine eq '(eval)' ) {

        $string = sprintf(
            "[%s] %s at %s line %s",
            $self->level      // '?',
            $self->subroutine // '?',
            $self->filename   // '?',
            $self->line       // '?'
        );

    }
    else {

        $string = sprintf(
            "[%s] %s called at %s line %s",
            $self->level      // '?',
            $self->subroutine // '?',
            $self->filename   // '?',
            $self->line       // '?'
        );

    }

    return $string;

}

sub info {

    return @{$_[0]->{'info'}};

}

sub level {

    return $_[0]->{'level'};

}


1;

__END__

=head1 NAME

GX::Exception::StackTrace::Frame - Stack trace frame class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Exception::StackTrace::Frame> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Exception::StackTrace::Frame> object.

    $frame = GX::Exception::StackTrace::Frame->new( $level, @info );

=over 4

=item Arguments:

=over 4

=item * C<$level> ( integer )

An integer identifying the position of the frame in the stack. 

=item * C<@info> ( scalars )

The frame information as provided by C<caller( $offset )>.

=back

=item Returns:

=over 4

=item * C<$frame> ( L<GX::Exception::StackTrace::Frame> object )

=back

=back

=head2 Public Methods

=head3 C<as_string>

Returns a text representation of the stack frame.

    $string = $frame->as_string;

=over 4

=item Returns:

=over 4

=item * C<$string> ( string )

=back

=back

=head3 C<bitmask>

Returns the C<bitmask> frame information as provided by C<caller()>.

    $value = $frame->bitmask;

=over 4

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<evaltext>

Returns the C<evaltext> frame information as provided by C<caller()>.

    $value = $frame->evaltext;

=over 4

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<filename>

Returns the C<filename> frame information as provided by C<caller()>.

    $value = $frame->filename;

=over 4

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<hasargs>

Returns the C<hasargs> frame information as provided by C<caller()>.

    $value = $frame->hasargs;

=over 4

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<hinthash>

Returns the C<hinthash> frame information as provided by C<caller()>.

    $value = $frame->hinthash;

=over 4

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<hints>

Returns the C<hints> frame information as provided by C<caller()>.

    $value = $frame->hints;

=over 4

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<info>

Returns a list with the stack frame information as provided by C<caller()>.

    @info = $frame->info;

=over 4

=item Returns:

=over 4

=item * C<@info> ( scalars )

=back

=back

=head3 C<is_require>

Returns the C<is_require> frame information as provided by C<caller()>.

    $value = $frame->is_require;

=over 4

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<level>

Returns the position of the frame in the stack.

    $level = $frame->level;

=over 4

=item Returns:

=over 4

=item * C<$level> ( integer )

=back

=back

=head3 C<line>

Returns the C<line> frame information as provided by C<caller()>.

    $value = $frame->line;

=over 4

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<package>

Returns the C<package> frame information as provided by C<caller()>.

    $value = $frame->package;

=over 4

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<subroutine>

Returns the C<subroutine> frame information as provided by C<caller()>.

    $value = $frame->subroutine;

=over 4

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<wantarray>

Returns the C<wantarray> frame information as provided by C<caller()>.

    $value = $frame->wantarray;

=over 4

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Exception>

=item * L<GX::Exception::StackTrace>

=item * C<< L<caller()|http://perldoc.perl.org/functions/caller.html> >>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
