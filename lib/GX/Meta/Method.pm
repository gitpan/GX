# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Method.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Method;

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
    '&{}'      => \&_overload_code_dereference,
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;
    my %args  = @_;

    if ( ! defined $args{'class'} ) {
        complain "Missing argument (\"class\")";
    }

    if ( ! blessed( $args{'class'} ) || ! $args{'class'}->isa( 'GX::Meta::Class' ) ) {
        complain "Invalid argument (\"class\" must be a GX::Meta::Class object)";
    }

    if ( ! defined $args{'name'} ) {
        complain "Missing argument (\"name\")";
    }

    if ( $args{'name'} !~ REGEX_METHOD_NAME ) {
        complain "Invalid argument (\"$args{'name'}\" is not a valid method name)";
    }

    my $method_full_name = $args{'class'}->name . '::' . $args{'name'};

    if ( ! defined &{$method_full_name} ) {
        complain "Method &$method_full_name does not exist";
    }

    my $self = bless {
        'class'     => $args{'class'},
        'full_name' => $method_full_name,
        'name'      => $args{'name'}
    }, $class;

    weaken $self->{'class'};

    return $self;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub class {

    return $_[0]->{'class'};

}

sub code {

    return defined &{$_[0]->{'full_name'}} ? \&{$_[0]->{'full_name'}} : undef;

}

sub code_attributes {

    return @{ ( $_[0]->class || return )->code_attribute_store->{ $_[0]->code || return } || return };

}

sub full_name {

    return $_[0]->{'full_name'};

}

sub name {

    return $_[0]->{'name'};

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _overload_code_dereference {

    return $_[0]->code || complain( "Undefined subroutine &" . $_[0]->full_name . " called" );

}


1;

__END__

=head1 NAME

GX::Meta::Method - Method metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Method> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Meta::Method> metaobject.

    $method = GX::Meta::Method->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<class> ( L<GX::Meta::Class> object ) [ required ]

The class metaobject that represents the class to which the method belongs.

=item * C<name> ( string ) [ required ]

The name of the method.

=back

=item Returns:

=over 4

=item * C<$method> ( L<GX::Meta::Method> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head2 Public Methods

=head3 C<class>

Returns the class metaobject that represents the class to which the method
belongs.

    $class = $method->class;

=over 4

=item Returns:

=over 4

=item * C<$class> ( L<GX::Meta::Class> object )

=back

=back

=head3 C<code>

Returns a reference to the method.

    $code = $method->code;

=over 4

=item Returns:

=over 4

=item * C<$code> ( C<CODE> reference )

=back

=back

=head3 C<code_attributes>

Returns the code attributes of the method.

    @code_attributes = $method->code_attributes;

=over 4

=item Returns:

=over 4

=item * C<@code_attributes> ( strings )

A list of simple names, each optionally followed by a parenthesised parameter
list. See L<attributes> for details.

=back

=back

=head3 C<full_name>

Returns the fully qualified name of the method.

    $full_name = $method->full_name;

=over 4

=item Returns:

=over 4

=item * C<$full_name> ( string )

=back

=back

=head3 C<name>

Returns the name of the method.

    $name = $method->name;

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
