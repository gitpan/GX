# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Callback/Method.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Callback::Method;

use GX::Exception;
use GX::Meta::Constants qw( REGEX_CLASS_NAME REGEX_METHOD_NAME );

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Callback';

has 'invocant' => (
    isa        => 'Scalar',
    constraint => sub { defined && ( blessed $_ || $_ =~ REGEX_CLASS_NAME ) },
    required   => 1,
    weaken     => 1,
    accessor   => { type => 'get' }
);

has 'method' => (
    isa        => 'String',
    constraint => sub { $_ =~ REGEX_METHOD_NAME },
    required   => 1,
    accessor   => { type => 'get' }
);

has 'code' => (
    isa         => 'Scalar',
    constraint  => sub { ref eq 'CODE' },
    initialize  => 1,
    initializer => sub { $_->invocant->can( $_->method ) // throw "Method does not exist" },
    accessor    => { type => 'get' }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub call {

    my $self = shift;

    return $self->{'code'}->( $self->{'invocant'}, ( $self->{'arguments'} ? @{$self->{'arguments'}} : () ), @_ );

}


1;

__END__

=head1 NAME

GX::Callback::Method - Method-based callback class

=head1 SYNOPSIS

    # Load the class
    use GX::Callback::Method;
    
    # Create a new callback object
    $callback = GX::Callback::Method->new(
        invocant => MyApp::View::XML->instance,
        method   => 'render'
    );
    
    # Execute the callback
    $callback->call( context => $context );

=head1 DESCRIPTION

This module provides the L<GX::Callback::Method> class which extends the
L<GX::Callback> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Callback::Method> object.

    $callback = GX::Callback::Method->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<arguments> ( C<ARRAY> reference )

A reference to an array with arguments to pass to the callback method when it
is called.

=item * C<invocant> ( string | object ) [ required ]

The invocant, which can be either a class name or an object.

=item * C<method> ( string ) [ required ]

The name of the callback method.

=back

=item Returns:

=over 4

=item * C<$callback> ( L<GX::Callback::Method> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<arguments>

Returns the callback method arguments.

    @arguments = $callback->arguments;

=over 4

=item Returns:

=over 4

=item * C<@arguments> ( scalars )

=back

=back

=head3 C<call>

Calls the callback method.

    $callback->call( @arguments );

=over 4

=item Arguments:

=over 4

=item * C<@arguments> ( scalars )

Additional arguments to pass to the callback method.

=back

=back

=head3 C<code>

Returns a reference to the callback method.

    $code = $callback->code;

=over 4

=item Returns:

=over 4

=item * C<$code> ( C<CODE> reference )

=back

=back

=head3 C<invocant>

Returns the invocant.

    $invocant = $callback->invocant;

=over 4

=item Returns:

=over 4

=item * C<$invocant> ( string | object )

=back

=back

=head3 C<method>

Returns the name of the callback method.

    $method = $callback->method;

=over 4

=item Returns:

=over 4

=item * C<$method> ( string )

=back

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
