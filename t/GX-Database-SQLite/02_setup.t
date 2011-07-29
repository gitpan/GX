#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    if ( ! eval { require DBD::SQLite } ) {
        plan skip_all => "DBD::SQLite is not installed";
        exit;
    }

    plan tests => 6;

}


package MyApp::Database::A;

use GX::Database::SQLite;

__PACKAGE__->setup(
    file            => 'filename.sqlite',
    connect_options => { 'TraceLevel' => 1 }
);


package MyApp::Database::B;

use GX::Database::SQLite;

__PACKAGE__->setup(
    dsn             => 'DBI:SQLite:dbname=filename.sqlite',
    connect_options => { 'TraceLevel' => 1, 'sqlite_unicode' => 1 }
);


package MyApp::Database::C;

use GX::Database::SQLite;

__PACKAGE__->setup(
    dsn             => 'DBI:SQLite(RaiseError=>1,PrintError=>1,sqlite_unicode=>1):dbname=filename.sqlite',
    connect_options => { 'TraceLevel' => 1 }
);


package main;


# MyApp::Database::A
{

    my $database = MyApp::Database::A->instance;

    is( $database->dsn, 'DBI:SQLite:dbname=filename.sqlite' );

    is_deeply(
        { $database->connect_options },
        {
            'HandleError' => MyApp::Database::A->can( '_dbi_error_handler' ),                                                                               
            'AutoCommit'  => 1,                                                                                              
            'RaiseError'  => 1,                                                                                              
            'PrintError'  => 0,
            'TraceLevel'  => 1
        }
    );

}

# MyApp::Database::B
{

    my $database = MyApp::Database::B->instance;

    is( $database->dsn, 'DBI:SQLite:dbname=filename.sqlite' );

    is_deeply(
        { $database->connect_options },
        {
            'HandleError'    => MyApp::Database::B->can( '_dbi_error_handler' ),                                                                               
            'AutoCommit'     => 1,                                                                                              
            'RaiseError'     => 1,                                                                                              
            'PrintError'     => 0,
            'TraceLevel'     => 1,
            'sqlite_unicode' => 1
        }
    );

}

# MyApp::Database::C
{

    my $database = MyApp::Database::C->instance;

    is( $database->dsn, 'DBI:SQLite(RaiseError=>1,PrintError=>1,sqlite_unicode=>1):dbname=filename.sqlite' );

    is_deeply(
        { $database->connect_options },
        {
            'HandleError'    => MyApp::Database::C->can( '_dbi_error_handler' ),                                                                               
            'AutoCommit'     => 1,                                                                                              
            'RaiseError'     => 1,                                                                                              
            'PrintError'     => 0,
            'TraceLevel'     => 1
        }
    );

}

