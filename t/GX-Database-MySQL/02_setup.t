#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    if ( ! eval { require DBD::mysql } ) {
        plan skip_all => "DBD::mysql is not installed";
        exit;
    }

    plan tests => 12;

}


package MyApp::Database::A;

use GX::Database::MySQL;

__PACKAGE__->setup(
    database        => 'gxtest',
    host            => '127.0.0.1',
    port            => 3306,
    user            => 'gxuser',
    password        => 'gxpassword',
    driver_options  => 'mysql_compression=1',
    connect_options => { 'TraceLevel' => 1 }
);


package MyApp::Database::B;

use GX::Database::MySQL;

__PACKAGE__->setup(
    dsn             => 'DBI:mysql:dbname=gxtest',
    connect_options => { 'TraceLevel' => 1 }
);


package MyApp::Database::C;

use GX::Database::MySQL;

__PACKAGE__->setup(
    dsn             => 'DBI:mysql(RaiseError=>1,PrintError=>1):dbname=gxtest',
    connect_options => { 'TraceLevel' => 1 }
);


package main;


# MyApp::Database::A
{

    my $database = MyApp::Database::A->instance;

    is( $database->dsn, 'DBI:mysql:database=gxtest;host=127.0.0.1;port=3306;mysql_compression=1' );
    is( $database->user, 'gxuser' );
    is( $database->password, 'gxpassword' );

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

    is( $database->dsn, 'DBI:mysql:dbname=gxtest' );
    is( $database->user, undef );
    is( $database->password, undef );

    is_deeply(
        { $database->connect_options },
        {
            'HandleError' => MyApp::Database::B->can( '_dbi_error_handler' ),                                                                               
            'AutoCommit'  => 1,                                                                                              
            'RaiseError'  => 1,                                                                                              
            'PrintError'  => 0,
            'TraceLevel'  => 1
        }
    );

}

# MyApp::Database::C
{

    my $database = MyApp::Database::C->instance;

    is( $database->dsn, 'DBI:mysql(RaiseError=>1,PrintError=>1):dbname=gxtest' );
    is( $database->user, undef );
    is( $database->password, undef );

    is_deeply(
        { $database->connect_options },
        {
            'HandleError' => MyApp::Database::C->can( '_dbi_error_handler' ),                                                                               
            'AutoCommit'  => 1,                                                                                              
            'RaiseError'  => 1,                                                                                              
            'PrintError'  => 0,
            'TraceLevel'  => 1
        }
    );

}

