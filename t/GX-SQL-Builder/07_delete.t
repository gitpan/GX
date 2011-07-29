#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    plan tests => 9;

}


use GX::SQL::Builder;
use GX::SQL::Types qw( :all );


my $SQL_BUILDER = GX::SQL::Builder->new;


# Delete all
{

    my ( $sql, $bind ) = $SQL_BUILDER->delete(
        table => 't1'
    );

    is( $sql, 'DELETE FROM "t1"' );

    is_deeply( $bind, [] );

}

# where => [ 'f1' => 1 ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->delete(
        table => 't1',
        where => [ 'f1' => 'v1' ]
    );

    is( $sql, 'DELETE FROM "t1" WHERE "f1" = ?' );

    is_deeply( $bind, [ 'v1' ] );

}

# where => [ 'f1' => 'v1' ], bind => {}
{

    my ( $sql, $bind ) = $SQL_BUILDER->delete(
        table => 't1',
        where => [ 'f1' => 'v1' ],
        bind  => {}
    );

    is( $sql, 'DELETE FROM "t1" WHERE "f1" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1' ]
        ]
    );

}

# where => [ 'f1' => 'v1' ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->delete(
        table => 't1',
        where => [ 'f1' => 'v1' ],
        bind  => { 'f1' => VARCHAR }
    );

    is( $sql, 'DELETE FROM "t1" WHERE "f1" = ?' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1', DBI::SQL_VARCHAR ]
        ]
    );

}

# Scalar context
{

    my ( $sql, $bind ) = $SQL_BUILDER->delete(
        table => 't1',
        where => [ 'f1' => 1 ]
    );

    is( $sql, 'DELETE FROM "t1" WHERE "f1" = ?' );

}

