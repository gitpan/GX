# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Database/SQLite.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Database::SQLite;

use GX::Exception;

use DBD::SQLite ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Database';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _connect {

    my $self = shift;

    return DBI->connect(
        $self->_get_dsn,
        '',
        '',
        { %{$self->_get_connect_options} }
    );

}

sub _dbi_driver {

    return 'SQLite';

}

sub _initialize_sql_builder {

    require GX::SQL::Builder::SQLite;

    return GX::SQL::Builder::SQLite->new;

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

        $self->_set_dsn( 'DBI:' . $self->_dbi_driver . ':dbname=' . ( $args->{'file'} // '' ) );

    }

    delete @$args{ qw( file ) };

    $self->SUPER::_setup_config( $args );

    return;

}


1;

__END__

=head1 NAME

GX::Database::SQLite - SQLite database component

=head1 SYNOPSIS

    package MyApp::Database::Default;
    
    use GX::Database::SQLite;
    
    __PACKAGE__->setup(
        file            => '/srv/myapp/database.sqlite',
        connect_options => { sqlite_unicode => 1 }
    );
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Database::SQLite> class which extends the
L<GX::Database> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the database component instance.

    $database = $database_class->new;

=over 4

=item Returns:

=over 4

=item * C<$database> ( L<GX::Database::SQLite> object )

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

=head3 C<setup>

Sets up the database component.

    $database_class->setup( %options );

=over 4

=item Options:

=over 4

=item * C<connect_options> ( C<HASH> reference )

A reference to a hash with additional options to pass to L<DBI>'s
C<connect()> method.

=item * C<dsn> ( string )

The full L<DBI> data source name (DSN) that is used for connecting to the
database. Overrides all other DSN related options if specified.

=item * C<file> ( string )

An absolute path to the SQLite database file. Required unless C<dsn> is
specified.

=item * C<sql_builder> ( L<GX::SQL::Builder> object )

The associated SQL builder. Defaults to a L<GX::SQL::Builder::SQLite>
instance.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<sql_builder>

See L<GX::Database|GX::Database/"sql_builder">.

=head1 SEE ALSO

=over 4

=item * L<DBD::SQLite>

=item * L<http://www.sqlite.org/>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
