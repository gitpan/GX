# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Accessor.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Accessor;

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
        'name'      => $args{'name'},
        'type'      => $args{'type'}
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

sub type {

    return $_[0]->{'type'};

}


1;

__END__

=head1 NAME

GX::Meta::Accessor - Accessor metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Accessor> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Meta::Accessor> metaobject.

    $accessor = GX::Meta::Accessor->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<attribute> ( L<GX::Meta::Attribute> object ) [ required ]

The associated attribute metaobject.

=item * C<code> ( C<CODE> reference ) [ required ]

A reference to the accessor subroutine.

=item * C<name> ( string ) [ required ]

The name of the accessor method.

=item * C<type> ( string )

A string identifying the accessor type, for example "get" or "set".

=back

=item Returns:

=over 4

=item * C<$accessor> ( L<GX::Meta::Accessor> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head2 Public Methods

=head3 C<attribute>

Returns the associated attribute metaobject.

    $attribute = $accessor->attribute;

=over 4

=item Returns:

=over 4

=item * C<$attribute> ( L<GX::Meta::Attribute> object )

=back

=back

=head3 C<code>

Returns a reference to the accessor subroutine.

    $code = $accessor->code;

=over 4

=item Returns:

=over 4

=item * C<$code> ( C<CODE> reference )

=back

=back

=head3 C<name>

Returns the name of the accessor method.

    $name = $accessor->name;

=over 4

=item Returns:

=over 4

=item * C<$name> ( string )

=back

=back

=head3 C<type>

Returns a string identifying the accessor type or C<undef> if the type is
unknown.

    $type = $accessor->type;

=over 4

=item Returns:

=over 4

=item * C<$type> ( string | C<undef> )

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
