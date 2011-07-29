# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Uploads.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Uploads;

use GX::Exception;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'uploads' => (
    isa       => 'Array',
    accessors => {
        '_get_uploads' => { type => 'get_reference' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    '@{}'      => sub { $_[0]->_get_uploads },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    my $self = shift;

    for ( @_ ) {

        if ( ! blessed $_ || ! $_->isa( 'GX::HTTP::Upload' ) ) {
            complain "Invalid argument";
        }

    }

    push @{$self->_get_uploads}, @_;

    return;

}

sub all {

    return @{$_[0]->_get_uploads};

}

sub count {

    return scalar @{$_[0]->_get_uploads};

}

sub get {

    my $self = shift;

    return if ! @_;

    my $name = shift;

    if ( wantarray ) {

        if ( defined $name ) {
            return grep { defined $_->name && $_->name eq $name } @{$self->_get_uploads};
        }
        else {
            return grep { ! defined $_->name } @{$self->_get_uploads};
        }

    }
    else {

        if ( defined $name ) {
            defined $_->name && $_->name eq $name && return $_ for @{$self->_get_uploads};
        }
        else {
            defined $_->name or return $_ for @{$self->_get_uploads};
        }

        return undef;

    }

}

sub names {

    my $self = shift;

    my @names;

    my %seen;

    for my $upload ( @{$self->_get_uploads} ) {
        my $name = $upload->name;
        next if ! defined $name || $seen{$name};
        push @names, $name;
        $seen{$name} = 1;
    }

    return @names;

}

sub remove {

    my $self = shift;

    my $uploads = $self->_get_uploads;

    my $count = @$uploads;

    for my $name ( @_ ) {

        if ( defined $name ) {
            @$uploads = grep { ! defined $_->name || $_->name ne $name } @$uploads;
        }
        else {
            @$uploads = grep { defined $_->name } @$uploads;
        }

    }

    return $count - @$uploads;

}

sub set {

    my $self = shift;

    for ( @_ ) {

        if ( ! blessed $_ || ! $_->isa( 'GX::HTTP::Upload' ) ) {
            complain "Invalid argument";
        }

    }

    $self->remove( map { $_->name } @_ );

    push @{$self->_get_uploads}, @_;

    return;

}


1;

__END__

=head1 NAME

GX::HTTP::Uploads - Container class for GX::HTTP::Upload objects

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Uploads;
    
    # Create a new container object
    $uploads = GX::HTTP::Uploads->new;
    
    # Add an upload object
    $uploads->add(
        GX::HTTP::Upload->new(
            name => 'picture',
            file => '/tmp/0001.png'
        )
    );
    
    # Retrieve an upload object by its name attribute
    $upload = $uploads->get( 'picture' );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Uploads> class which extends
the L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Uploads> object.

    $uploads = GX::HTTP::Uploads->new;

=over 4

=item Returns:

=over 4

=item * C<$uploads> ( L<GX::HTTP::Uploads> object )

=back

=back

=head2 Public Methods

=head3 C<add>

Adds the given upload object(s) to the container.

    $uploads->add( @uploads );

=over 4

=item Arguments:

=over 4

=item * C<@uploads> ( L<GX::HTTP::Upload> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<all>

Returns all upload objects in the same order they were added.

    @uploads = $uploads->all;

=over 4

=item Returns:

=over 4

=item * C<@uploads> ( L<GX::HTTP::Upload> objects )

=back

=back

=head3 C<clear>

Empties the container.

    $uploads->clear;

=head3 C<count>

Returns the number of upload objects currently in the container.

    $count = $uploads->count;

=over 4

=item Returns:

=over 4

=item * C<$count> ( integer )

=back

=back

=head3 C<get>

Returns all upload objects with the specified name in the order they were
added.

    @uploads = $uploads->get( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

=back

=item Returns:

=over 4

=item * C<@uploads> ( L<GX::HTTP::Upload> objects )

=back

=back

In scalar context, the first of those objects is returned.

    $upload = $uploads->get( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

=back

=item Returns:

=over 4

=item * C<$upload> ( L<GX::HTTP::Upload> object | C<undef> )

=back

=back

=head3 C<names>

Returns the distinct names of the uploads.

    @names = $uploads->names;

=over 4

=item Returns:

=over 4

=item * C<@names> ( strings )

=back

=back

=head3 C<remove>

Removes the upload objects with the specified name(s) from the container.

    $result = $uploads->remove( @names );

=over 4

=item Arguments:

=over 4

=item * C<@names> ( strings )

=back

=item Returns:

=over 4

=item * C<$result> ( integer )

Number of removed upload objects.

=back

=back

=head3 C<set>

Adds the given upload object(s) to the container, replacing any previously
added upload objects with the same name(s).

    $uploads->set( @uploads );

=over 4

=item Arguments:

=over 4

=item * C<@uploads> ( L<GX::HTTP::Upload> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::HTTP::Upload>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
