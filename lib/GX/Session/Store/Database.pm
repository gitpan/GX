# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Session/Store/Database.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Session::Store::Database;

use GX::Exception;
use GX::SQL::Types;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Session::Store';

has 'database' => (
    isa          => 'Object',
    preprocessor => sub { eval { $_ = $_->instance } },
    constraint   => sub { $_->isa( 'GX::Database' ) },
    required     => 1,
    weaken       => 1,
    accessor     => { type => 'get' }
);

has 'table' => (
    isa        => 'String',
    initialize => 1,
    default    => 'sessions',
    accessor   => { type => 'get' }
);

has '_column_type_map' => (
    isa         => 'Hash',
    initialize  => 1,
    initializer => '_initialize_column_type_map',
    accessors   => {
        '_get_column_type_map' => { type => 'get_reference' }
    }
);

has '_sql_cache' => (
    isa         => 'Hash',
    initialize  => 1,
    initializer => '_initialize_sql_cache',
    accessors   => {
        '_get_sql_cache' => { type => 'get_reference' }
    }
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

    my ( $sql, $bind ) = @{$self->_get_sql_cache->{'delete'}};

    my $dbh = $self->database->dbh;

    my $sth = $dbh->prepare_cached( $sql, { gx_cache_key => __PACKAGE__ . __LINE__ } );

    $sth->bind_param( 1, $session_id, $bind->[0] );

    $sth->execute;

    my $result = $sth->rows > 0 ? 1 : 0;

    return $result;

}

sub load {

    my $self       = shift;
    my $session_id = shift;

    if ( ! defined $session_id ) {
        complain "Missing argument";
    }

    my ( $sql, $bind ) = @{$self->_get_sql_cache->{'load'}};

    my $dbh = $self->database->dbh;

    my $sth = $dbh->prepare_cached( $sql, { gx_cache_key => __PACKAGE__ . __LINE__ } );

    $sth->bind_param( 1, $session_id, $bind->[0] );

    $sth->execute;

    my $row = $sth->fetchrow_arrayref;

    $sth->finish;

    return unless $row;

    my $session_info = {
        'remote_address' => $row->[0],
        'started_at'     => $row->[1],
        'updated_at'     => $row->[2],
        'expires_at'     => $row->[3]
    };

    my $session_data = $self->serializer->unserialize( $row->[4] );

    return $session_info, $session_data;

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

    my $serialized_session_data = $self->serializer->serialize( $session_data );

    my ( $sql, $bind ) = @{$self->_get_sql_cache->{'save'}};

    my $dbh = $self->database->dbh;

    my $sth = $dbh->prepare_cached( $sql, { gx_cache_key => __PACKAGE__ . __LINE__ } );

    $sth->bind_param( 1, $session_id,                       $bind->[0] );
    $sth->bind_param( 2, $session_info->{'remote_address'}, $bind->[1] );
    $sth->bind_param( 3, $session_info->{'started_at'},     $bind->[2] );
    $sth->bind_param( 4, $session_info->{'updated_at'},     $bind->[3] );
    $sth->bind_param( 5, $session_info->{'expires_at'},     $bind->[4] );
    $sth->bind_param( 6, $serialized_session_data,          $bind->[5] );

    $sth->execute;

    return 1;

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

    my $serialized_session_data = $self->serializer->serialize( $session_data );

    my ( $sql, $bind ) = @{$self->_get_sql_cache->{'update'}};

    my $dbh = $self->database->dbh;

    my $sth = $dbh->prepare_cached( $sql, { gx_cache_key => __PACKAGE__ . __LINE__ } );

    $sth->bind_param( 1, $session_info->{'remote_address'}, $bind->[0] );
    $sth->bind_param( 2, $session_info->{'started_at'},     $bind->[1] );
    $sth->bind_param( 3, $session_info->{'updated_at'},     $bind->[2] );
    $sth->bind_param( 4, $session_info->{'expires_at'},     $bind->[3] );
    $sth->bind_param( 5, $serialized_session_data,          $bind->[4] );
    $sth->bind_param( 6, $session_id,                       $bind->[5] );

    $sth->execute;

    my $result = $sth->rows > 0 ? 1 : 0;

    return $result;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _build_sql_delete {

    my $self = shift;

    my ( $sql, $bind ) = $self->database->sql_builder->delete(
        table => $self->table,
        where => [ 'id' => '?' ],
        bind  => $self->_get_column_type_map
    );

    return [ $sql, [ map { $_->[2] } @$bind ] ];

}

sub _build_sql_load {

    my $self = shift;

    my ( $sql, $bind ) = $self->database->sql_builder->select(
        table   => $self->table,
        columns => [ qw( remote_address started_at updated_at expires_at data ) ],
        where   => [ 'id' => '?' ],
        bind    => $self->_get_column_type_map
    );

    return [ $sql, [ map { $_->[2] } @$bind ] ];

}

sub _build_sql_save {

    my $self = shift;

    my ( $sql, $bind ) = $self->database->sql_builder->insert(
        table   => $self->table,
        columns => [ qw( id remote_address started_at updated_at expires_at data ) ],
        bind    => $self->_get_column_type_map
    );

    return [ $sql, [ map { $_->[2] } @$bind ] ];

}

sub _build_sql_update {

    my $self = shift;

    my ( $sql, $bind ) = $self->database->sql_builder->update(
        table   => $self->table,
        columns => [ qw( remote_address started_at updated_at expires_at data ) ],
        where   => [ 'id' => '?' ],
        bind    => $self->_get_column_type_map
    );

    return [ $sql, [ map { $_->[2] } @$bind ] ];

}

sub _initialize_column_type_map {

    return {
        'id'             => GX::SQL::Types::VARCHAR,
        'remote_address' => GX::SQL::Types::VARCHAR,
        'started_at'     => GX::SQL::Types::INTEGER,
        'updated_at'     => GX::SQL::Types::INTEGER,
        'expires_at'     => GX::SQL::Types::INTEGER,
        'data'           => GX::SQL::Types::BINARY
    };

}

sub _initialize_sql_cache {

    my $self = shift;

    return {
        'delete' => $self->_build_sql_delete,
        'load'   => $self->_build_sql_load,
        'save'   => $self->_build_sql_save,
        'update' => $self->_build_sql_update
    };

}


1;

__END__

=head1 NAME

GX::Session::Store::Database - GX::Database-based session store

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Session::Store::Database> class which extends
the L<GX::Session::Store> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Session::Store::Database> object.

    $store = GX::Session::Store::Database->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<database> ( L<GX::Database> class or object ) [ required ]

The database component.

=item * C<serializer> ( L<GX::Serializer> object )

The serializer to use. Defaults to a L<GX::Serializer::Storable> instance.

=item * C<table> ( string )

The name of the database table. Defaults to "sessions".

=back

=item Returns:

=over 4

=item * C<$store> ( L<GX::Session::Store::Database> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<database>

Returns the associated database component instance.

    $database = $store->database;

=over 4

=item Returns:

=over 4

=item * C<$database> ( L<GX::Database> object )

=back

=back

=head3 C<delete>

See L<GX::Session::Store|GX::Session::Store/"delete">.

=head3 C<load>

See L<GX::Session::Store|GX::Session::Store/"load">.

=head3 C<save>

See L<GX::Session::Store|GX::Session::Store/"save">.

=head3 C<serializer>

See L<GX::Session::Store|GX::Session::Store/"serializer">.

=head3 C<table>

Returns the name of the database table.

    $table = $store->table;

=over 4

=item Returns:

=over 4

=item * C<$table> ( string )

=back

=back

=head3 C<update>

See L<GX::Session::Store|GX::Session::Store/"update">.

=head1 USAGE

=head2 Database Setup

=head3 MySQL

For version 5.1:

    CREATE TABLE sessions (
        id             VARCHAR(32) NOT NULL PRIMARY KEY,
        remote_address VARCHAR(39),
        started_at     INT,
        updated_at     INT,
        expires_at     INT,
        data           BLOB
    )

=head3 PostgreSQL

For version 8.4:

    CREATE TABLE sessions (
        id             VARCHAR(32) PRIMARY KEY,
        remote_address VARCHAR(39),
        started_at     INTEGER,
        updated_at     INTEGER,
        expires_at     INTEGER,
        data           BYTEA
    )

=head3 SQLite

For version 3.6:

    CREATE TABLE sessions (
        id             VARCHAR(32) NOT NULL PRIMARY KEY,
        remote_address VARCHAR(39),
        started_at     INTEGER,
        updated_at     INTEGER,
        expires_at     INTEGER,
        data           BLOB
    )

=head1 SEE ALSO

=over 4

=item * L<GX::Session>

=item * L<GX::Database>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
