# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Database/Pg.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Database::Pg;

use GX::Exception;

use DBD::Pg ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Database';

has 'password' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_password' => { type => 'get' },
        '_set_password' => { type => 'set' }
    }
);

has 'user' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_user' => { type => 'get' },
        '_set_user' => { type => 'set' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub password {

    return $_[0]->instance->_get_password;

}

sub user {

    return $_[0]->instance->_get_user;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _connect {

    my $self = shift;

    return DBI->connect(
        $self->_get_dsn,
        $self->_get_user,
        $self->_get_password,
        { %{$self->_get_connect_options} }
    );

}

sub _dbi_driver {

    return 'Pg';

}

sub _initialize_sql_builder {

    require GX::SQL::Builder::Pg;

    return GX::SQL::Builder::Pg->new;

}

sub _setup_config {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'dsn'} ) {

        my $dsn = delete $args->{'dsn'} // '';

        my ( $scheme, $driver, undef, undef, undef ) = DBI->parse_dsn( $dsn );

        if ( ! defined $scheme ) {
            throw "Invalid option (\"dsn\" must be DBI data source name)";
        }

        if ( ! defined $driver ) {
            throw "Invalid option (\"dsn\" does not specify a DBI driver)";
        }

        if ( $driver ne $self->_dbi_driver ) {
            throw "Invalid option (\"dsn\" specifies an unsupported DBI driver)";
        }

        $self->_set_dsn( $dsn );

    }
    else {

        if ( ! defined $args->{'database'} ) {
            throw "Missing option (\"database\")";
        }

        my $dsn = 'DBI:' . $self->_dbi_driver . ':database=' . $args->{'database'};

        if ( defined $args->{'host'} ) {
            $dsn .= ';host=' . $args->{'host'};
        }

        if ( defined $args->{'port'} ) {
            $dsn .= ';port=' . $args->{'port'};
        }

        if ( defined $args->{'driver_options'} ) {
            $dsn .= ';' . $args->{'driver_options'};
        }

        $self->_set_dsn( $dsn );

    }

    $self->_set_user( $args->{'user'} );

    $self->_set_password( $args->{'password'} );

    delete @$args{ qw( database driver_options host password port user ) };

    $self->SUPER::_setup_config( $args );

    return;

}


1;

__END__

=head1 NAME

GX::Database::Pg - PostgreSQL database component

=head1 SYNOPSIS

    package MyApp::Database::Default;
    
    use GX::Database::Pg;
    
    __PACKAGE__->setup(
        database => 'myapp',
        host     => '127.0.0.1',
        user     => 'jau',
        password => '12345'
    );
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Database::Pg> class which extends the
L<GX::Database> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the database component instance.

    $database = $database_class->new;

=over 4

=item Returns:

=over 4

=item * C<$database> ( L<GX::Database::Pg> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

All public methods can be called both as instance and class methods.

=head3 C<connect>

See L<GX::Database|GX::Database/"connect">.

=head3 C<connect_options>

See L<GX::Database|GX::Database/"connect_options">.

=head3 C<dbh>

See L<GX::Database|GX::Database/"dbh">.

=head3 C<disconnect>

See L<GX::Database|GX::Database/"disconnect">.

=head3 C<dsn>

See L<GX::Database|GX::Database/"dsn">.

=head3 C<is_connected>

See L<GX::Database|GX::Database/"is_connected">.

=head3 C<password>

Returns the password that is used for connecting to the database.

    $password = $database->password;

=over 4

=item Returns:

=over 4

=item * C<$password> ( string | C<undef> )

=back

=back

=head3 C<setup>

Sets up the database component.

    $database_class->setup( %options );

=over 4

=item Options:

=over 4

=item * C<connect_options> ( C<HASH> reference )

A reference to a hash with additional options to pass to L<DBI>'s
C<connect()> method.

=item * C<database> ( string )

The name of the database. Required unless C<dsn> is specified.

=item * C<driver_options> ( string )

Additional driver-specific options that should be appended to the
auto-generated data source name (DSN).

=item * C<dsn> ( string )

The full L<DBI> data source name (DSN) that is used for connecting to the
database. Overrides all other DSN related options if specified.

=item * C<host> ( string )

The hostname of the PostgreSQL server.

=item * C<password> ( string )

The password that is used for connecting to the database.

=item * C<port> ( integer )

The port number on which the PostgreSQL server is running.

=item * C<sql_builder> ( L<GX::SQL::Builder> object )

The associated SQL builder. Defaults to a L<GX::SQL::Builder::Pg> instance.

=item * C<user> ( string )

The username that is used for connecting to the database.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<sql_builder>

See L<GX::Database|GX::Database/"sql_builder">.

=head3 C<user>

Returns the user name that is used for connecting to the database.

    $user = $database->user;

=over 4

=item Returns:

=over 4

=item * C<$user> ( string | C<undef> )

=back

=back

=head1 SEE ALSO

=over 4

=item * L<DBD::Pg>

=item * L<http://www.postgresql.org/>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
