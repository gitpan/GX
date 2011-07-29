# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Attribute/Hash.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Attribute::Hash;

use strict;
use warnings;

use base 'GX::Meta::Attribute';

use GX::Meta::Exception;

use Scalar::Util qw( isweak weaken );


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant TYPE_CONSTRAINT => sub { ref $_[1] eq 'HASH' };


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub type {

    return 'Hash';

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

        push @$code, 'return wantarray ? %{' . $data->{'slot'} . '} : ' . $data->{'slot'} . ';';

    }
    elsif ( $type eq 'get' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return wantarray ? %{' . $data->{'slot'} . '} : ' . $data->{'slot'} . ';';

    }
    elsif ( $type eq 'get_list' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return %{' . $data->{'slot'} . '};';

    }
    elsif ( $type eq 'get_reference' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return ' . $data->{'slot'} . ';';

    }
    elsif ( $type eq 'get_value' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return ' . $data->{'slot'} . '{$_[0]};';

    }
    elsif ( $type eq 'set' ) {

        $self->_inline_set_values( $data, $code, $vars, '@_' );

        push @$code, 'return;';

    }
    elsif ( $type eq 'set_value' or $type eq 'set_values' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'my %data = @_;';

        $self->_inline_preprocess_value( $data, $code, $vars, '\%data' );
        $self->_inline_check_value_constraints( $data, $code, $vars, '\%data' );
        $self->_inline_process_value( $data, $code, $vars, '\%data' );

        push @$code,
            'while ( my ( $key, $value ) = each %data ) {',
            $data->{'slot'} . '{$key} = $value;';

        if ( $self->_get_options->{'weaken'} ) {
            push @$code,
                'Scalar::Util::weaken( ' . $data->{'slot'} . '{$key}' . ' ) if ref $value;'
        }

        push @$code, '}';

        push @$code, 'return;';

    }
    elsif ( $type eq 'delete' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return delete ' . $data->{'slot'} . '{$_[0]};';

    }
    elsif ( $type eq 'exists' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return exists ' . $data->{'slot'} . '{$_[0]};';

    }
    elsif ( $type eq 'size' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return scalar keys %{' . $data->{'slot'} . '};';

    }
    elsif ( $type eq 'get_keys' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return keys %{' . $data->{'slot'} . '};';

    }
    elsif ( $type eq 'get_values' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return values %{' . $data->{'slot'} . '};';

    }
    elsif ( $type eq 'clear' ) {

        $self->_inline_delete_slot( $data, $code, $vars );

        push @$code, 'return;';

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

    return {};

}

sub set_value {

    my $self    = shift;
    my $context = shift;
    my $store   = shift;
    my $value   = shift;

    $self->SUPER::set_value( $context, $store, $value );

    $self->weaken_slot_values( $store ) if $self->_get_options->{'weaken'};

    return;

}

sub weaken_slot_values {

    my $self  = shift;
    my $store = shift;

    my $slot = $store->{$self->slot_key};

    while ( my $key = each %$slot ) {
        ref( $slot->{$key} ) && ( isweak( $slot->{$key} ) || weaken( $slot->{$key} ) );
    }

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

    push @$code, '%{ ' . $data->{'slot'} . ' } = ' . $var . ';';

    return;

}

sub _inline_set_slot_to_native_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    $self->_inline_assign_to_slot( $data, $code, $vars, '{}' );

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

    if ( $self->_get_preprocessors || $self->_get_processors || $self->_get_value_constraints ) {
        push @$code, 'my %data = ' . $var . ';';
        $self->_inline_preprocess_value( $data, $code, $vars, '\%data' );
        $self->_inline_check_value_constraints( $data, $code, $vars, '\%data' );
        $self->_inline_process_value( $data, $code, $vars, '\%data' );
        $self->_inline_assign_list_to_slot( $data, $code, $vars, '%data' );
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
            '{',
            '    my $slot = ' . $data->{'slot'} . ';',
            '    while ( my $key = each %$slot ) {',
            '        ref( $slot->{$key} ) &&',
            '        ( Scalar::Util::isweak( $slot->{$key} ) || Scalar::Util::weaken( $slot->{$key} ) );',
            '    }',
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

GX::Meta::Attribute::Hash - Attribute metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Attribute::Hash> class which extends the
L<GX::Meta::Attribute> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Meta::Attribute::Hash> attribute metaobject.

    $attribute = GX::Meta::Attribute::Hash->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<default> ( C<HASH> reference )

See L<GX::Meta::Attribute|GX::Meta::Attribute/new>. The supplied value must be
a reference to a hash.

=item * C<initializer> ( string | C<CODE> reference )

See L<GX::Meta::Attribute|GX::Meta::Attribute/new>. The initializer must
return a reference to a hash.

=item * C<weaken> ( bool )

A boolean flag indicating whether or not to L<weaken|Scalar::Util/weaken> the
stored attribute values. Defaults to false.

=item * See L<GX::Meta::Attribute|GX::Meta::Attribute/new> for more.

=back

=item Returns:

=over 4

=item * C<$attribute> ( L<GX::Meta::Attribute::Hash> object )

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

    %data = $invocant->accessor;
    %data = $invocant->accessor( %data );

    $data = $invocant->accessor( ... );

=item * C<delete>

    $value = $invocant->accessor( $key );

=item * C<exists>

    $bool = $invocant->accessor( $key );

=item * C<get>

    %data = $invocant->accessor;
    $data = $invocant->accessor;

=item * C<get_keys>

    @keys = $invocant->get_keys;

=item * C<get_list>

    %data = $invocant->accessor;

=item * C<get_reference>

    $data = $invocant->accessor;

=item * C<get_value>

    $value = $invocant->accessor( $key );

=item * C<get_values>

    @values = $invocant->get_values;

=item * C<set>

    $invocant->accessor( %data );

=item * C<set_value>

    $invocant->accessor( $key => $value );

=item * C<set_values>

    $invocant->accessor( $key => $value, ... );

=item * C<size>

    $size = $invocant->size;

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
