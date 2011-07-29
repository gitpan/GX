# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Exception.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Exception;

use strict;
use warnings;

use GX::Exception::StackTrace;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

{

    my %EXPORTS = (

        'catch' => sub (&) {
            return $_[0];
        },

        'try' => sub (&;$) {

            my $try   = shift;
            my $catch = shift;

            my $wantarray = wantarray;

            my ( @result, $died, $error );

            {

                local $@;

                eval {

                    if ( $wantarray ) {
                        @result = $try->();
                    } elsif ( defined $wantarray ) {
                        $result[0] = $try->();
                    } else {
                        $try->();
                    };

                    1;

                } or do {
                    $died  = 1;
                    $error = $@;
                };

            }

            if ( $died ) {

                if ( $catch ) {
                    local $_ = $error;
                    return $catch->( $error );
                }

                return;

            }

            return $wantarray ? @result : $result[0];

        }

    );

    sub import {

        my $class = shift;

        my $caller = caller();

        {

            no strict 'refs';

            *{"$caller\::complain"} = sub (*) {
                unshift( @_, $class );
                goto &complain;
            };

            *{"$caller\::throw"} = sub (*) {
                unshift( @_, $class );
                goto &throw;
            };

            while ( my ( $name, $code ) = each %EXPORTS ) {
                *{"$caller\::$name"} = $code;
            }

        }

        return;

    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { scalar $_[0]->_as_string },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;

    my $message;
    my $stack_trace;
    my $subexception;
    my $verbosity;

    if ( @_ == 1 ) {

        if ( blessed $_[0] ) {

            if ( $_[0]->isa( __PACKAGE__ ) ) {
                $message      = $_[0]->message;
                $subexception = $_[0]->subexception;
            }
            else {
                $message = "$_[0]";
            }

        }
        else {
            $message = defined $_[0] ? "$_[0]" : $class->_default_message;
        }

        $verbosity = $class->_default_verbosity;

    }
    else {

        my %args = @_;

        if ( defined $args{'message'} ) {
            $message = $args{'message'};
        }
        else {
            $message = $class->_default_message;
        }

        if ( blessed $args{'stack_trace'} && $args{'stack_trace'}->isa( 'GX::Exception::StackTrace' ) ) {
            $stack_trace = $args{'stack_trace'};
        }

        if ( defined $args{'subexception'} ) {

            if ( blessed $args{'subexception'} && $args{'subexception'}->isa( __PACKAGE__ ) ) {
                $subexception = $args{'subexception'};
            }
            elsif ( length $args{'subexception'} ) {
                $subexception = __PACKAGE__->new( $args{'subexception'} );
            }

        }

        if ( defined $args{'verbosity'} && $args{'verbosity'} =~ /^(?:0|1|2|3)$/ ) {
            $verbosity = $args{'verbosity'};
        }
        else {
            $verbosity = $class->_default_verbosity;
        }

    }

    my $self = bless {
        'message'      => $message,
        'stack_trace'  => $stack_trace,
        'subexception' => $subexception,
        'verbosity'    => $verbosity
    }, $class;

    return $self;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub as_string {

    return shift->_as_string( @_ );

}

sub complain {

    my $self = blessed $_[0] ? shift : shift->new( @_ );

    $self->_update_stack_trace( 1 );

    die $self;

}

sub message {

    my $self = shift;

    if ( @_ ) {
        return $self->{'message'} = defined $_[0] ? "$_[0]" : '';
    }

    return $self->{'message'};

}

sub stack_trace {

    my $self = shift;

    if ( @_ ) {

        if ( blessed $_[0] && $_[0]->isa( 'GX::Exception::StackTrace' ) ) {
            $self->{'subexception'} = $_[0];
        }
        else {
            $self->{'subexception'} = undef;
        }

    }

    return wantarray ? @{ $self->{'stack_trace'} || return } : $self->{'stack_trace'};

}

sub subexception {

    my $self = shift;

    if ( @_ ) {

        if ( defined $_[0] ) {

            if ( blessed $_[0] && $_[0]->isa( __PACKAGE__ ) ) {
                $self->{'subexception'} = $_[0];
            }
            elsif ( length $_[0] ) {
                $self->{'subexception'} = __PACKAGE__->new( $_[0] );
            }
            else {
                $self->{'subexception'} = undef;
            }

        }
        else {
            $self->{'subexception'} = undef;
        }

    }

    return $self->{'subexception'};

}

sub throw {

    my $self = blessed $_[0] ? shift : shift->new( @_ );

    $self->_update_stack_trace;

    die $self;

}

sub verbosity {

    my $self = shift;

    if ( @_ ) {

        if ( defined $_[0] && $_[0] =~ /^(?:0|1|2|3)$/ ) {
            $self->{'verbosity'} = $_[0];
        }

    }

    return $self->{'verbosity'};

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _as_string {

    my $self      = shift;
    my $verbosity = shift;

    $verbosity //= $self->verbosity;

    my @lines;

    push @lines, $self->_message_as_string;

    if ( $verbosity > 0 ) {

        if ( $verbosity == 1 ) {

            my $exception = $self;

            while ( $exception = $exception->subexception ) {
                push @lines, $exception->_message_as_string;
            }

        }
        elsif ( $verbosity == 2 ) {

            push @lines, $self->_stack_trace_as_string( 1 );

        }
        elsif ( $verbosity == 3 ) {

            push @lines, $self->_stack_trace_as_string( 1 );

            {

                my $level     = 0;
                my $exception = $self;

                while ( $exception = $exception->subexception ) {
                    my $indentation = ' ' x ( 4 * ++$level );
                    push @lines, map { $indentation . $_ } $exception->_as_string( 1 );
                }

            }

        }

    }

    return wantarray ? @lines : join( "\n", @lines ) . "\n";

}

sub _build_stack_trace {

    my $self   = shift;
    my $offset = shift;

    my $stack_trace = GX::Exception::StackTrace->new;

    $stack_trace->build( ( $offset || 0 ) + 1 );

    return $stack_trace;

}

sub _default_message {

    return 'Unknown error';

}

sub _default_verbosity {

    return 0;

}

sub _message_as_string {

    my $self = shift;

    my $string = $self->message;

    if ( $string !~ s/\n$// ) {

        if ( my $stack_trace = $self->stack_trace ) {

            if ( my $frame = $stack_trace->[0] ) {
                $string .= sprintf(
                    " at %s line %s.",
                    $frame->filename // '?',
                    $frame->line     // '?'
                );
            }

        }

    }

    return $string;

}

sub _stack_trace_as_string {

    my $self   = shift;
    my $offset = shift;

    my $stack_trace = $self->stack_trace;

    return $stack_trace ? $stack_trace->as_string( $offset ) : '';

}

sub _update_stack_trace {

    my $self   = shift;
    my $offset = shift;

    $offset //= 0;

    $self->{'stack_trace'} = $self->_build_stack_trace( $offset + 2 );

    return; 

}


1;

__END__

=head1 NAME

GX::Exception - Exception class

=head1 SYNOPSIS

    # Load the module
    use GX::Exception;
    
    # Try
    eval {
        throw "Oops!";
    };
    # Catch
    if ( $@ ) {
        warn "Exception: $@";
    }
    
    # Same as above, but with proper localization of $@
    try {
        throw "Oops!";
    }
    catch {
        warn "Exception: $_";
    };

=head1 DESCRIPTION

This module provides the L<GX::Exception> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Exception> object.

    $exception = GX::Exception->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<message> ( string )

An error message.

=item * C<stack_trace> ( L<GX::Exception::StackTrace> object )

A stack trace object.

=item * C<subexception> ( L<GX::Exception> object | string )

A subexception.

=item * C<verbosity> ( integer )

The default verbosity level. Possible values are: "0" (only prints the error
message), "1" (prints the error message and also the error messages of all
subexceptions), "2" (prints a short stack trace) or "3" (prints a full stack
trace). The default value is "0".

=back

=item Returns:

=over 4

=item * C<$exception> ( L<GX::Exception> object )

=back

=back

Alternative syntax:

    $exception = GX::Exception->new( $message );
    $exception = GX::Exception->new( $subexception );

=over 4

=item Arguments:

=over 4

=item * C<$message> ( string )

An error message.

=item * C<$subexception> ( L<GX::Exception> object )

A subexception.

=back

=item Returns:

=over 4

=item * C<$exception> ( L<GX::Exception> object )

=back

=back

=head2 Public Methods

=head3 C<as_string>

Returns a text representation of the exception. 

    $string = $exception->as_string( $verbosity );

=over 4

=item Arguments:

=over 4

=item * C<$verbosity> ( integer ) [ optional ]

Possible values: "0", "1", "2" or "3". Defaults to the value returned by
C<< L<verbosity()|/verbosity> >>.

=back

=item Returns:

=over 4

=item * C<$string> ( string )

=back

=back

In list context, C<as_string()> returns individual lines of text.

    @strings = $exception->as_string( ... );

=over 4

=item Returns:

=over 4

=item * C<@strings> ( strings )

=back

=back

=head3 C<complain>

Raises the exception just like C<< L<throw()|/throw> >>, but with the stack
trace originating at the caller.

    $exception->complain;

This method can also be called as a class method. See C<< L<throw()|/throw> >>
for details.

=head3 C<message>

Returns / sets the error message.

    $message = $exception->message;
    $message = $exception->message( $message );

=over 4

=item Arguments:

=over 4

=item * C<$message> ( string ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$message> ( string )

=back

=back

=head3 C<stack_trace>

Returns / sets the associated stack trace object.

    $stack_trace = $exception->stack_trace;
    $stack_trace = $exception->stack_trace( $stack_trace );

=over 4

=item Arguments:

=over 4

=item * C<$stack_trace> ( L<GX::Exception::StackTrace> object | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$stack_trace> ( L<GX::Exception::StackTrace> object | C<undef> )

=back

=back

In list context, C<stack_trace()> returns a list with the individual stack
frame objects.

    @frames = $exception->stack_trace( ... );

=over 4

=item Returns:

=over 4

=item * C<@frames> ( L<GX::Exception::StackTrace::Frame> objects )

=back

=back

=head3 C<subexception>

Returns / sets the associated subexception.

    $subexception = $exception->subexception;
    $subexception = $exception->subexception( $subexception );

=over 4

=item Arguments:

=over 4

=item * C<$subexception> ( L<GX::Exception> object | string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$subexception> ( L<GX::Exception> object | C<undef> )

=back

=back

=head3 C<throw>

Throws the exception by calling C<die()>.

    $exception->throw;

This method can also be called as a class method:

    GX::Exception->throw;
    GX::Exception->throw( $message );
    GX::Exception->throw( $subexception );
    GX::Exception->throw( %attributes );

This will create a new instance of the exception class (see C<< L<new()|/new> >>
for details) on which C<throw()> is then called.

=head3 C<verbosity>

Returns / sets the default verbosity level.

    $verbosity = $exception->verbosity;
    $verbosity = $exception->verbosity( $verbosity );

=over 4

=item Arguments:

=over 4

=item * C<$verbosity> ( integer ) [ optional ]

Possible values: "0", "1", "2" or "3".

=back

=item Returns:

=over 4

=item * C<$verbosity> ( integer )

=back

=back

=head1 EXPORTS

=head2 Functions

The following functions are exported by default.

=head3 C<catch>

This function is meant to be used with C<< L<try()|/try> >>. It simply returns
the first argument passed to it, which must be a block of code.

    try {
        # Block of code ...
    }
    catch {
        # Block of code ...
    };

=head3 C<complain>

Throws an exception with the the stack trace originating at the caller.

    complain $message;
    complain $subexception;

=over 4

=item Arguments:

=over 4

=item * C<$message> ( string )

=item * C<$subexception> ( L<GX::Exception> object )

=back

=back

=head3 C<throw>

Throws an exception.

    throw $message;
    throw $subexception;

=over 4

=item Arguments:

=over 4

=item * C<$message> ( string )

=item * C<$subexception> ( L<GX::Exception> object )

=back

=back

=head3 C<try>

This function expects a "try" block as its first argument and optionally a
"catch" block as its second argument (see C<< L<catch()|/catch> >> above).

    try {
        # Block of code ...
    };

=head1 SEE ALSO

=over 4

=item * L<GX::Exception::StackTrace>

=item * L<GX::Exception::StackTrace::Frame>

=item * L<GX::Exception::Formatter::HTML>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
