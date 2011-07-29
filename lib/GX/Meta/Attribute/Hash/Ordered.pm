# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Attribute/Hash/Ordered.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Attribute::Hash::Ordered;

use strict;
use warnings;

use base 'GX::Meta::Attribute::Hash';

use GX::Meta::Exception;
use GX::Tie::Hash::Ordered;


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant TYPE_CONSTRAINT => sub {
    ref $_[1] eq 'HASH' && ref( tied %{$_[1]} ) eq 'GX::Tie::Hash::Ordered'
};


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub type {

    return 'Hash::Ordered';

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
    elsif ( $type eq 'set_value' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'my %data = @_;';

        $self->_inline_preprocess_value( $data, $code, $vars, '\%data' );
        $self->_inline_check_value_constraints( $data, $code, $vars, '\%data' );
        $self->_inline_process_value( $data, $code, $vars, '\%data' );

        push @$code,
            'while ( my ( $key, $value ) = each %data ) {',
            $data->{'slot'} . '{$key} = $value;' ,
            '}';

        push @$code, 'return;';

    }
    elsif ( $type eq 'set_values' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code,
            'tie my %data, \'GX::Tie::Hash::Ordered\';',
            '%data = @_;';

        $self->_inline_preprocess_value( $data, $code, $vars, '\%data' );
        $self->_inline_check_value_constraints( $data, $code, $vars, '\%data' );
        $self->_inline_process_value( $data, $code, $vars, '\%data' );

        push @$code,
            'while ( my ( $key, $value ) = each %data ) {',
            $data->{'slot'} . '{$key} = $value;',
            '}';

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

    tie my %hash, 'GX::Tie::Hash::Ordered';

    return \%hash;

}

sub weaken_slot_values {

    throw "Unsupported";

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

    push @$code, 'if ( ! exists ' . $data->{'slot'} . ' ) {';
    $self->_inline_set_slot_to_native_value( $data, $code, $vars );
    push @$code, '}';

    push @$code, '%{ ' . $data->{'slot'} . ' } = ' . $var . ';';

    return;

}

sub _inline_set_slot_to_native_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    push @$code, 'tie my %hash, \'GX::Tie::Hash::Ordered\';';

    $self->_inline_assign_to_slot( $data, $code, $vars, '\%hash' );

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

    return;

}

sub _inline_set_values {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    if ( $self->_get_preprocessors || $self->_get_processors || $self->_get_value_constraints ) {

        push @$code,
            'tie my %data, \'GX::Tie::Hash::Ordered\';',
            '%data = ' . $var . ';';

        $self->_inline_preprocess_value( $data, $code, $vars, '\%data' );
        $self->_inline_check_value_constraints( $data, $code, $vars, '\%data' );
        $self->_inline_process_value( $data, $code, $vars, '\%data' );
        $self->_inline_assign_list_to_slot( $data, $code, $vars, '%data' );

    }
    else {
        $self->_inline_assign_list_to_slot( $data, $code, $vars, $var );
    }

    return;

}

sub _inline_weaken_slot_values {

    throw "Unsupported";

}


# ----------------------------------------------------------------------------------------------------------------------
# Object initialization
# ----------------------------------------------------------------------------------------------------------------------

sub __initialize_options {

    my $self = shift;
    my $args = shift;

    throw "Unsupported" if delete $args->{'weaken'};

    $self->SUPER::__initialize_options( $args );

    return;

}


1;

__END__

=head1 NAME

GX::Meta::Attribute::Hash::Ordered - Attribute metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Attribute::Hash::Ordered> class which
extends the L<GX::Meta::Attribute::Hash> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Meta::Attribute::Hash::Ordered> attribute metaobject.

    $attribute = GX::Meta::Attribute::Hash::Ordered->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * See L<GX::Meta::Attribute::Hash|GX::Meta::Attribute::Hash/new>. The
"weaken" option is not available for this attribute type.

=back

=item Returns:

=over 4

=item * C<$attribute> ( L<GX::Meta::Attribute::Hash::Ordered> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head2 Public Methods

See L<GX::Meta::Attribute::Hash|GX::Meta::Attribute::Hash/"Public Methods">.

=head1 USAGE

=head2 Accessor Types

See L<GX::Meta::Attribute::Hash/"Accessor Types">.

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
