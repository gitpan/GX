#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    plan tests => 19;

}


use GX::SQL::Builder;
use GX::SQL::Types qw( :all );


my $SQL_BUILDER = GX::SQL::Builder->new;


# columns => [ 'f1' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->insert(
        table   => 't1',
        columns => [ 'f1' ]
    );

    is( $sql, 'INSERT INTO "t1" ( "f1" ) VALUES ( ? )' );

    is_deeply( $bind, [ undef ] );

}

# columns => [ 'f1', 'f2' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->insert(
        table   => 't1',
        columns => [ 'f1', 'f2' ]
    );

    is( $sql, 'INSERT INTO "t1" ( "f1", "f2" ) VALUES ( ?, ? )' );

    is_deeply( $bind, [ undef, undef ] );

}

# columns => [ 'f1' ], values => [ 'v1' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->insert(
        table   => 't1',
        columns => [ 'f1' ],
        values  => [ 'v1' ],
    );

    is( $sql, 'INSERT INTO "t1" ( "f1" ) VALUES ( ? )' );

    is_deeply(
        $bind,
        [ 'v1' ]
    );

}

# columns => [ 'f1', 'f2' ], values => [ 'v1', 'v2' ]
{

    my ( $sql, $bind ) = $SQL_BUILDER->insert(
        table   => 't1',
        columns => [ 'f1', 'f2' ],
        values  => [ 'v1', 'v2' ],
    );

    is( $sql, 'INSERT INTO "t1" ( "f1", "f2" ) VALUES ( ?, ? )' );

    is_deeply(
        $bind,
        [ 'v1', 'v2' ]
    );

}


# columns => [ 'f1' ], bind => {}
{

    my ( $sql, $bind ) = $SQL_BUILDER->insert(
        table   => 't1',
        columns => [ 'f1' ],
        bind    => {}
    );

    is( $sql, 'INSERT INTO "t1" ( "f1" ) VALUES ( ? )' );

    is_deeply(
        $bind,
        [
            [ 1, undef ]
        ]
    );

}

# columns => [ 'f1' ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->insert(
        table   => 't1',
        columns => [ 'f1' ],
        bind    => { 'f1' => VARCHAR }
    );

    is( $sql, 'INSERT INTO "t1" ( "f1" ) VALUES ( ? )' );

    is_deeply(
        $bind,
        [
            [ 1, undef, DBI::SQL_VARCHAR ]
        ]
    );

}

# columns => [ 'f1' ], values => [ 'v1' ], bind => { 'f1' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->insert(
        table   => 't1',
        columns => [ 'f1' ],
        values  => [ 'v1' ],
        bind    => { 'f1' => VARCHAR }
    );

    is( $sql, 'INSERT INTO "t1" ( "f1" ) VALUES ( ? )' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1', DBI::SQL_VARCHAR ]
        ]
    );

}

# columns => [ 'f1', 'f2' ], values => [ 'v1', 'v2' ], bind => { 'f2' => VARCHAR }
{

    my ( $sql, $bind ) = $SQL_BUILDER->insert(
        table   => 't1',
        columns => [ 'f1', 'f2' ],
        values  => [ 'v1', 'v2' ],
        bind    => { 'f2' => VARCHAR }
    );

    is( $sql, 'INSERT INTO "t1" ( "f1", "f2" ) VALUES ( ?, ? )' );

    is_deeply(
        $bind,
        [
            [ 1, 'v1' ],
            [ 2, 'v2', DBI::SQL_VARCHAR ]
        ]
    );

}


# Number of columns / values mismatch
{

    local $@;

    eval {
        my ( $sql, $bind ) = $SQL_BUILDER->insert(
            table   => 't1',
            columns => [ 'f1' ],
            values  => []
        );
    };

    isa_ok( $@, 'GX::Exception' );

    eval {
        my ( $sql, $bind ) = $SQL_BUILDER->insert(
            table   => 't1',
            columns => [ 'f1' ],
            values  => [ 1, 2 ]
        );
    };

    isa_ok( $@, 'GX::Exception' );

}

# Scalar context
{

    my $sql = $SQL_BUILDER->insert(
        table   => 't1',
        columns => [ 'f1' ]
    );

    is( $sql, 'INSERT INTO "t1" ( "f1" ) VALUES ( ? )' );

}

