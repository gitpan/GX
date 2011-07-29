# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Attribute/Object.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Attribute::Object;

use strict;
use warnings;

use base 'GX::Meta::Attribute::Scalar';

use GX::Meta::Exception;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant TYPE_CONSTRAINT => sub { blessed $_[1] };


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add_delegator {

    my $self = shift;

    my $delegator = eval {
        $self->create_delegator( @_ );
    };

    if ( ! $delegator ) {
        GX::Exception->complain(
            message      => "Cannot create delegator",
            subexception => $@
        );
    }

    push @{$self->{'delegators'}}, $delegator;

    return $delegator;

}

sub delegators {

    return @{ $_[0]->{'delegators'} || return };

}

sub install {

    my $self = shift;

    eval {
        $self->SUPER::install;
        $self->install_delegators;
    };

    if ( $@ ) {
        complain $@;
    }

    return;

}

sub install_delegators {

    my $self = shift;

    for my $delegator ( $self->delegators ) {

        if ( my $method = $self->class->method( $delegator->name ) ) {
            next if $method->code == $delegator->code;
            complain sprintf( "Cannot install delegator (method &%s already exists)", $method->full_name );
        }
        else {
            $self->class->add_method( $delegator->name, $delegator->code );
        }

    }

    return;

}

sub type {

    return 'Object';

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub create_delegator {

    my $self = shift;
    my %args = @_;

    my $name = $args{'name'} // $self->name;
    my $to   = $args{'to'}   // $name;

    my $data = {};
    my $code = [];
    my $vars = {};

    push @$code,
        'package ' . ref( $self ) . ';',
        'sub {',
        'my $invocant = shift;';

    $data->{'invocant'} = '$invocant';

    $self->_inline_accessor_prologue( $data, $code, $vars );

    $self->_inline_prepare_slot( $data, $code, $vars );

    push @$code,
        'return ' . $data->{'slot'} . '->' . $to . '( @_ );',
        '}';

    my $delegator = eval {
        GX::Meta::Delegator->new(
            attribute => $self,
            name      => $name,
            code      => GX::Meta::Util::eval_code( $code, $vars )
        )
    };

    if ( ! $delegator ) {
        complain $@;
    }

    return $delegator;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _get_delegators {

    return $_[0]->{'delegators'};

}


# ----------------------------------------------------------------------------------------------------------------------
# Object initialization
# ----------------------------------------------------------------------------------------------------------------------

sub __initialize_delegators {

    my $self = shift;
    my $args = shift;

    my @delegators;

    if ( exists $args->{'delegator'} ) {

        if ( defined $args->{'delegator'} ) {
            push @delegators, $args->{'delegator'};
        }

        delete $args->{'delegator'};

    }

    if ( exists $args->{'delegators'} ) {

        if ( ref $args->{'delegators'} ne 'ARRAY' ) {
            throw "Invalid option (\"delegators\" must be an array reference)";
        }

        push @delegators, @{$args->{'delegators'}};

        delete $args->{'delegators'};

    }

    for my $delegator ( @delegators ) {

        if ( ref $delegator eq 'HASH' ) {
            $self->add_delegator( %$delegator );
        }
        else {
            $self->add_delegator( name => $delegator );
        }

    }

    return;

}

sub __initialize_other {

    my $self = shift;
    my $args = shift;

    $self->__initialize_delegators( $args );

    return;

}


1;

__END__

=head1 NAME

GX::Meta::Attribute::Object - Attribute metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Attribute::Object> class which extends
the L<GX::Meta::Attribute::Scalar> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Meta::Attribute::Object> attribute metaobject.

    $attribute = GX::Meta::Attribute::Object->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<default> ( object | C<undef> )

See L<GX::Meta::Attribute|GX::Meta::Attribute/new>. The supplied value must be
a blessed reference or C<undef>.

=item * C<delegator> ( string | C<HASH> reference )

A method name or delegator definition.

=item * C<delegators> ( C<ARRAY> reference )

A reference to an array containing method names and / or delegator
definitions.

=item * C<initializer> ( string | C<CODE> reference )

See L<GX::Meta::Attribute|GX::Meta::Attribute/new>. The initializer must
return a blessed reference or C<undef>.

=item * C<weaken> ( bool )

A boolean flag indicating whether or not to L<weaken|Scalar::Util/weaken> the
stored reference. Defaults to false.

=item * See L<GX::Meta::Attribute|GX::Meta::Attribute/new> for more.

=back

=item Returns:

=over 4

=item * C<$attribute> ( L<GX::Meta::Attribute::Object> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head2 Public Methods

Also see L<GX::Meta::Attribute|GX::Meta::Attribute/"Public Methods">.

=head3 C<add_delegator>

Creates a new delegator metaobject for the attribute and adds it.

    $delegator = $attribute->add_delegator( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<%arguments> ( named list )

Arguments to pass to the L<GX::Meta::Delegator> L<constructor|GX::Meta::Delegator/new>.

=back

=item Returns:

=over 4

=item * C<$delegator> ( L<GX::Meta::Delegator> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<delegators>

Returns the associated delegator metaobjects.

    @delegators = $attribute->delegators;

=over 4

=item Returns:

=over 4

=item * C<@delegators> ( L<GX::Meta::Delegator> objects )

=back

=back

=head3 C<install_delegators>

Installs the delegators.

    $attribute->install_delegators;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head1 USAGE

=head2 Accessor Types

See L<GX::Meta::Attribute::Scalar/"Accessor Types">.

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
