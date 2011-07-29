#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if ( ! eval { require DBI } ) {
        plan skip_all => "DBI is not installed";
        exit;
    }

    if ( ! eval { require DBD::Pg } ) {
        plan skip_all => "DBD::Pg is not installed";
        exit;
    }

    plan tests => 12;

}


package MyApp::Database::A;

use GX::Database::Pg;

__PACKAGE__->setup(
    database        => 'gxtest',
    host            => '127.0.0.1',
    port            => 5432,
    user            => 'gxuser',
    password        => 'gxpassword',
    driver_options  => 'sslmode=allow',
    connect_options => { 'TraceLevel' => 1 }
);


package MyApp::Database::B;

use GX::Database::Pg;

__PACKAGE__->setup(
    dsn             => 'DBI:Pg:database=gxtest',
    connect_options => { 'TraceLevel' => 1 }
);


package MyApp::Database::C;

use GX::Database::Pg;

__PACKAGE__->setup(
    dsn             => 'DBI:Pg(RaiseError=>1,PrintError=>1):database=gxtest',
    connect_options => { 'TraceLevel' => 1 }
);


package main;


# MyApp::Database::A
{

    my $database = MyApp::Database::A->instance;

    is( $database->dsn, 'DBI:Pg:database=gxtest;host=127.0.0.1;port=5432;sslmode=allow' );
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

    is( $database->dsn, 'DBI:Pg:database=gxtest' );
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

    is( $database->dsn, 'DBI:Pg(RaiseError=>1,PrintError=>1):database=gxtest' );
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

