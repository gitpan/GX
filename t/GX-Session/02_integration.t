#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 23;


require_ok( 'MyApp' );


# MyApp::Session::A
{

    is_deeply(
        { MyApp::Session::A->options },
        {
            'auto_resume'            => 1,
            'auto_save'              => 1,
            'auto_start'             => 0,
            'bind_to_remote_address' => 1,
        }
    );

    is( MyApp::Session::A->lifetime, 86400 );
    is( MyApp::Session::A->timeout, 3600 );

    isa_ok( MyApp::Session::A->id_generator, 'GX::Session::ID::Generator::MD5' );
    isa_ok( MyApp::Session::A->store, 'GX::Session::Store::Dummy' );
    isa_ok( MyApp::Session::A->tracker, 'GX::Session::Tracker::Cookie' );

    is_deeply(
        { MyApp::Session::A->tracker->cookie_attributes },
        {
            'name'      => 'A_SESSION_ID',
            'path'      => '/',
            'max_age'   => 86400,
            'http_only' => 1,
            'secure'    => 0
        }
    );

}

# MyApp::Session::B
{

    is_deeply(
        { MyApp::Session::B->options },
        {
            'auto_resume'            => 0,
            'auto_save'              => 0,
            'auto_start'             => 1,
            'bind_to_remote_address' => 0,
        }
    );

    is( MyApp::Session::B->lifetime, 99999 );
    is( MyApp::Session::B->timeout, 999 );

    isa_ok( MyApp::Session::B->id_generator, 'GX::Session::ID::Generator::MD5' );
    isa_ok( MyApp::Session::B->store, 'GX::Session::Store::Dummy' );
    isa_ok( MyApp::Session::B->tracker, 'GX::Session::Tracker::Cookie' );

    is_deeply(
        { MyApp::Session::B->tracker->cookie_attributes },
        {
            'name'      => 'CUSTOM_COOKIE_NAME_B',
            'path'      => '/',
            'http_only' => 1,
            'secure'    => 0
        }
    );

}

# Handlers
{

    {

        my $hook = MyApp->instance->hook( 'ProcessSessions' );

        my @handlers = sort { $a->invocant cmp $b->invocant } $hook->all;

        is( scalar @handlers, 2 );

        is( $handlers[0]->invocant, 'MyApp::Session::A' );
        is( $handlers[0]->method, '_auto_resume_handler' );

        is( $handlers[1]->invocant, 'MyApp::Session::B' );
        is( $handlers[1]->method, '_auto_start_handler' );

    }

    {

        my $hook = MyApp->instance->hook( 'FinalizeSessions' );

        my @handlers = $hook->all;

        is( scalar @handlers, 1 );

        is( $handlers[0]->invocant, 'MyApp::Session::A' );
        is( $handlers[0]->method, '_auto_save_handler' );

    }

}

