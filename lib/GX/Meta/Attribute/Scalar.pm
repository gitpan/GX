# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Attribute/Scalar.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Attribute::Scalar;

use strict;
use warnings;

use base 'GX::Meta::Attribute';

use GX::Meta::Exception;

use Scalar::Util qw( weaken );


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub type {

    return 'Scalar';

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub assign_to_slot {

    my $self  = shift;
    my $store = shift;
    my $value = shift;

    if ( ref $value && $self->_get_options->{'weaken'} ) {
        weaken( $store->{$self->slot_key} = $value );
    }
    else {
        $store->{$self->slot_key} = $value;
    }

    return;

}

sub create_accessor {

    my $self = shift;
    my %args = @_;

    my $name = $args{'name'} // $self->name;
    my $type = $args{'type'} // 'default';

    my $data = {};
    my $code = [];
    my $vars = {};

    push @$code,
        'package ' . ref( $self ) . ';',
        'sub {';

    $self->_inline_accessor_prologue( $data, $code, $vars );

    if ( $type eq 'default' ) {

        push @$code, 'if ( @_ > 1 ) {';
        $self->_inline_set_value( $data, $code, $vars, '$_[1]' );
        push @$code, '} else {';
        $self->_inline_prepare_slot( $data, $code, $vars );
        push @$code, '}';

        $self->_inline_return_slot( $data, $code, $vars );

    }
    elsif ( $type eq 'get' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        $self->_inline_return_slot( $data, $code, $vars );

    }
    elsif ( $type eq 'set' ) {

        $self->_inline_set_value( $data, $code, $vars, '$_[1]' );

        push @$code, 'return;';

    }
    elsif ( $type eq 'defined' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return defined ' . $data->{'slot'} . ';';

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


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _inline_set_slot_to_value {

    my $self  = shift;
    my $data  = shift;
    my $code  = shift;
    my $vars  = shift;
    my $value = shift;

    if ( defined $value ) {

        my $var = '$EVAL_VAR_' . keys %$vars;

        $vars->{$var} = $value;

        $self->_inline_assign_to_slot( $data, $code, $vars, $var );

        if ( ref $value && $self->_get_options->{'weaken'} ) {
            push @$code, 'Scalar::Util::weaken( ' . $data->{'slot'} . ' );';
        }

    }
    else {
        $self->_inline_assign_to_slot( $data, $code, $vars, 'undef' );
    }

    return;

}

sub _inline_set_slot_to_initializer_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    $self->SUPER::_inline_set_slot_to_initializer_value( $data, $code, $vars );

    $self->_inline_weaken_slot_value( $data, $code, $vars );

    return;

}

sub _inline_set_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    $self->SUPER::_inline_set_value( $data, $code, $vars, $var );

    $self->_inline_weaken_slot_value( $data, $code, $vars );
    
    return;

}

sub _inline_weaken_slot_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    if ( $self->_get_options->{'weaken'} ) {
        push @$code, 'Scalar::Util::weaken( ' . $data->{'slot'} . ' ) if ref ' . $data->{'slot'} . ';';
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

GX::Meta::Attribute::Scalar - Attribute metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Attribute::Scalar> class which extends
the L<GX::Meta::Attribute> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Meta::Attribute::Scalar> attribute metaobject.

    $attribute = GX::Meta::Attribute::Scalar->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<weaken> ( bool )

A boolean value indicating whether or not to L<weaken|Scalar::Util/weaken> the
stored attribute value. Defaults to false.

=item * See L<GX::Meta::Attribute|GX::Meta::Attribute/new> for more.

=back

=item Returns:

=over 4

=item * C<$attribute> ( L<GX::Meta::Attribute::Scalar> object )

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

    $value = $invocant->accessor;
    $value = $invocant->accessor( $value );

=item * C<defined>

    $bool = $invocant->accessor;

=item * C<get>

    $value = $invocant->accessor;

=item * C<set>

    $invocant->accessor( $value );

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
