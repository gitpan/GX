#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp;

use GX::Application;


package main;

use Scalar::Util qw( refaddr );


use Test::More tests => 20;


# new()
{

    my $application = MyApp->new;

    isa_ok( $application, 'MyApp' );
    isa_ok( $application, 'GX::Application' );

    is( refaddr( MyApp->new ), refaddr( $application ) );

    is_deeply(
        { $application->paths },
        {
            'tmp' => File::Spec->tmpdir
        }
    );

    is_deeply( [ $application->hooks ], [] );

    is_deeply( [ $application->handlers ], [] );

    is_deeply( [ $application->components ], [] );

    is( $application->dispatcher, undef );
    is( $application->engine,     undef );
    is( $application->router,     undef );

    is_deeply( [ $application->caches ],      [] );
    is_deeply( [ $application->controllers ], [] );
    is_deeply( [ $application->databases ],   [] );
    is_deeply( [ $application->loggers ],     [] );
    is_deeply( [ $application->models ],      [] );
    is_deeply( [ $application->sessions ],    [] );
    is_deeply( [ $application->views ],       [] );

    is_deeply( [ $application->actions ], [] );

    is( $application->mode, 'production' );

    is( $application->default_encoding, 'utf-8-strict' );

}

