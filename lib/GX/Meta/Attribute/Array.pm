# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Attribute/Array.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Attribute::Array;

use strict;
use warnings;

use base 'GX::Meta::Attribute';

use GX::Meta::Exception;

use Scalar::Util qw( isweak weaken );


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant TYPE_CONSTRAINT => sub { ref $_[1] eq 'ARRAY' };


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub type {

    return 'Array';

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub create_accessor {

    my $self = shift;
    my %args = @_;

    my $name = $args{'name'} // $self->name;
    my $type = $args{'type'} // 'default';

    my $data = { 'invocant' => '$invocant' };
    my $code = [];
    my $vars = {};

    push @$code,
        'package ' . ref( $self ) . ';',
        'sub {',
        'my $invocant = shift;';

    $self->_inline_accessor_prologue( $data, $code, $vars );

    if ( $type eq 'default' ) {

        push @$code, 'if ( @_ ) {';
        $self->_inline_set_values( $data, $code, $vars, '@_' );
        push @$code, '} else {';
        $self->_inline_prepare_slot( $data, $code, $vars );
        push @$code, '}';

        push @$code, 'return wantarray ? @{' . $data->{'slot'} . '} : ' . $data->{'slot'} . ';';

    }
    elsif ( $type eq 'get' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return wantarray ? @{' . $data->{'slot'} . '} : ' . $data->{'slot'} . ';';


    }
    elsif ( $type eq 'get_list' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return @{' . $data->{'slot'} . '};';

    }
    elsif ( $type eq 'get_reference' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return ' . $data->{'slot'} . ';';

    }
    elsif ( $type eq 'set' ) {

        $self->_inline_set_values( $data, $code, $vars, '@_' );

        push @$code, 'return;';

    }
    elsif ( $type eq 'clear' ) {

        $self->_inline_delete_slot( $data, $code, $vars );

        push @$code, 'return;';

    }
    elsif ( $type eq 'size' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return scalar @{' . $data->{'slot'} . '};';

    }
    else {
        complain "Unsupported accessor type: \"$type\"";
    }

    push @$code, '}';

    my $accessor = eval {
        GX::Meta::Accessor->new(
            attribute => $self,
            name      => $name,
            type      => $type,
            code      => GX::Meta::Util::eval_code( $code, $vars )
        );
    };

    if ( ! $accessor ) {
        complain $@;
    }

    return $accessor;

}

sub native_value {

    return [];

}

sub set_value {

    my $self    = shift;
    my $context = shift;
    my $store   = shift;
    my $value   = shift;

    $self->SUPER::set_value( $context, $store, $value );

    if ( $self->_get_options->{'weaken'} ) {
        $self->weaken_slot_values( $store );
    }

    return;

}

sub weaken_slot_values {

    my $self  = shift;
    my $store = shift;

    my $slot = $store->{$self->slot_key};

    ref( $_ ) && ( isweak( $_ ) || weaken( $_ ) ) for @$slot;

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _inline_assign_list_to_slot {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    push @$code, '@{' . $data->{'slot'} . '} = ' . $var . ';';

    return;

}

sub _inline_set_slot_to_native_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    $self->_inline_assign_to_slot( $data, $code, $vars, '[]' );

    return;

}

sub _inline_set_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    $self->_inline_preprocess_value( $data, $code, $vars, $var );
    $self->_inline_check_constraints( $data, $code, $vars, $var );
    $self->_inline_process_value( $data, $code, $vars, $var );
    $self->_inline_assign_to_slot( $data, $code, $vars, $var );
    $self->_inline_weaken_slot_values( $data, $code, $vars, $var );

    return;

}

sub _inline_set_values {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    if ( $self->_get_preprocessors || $self->_get_processors ) {
        push @$code, 'my @data = ' . $var . ';';
        $self->_inline_preprocess_value( $data, $code, $vars, '\@data' );
        $self->_inline_check_value_constraints( $data, $code, $vars, '\@data' );
        $self->_inline_process_value( $data, $code, $vars, '\@data' );
        $self->_inline_assign_list_to_slot( $data, $code, $vars, '@data' );
    }
    elsif ( $self->_get_value_constraints ) {
        $self->_inline_check_value_constraints( $data, $code, $vars, '\\' . $var );
        $self->_inline_assign_list_to_slot( $data, $code, $vars, $var );
    }
    else {
        $self->_inline_assign_list_to_slot( $data, $code, $vars, $var );
    }

    $self->_inline_weaken_slot_values( $data, $code, $vars, $var );

    return;

}

sub _inline_weaken_slot_values {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    if ( $self->_get_options->{'weaken'} ) {
        push @$code,
            'for ( @{ ' . $data->{'slot'} . ' } ) {',
            '    Scalar::Util::weaken( $_ ) if ref( $_ ) && ! Scalar::Util::isweak( $_ );',
            '}';
    }

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Object initialization
# ----------------------------------------------------------------------------------------------------------------------

sub __initialize_options {

    my $self = shift;
    my $args = shift;

    $self->SUPER::__initialize_options( $args );

    for ( qw( weaken ) ) {
        $self->_get_options->{$_} = 1 if delete $args->{$_};
    }

    return;

}


1;

__END__

=head1 NAME

GX::Meta::Attribute::Array - Attribute metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Attribute::Array> class which extends the
L<GX::Meta::Attribute> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Meta::Attribute::Array> attribute metaobject.

    $attribute = GX::Meta::Attribute::Array->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<default> ( C<ARRAY> reference )

See L<GX::Meta::Attribute|GX::Meta::Attribute/new>. The supplied value must be
a reference to an array.

=item * C<initializer> ( string | C<CODE> reference )

See L<GX::Meta::Attribute|GX::Meta::Attribute/new>. The initializer must
return a reference to an array.

=item * C<weaken> ( bool )

A boolean flag indicating whether or not to L<weaken|Scalar::Util/weaken> the
stored attribute values. Defaults to false.

=item * See L<GX::Meta::Attribute|GX::Meta::Attribute/new> for more.

=back

=item Returns:

=over 4

=item * C<$attribute> ( L<GX::Meta::Attribute::Array> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head2 Public Methods

See L<GX::Meta::Attribute|GX::Meta::Attribute/"Public Methods">.

=head1 USAGE

=head2 Accessor Types

This attribute class provides the following accessor types:

=over 4

=item * C<clear>

    $invocant->accessor;

=item * C<default>

    @values = $invocant->accessor;
    @values = $invocant->accessor( @values );
    
    $values = $invocant->accessor( ... );

=item * C<get>

    $values = $invocant->accessor;
    @values = $invocant->accessor;

=item * C<get_list>

    @values = $invocant->accessor;

=item * C<get_reference>

    $values = $invocant->accessor;

=item * C<set>

    $invocant->accessor( @values );

=item * C<size>

    $size = $invocant->accessor;

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Meta>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
