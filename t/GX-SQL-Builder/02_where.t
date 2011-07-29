#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    plan tests => 56;

}


use GX::SQL::Builder;
use GX::SQL::Types qw( :all );


my $SQL_BUILDER = GX::SQL::Builder->new;


# where => [ 'f1' => 'v1' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => 'v1' ]
    );

    is( $sql, 'WHERE "f1" = ?' );

    is_deeply( $bind, [ 'v1' ] );

}

# where => [ 'f1' => undef ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => undef ]
    );

    is( $sql, 'WHERE "f1" IS NULL' );

    is_deeply( $bind, [] );

}

# where => [ 'f1' => [ 'v1', 'v2', 'v3' ] ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => [ 'v1', 'v2', 'v3' ] ]
    );

    is( $sql, 'WHERE "f1" IN ( ?, ?, ? )' );

    is_deeply( $bind, [ 'v1', 'v2', 'v3' ] );

}

# where => [ 'f1' => 'v1', 'f2' => 'v2' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => 'v1', 'f2' => 'v2' ]
    );

    is( $sql, 'WHERE "f1" = ? AND "f2" = ?' );

    is_deeply( $bind, [ 'v1', 'v2' ] );

}

# where => [ 'f1' => 'v1', 'AND', 'f2' => 'v2' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => 'v1', 'AND', 'f2' => 'v2' ]
    );

    is( $sql, 'WHERE "f1" = ? AND "f2" = ?' );

    is_deeply( $bind, [ 'v1', 'v2' ] );

}

# where => [ 'f1' => 'v1', 'OR', 'f1' => 'v2' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => 'v1', 'OR', 'f1' => 'v2' ]
    );

    is( $sql, 'WHERE "f1" = ? OR "f1" = ?' );

    is_deeply( $bind, [ 'v1', 'v2' ] );

}

# where => [ [ 'f1' => 'v1' ], [ 'f2' => 'v2' ] ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [
            [ 'f1' => 'v1' ],
            [ 'f2' => 'v2' ]
        ]
    );

    is( $sql, 'WHERE ( "f1" = ? ) AND ( "f2" = ? )' );

    is_deeply( $bind, [ 'v1', 'v2' ] );

}


# where => [ 'f1' => { '=' => undef } ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => { '=' => undef } ]
    );

    is( $sql, 'WHERE "f1" IS NULL' );

    is_deeply( $bind, [] );

}

# where => [ 'f1' => { '!=' => undef } ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => { '!=' => undef } ]
    );

    is( $sql, 'WHERE "f1" IS NOT NULL' );

    is_deeply( $bind, [] );

}

# where => [ 'f1' => { 'IS' => undef } ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => { 'IS' => undef } ]
    );

    is( $sql, 'WHERE "f1" IS NULL' );

    is_deeply( $bind, [] );

}

# where => [ 'f1' => { 'IS NOT' => undef } ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => { 'IS NOT' => undef } ]
    );

    is( $sql, 'WHERE "f1" IS NOT NULL' );

    is_deeply( $bind, [] );

}

# where => [ 'f1' => { '>' => 'v1' }, 'f2' => { '<' => 'v2' } ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => { '>' => 'v1' }, 'f2' => { '<' => 'v2' } ]
    );

    is( $sql, 'WHERE "f1" > ? AND "f2" < ?' );

    is_deeply( $bind, [ 'v1', 'v2' ] );

}

# where => [ 'f1' => { '>' => 'v11' }, 'OR', [ 'f1' => 'v12', 'f2' => { '>' => 'v2' } ] ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [
            'f1' => { '>' => 'v11' },
            'OR',
            [
                'f1' => 'v12',
                'f2' => { '>' => 'v2' }
            ]
        ]
    );

    is( $sql, 'WHERE "f1" > ? OR ( "f1" = ? AND "f2" > ? )' );

    is_deeply( $bind, [ 'v11', 'v12', 'v2' ] );

}

# where => [ 'f1' => { 'IN' => [ 'v1', 'v2', 'v3' ] } ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => { 'IN' => [ 'v1', 'v2', 'v3' ] } ]
    );

    is( $sql, 'WHERE "f1" IN ( ?, ?, ? )' );

    is_deeply( $bind, [ 'v1', 'v2', 'v3' ] );

}

# where => [ 'f1' => { 'BETWEEN' => [ 'v1', 'v2' ] } ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => { 'BETWEEN' => [ 'v1', 'v2' ] } ]
    );

    is( $sql, 'WHERE "f1" BETWEEN ? AND ?' );

    is_deeply( $bind, [ 'v1', 'v2' ] );

}


# ----------------------------------------------------------------------------------------------------------------------
# Tests with bind => \%bind
# ----------------------------------------------------------------------------------------------------------------------

# where => [ 'f1' => 'v1' ], bind => {}
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => 'v1' ],
        bind => {}
    );

    is( $sql, 'WHERE "f1" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1' ]
        ]
    );

}

# where => [ 'f1' => 'v1' ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => 'v1' ],
        bind => { 'f1' => VARCHAR }
    );

    is( $sql, 'WHERE "f1" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1', DBI::SQL_VARCHAR ]
        ]
    );

}

# where => [ 'f1' => $sql ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => \"= SQL" ],
        bind => { 'f1' => VARCHAR }
    );

    is( $sql, 'WHERE "f1" = SQL' );

    is_deeply( $bind, [] );

}

# where => [ 'f1' => 'v1', 'f2' => 'v2' ], bind => { 'f1' => VARCHAR, 'f2' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => 'v1', 'f2' => 'v2' ],
        bind => { 'f1' => VARCHAR, 'f2' => VARCHAR }
    );

    is( $sql, 'WHERE "f1" = ? AND "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1', DBI::SQL_VARCHAR ],
            [ 2, 'v2', DBI::SQL_VARCHAR ]
        ]
    );

}

# where => [ 'f1' => $sql, 'f2' => 'v2' ], bind => { 'f1' => VARCHAR, 'f2' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => \"= SQL", 'f2' => 'v2' ],
        bind => { 'f1' => VARCHAR, 'f2' => VARCHAR }
    );

    is( $sql, 'WHERE "f1" = SQL AND "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v2', DBI::SQL_VARCHAR ]
        ]
    );

}

# where => [ 'f1' => 'v1', 'f2' => 'v2' ], bind => {}
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => 'v1', 'f2' => 'v2' ],
        bind => {}
    );

    is( $sql, 'WHERE "f1" = ? AND "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1' ],
            [ 2, 'v2' ]
        ]
    );

}

# where => [ 'f1' => 'v1', 'OR', 'f1' => 'v2' ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => 'v1', 'OR', 'f1' => 'v2' ],
        bind => { 'f1' => VARCHAR }
    );

    is( $sql, 'WHERE "f1" = ? OR "f1" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1', DBI::SQL_VARCHAR ],
            [ 2, 'v2', DBI::SQL_VARCHAR ]
        ]
    );

}

# where => [ 'f1' => [ 'v1', 'v2', 'v3' ] ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => [ 'v1', 'v2', 'v3' ] ],
        bind => { 'f1' => VARCHAR }
    );

    is( $sql, 'WHERE "f1" IN ( ?, ?, ? )' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1', DBI::SQL_VARCHAR ],
            [ 2, 'v2', DBI::SQL_VARCHAR ],
            [ 3, 'v3', DBI::SQL_VARCHAR ],
        ]
    );

}

# where => [ 'f1' => { 'IS' => undef } ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => { 'IS' => undef } ],
        bind => { 'f1' => VARCHAR }
    );

    is( $sql, 'WHERE "f1" IS NULL' );

    is_deeply( $bind, [] );

}

# where => [ 'f1' => { 'IS NOT' => undef } ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => { 'IS NOT' => undef } ],
        bind => { 'f1' => VARCHAR }
    );

    is( $sql, 'WHERE "f1" IS NOT NULL' );

    is_deeply( $bind, [] );

}

# Complex expression, Nesting
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [
            'f1' => { '>' => 1 },
            'OR',
            [
                'f2' => 'v2',
                'f3' => { '>' => 3 }
            ]
        ],
        bind => { 'f1' => INTEGER, 'f2' => VARCHAR, 'f3' => INTEGER }
    );

    is( $sql, 'WHERE "f1" > ? OR ( "f2" = ? AND "f3" > ? )' );

    is_deeply(
        $bind,
        [
            [ 1, 1,    DBI::SQL_INTEGER ],
            [ 2, 'v2', DBI::SQL_VARCHAR ],
            [ 3, 3,    DBI::SQL_INTEGER ]
        ]
    );

}

# Complex expression, NULL values
{

    my ( $sql, $bind ) = $SQL_BUILDER->where(
        [ 'f1' => undef, 'f2' => 'v2', 'f3' => undef, 'f4' => 'v4' ],
        bind => { 'f1' => VARCHAR, 'f2' => VARCHAR, 'f3' => VARCHAR, 'f4' => VARCHAR }
    );

    is( $sql, 'WHERE "f1" IS NULL AND "f2" = ? AND "f3" IS NULL AND "f4" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v2', DBI::SQL_VARCHAR ],
            [ 2, 'v4', DBI::SQL_VARCHAR ]
        ]
    );

}


# ----------------------------------------------------------------------------------------------------------------------
# Miscellaneous tests
# ----------------------------------------------------------------------------------------------------------------------

# Scalar context
{

    my $sql = $SQL_BUILDER->where(
        [ 'f1' => 1 ]
    );

    is( $sql, 'WHERE "f1" = ?' );

}

# Quoting, qualified column name
{

    my $sql = $SQL_BUILDER->where(
        [ 'table_1.f1' => 1 ]
    );

    is( $sql, 'WHERE "table_1"."f1" = ?' );

}

