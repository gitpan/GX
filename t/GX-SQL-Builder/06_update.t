#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    plan tests => 30;

}


use GX::SQL::Builder;
use GX::SQL::Types qw( :all );


my $SQL_BUILDER = GX::SQL::Builder->new;


# columns => [ 'f1' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1' ]
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ?' );

    is_deeply( $bind, [ undef ] );

}

# columns => [ 'f1', 'f2' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1', 'f2' ]
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ?, "f2" = ?' );

    is_deeply( $bind, [ undef, undef ] );

}


# columns => [ 'f1' ], values => [ 'v1' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1' ],
        values  => [ 'v1' ]
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ?' );

    is_deeply( $bind, [ 'v1' ] );

}

# columns => [ 'f1', 'f2' ], values => [ 'v1', 'v2' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1', 'f2' ],
        values  => [ 'v1', 'v2' ]
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ?, "f2" = ?' );

    is_deeply( $bind, [ 'v1', 'v2' ] );

}


# columns => [ 'f1' ], bind => {}
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1' ],
        bind    => {}
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, undef ]
        ]
    );

}

# columns => [ 'f1' ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1' ],
        bind    => { 'f1' => VARCHAR }
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, undef, DBI::SQL_VARCHAR ]
        ]
    );

}

# columns => [ 'f1', 'f2' ], bind => {}
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1', 'f2' ],
        bind    => {}
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ?, "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, undef ],
            [ 2, undef ]
        ]
    );

}

# columns => [ 'f1', 'f2' ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1', 'f2' ],
        bind    => { 'f1' => VARCHAR }
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ?, "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, undef, DBI::SQL_VARCHAR ],
            [ 2, undef ]
        ]
    );

}

# columns => [ 'f1', 'f2' ], bind => { 'f2' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1', 'f2' ],
        bind    => { 'f2' => VARCHAR }
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ?, "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, undef ],
            [ 2, undef, DBI::SQL_VARCHAR ]
        ]
    );

}

# columns => [ 'f1', 'f2' ], bind => { 'f1' => VARCHAR, 'f2' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1', 'f2' ],
        bind    => { 'f1' => VARCHAR, 'f2' => VARCHAR }
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ?, "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, undef, DBI::SQL_VARCHAR ],
            [ 2, undef, DBI::SQL_VARCHAR ]
        ]
    );

}


# columns => [ 'f1' ], where => [ 'f2' => 'v2' ], bind => {}
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1' ],
        where   => [ 'f2' => 'v2' ],
        bind    => {}
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ? WHERE "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, undef ],
            [ 2, 'v2' ],
        ]
    );

}


# columns => [ 'f1' ], values => [ 'v1' ], where => [ 'f2' => 'v2' ], bind => {}
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1' ],
        values  => [ 'v1' ],
        where   => [ 'f2' => 'v2' ],
        bind    => {}
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ? WHERE "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1' ],
            [ 2, 'v2' ],
        ]
    );

}

# columns => [ 'f1' ], values => [ 'v1' ], where => [ 'f2' => 'v2' ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1' ],
        values  => [ 'v1' ],
        where   => [ 'f2' => 'v2' ],
        bind    => { 'f1' => VARCHAR }
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ? WHERE "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1', DBI::SQL_VARCHAR ],
            [ 2, 'v2' ]
        ]
    );

}

# columns => [ 'f1' ], values => [ 'v1' ], where => [ 'f2' => 'v2' ], bind => { 'f1' => VARCHAR, 'f2' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1' ],
        values  => [ 'v1' ],
        where   => [ 'f2' => 'v2' ],
        bind    => { 'f1' => VARCHAR, 'f2' => VARCHAR }
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ? WHERE "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1', DBI::SQL_VARCHAR ],
            [ 2, 'v2', DBI::SQL_VARCHAR ]
        ]
    );

}

# columns => [ 'f1', 'f2' ], values => [ 'v1', 'v21' ], where => [ 'f2' => 'v22' ], bind => { 'f1' => VARCHAR, 'f2' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->update(
        table   => 't1',
        columns => [ 'f1', 'f2' ],
        values  => [ 'v1', 'v21' ],
        where   => [ 'f2' => 'v22' ],
        bind    => { 'f1' => VARCHAR, 'f2' => VARCHAR }
    );

    is( $sql, 'UPDATE "t1" SET "f1" = ?, "f2" = ? WHERE "f2" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1', DBI::SQL_VARCHAR ],
            [ 2, 'v21', DBI::SQL_VARCHAR ],
            [ 3, 'v22', DBI::SQL_VARCHAR ]
        ]
    );

}


