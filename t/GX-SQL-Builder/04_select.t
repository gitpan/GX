#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    plan tests => 32;

}


use GX::SQL::Builder;
use GX::SQL::Types qw( :all );


my $SQL_BUILDER = GX::SQL::Builder->new;


# Select all
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table => 't1'
    );

    is( $sql, 'SELECT * FROM "t1"' );

    is_deeply( $bind, [] );

}

# order => 'f1'
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table => 't1',
        order => 'f1'
    );

    is( $sql, 'SELECT * FROM "t1" ORDER BY "f1"' );

    is_deeply( $bind, [] );

}

# order => [ 'f1', 'f2' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table => 't1',
        order => [ 'f1', 'f2' ]
    );

    is( $sql, 'SELECT * FROM "t1" ORDER BY "f1", "f2"' );

    is_deeply( $bind, [] );

}

# order => [ [ 'f1', 'ASC' ], [ 'f2', 'DESC' ] ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table => 't1',
        order => [ [ 'f1', 'ASC' ], [ 'f2', 'DESC' ] ]
    );

    is( $sql, 'SELECT * FROM "t1" ORDER BY "f1" ASC, "f2" DESC' );

    is_deeply( $bind, [] );

}

# where => [ 'f1' => 'v1' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table => 't1',
        where => [ 'f1' => 'v1' ]
    );

    is( $sql, 'SELECT * FROM "t1" WHERE "f1" = ?' );

    is_deeply( $bind, [ 'v1' ] );

}

# where => [ 'f1' => 'v1' ], bind => {}
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table => 't1',
        where => [ 'f1' => 'v1' ],
        bind  => {}
    );

    is( $sql, 'SELECT * FROM "t1" WHERE "f1" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1' ]
        ]
    );

}

# where => [ 'f1' => 'v1' ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table => 't1',
        where => [ 'f1' => 'v1' ],
        bind  => { 'f1' => VARCHAR }
    );

    is( $sql, 'SELECT * FROM "t1" WHERE "f1" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1', DBI::SQL_VARCHAR ]
        ]
    );

}

# where => [ 'f1' => 'v1' ], order => 'f1'
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table => 't1',
        where => [ 'f1' => 'v1' ],
        order => 'f1'
    );

    is( $sql, 'SELECT * FROM "t1" WHERE "f1" = ? ORDER BY "f1"' );

    is_deeply( $bind, [ 'v1' ] );

}

# columns => [ 'f1' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table   => 't1',
        columns => [ 'f1' ]
    );

    is( $sql, 'SELECT "f1" FROM "t1"' );

    is_deeply( $bind, [] );

}

# columns => [ 'f1' ], where => [ 'f1' => 'v1' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table   => 't1',
        columns => [ 'f1' ],
        where   => [ 'f1' => 'v1' ]
    );

    is( $sql, 'SELECT "f1" FROM "t1" WHERE "f1" = ?' );

    is_deeply( $bind, [ 'v1' ] );

}

# columns => [ 'f1' ], where => [ 'f1' => 'v1' ], bind => {}
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table   => 't1',
        columns => [ 'f1' ],
        where   => [ 'f1' => 'v1' ],
        bind    => {}
    );

    is( $sql, 'SELECT "f1" FROM "t1" WHERE "f1" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1' ]
        ]
    );

}

# columns => [ 'f1' ], where => [ 'f1' => 'v1' ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table   => 't1',
        columns => [ 'f1' ],
        where   => [ 'f1' => 'v1' ],
        bind    => { 'f1' => VARCHAR }
    );

    is( $sql, 'SELECT "f1" FROM "t1" WHERE "f1" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1', DBI::SQL_VARCHAR ]
        ]
    );

}

# columns => [ 'f1', 'f2', 'f3' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table   => 't1',
        columns => [ 'f1', 'f2', 'f3' ]
    );

    is( $sql, 'SELECT "f1", "f2", "f3" FROM "t1"' );

    is_deeply( $bind, [] );

}

# columns => [ 'f1', 'f2', 'f3' ], where => [ 'f1' => 'v1' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->select(
        table   => 't1',
        columns => [ 'f1', 'f2', 'f3' ],
        where   => [ 'f1' => 'v1' ]
    );

    is( $sql, 'SELECT "f1", "f2", "f3" FROM "t1" WHERE "f1" = ?' );

    is_deeply( $bind, [ 'v1' ] );

}

# Scalar context
{

    my $sql = $SQL_BUILDER->select(
        table   => 't1',
        columns => [ 'f1' ],
        where   => [ 'f1' => 'v1' ]
    );

    is( $sql, 'SELECT "f1" FROM "t1" WHERE "f1" = ?' );

}

# Quoting, select list
{

    {

        my $sql = $SQL_BUILDER->select(
            table   => 't1',
            columns => [ 't1.f1' ]
        );
    
        is( $sql, 'SELECT "t1"."f1" FROM "t1"' );

    }

    {

        my $sql = $SQL_BUILDER->select(
            table   => 't1',
            columns => [ '*' ]
        );
    
        is( $sql, 'SELECT * FROM "t1"' );

    }

    {

        my $sql = $SQL_BUILDER->select(
            table   => 't1',
            columns => [ 't1.*' ]
        );
    
        is( $sql, 'SELECT "t1".* FROM "t1"' );

    }

}

