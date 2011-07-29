# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/SQL/Builder.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::SQL::Builder;

use GX::Exception;
use GX::SQL::Types;

use DBI ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'bind_type_map' => (
    isa         => 'Hash',
    initialize  => 1,
    initializer => '_initialize_bind_type_map',
    accessors   => {
        '_bind_type_map' => { type => 'get_reference' }
    }
);

has 'quote_char' => (
    isa         => 'String',
    initialize  => 1,
    initializer => '_initialize_quote_char',
    accessor    => { type => 'get' }
);

has 'where_op_handlers' => (
    isa         => 'Hash',
    initialize  => 1,
    initializer => '_initialize_where_op_handlers',
    accessors   => {
        '_where_op_handler' => { type => 'get_value' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub count {

    my $self = shift;
    my %args = @_;

    if ( ! defined $args{'table'} ) {
        complain "Missing argument (\"table\")";
    }

    my $sql;
    my $bind;

    eval {

        $bind = [];
        $sql  = 'SELECT COUNT(*) FROM ' . $self->_quote_table( $args{'table'} );

        if ( defined $args{'where'} ) {
            $self->_build_where_clause( $args{'where'}, \$sql, $bind, $args{'bind'} );
        }

    };

    if ( $@ ) {
        complain $@;
    }

    return wantarray ? ( $sql, $bind ) : $sql;

}

sub delete {

    my $self = shift;
    my %args = @_;

    if ( ! defined $args{'table'} ) {
        complain "Missing argument (\"table\")";
    }

    my $sql;
    my $bind;

    eval {

        $bind = [];
        $sql  = 'DELETE FROM ' . $self->_quote_table( $args{'table'} );

        if ( defined $args{'where'} ) {
            $self->_build_where_clause( $args{'where'}, \$sql, $bind, $args{'bind'} );
        }

    };

    if ( $@ ) {
        complain $@;
    }

    return wantarray ? ( $sql, $bind ) : $sql;

}

sub insert {

    my $self = shift;
    my %args = @_;

    if ( ! defined $args{'table'} ) {
        complain "Missing argument (\"table\")";
    }

    if ( ! defined $args{'columns'} ) {
        complain "Missing argument (\"columns\")";
    }

    if ( ref $args{'columns'} ne 'ARRAY' ) {
        complain "Invalid argument (\"columns\")";
    }

    my $sql;
    my $bind;

    eval {

        my $sql_columns;
        my $sql_values;

        ( $bind, $sql_columns, $sql_values ) = $self->_bind_column_values(
            $args{'columns'},
            $args{'values'},
            undef,
            $args{'bind'}
        );

        $sql = 'INSERT INTO ' . $self->_quote_table( $args{'table'} )
             . ' ( ' . join( ', ', @$sql_columns ) . ' ) '
             . 'VALUES ( ' . join( ', ', @$sql_values ) . ' )';

    };

    if ( $@ ) {
        complain $@;
    }

    return wantarray ? ( $sql, $bind ) : $sql;

}

sub select {

    my $self = shift;
    my %args = @_;

    if ( ! defined $args{'table'} ) {
        complain "Missing argument (\"table\")";
    }

    my $sql;
    my $bind;

    eval {

        $bind = [];
        $sql  = 'SELECT ';

        if ( $args{'distinct'} ) {
            $sql .= 'DISTINCT ';
        }

        if ( defined $args{'columns'} ) {

            if ( ref $args{'columns'} ne 'ARRAY' ) {
                throw "Invalid argument (\"columns\")";
            }

            $sql .= join( ', ', map { $self->_quote_column( $_ ) } @{$args{'columns'}} );

        }
        else {
            $sql .= '*';
        }

        $sql .= ' FROM ' . $self->_quote_table( $args{'table'} );

        if ( defined $args{'where'} ) {
            $self->_build_where_clause(
                $args{'where'},
                \$sql,
                $bind,
                $args{'bind'}
            );
        }

        if ( defined $args{'order'} ) {
            $self->_build_order_clause(
                $args{'order'},
                \$sql,
                $bind,
                $args{'bind'}
            );
        }

        if ( defined $args{'limit'} ) {
            $self->_build_limit_clause(
                $args{'limit'},
                $args{'offset'},
                \$sql,
                $bind,
                $args{'bind'}
            );
        }

    };

    if ( $@ ) {
        complain $@;
    }

    return wantarray ? ( $sql, $bind ) : $sql;

}

sub update {

    my $self = shift;
    my %args = @_;

    if ( ! defined $args{'table'} ) {
        complain "Missing argument (\"table\")";
    }

    if ( ! defined $args{'columns'} ) {
        complain "Missing argument (\"columns\")";
    }

    if ( ref $args{'columns'} ne 'ARRAY' ) {
        complain "Invalid argument (\"columns\")";
    }

    my $sql;
    my $bind;

    eval {

        my $sql_columns;
        my $sql_values;

        ( $bind, $sql_columns, $sql_values ) = $self->_bind_column_values(
            $args{'columns'},
            $args{'values'},
            undef,
            $args{'bind'}
        );

        $sql = 'UPDATE ' . $self->_quote_table( $args{'table'} ) . ' SET ';

        my @sql_set;

        for ( my $i = 0; $i < @$sql_columns; $i++ ) {
            push @sql_set, $sql_columns->[$i] . ' = ' . $sql_values->[$i];
        }

        $sql .= join( ', ', @sql_set );

        if ( defined $args{'where'} ) {
            $self->_build_where_clause( $args{'where'}, \$sql, $bind, $args{'bind'} );
        }

    };

    if ( $@ ) {
        complain $@;
    }

    return wantarray ? ( $sql, $bind ) : $sql;

}

sub where {

    my $self  = shift;
    my $where = shift;
    my %args  = @_;

    if ( ! defined $where ) {
        complain "Missing argument";
    }

    if ( ref $where ne 'ARRAY' ) {
        complain "Invalid argument";
    }

    my $sql;
    my $bind;

    eval {

        $bind = [];
        $sql  = 'WHERE ';

        $self->_process_where_expression( 0, $where, \$sql, $bind, $args{'bind'} );

    };

    if ( $@ ) {
        complain $@;
    }

    return wantarray ? ( $sql, $bind ) : $sql;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _bind_column_value {

    my ( $self, $column, $value, $bind, $bind_attrs ) = @_;

    $bind ||= [];

    if ( $bind_attrs ) {

        if ( ref $bind_attrs ne 'HASH' ) {
            throw "Invalid argument (\"bind\")";
        }

        if ( exists $bind_attrs->{$column} ) {
            push @$bind, [ @$bind + 1, $value, $self->_convert_bind_type( $bind_attrs->{$column} ) ];
        }
        else {
            push @$bind, [ @$bind + 1, $value ];
        }

    }
    else {
        push @$bind, $value;
    }

    if ( wantarray ) {
        return $bind, $self->_quote_column( $column ), '?';
    }
    else {
        return $bind;
    }

}

sub _bind_column_values {

    my ( $self, $columns, $values, $bind, $bind_attrs ) = @_;

    $bind ||= [];

    if ( defined $values ) {

        if ( ref $values ne 'ARRAY' ) {
            throw "Invalid argument (\"values\")";
        }

        if ( @$columns != @$values ) {
            throw "Invalid number of column values";
        }

        if ( defined $bind_attrs ) {

            if ( ref $bind_attrs ne 'HASH' ) {
                throw "Invalid argument (\"bind\")";
            }

            my $n = @$bind + 1;

            for ( my $i = 0; $i < @$columns; $i++ ) {

                my $column = $columns->[$i];
                my $value  = $values->[$i];

                if ( exists $bind_attrs->{$column} ) {
                    push @$bind, [ $n, $value, $self->_convert_bind_type( $bind_attrs->{$column} ) ];
                }
                else {
                    push @$bind, [ $n, $value ];
                }

                $n++;

            }

        }
        else {
            push @$bind, @$values;
        }


    }
    else {

        if ( defined $bind_attrs ) {

            if ( ref $bind_attrs ne 'HASH' ) {
                throw "Invalid argument (\"bind\")";
            }

            my $n = @$bind + 1;

            for my $column ( @$columns ) {

                if ( exists $bind_attrs->{$column} ) {
                    push @$bind, [ $n, undef, $self->_convert_bind_type( $bind_attrs->{$column} ) ];
                }
                else {
                    push @$bind, [ $n, undef ];
                }

                $n++;

            }

        }
        else {
            push @$bind, map { undef } @$columns;
        }

    }

    if ( wantarray ) {
        return $bind, [ map { $self->_quote_column( $_ ) } @$columns ], [ map { '?' } @$columns ];
    }
    else {
        return $bind;
    }

}

sub _build_limit_clause {

    throw "Invalid argument (\"limit\" is not supported by " . ref( $_[0] ) . ")";

}

sub _build_order_clause {

    my ( $self, $order, $sql, $bind, $bind_attrs ) = @_;

    $$sql .= ' ORDER BY ';

    if  ( ! ref $order ) {
        $$sql .= $self->_quote_column( $order );
    }
    elsif ( ref $order eq 'ARRAY' ) {

        $$sql .= join(
            ', ',
            map {
                ref( $_ )
                    ? $self->_quote_column( $_->[0] ) . ' ' . $_->[1]
                    : $self->_quote_column( $_ )
            } @$order
        );

    }

    elsif  ( ref $order eq 'SCALAR' ) {
        $$sql .= $$order;
    }
    else {
        throw "Invalid argument (\"order\")";
    }

    return;

}

sub _build_where_clause {

    my ( $self, $where, $sql, $bind, $bind_attrs ) = @_;

    if ( ref $where eq 'ARRAY' ) {
        $$sql .= ' WHERE ';
        $self->_process_where_expression( 0, $where, $sql, $bind, $bind_attrs );
    }
    elsif ( ref $where eq 'SCALAR' && defined $$where ) {
        $$sql .= ' WHERE ' . $$where;
    }
    elsif ( ! ref $where && defined $where ) {
        $$sql .= ' WHERE ' . $where;
    }
    else {
        throw "Invalid argument (\"where\")";
    }

    return;

}

sub _convert_bind_type {

    my $self = shift;
    my $type = shift;

    return undef if ! defined $type;

    return $type if ref $type;

    my $dbi_type = $self->{'bind_type_map'}{$type};

    if ( ! defined $dbi_type ) {
        throw "Unsupported bind type \"$type\"";
    }

    return $dbi_type;

}

sub _process_where_expression {

    my ( $self, $depth, $block, $sql, $bind, $bind_attrs ) = @_;

    $$sql .= '( ' if $depth;

    my @tokens = @$block;

    while ( @tokens ) {

        my $token = shift @tokens;

        if ( ! defined $token ) {
            throw "Syntax error in \"where\" expression";
        }

        if ( ! ref $token ) {

            # $column => ...

            my $column = $token;

            $token = shift @tokens;

            if ( ! ref $token ) {

                # $column => $value

                my $handler = $self->_where_op_handler( '=' );

                $handler->( $self, $column, '=', $token, $sql, $bind, $bind_attrs );

            }
            elsif ( ref $token eq 'HASH' ) {

                # $column => { ... }

                if ( keys %$token == 1 ) {

                    # $column => { $operator => $value }

                    my ( $operator ) = keys %$token;

                    my $handler = $self->_where_op_handler( $operator );

                    if ( ! $handler ) {
                        throw "Unsupported operator \"$operator\" in \"where\" expression";
                    }

                    $handler->( $self, $column, %$token, $sql, $bind, $bind_attrs );

                }
                else {
                    throw "Syntax error in \"where\" expression";
                }

            }
            elsif ( ref $token eq 'ARRAY' ) {

                # $column => \@values 

                my $handler = $self->_where_op_handler( 'IN' );

                if ( ! $handler ) {
                    throw "Unsupported operator \"IN\" in \"where\" expression";
                }

                $handler->( $self, $column, 'IN', $token, $sql, $bind, $bind_attrs );

            }
            elsif ( ref $token eq 'SCALAR' ) {

                # $column => \$sql 

                $$sql .= $self->_quote_column( $column ) . ' ' . $$token;

            }
            else {
                throw "Syntax error in \"where\" expression";
            }

        }
        elsif ( ref $token eq 'ARRAY' ) {
            $self->_process_where_expression( $depth + 1, $token, $sql, $bind, $bind_attrs );
        }
        elsif ( ref $token eq 'SCALAR' ) {
            $$sql .= $$token;
        }
        else {
            throw "Syntax error in \"where\" expression";
        }

        if ( @tokens ) {

            my $next_token = $tokens[0];

            if ( ! defined $next_token ) {
                throw "Syntax error in \"where\" expression";
            }

            if ( ! ref $next_token && $next_token =~ /^(?:OR|AND)(?: NOT)?$/ ) {
                $$sql .= ' ' . $next_token . ' ';
                shift @tokens;
            }
            else {
                $$sql .= ' AND ';
            }

        }

    }

    $$sql .= ' )' if $depth;

    return;

}

sub _quote_column {

    return $_[1] if ! length $_[0]->{'quote_char'};

    return join(
        '.',
        map(
            { $_ ne '*' ? $_[0]->{'quote_char'} . $_ . $_[0]->{'quote_char'} : $_ }
            split( /\./, $_[1] )
        )
    );

}

sub _quote_table {

    return $_[1] if ! length $_[0]->{'quote_char'};

    return $_[0]->{'quote_char'} . $_[1] . $_[0]->{'quote_char'};

}


# ----------------------------------------------------------------------------------------------------------------------
# Attribute initializers
# ----------------------------------------------------------------------------------------------------------------------

sub _initialize_bind_type_map {

    return {
        GX::SQL::Types::BIGINT      => DBI::SQL_BIGINT,
        GX::SQL::Types::BINARY      => DBI::SQL_BINARY,
        GX::SQL::Types::BIT         => DBI::SQL_BIT,
        GX::SQL::Types::BLOB        => DBI::SQL_BLOB,
        GX::SQL::Types::BOOLEAN     => DBI::SQL_BOOLEAN,
        GX::SQL::Types::CHAR        => DBI::SQL_CHAR,
        GX::SQL::Types::DATE        => DBI::SQL_DATE,
        GX::SQL::Types::DATETIME    => DBI::SQL_DATETIME,
        GX::SQL::Types::DECIMAL     => DBI::SQL_DECIMAL,
        GX::SQL::Types::DOUBLE      => DBI::SQL_DOUBLE,
        GX::SQL::Types::FLOAT       => DBI::SQL_FLOAT,
        GX::SQL::Types::INTEGER     => DBI::SQL_INTEGER,
        GX::SQL::Types::LONGVARCHAR => DBI::SQL_LONGVARCHAR,
        GX::SQL::Types::NUMERIC     => DBI::SQL_NUMERIC,
        GX::SQL::Types::REAL        => DBI::SQL_REAL,
        GX::SQL::Types::SMALLINT    => DBI::SQL_SMALLINT,
        GX::SQL::Types::TIME        => DBI::SQL_TIME,
        GX::SQL::Types::TIMESTAMP   => DBI::SQL_TIMESTAMP,
        GX::SQL::Types::TINYINT     => DBI::SQL_TINYINT,
        GX::SQL::Types::VARCHAR     => DBI::SQL_VARCHAR
    };

}

sub _initialize_quote_char {

    return '"';

}

sub _initialize_where_op_handlers {

    my $self = shift;

    my %handlers;

    {

        my $handler = sub {

            my ( $self, $column, $operator, $value, $sql, $bind, $bind_attrs ) = @_;

            if ( ref $value ) {

                if ( ref $value eq 'SCALAR' && defined $$value ) {
                    $$sql .= $self->_quote_column( $column ) . ' ' . $operator . ' ' . $$value;
                }
                else {
                    throw "Syntax error in \"where\" expression";
                }

            }
            elsif ( defined $value ) {

                $$sql .= $self->_quote_column( $column ) . ' ' . $operator . ' ?';

                $self->_bind_column_value( $column, $value, $bind, $bind_attrs );

            }
            else {

                if ( $operator eq '=' ) {
                    $operator = 'IS';
                }
                elsif ( $operator eq '!=' ) {
                    $operator = 'IS NOT';
                }

                $$sql .= $self->_quote_column( $column ) . ' ' . $operator . ' NULL';

            }

            return;

        };

        for my $operator ( '=', 'IS', '!=', 'IS NOT', '<', '<=', '>', '>=' ) {
            $handlers{$operator} ||= $handler;
        }

    }

    {

        $handlers{'IN'} ||= sub {

            my ( $self, $column, $operator, $value, $sql, $bind, $bind_attrs ) = @_;

            if ( ref $value ne 'ARRAY' ) {
                throw "Syntax error in \"where\" expression";
            }

            $$sql .= $self->_quote_column( $column ) . ' IN ( '
                    . join( ', ', map { defined( $_ ) ? '?' : 'NULL' } @$value )
                    . ' )';

            for ( grep { defined } @$value ) {
                $self->_bind_column_value( $column, $_, $bind, $bind_attrs );
            }

            return;

        };

    }

    {

        $handlers{'BETWEEN'} ||= sub {

            my ( $self, $column, $operator, $value, $sql, $bind, $bind_attrs ) = @_;

            if ( ref $value ne 'ARRAY' || @$value != 2 ) {
                throw "Syntax error in \"where\" expression";
            }

            $$sql .= $self->_quote_column( $column ) . ' BETWEEN '
                   . ( defined $value->[0] ? '?' : 'NULL' )
                   . ' AND '
                   . ( defined $value->[1] ? '?' : 'NULL' );

            for ( grep { defined } @$value ) {
                $self->_bind_column_value( $column, $_, $bind, $bind_attrs );
            }

            return;

        };

    }

    return \%handlers;

}


1;

__END__

=head1 NAME

GX::SQL::Builder - Base class for SQL builders

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::SQL::Builder> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new SQL builder instance.

    $builder = $builder_class->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<quote_char> ( string )

Defaults to a double quote.

=back

=item Returns:

=over 4

=item * C<$builder> ( L<GX::SQL::Builder> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<count>

Creates a C<SELECT COUNT(*)> statement.

    ( $sql, $bind ) = $builder->count( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<bind> ( C<HASH> reference )

=item * C<table> ( string ) [ required ]

=item * C<where> ( C<ARRAY> reference )

=back

=item Returns:

=over 4

=item * C<$sql> ( string )

=item * C<$bind> ( C<ARRAY> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

In scalar context, only the generated SQL is returned.

=head3 C<delete>

Creates a C<DELETE> statement.

    ( $sql, $bind ) = $builder->delete( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<bind> ( C<HASH> reference )

=item * C<table> ( string ) [ required ]

=item * C<where> ( C<ARRAY> reference )

=back

=item Returns:

=over 4

=item * C<$sql> ( string )

=item * C<$bind> ( C<ARRAY> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

In scalar context, only the generated SQL is returned.

=head3 C<insert>

Creates an C<INSERT> statement.

    ( $sql, $bind ) = $builder->insert( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<bind> ( C<HASH> reference )

=item * C<columns> ( C<ARRAY> reference ) [ required ]

=item * C<table> ( string ) [ required ]

=item * C<values> ( C<ARRAY> reference )

=back

=item Returns:

=over 4

=item * C<$sql> ( string )

=item * C<$bind> ( C<ARRAY> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

In scalar context, only the generated SQL is returned.

=head3 C<select>

Creates a C<SELECT> statement.

    ( $sql, $bind ) = $builder->select( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<bind> ( C<HASH> reference )

=item * C<columns> ( C<ARRAY> reference )

=item * C<distinct> ( bool )

Adds the "DISTINCT" keyword to the query if set to true.

=item * C<limit> ( integer )

=item * C<offset> ( integer )

=item * C<order> ( string | C<SCALAR> reference | C<ARRAY> reference )

Examples:

    order => 'column_1'
    order => [ [ 'column_1', 'DESC' ] ]
    order => [ 'column_1', [ 'column_2', 'DESC' ] ]
    order => \$sql

=item * C<table> ( string ) [ required ]

=item * C<where> ( C<ARRAY> reference )

=back

=item Returns:

=over 4

=item * C<$sql> ( string )

=item * C<$bind> ( C<ARRAY> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

In scalar context, only the generated SQL is returned.

=head3 C<update>

Creates an C<UPDATE> statement.

    ( $sql, $bind ) = $builder->update( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<bind> ( C<HASH> reference )

=item * C<columns> ( C<ARRAY> reference ) [ required ]

=item * C<table> ( string ) [ required ]

=item * C<values> ( C<ARRAY> reference )

=item * C<where> ( C<ARRAY> reference )

=back

=item Returns:

=over 4

=item * C<$sql> ( string )

=item * C<$bind> ( C<ARRAY> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

In scalar context, only the generated SQL is returned.

=head3 C<where>

Creates a C<WHERE> clause.

    ( $sql, $bind ) = $builder->where( $where );
    ( $sql, $bind ) = $builder->where( $where, bind => $bind );

=over

=item Arguments:

=over 4

=item * C<$bind> ( C<HASH> reference ) [ optional ]

=item * C<$where> ( C<ARRAY> reference ) [ required ]

=back

=item Returns:

=over 4

=item * C<$sql> ( string )

=item * C<$bind> ( C<ARRAY> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

In scalar context, only the generated SQL is returned.

=head1 USAGE

=head2 Introduction

Example 1 - Generate a SQL INSERT statement and the neccessary bind parameters
to execute it:

    my ( $sql, $bind ) = $builder->insert(
        table   => 'countries',
        columns => [ 'id', 'name', 'code' ],
        values  => [ 1, 'Germany', 'DE' ]
    );

Returned SQL:

    'INSERT INTO "countries" ( "id", "name", "code" ) VALUES ( ?, ?, ? )'

Returned bind parameters:

    [ 1, 'Germany', 'DE' ]

Prepare the statement:

    my $sth = $dbh->prepare( $sql );

Execute the prepared statement:

    $sth->execute( @$bind );

Example 2 - Generate a SQL INSERT statement and execute it with varying data:

    my $sql = $builder->insert(
        table   => 'countries',
        columns => [ 'id', 'name', 'code' ]
    );
    
    my $sth = $dbh->prepare( $sql );
    
    my @data = (
        [ 1, 'Germany', 'DE' ],
        [ 2, 'Austria', 'AT' ],
        # ...
    );
    
    for my $row ( @data ) {
        $sth->execute( @$row );
    }

=head2 Bind Values and Bind Types

Example:

    use GX::SQL::Types qw( :all );
    
    my ( $sql, $bind ) = $builder->insert(
        table   => 'countries',
        columns => [ 'id', 'name', 'code' ],
        values  => [ 1, 'Germany', 'DE' ],
        bind    => {
            'id'   => INTEGER,
            'name' => VARCHAR,
            'code' => VARCHAR
        }
    );

Returned bind parameters:

    [
        [ 1, 1,         DBI::SQL_INTEGER ],
        [ 2, 'Germany', DBI::SQL_VARCHAR ],
        [ 3, 'DE',      DBI::SQL_VARCHAR ]
    ] 

Usage:

    my $sth = $dbh->prepare( $sql );
    
    for my $parameters ( @$bind ) {
        $sth->bind_param( @$parameters );
    }
    
    $sth->execute;

=head2 Custom Bind Arguments

    my ( $sql, $bind ) = $builder->insert(
        table   => 'countries',
        columns => [ 'id', 'name', 'code' ],
        values  => [ 1, 'Germany', 'DE' ],
        bind    => {
            'id'   => { TYPE => DBI::SQL_INTEGER },
            'name' => { TYPE => DBI::SQL_VARCHAR },
            'code' => { TYPE => DBI::SQL_VARCHAR }
        }
    );

Returned bind parameters:

    [
        [ 1, 1,         { TYPE => DBI::SQL_INTEGER } ],
        [ 2, 'Germany', { TYPE => DBI::SQL_VARCHAR } ],
        [ 3, 'DE',      { TYPE => DBI::SQL_VARCHAR } ]
    ] 

=head2 WHERE Clauses

=head3 Basic Syntax

    @where = ( 'name' => 'Germany' );

Result:

    $sql  = 'WHERE "name" = ?';
    $bind = [ 'Germany' ];

"AND" logic by default:

    @where = ( 'currency' => 'EUR', 'time_zone' => 'CET' );

Result:

    $sql  = 'WHERE "currency" = ? AND "time_zone" = ?';
    $bind = [ 'Euro', 'CET' ];

Supported logic: "AND", "OR", "AND NOT", "OR NOT".

    @where = ( 'currency' => 'EUR', 'OR', 'currency' => 'GBP' );

Result:

    $sql  = 'WHERE "currency" = ? OR "currency" = ?';
    $bind = [ 'EUR', 'GBP' ];

Multiple values:

    @where = ( 'currency' => [ 'EUR', 'GBP', 'USD' ] );

Result:

    $sql  = 'WHERE "currency" IN ( ?, ?, ? )';
    $bind = [ 'EUR', 'GBP', 'USD' ];

=head3 Operators

Simple operators: "=", "!=", "E<lt>", "E<gt>", "E<lt>=", "=E<gt>", 'IS', 'IS NOT'.

    @where = ( 'population' => { '>' => 50000000 } );

Result:

    $sql  = 'WHERE "population" > ?';
    $bind = [ 50000000 ];

"IN" operator:

    @where = ( 'currency' => { 'IN' => [ 'EUR', 'GBP', 'USD' ] } );

Result:

    $sql  = 'WHERE "currency" IN ( ?, ?, ? )';
    $bind = [ 'EUR', 'GBP', 'USD' ];

"BETWEEN" operator:

    @where = ( 'population' => { 'BETWEEN' => [ 10000000, 50000000 ] } );

Result:

    $sql  = 'WHERE "population" BETWEEN ? AND ?';
    $bind = [ 10000000, 50000000 ];

=head3 NULL Conversion

    @where = ( 'id' => undef );

Result:

    $sql  = 'WHERE "id" IS NULL';
    $bind = [];

Also NOT NULL conversion:

    @where = ( 'id' => { '!=' => undef } );

Result:

    $sql  = 'WHERE "id" IS NOT NULL';
    $bind = [];

=head3 Nesting

    @where = (
        'id' => 1,
        'OR',
        [ 'name' => 'Germany', 'code' => 'DE' ]
    );

Result:

    $sql  = 'WHERE "id" = ? OR ( "name" = ? AND "code" = ? )';
    $bind = [ 1, 'Germany', 'DE' ];

=head3 Literal SQL

    @where = ( 'id' => \'IS NOT NULL' );

Result:

    $sql  = 'WHERE "id" IS NOT NULL';
    $bind = [];

=head1 SUBCLASSES

The following classes inherit directly from L<GX::SQL::Builder>:

=over 4

=item * L<GX::SQL::Builder::MySQL>

=item * L<GX::SQL::Builder::Pg>

=item * L<GX::SQL::Builder::SQLite>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut

