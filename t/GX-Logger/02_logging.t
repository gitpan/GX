#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Logger::A;
{

    use GX::Logger;

    __PACKAGE__->setup;

}


package main;


use Test::More tests => 111;


my @Log_levels = qw( trace debug notice warning error fatal );
my $Logger     = MyApp::Logger::A->instance;


# levels()
{

    my @levels = @Log_levels;

    while ( @levels ) {
        is_deeply( [ $Logger->levels( @levels ) ], \@levels );
        is_deeply( [ $Logger->levels ], \@levels );
        pop @levels;
    }

}

# levels()
{

    for ( my $i = 0; $i < @Log_levels; $i++ ) {
        is_deeply( [ $Logger->levels( @Log_levels[ 0 .. $i ] ) ], [ @Log_levels[ 0 .. $i ] ] );
        is_deeply( [ $Logger->levels ], [ @Log_levels[ 0 .. $i ] ] );
    }

}

# enable_all,() disable_all()
{

    is_deeply( [ $Logger->levels ], \@Log_levels );

    $Logger->disable_all;

    is_deeply( [ $Logger->levels ], [] );

    $Logger->enable_all;

    is_deeply( [ $Logger->levels ], \@Log_levels );

}

# enable(), disable(), is_enabled()
{

    for ( @Log_levels ) {
        $Logger->disable( $_ );
        ok( ! $Logger->is_enabled( $_ ) );
    }

    for ( @Log_levels ) {
        $Logger->enable( $_ );
        ok( $Logger->is_enabled( $_ ) );
    }

}

# log()
{

    $Logger->enable_all;

    for ( @Log_levels ) {

        ok( $Logger->is_enabled( $_ ) );

        my $message = "message_$_";

        {

            my $stderr = '';
            open local( *STDERR ), '>', \$stderr;

            $Logger->log( $_, $message );
            is( $stderr, "[MyApp::Logger::A] [$_] $message\n" );

            close STDERR;

        }

        {

            my $stderr = '';
            open local( *STDERR ), '>', \$stderr;

            $Logger->$_( $message );
            is( $stderr, "[MyApp::Logger::A] [$_] $message\n" );

            close STDERR;

        }

        $Logger->disable( $_ );
        ok( ! $Logger->is_enabled( $_ ) );

        {

            my $stderr = '';
            open local( *STDERR ), '>', \$stderr;

            $Logger->log( $_, 'XXX' );
            is( $stderr, '' );

            $Logger->$_( 'XXX' );
            is( $stderr, '' );

            close STDERR;

        }

        $Logger->enable( $_ );
        ok( $Logger->is_enabled( $_ ) );

        {

            my $stderr = '';
            open local( *STDERR ), '>', \$stderr;

            $Logger->log( $_, $message );
            is( $stderr, "[MyApp::Logger::A] [$_] $message\n" );

            close STDERR;

        }

        {

            my $stderr = '';
            open local( *STDERR ), '>', \$stderr;

            $Logger->$_( $message );
            is( $stderr, "[MyApp::Logger::A] [$_] $message\n" );

            close STDERR;

        }

    }

    $Logger->disable_all;

    for ( @Log_levels ) {

        ok( ! $Logger->is_enabled( $_ ) );

        {

            my $stderr = '';
            open local( *STDERR ), '>', \$stderr;

            $Logger->log( $_, 'XXX' );
            is( $stderr, '' );

            $Logger->$_( 'XXX' );
            is( $stderr, '' );

            close STDERR;

        }

    }

}

