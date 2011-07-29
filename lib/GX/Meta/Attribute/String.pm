# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Attribute/String.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Attribute::String;

use strict;
use warnings;

use base 'GX::Meta::Attribute';

use GX::Meta::Exception;


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant TYPE_CONSTRAINT => sub { defined $_[1] && ! ref $_[1] };


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub type {

    return 'String';

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

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
    elsif ( $type eq 'clear' ) {

        $self->_inline_delete_slot( $data, $code, $vars );

        push @$code, 'return;';

    }
    elsif ( $type eq 'length' ) {

        $self->_inline_prepare_slot( $data, $code, $vars );

        push @$code, 'return length ' . $data->{'slot'} . ';';

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

    return '';

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _inline_set_slot_to_native_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    $self->_inline_assign_to_slot( $data, $code, $vars, '\'\'' );

    return;

}


1;

__END__

=head1 NAME

GX::Meta::Attribute::String - Attribute metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Attribute::String> class which extends
the L<GX::Meta::Attribute> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Meta::Attribute::String> attribute metaobject.

    $attribute = GX::Meta::Attribute::String->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<default> ( string )

See L<GX::Meta::Attribute|GX::Meta::Attribute/new>. The supplied value must be
a string.

=item * C<initializer> ( string | C<CODE> reference )

See L<GX::Meta::Attribute|GX::Meta::Attribute/new>. The initializer must
return a string.

=item * See L<GX::Meta::Attribute|GX::Meta::Attribute/new> for more.

=back

=item Returns:

=over 4

=item * C<$attribute> ( L<GX::Meta::Attribute::String> object )

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

=item * C<get>

    $value = $invocant->accessor;

=item * C<length>

    $length = $invocant->accessor;

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
