# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Database.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Database;

use GX::Exception;

use DBI ();


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant DEBUG => $ENV{'GX_DATABASE_DEBUG_LEVEL'} // 0;

use constant DBH_STATE_KEY => 'private_GX_Database';

use constant DBH_STATE_ATTRIBUTES => (
    qw(
        AutoCommit
        ChopBlanks
        CompatMode
        FetchHashKeyName
        HandleError
        InactiveDestroy
        LongReadLen
        LongTruncOk
        PrintError
        PrintWarn
        Profile
        RaiseError
        ShowErrorStatement
        Taint
        TraceLevel
        Warn
    ),
    ( $DBI::VERSION >= 1.31  ? ( qw( TaintIn TaintOut ) )    : () ),
    ( $DBI::VERSION >= 1.614 ? ( qw( AutoInactiveDestroy ) ) : () )
);


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Component::Singleton';

has 'connect_options' => (
    isa         => 'Hash',
    initialize  => 1,
    initializer => '_initialize_connect_options',
    accessors   => {
        '_get_connect_options' => { type => 'get_reference' }
    }
);

has 'dsn' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_dsn' => { type => 'get' },
        '_set_dsn' => { type => 'set' }
    }
);

has 'sql_builder' => (
    isa         => 'Scalar',
    initialize  => 1,
    initializer => '_initialize_sql_builder',
    accessors   => {
        '_get_sql_builder' => { type => 'get' },
        '_set_sql_builder' => { type => 'set' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Database handle cache
# ----------------------------------------------------------------------------------------------------------------------

{

    my %CACHE;

    sub _delete_cached_dbh {
        return delete( ( $CACHE{$$} // return undef )->{ ref $_[0] } );
    }

    sub _get_cached_dbh {
        return ( $CACHE{$$} // return undef )->{ ref $_[0] };
    }

    sub _set_cached_dbh {
        return $CACHE{$$}{ ref $_[0] } = $_[1];
    }

    sub CLONE {
        %CACHE = ();
        return;
    }

    END {

        local $@;

        if ( $CACHE{$$} ) {

            for my $class ( keys %{$CACHE{$$}} ) {

                if ( my $dbh = delete $CACHE{$$}{$class} ) {

                    if ( DEBUG ) {
                        warn "[GX::Database] [$$] END: Forcing disconnect from database $class\n";
                    }
        
                    if ( $dbh->{'Active'} && ! $dbh->{'AutoCommit'} ) {

                        if ( DEBUG ) {
                            warn "[GX::Database] [$$] END: Forcing rollback of database $class\n";
                        }

                        eval { $dbh->rollback };

                        if ( DEBUG && $@ ) {
                            warn "[GX::Database] [$$] END: Rollback of database $class failed: $@\n";
                        }

                    }

                    eval { $dbh->disconnect };

                    if ( DEBUG && $@ ) {
                        warn "[GX::Database] [$$] END: Disconnect from database $class failed: $@\n";
                    }
        
                }
        
            }
        
            delete $CACHE{$$};

        }

        for my $pid ( keys %CACHE ) {

            for my $class ( keys %{$CACHE{$pid}} ) {

                if ( my $dbh = delete $CACHE{$pid}{$class} ) {
                    # Instruct DBI to treat the handle as not-Active on destruction
                    $dbh->{'InactiveDestroy'} = 1;
                }

            }

            delete $CACHE{$pid};

        }

    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub connect {

    my $self = shift->instance;

    if ( DEBUG ) {
        $self->_debug( "Connecting to database" );
    }

    my $dbh;

    if ( $dbh = $self->_get_cached_dbh ) {

        if ( DEBUG ) {
            $self->_debug( "Reusing cached connection" );
        }

        if ( $self->_ping_dbh( $dbh ) ) {

            if ( $self->_reset_dbh( $dbh ) ) {
                return $dbh;
            }

            if ( DEBUG ) {
                $self->_debug( "Cannot reset cached connection" );
            }

        }
        else {

            if ( DEBUG ) {
                $self->_debug( "Cached connection is dead" );
            }

        }

        $self->_delete_cached_dbh;

    }

    if ( ! eval { $dbh = $self->_connect } ) {
        GX::Exception->complain(
            message      => "Cannot connect to database $self",
            subexception => ( $@ || $DBI::errstr ),
            verbosity    => 1
        );
    }

    $self->_store_dbh_state( $dbh );

    $self->_set_cached_dbh( $dbh );

    return $dbh;

}

sub connect_options {

    return %{$_[0]->instance->_get_connect_options};

}

sub disconnect {

    my $self = shift->instance;

    if ( DEBUG ) {
        $self->_debug( "Disconnecting from database" );
    }

    my $dbh = $self->_delete_cached_dbh;

    if ( ! $dbh ) {

        if ( DEBUG ) {
            $self->_debug( "Not connected" );
        }

        return -1;

    }

    {

        local $@;

        if ( $dbh->{'Active'} && ! $dbh->{'AutoCommit'} ) {

            if ( DEBUG ) {
                $self->_debug( "Forcing rollback before disconnect" );
            }

            eval { $dbh->rollback };

            if ( DEBUG && $@ ) {
                $self->_debug( "Rollback failed: $@" );
            }

        }

        eval { $dbh->disconnect };

        if ( $@ ) {

            if ( DEBUG ) {
                $self->_debug( "Disconnect failed: $@" );
            }

            return 0;

        }

    }

    return 1;

}

sub dsn {

    return $_[0]->instance->_get_dsn;

}

sub is_connected {

    my $self = shift->instance;

    my $dbh = $self->_get_cached_dbh;

    return $dbh ? $self->_ping_dbh( $dbh ) : 0;

}

sub sql_builder {

    return $_[0]->instance->_get_sql_builder;

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub DESTROY {

    my $self = shift;

    if ( DEBUG ) {
        $self->_debug( "DESTROYing database instance" );
    }

    $self->disconnect;

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _connect {

    # Abstract method

}

sub _dbi_driver {

    # Abstract method

}

sub _dbi_error_handler {

    my $error = shift;
    my $dbh   = shift;

    my $statement = $dbh->{'Statement'};

    throw sprintf(
        "DBI Error: \"%s\"%s",
        $error,
        ( $statement ? " (statement: \"$statement\")" : '' )
    );

}

sub _initialize_connect_options {

    my $self = shift;

    return {
        'AutoCommit'  => 1,
        'HandleError' => $self->can( '_dbi_error_handler' ),
        'PrintError'  => 0,
        'RaiseError'  => 1
    };

}

sub _initialize_sql_builder {

    require GX::SQL::Builder;

    return GX::SQL::Builder->new;

}

sub _ping_dbh {

    my $self = shift;
    my $dbh  = shift;

    if ( DEBUG ) {
        $self->_debug( "Pinging dbh" );
    }

    return $dbh->ping;

}

sub _reset_dbh {

    my $self = shift;
    my $dbh  = shift;

    if ( DEBUG ) {
        $self->_debug( "Resetting dbh" );
    }

    if ( $dbh->{'Active'} && ! $dbh->{'AutoCommit'} ) {

        if ( DEBUG ) {
            $self->_debug( "Forcing rollback" );
        }

        local $@;

        eval { $dbh->rollback };

        if ( $@ ) {

            if ( DEBUG ) {
                $self->_debug( "Rollback failed: $@" );
            }

            return 0;

        }

    }

    my $state = $self->_retrieve_dbh_state( $dbh );

    if ( ! $state ) {

        if ( DEBUG ) {
            $self->_debug( "No stored dbh state" );
        }

        return 0;

    }

    for my $attribute ( keys %$state ) {
        $dbh->{$attribute} = $state->{$attribute};
    }

    return 1;

}

sub _retrieve_dbh_state {

    my $self = shift;
    my $dbh  = shift;

    if ( DEBUG ) {
        $self->_debug( "Retrieving dbh state" );
    }

    return $dbh->{ DBH_STATE_KEY() };

}

sub _setup_config {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'connect_options'} ) {

        my $connect_options = delete $args->{'connect_options'};

        if ( ref $connect_options ne 'HASH' ) {
            throw "Invalid option (\"connect_options\" must be a hash reference)";
        }

        %{$self->_get_connect_options} = ( %{$self->_get_connect_options}, %$connect_options );

    }

    $self->SUPER::_setup_config( $args );

    return;

}

sub _start {

    my $self = shift;

    $self->SUPER::_start;

    $self->disconnect;

    return;

}

sub _store_dbh_state {

    my $self = shift;
    my $dbh  = shift;

    if ( DEBUG ) {
        $self->_debug( "Storing dbh state" );
    }

    if ( exists $dbh->{ DBH_STATE_KEY() } ) {
        throw "Cannot store dbh state";
    }

    my %state;

    for my $attribute ( DBH_STATE_ATTRIBUTES ) {
        $state{$attribute} = $dbh->{$attribute} if exists $dbh->{$attribute};
    }

    $dbh->{ DBH_STATE_KEY() } = \%state;

    return 1;

}

sub _validate_class_name {

    return $_[1] =~ /^(?:[_a-zA-Z]\w*::)+?Database(?:::[_a-zA-Z]\w*)+$/;

}


# ----------------------------------------------------------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------------------------------------------------------

*dbh = \&connect;


# ----------------------------------------------------------------------------------------------------------------------
# Debugging
# ----------------------------------------------------------------------------------------------------------------------

sub _debug {

    my $invocant = shift;
    my $message  = shift;

    warn "[$invocant] [$$] $message\n";

    return;

}


1;

__END__

=head1 NAME

GX::Database - Base class for database components

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Database> class which extends the
L<GX::Component::Singleton> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the database component instance.

    $database = $database_class->new;

=over 4

=item Returns:

=over 4

=item * C<$database> ( L<GX::Database> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

All public methods can be called both as instance and class methods.

=head3 C<connect>

Returns a new or, if available, cached L<DBI> database handle.

    $dbh = $database->connect;

=over 4

=item Returns:

=over 4

=item * C<$dbh> ( DBI::db object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<connect_options>

Returns any additional, user-specified options that are passed to
L<DBI>'s C<connect()> method when C<< L<connect()|/connect> >> is called.

    %options = $database->connect_options;

=over 4

=item Returns:

=over 4

=item * C<%options> ( named list )

=back

=back

=head3 C<dbh>

An alias for L<connect()|/connect>.

    $dbh = $database->dbh;

=head3 C<disconnect>

Disconnects the database.

    $database->disconnect;

=head3 C<dsn>

Returns the full data source name (DSN) that is passed to L<DBI>'s
C<connect()> method when C<< L<connect()|/connect> >> is called.

    $dsn = $database->dsn;

=over 4

=item Returns:

=over 4

=item * C<$dsn> ( string )

=back

=back

=head3 C<is_connected>

Returns true if the database is connected, otherwise false.

    $result = $database->is_connected;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<setup>

Sets up the database component.

    $database_class->setup( %options );

=over 4

=item Options:

=over 4

=item * C<%options> ( named list )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<sql_builder>

Returns the associated SQL builder.

    $sql_builder = $database->sql_builder;

=over 4

=item Returns:

=over 4

=item * C<$sql_builder> ( L<GX::SQL::Builder> object | C<undef> )

=back

=back

=head1 SUBCLASSES

The following classes inherit directly from L<GX::Database>:

=over 4

=item * L<GX::Database::MySQL>

=item * L<GX::Database::Pg>

=item * L<GX::Database::SQLite>

=back

=head1 SEE ALSO

=over 4

=item * L<DBI>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
