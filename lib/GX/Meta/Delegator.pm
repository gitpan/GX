# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Delegator.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Delegator;

use strict;
use warnings;

use GX::Meta::Constants qw( REGEX_METHOD_NAME );
use GX::Meta::Exception;

use Scalar::Util qw( blessed weaken );


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { $_[0]->name },
    '&{}'      => sub { $_[0]->code },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;
    my %args  = @_;

    for ( qw( attribute code name ) ) {
        defined $args{$_} or complain "Missing argument (\"$_\")";
    }

    if ( ! ( blessed $args{'attribute'} && $args{'attribute'}->isa( 'GX::Meta::Attribute' ) ) ) {
        complain "Invalid argument (\"attribute\" must be a GX::Meta::Attribute object)";
    }

    if ( ref $args{'code'} ne 'CODE' ) {
        complain "Invalid argument (\"code\" must be a code reference)";
    }

    if ( $args{'name'} !~ REGEX_METHOD_NAME ) {
        complain "Invalid argument (\"name\" must be a method name)";
    }

    my $self = bless {
        'attribute' => $args{'attribute'},
        'code'      => $args{'code'},
        'name'      => $args{'name'}
    }, $class;

    weaken $self->{'attribute'};

    return $self;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub attribute {

    return $_[0]->{'attribute'};

}

sub code {

    return $_[0]->{'code'};

}

sub name {

    return $_[0]->{'name'};

}


1;

__END__

=head1 NAME

GX::Meta::Delegator - Delegator metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Delegator> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Meta::Delegator> metaobject.

    $delegator = GX::Meta::Delegator->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<attribute> ( L<GX::Meta::Attribute> object ) [ required ]

The associated attribute metaobject.

=item * C<code> ( C<CODE> reference ) [ required ]

A reference to the delegator subroutine.

=item * C<name> ( string ) [ required ]

The name of the delegator method.

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

=head2 Public Methods

=head3 C<attribute>

Returns the associated attribute metaobject.

    $attribute = $delegator->attribute;

=over 4

=item Returns:

=over 4

=item * C<$attribute> ( L<GX::Meta::Attribute> object )

=back

=back

=head3 C<code>

Returns a reference to the delegator subroutine.

    $code = $delegator->code;

=over 4

=item Returns:

=over 4

=item * C<$code> ( C<CODE> reference )

=back

=back

=head3 C<name>

Returns the name of the delegator method.

    $name = $delegator->name;

=over 4

=item Returns:

=over 4

=item * C<$name> ( string )

=back

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
