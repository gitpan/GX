# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Renderer.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Renderer;

use GX::Exception;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'handlers' => (
    isa        => 'Hash',
    initialize => 1
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub can_render {

    my $self   = shift;
    my $format = shift;

    return defined $format && $self->{'handlers'}{$format} || $self->{'handlers'}{'*'} ? 1 : 0;

}

sub clone {

    my $self = shift;

    my $clone = bless {}, ref $self;

    $clone->{'handlers'} = { %{$self->{'handlers'}} };

    return $clone;

}

sub formats {

    return sort keys %{$_[0]->{'handlers'}};

}

sub handler {

    my $self   = shift;
    my $format = shift;

    if ( @_ ) {

        if ( ! defined $format ) {
            complain "Invalid argument";
        }

        my $handler = shift;

        if ( defined $handler ) {

            if ( blessed $handler && $handler->isa( 'GX::Callback' ) ) {
                return $self->{'handlers'}{$format} = $handler;
            }
            else {
                complain "Invalid argument";
            }

        }
        else {
            delete $self->{'handlers'}{$format};
        }

        return $handler;

    }

    return defined $format ? $self->{'handlers'}{$format} : undef;

}

sub handlers {

    return @{$_[0]->{'handlers'}}{$_[0]->formats};

}

sub merge {

    my $self = shift;

    for my $renderer ( @_ ) {

        if ( ! blessed $renderer || ! $renderer->isa( __PACKAGE__ ) ) {
            complain "Invalid argument";
        }

        for my $format ( $renderer->formats ) {
            $self->handler( $format => $renderer->handler( $format ) );
        }

    }

    return;

}

sub render {

    my $self   = shift;
    my $format = shift;

    my $handler = ( defined $format && $self->{'handlers'}{$format} ) || $self->{'handlers'}{'*'};

    if ( ! $handler ) {
        return if defined wantarray;
        complain "Render error (no format handler)";
    }

    eval {
        $handler->call( @_ );
    };

    if ( $@ ) {
        complain $@;
    }

    return 1;

}


1;

__END__

=head1 NAME

GX::Renderer - Renderer class 

=head1 SYNOPSIS

    # Load the module
    use GX::Renderer;
    
    # Create a new renderer
    my $renderer = GX::Renderer->new;
    
    # Set the renderer's "xml"-format handler
    $renderer->handler(
        xml => GX::Callback::Method->new(
            invocant => $application->view( 'XML' ),
            method   => 'render'
        )
    );
    
    # Render
    $renderer->render( xml => ( context => $context, tidy => 1 ) );


=head1 DESCRIPTION

This module provides the L<GX::Renderer> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Renderer> object.

    $renderer = GX::Renderer->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<handlers> ( C<HASH> reference )

A reference to a hash with format / handler pairs. Handlers must be
L<GX::Callback> objects.

=back

=item Returns:

=over 4

=item * C<$renderer> ( L<GX::Renderer> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<can_render>

Returns true if the renderer can handle the specified format, otherwise false.

    $result = $renderer->can_render( $format );

=over 4

=item Arguments:

=over 4

=item * C<$format> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<clone>

Clones the renderer.

    $clone = $renderer->clone;

=over 4

=item Returns:

=over 4

=item * C<$clone> ( L<GX::Renderer> object )

=back

=back

=head3 C<formats>

Returns a list with the formats supported by the renderer.

    @formats = $renderer->formats;

=over 4

=item Returns:

=over 4

=item * C<@formats> ( strings )

=back

=back

=head3 C<handler>

Returns / sets the handler for the specified format.

    $handler = $renderer->handler( $format );
    $handler = $renderer->handler( $format, $handler );

=over 4

=item Arguments:

=over 4

=item * C<$format> ( string )

=item * C<$handler> ( L<GX::Callback> object | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$handler> ( L<GX::Callback> object | C<undef> )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<handlers>

Returns all format handlers.

    @handlers = $renderer->handlers;

=over 4

=item Returns:

=over 4

=item * C<@handlers> ( L<GX::Callback> objects )

=back

=back

=head3 C<merge>

Adds the format handlers from the given renderers.

    $renderer->merge( @renderers );

=over 4

=item Arguments:

=over 4

=item * C<@renderers> ( L<GX::Renderer> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Already existing handlers are replaced.

=head3 C<render>

Executes the specified format handler.

    $renderer->render( $format, @arguments );

=over 4

=item Arguments:

=over 4

=item * C<$format> ( string )

=item * C<@arguments> ( scalars )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Exceptions raised in the handler are caught and rethrown. If C<render()> is
called in void context, an exception is raised if the specified format is not
supported by the renderer. In non-void context, C<render()> returns false if
the specified format is not supported, otherwise true.

    $result = $renderer->render( $format, @arguments );


=over 4

=item Arguments:

=over 4

=item * C<$format> ( string )

=item * C<@arguments> ( scalars )

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

=head1 USAGE

=head2 Fallback Handler

If set, the "*" format handler acts as a fallback.

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
