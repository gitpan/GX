# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Session/Store/Cache.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Session::Store::Cache;

use GX::Exception;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Session::Store';

has 'cache' => (
    isa          => 'Object',
    preprocessor => sub { eval { $_ = $_->instance } },
    constraint   => sub { $_->isa( 'GX::Cache' ) },
    required     => 1,
    weaken       => 1,
    accessor     => { type => 'get' }
);

has 'key_prefix' => (
    isa        => 'String',
    initialize => 1,
    accessor   => { type => 'get' }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub delete {

    my $self       = shift;
    my $session_id = shift;

    if ( ! defined $session_id ) {
        complain "Missing argument";
    }

    my $result = $self->cache->remove( $self->key_prefix . $session_id );

    return $result;

}

sub load {

    my $self       = shift;
    my $session_id = shift;

    if ( ! defined $session_id ) {
        complain "Missing argument";
    }

    my $cache_data = $self->cache->get( $self->key_prefix . $session_id );

    return $cache_data ? @{ $self->serializer->unserialize( $cache_data ) } : ();

}

sub save {

    my $self         = shift;
    my $session_id   = shift;
    my $session_info = shift;
    my $session_data = shift;

    if ( ! defined $session_id ) {
        complain "Missing argument";
    }

    if ( ! defined $session_info ) {
        complain "Missing argument";
    }

    if ( ref $session_info ne 'HASH' ) {
        complain "Invalid argument";
    }

    my $cache_key  = $self->key_prefix . $session_id;
    my $cache_data = $self->serializer->serialize( [ $session_info, $session_data ] );

    my $result = $self->cache->add( $cache_key, $cache_data, $session_info->{'expires_at'} );

    return $result;

}

sub update {

    my $self         = shift;
    my $session_id   = shift;
    my $session_info = shift;
    my $session_data = shift;

    if ( ! defined $session_id ) {
        complain "Missing argument";
    }

    if ( ! defined $session_info ) {
        complain "Missing argument";
    }

    if ( ref $session_info ne 'HASH' ) {
        complain "Invalid argument";
    }

    my $cache_key  = $self->key_prefix . $session_id;
    my $cache_data = $self->serializer->serialize( [ $session_info, $session_data ] );

    my $result = $self->cache->replace( $cache_key, $cache_data, $session_info->{'expires_at'} );

    return $result;

}


1;

__END__

=head1 NAME

GX::Session::Store::Cache - GX::Cache-based session store

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Session::Store::Cache> class which extends the
L<GX::Session::Store> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Session::Store::Cache> object.

    $store = GX::Session::Store::Cache->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<cache> ( L<GX::Cache> class or object ) [ required ]

The cache component.

=item * C<key_prefix> ( string )

A cache key prefix.

=item * C<serializer> ( L<GX::Serializer> object )

The serializer to use. Defaults to a L<GX::Serializer::Storable> instance.

=back

=item Returns:

=over 4

=item * C<$store> ( L<GX::Session::Store::Cache> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<cache>

Returns the associated cache component instance.

    $cache = $store->cache;

=over 4

=item Returns:

=over 4

=item * C<$cache> ( L<GX::Cache> object )

=back

=back

=head3 C<delete>

See L<GX::Session::Store|GX::Session::Store/"delete">.

=head3 C<key_prefix>

Returns the cache key prefix.

    $key_prefix = $store->key_prefix;

=over 4

=item Returns:

=over 4

=item * C<$key_prefix> ( string )

=back

=back

=head3 C<load>

See L<GX::Session::Store|GX::Session::Store/"load">.

=head3 C<save>

See L<GX::Session::Store|GX::Session::Store/"save">.

=head3 C<serializer>

See L<GX::Session::Store|GX::Session::Store/"serializer">.

=head3 C<update>

See L<GX::Session::Store|GX::Session::Store/"update">.

=head1 SEE ALSO

=over 4

=item * L<GX::Session>

=item * L<GX::Cache>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
