# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Parameters.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Parameters;

use GX::Exception;
use GX::HTTP::Util;

use Encode ();
use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'data' => (
    isa       => 'Hash::Ordered',
    accessors => {
        '_get_data' => { type => 'get_reference' }
    }
);

has 'encoding' => (
    isa => 'Scalar'
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { $_[0]->as_string },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    my $self = shift;
    my $key  = shift;

    if ( ! defined $key || ! length $key ) {
        complain "Invalid parameter name";
    }

    push @{$self->_get_data->{$key}}, map { defined $_ ? "$_" : undef } @_;

    return;

}

sub as_string {

    my $self = shift;

    my $data = $self->_get_data;

    my @pairs;

    if ( defined( my $encoding = $self->encoding ) ) {

        my $encoder = Encode::find_encoding( $encoding );

        if ( ! $encoder ) {
            complain "Cannot encode parameters (unsupported encoding)";
        }

        eval {

            while ( my ( $key, $values ) = each %$data ) {

                my $encoded_key = GX::HTTP::Util::url_encode( $encoder->encode( $key, Encode::FB_CROAK ) );

                for ( @$values ) {
                    push @pairs, $encoded_key . '=' . (
                        defined $_
                            ? GX::HTTP::Util::url_encode( $encoder->encode( $_, Encode::FB_CROAK ) )
                            : ''
                    );
                }

            }

        };

    }
    else {

        eval {

            while ( my ( $key, $values ) = each %$data ) {

                my $encoded_key = GX::HTTP::Util::url_encode( $key );

                for ( @$values ) {
                    push @pairs, $encoded_key . '=' . ( defined $_ ? GX::HTTP::Util::url_encode( $_ ) : '' );
                }

            }

        };

    }

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot encode parameters",
            subexception => $@
        );
    }

    return join( '&', @pairs );

}

sub count {

    return scalar keys %{$_[0]->_get_data};

}

sub decode {

    my $self     = shift;
    my $encoding = shift;

    $encoding //= $self->encoding // 'utf8';

    my $decoder = Encode::find_encoding( $encoding );

    if ( ! $decoder ) {
        complain "Cannot decode parameters (unsupported encoding)";
    }

    my $data = $self->_get_data;

    my @data;

    eval {

        while ( my ( $key, $values ) = each %$data ) {

            push @data, [
                $decoder->decode( $key, Encode::FB_CROAK ), 
                [ map { defined $_ ? $decoder->decode( $_, Encode::FB_CROAK ) : undef } @$values ]
            ];

        }

    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot decode parameters",
            subexception => $@
        );
    }

    %$data = map { $_->[0] => $_->[1] } @data;

    return;

}

sub exists {

    my $self = shift;
    my $key  = shift;

    return defined $key && exists $self->_get_data->{$key};

}

sub get {

    my $self = shift;
    my $key  = shift;

    defined $key or return;

    my $values = $self->_get_data->{$key} or return;

    return wantarray ? @$values : $values->[0];

}

sub keys {

    return keys %{$_[0]->_get_data};

}

sub merge {

    my $invocant = shift;

    my $self  = ref $invocant ? $invocant : $invocant->new;
    my $class = ref $self;

    my $data = $self->_get_data;

    for my $container ( @_ ) {

        if ( ! blessed $container || ! $container->isa( $class ) ) {
            complain "Invalid argument (arguments must be $class objects)";
        }

        for my $key ( $container->keys ) {
            push @{$data->{$key}}, $container->get( $key );
        }

    }

    return $self;

}

sub parse {

    my $self   = ref $_[0] ? shift : shift->new;
    my $string = shift;

    return $self unless defined $string && length $string;

    if ( utf8::is_utf8( $string ) ) {
        complain "Invalid argument (argument must be a byte string)";
    }

    my @pairs;

    for my $pair ( split( /&/, $string ) ) {

        my ( $key, $value ) = split( /=/, $pair, 2 );

        length $key or next;

        $key =~ tr/+/ /;
        $key =~ s/%([0-9a-fA-F]{2})/chr( hex( $1 ) )/eg;

        if ( defined $value ) {
            $value =~ tr/+/ /;
            $value =~ s/%([0-9a-fA-F]{2})/chr( hex( $1 ) )/eg;
        }
        else {
            $value = '';
        }

        push @pairs, [ $key, $value ];

    }

    if ( defined( my $encoding = $self->encoding ) ) {

        my $decoder = Encode::find_encoding( $encoding );

        if ( ! $decoder ) {
            complain "Cannot decode parameters (unsupported encoding)";
        }

        eval {

            for ( @pairs ) {
                $_->[0] = $decoder->decode( $_->[0], Encode::FB_CROAK );
                $_->[1] = $decoder->decode( $_->[1], Encode::FB_CROAK );
            }

        };

        if ( $@ ) {
            GX::Exception->complain(
                message      => "Cannot decode parameters",
                subexception => $@
            );
        }

    }

    my $data = $self->_get_data;

    for ( @pairs ) {
        push @{$data->{$_->[0]}}, $_->[1];
    }

    return $self;

}

sub remove {

    my $self = shift;
    my $key  = shift;

    defined $key or return;

    return delete $self->_get_data->{$key} ? 1 : 0;

}

sub set {

    my $self = shift;
    my $key  = shift;

    if ( ! defined $key || ! length $key ) {
        complain "Invalid parameter name";
    }

    if ( @_ ) {
        $self->_get_data->{$key} = [ map { defined $_ ? "$_" : undef } @_ ];
    }
    else {
        delete $self->_get_data->{$key};
    }

    return;

}


1;

__END__

=head1 NAME

GX::HTTP::Parameters - Container class for key / value pairs

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Parameters;
    
    # Create a new container object
    $parameters = GX::HTTP::Parameters->new;
    
    # Add a key / value pair
    $parameters->add( 'customer' => 'Wile E. Coyote' );
    
    # Get the (first) value for a key
    $value = $parameters->get( 'customer' );
    
    # Add multiple values for a key
    $parameters->add( 'shopping_cart' => ( 'Birdseed', 'Rocket Laucher' ) );
    
    # Get all values for a key
    @values = $parameters->get( 'shopping_cart' );
    
    # Parse a query string (or HTML form data)
    $parameters = GX::HTTP::Parameters->parse( 'customer=Wile%20E.%20Coyote' );
    
    # Get the container data as an URL-encoded string
    print $parameters->as_string;
    
    # Same as above
    print $parameters;

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Parameters> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Parameters> object.

    $parameters = GX::HTTP::Parameters->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<encoding> ( string )

The encoding to use in C<< L<parse()|/parse> >> and
C<< L<as_string()|/as_string> >>, for example "utf-8" or "iso-8859-1". See
L<Encode> for a list of supported encodings.

=back

=item Returns:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Also see C<< L<merge()|/merge> >> and C<< L<parse()|/parse> >>.

=head2 Public Methods

=head3 C<add>

Adds the given parameter key / value pair to the container.

    $parameters->add( $key, $value );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=item * C<$value> ( string )

=back

=back

Multiple values can be passed as a list:

    $parameters->add( $key, @values );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=item * C<@values> ( strings )

=back

=back

=head3 C<as_string>

Returns the parameter key / value pairs as an URL-encoded string of bytes.

    $string = $parameters->as_string;

=over 4

=item Returns:

=over 4

=item * C<$string> ( byte string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

This method uses the C<< L<url_encode()|GX::HTTP::Util/"url_encode"> >>
function from L<GX::HTTP::Util> internally, so spaces are encoded as "%20"
(and not as "+").

=head3 C<clear>

Empties the container and clears the L</encoding> attribute.

    $parameters->clear;

=head3 C<count>

Returns the number of (distinct) parameter keys.

    $count = $parameters->count;

=over 4

=item Returns:

=over 4

=item * C<$count> ( integer )

=back

=back

=head3 C<decode>

Decodes the parameter keys / values.

    $parameters->decode( $encoding );

=over 4

=item Arguments:

=over 4

=item * C<$encoding> ( string ) [ optional ]

Defaults to L<encoding|/encoding> or, as a final fallback, to "utf8".

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<encoding>

Returns / sets the encoding to use in C<< L<parse()|/parse> >> and
C<< L<as_string()|/as_string> >>.

    $encoding = $parameters->encoding;
    $encoding = $parameters->encoding( $encoding );

=over 4

=item Arguments:

=over 4

=item * C<$encoding> ( string ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$encoding> ( string )

=back

=back

=head3 C<exists>

Returns true if the specified parameter key exists, otherwise false.

    $result = $parameters->exists( $key );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<get>

Returns the values associated with the given parameter key in the order they
were added.

    @values = $parameters->get( $key );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=back

=item Returns:

=over 4

=item * C<@values> ( strings )

=back

=back

In scalar context, the first of those values is returned.

    $value = $parameters->get( $key );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=back

=item Returns:

=over 4

=item * C<$value> ( string )

=back

=back

=head3 C<keys>

Returns the (distinct) parameter keys.

    @keys = $parameters->keys;

=over 4

=item Returns:

=over 4

=item * C<@keys> ( strings )

=back

=back

=head3 C<merge>

Adds the key / value pairs from the given L<GX::HTTP::Parameters> objects.

    $parameters->merge( @parameters );

=over 4

=item Arguments:

=over 4

=item * C<@parameters> ( L<GX::HTTP::Parameters> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

This method can also be used as a constructor:

    $parameters = GX::HTTP::Parameters->merge( @parameters );

=over 4

=item Arguments:

=over 4

=item * C<@parameters> ( L<GX::HTTP::Parameters> objects )

=back

=item Returns:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<parse>

Parses an URL-encoded query string (or URL-encoded HTML form data) and adds
the resulting key / value pairs.

    $parameters->parse( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( byte string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

This method can also be used as a constructor:

    $parameters = GX::HTTP::Parameters->parse( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( byte string )

=back

=item Returns:

=over 4

=item * C<$parameters> ( L<GX::HTTP::Parameters> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<remove>

Removes the given key and all the values associated with it from the
container.

    $parameters->remove( $key );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=back

=back

=head3 C<set>

Same as C<< L<add()|/"add"> >>, but replaces any existing values for the
specified key with the ones given.

    $parameters->set( $key, $value );
    $parameters->set( $key, @values );

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
