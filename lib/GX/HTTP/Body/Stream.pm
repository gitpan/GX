# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Body/Stream.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Body::Stream;

use GX::Exception;

use IO::Handle ();
use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant BUFFER_SIZE => 8192;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::HTTP::Body';

has 'source' => (
    isa      => 'Scalar',
    accessor => { type => 'get' }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $invocant = shift;

    return eval { $invocant->SUPER::new( ( @_ == 1 ) ? ( source => $_[0] ) : @_ ) } || complain $@;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub length {

    return -1;

}

sub print_to {

    my $self   = shift;
    my $handle = shift;

    my $source = $self->source or return;

    my $result;

    if ( ref $source eq 'CODE' ) {

        while ( 1 ) {
            $result = $source->( $handle ) or last;
        }

    }
    else {

        while ( $result = $source->read( my $buffer, BUFFER_SIZE ) ) {
            $handle->print( $buffer ) or return;
        }

    }

    return defined $result;

}

sub readonly {

    return 1;

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub __initialize {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'source'} ) {

        if ( defined $args->{'source'} ) {

            if ( blessed $args->{'source'} ) {
                $self->{'source'} = $args->{'source'};
            }
            elsif ( ref $args->{'source'} eq 'CODE' ) {
                $self->{'source'} = $args->{'source'};
            }
            else {
                $self->{'source'} = eval { IO::Handle->new_from_fd( $args->{'source'}, '<' ) };
            }

        }

        if ( ! $self->{'source'} ) {
            throw "Invalid argument (\"source\")";
        }

    }

    return;

}


1;

__END__

=head1 NAME

GX::HTTP::Body::Stream - Stream-based HTTP message body class

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Body::Stream;
    
    # Create a new filehandle-based body object
    $body = GX::HTTP::Body::Stream->new( *FH );
    
    # Create a new callback-based body object
    $body = GX::HTTP::Body::Stream->new( \&code );
    
    # Print the message body
    $body->print_to( *STDOUT );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Body::Stream> class which extends the
L<GX::HTTP::Body> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Body::Stream> object.

    $body = GX::HTTP::Body::Stream->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<source> ( object | typeglob | C<GLOB> reference | C<CODE> reference )

The source of the content stream.

=back

=item Returns:

=over 4

=item * C<$body> ( L<GX::HTTP::Body::Stream> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Alternative syntax:

    $body = GX::HTTP::Body::Stream->new( $source );

=over 4

=item Arguments:

=over 4

=item * C<$source> ( object | typeglob | C<GLOB> reference | C<CODE> reference )

=back

=item Returns:

=over 4

=item * C<$body> ( L<GX::HTTP::Body::Stream> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<length>

Returns "-1".

    $length = $body->length;

=over 4

=item Returns:

=over 4

=item * C<$length> ( integer )

Always "-1".

=back

=back

=head3 C<print_to>

Prints the message body to the given filehandle, returning true on success or
false on failure.

    $result = $body->print_to( $handle );

=over 4

=item Arguments:

=over 4

=item * C<$handle> ( L<IO::File> object | typeglob | C<GLOB> reference )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<readonly>

Returns true.

    $bool = $body->readonly;

=over 4

=item Returns:

=over 4

=item * C<$bool> ( bool )

Always true.

=back

=back

=head3 C<source>

Returns the source of the content stream.

    $source = $body->source;

=over 4

=item Returns:

=over 4

=item * C<$source> ( object | typeglob | C<GLOB> reference | C<CODE> reference )

=back

=back

=head1 EXAMPLES

=head2 Content Sources

B<Example #1>

Simple callback example:

    my $body = GX::HTTP::Body::Stream->new( sub {
    
        my $outstream = shift;
    
        for ( 1 .. 10 ) {
            $outstream->print( $_ );
            $outstream->flush;
            sleep( 1 );
        }
    
        return;
    
    } );

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
