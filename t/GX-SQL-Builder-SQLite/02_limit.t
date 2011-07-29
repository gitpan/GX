#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    plan tests => 8;

}


use GX::SQL::Builder::SQLite;


my $SQL_BUILDER = GX::SQL::Builder::SQLite->new;


# limit => 10
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table => 't1',
        limit => 10
    );

    is( $sql, 'SELECT * FROM "t1" LIMIT 10' );

    is_deeply( $bind, [] );

}

# limit => 10, offset => 5
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table  => 't1',
        limit  => 10,
        offset => 5
    );

    is( $sql, 'SELECT * FROM "t1" LIMIT 10 OFFSET 5' );

    is_deeply( $bind, [] );

}

# where => [ 'f1' => 'v1' ], limit => 10, offset => 5
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table  => 't1',
        where  => [ 'f1' => 'v1' ],
        limit  => 10,
        offset => 5
    );

    is( $sql, 'SELECT * FROM "t1" WHERE "f1" = ? LIMIT 10 OFFSET 5' );

    is_deeply( $bind, [ 'v1' ] );

}

# where => [ 'f1' => 'v1' ], order => 'f1', limit => 10, offset => 5
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table  => 't1',
        where  => [ 'f1' => 'v1' ],
        order  => 'f1',
        limit  => 10,
        offset => 5
    );

    is( $sql, 'SELECT * FROM "t1" WHERE "f1" = ? ORDER BY "f1" LIMIT 10 OFFSET 5' );

    is_deeply( $bind, [ 'v1' ] );

}

