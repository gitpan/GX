#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );

use Scalar::Util qw( refaddr weaken );


use Test::More tests => 389;


my @HOOK_NAMES = qw(
    Initialize
    ProcessConnection
    ProcessRequest
    ProcessRequestQuery
    ProcessRequestHeaders
    ProcessRequestCookies
    ProcessRequestBody
    ProcessSessions
    ResolveActions
    DispatchActions
    FinalizeSessions
    FinalizeResponse
    FinalizeResponseBody
    FinalizeResponseCookies
    FinalizeResponseHeaders
    FinalizeResponseStatus
    SendResponse
    Cleanup
);

my @CACHE_COMPONENTS      = ();
my @CONTROLLER_COMPONENTS = sort map { "MyApp::Controller::$_" } qw( A );
my @DATABASE_COMPONENTS   = ();
my @LOGGER_COMPONENTS     = sort map { "MyApp::Logger::$_" } qw( A );
my @MODEL_COMPONENTS      = ();
my @VIEW_COMPONENTS       = ();
my @SESSION_COMPONENTS    = ();

my @COMPONENTS = sort(
    ( map { "MyApp::$_" } qw( Context Dispatcher Engine Request Response Router ) ),
    @CONTROLLER_COMPONENTS,
    @LOGGER_COMPONENTS,
    @VIEW_COMPONENTS
);


# Load
{

    require_ok( 'MyApp' );

#     my $MyApp = MyApp->instance;
#     warn $MyApp->dump;

    run_tests();

}

# Reload
{


    for ( 1 .. 3 ) {
        MyApp->reload( 1 );
        run_tests();
    }

}


sub run_tests {

    my $MyApp = MyApp->instance;

    # Application instance
    {

        isa_ok( $MyApp, 'GX::Application' );

    }

    # Paths
    {

        is( $MyApp->path( 'base' ),      File::Spec->catdir( $Bin, 'data', 'myapp' ) );
        is( $MyApp->path( 'cache' ),     File::Spec->catdir( $Bin, 'data', 'myapp', 'cache' ) );
        is( $MyApp->path( 'lib' ),       File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' ) );
        is( $MyApp->path( 'log' ),       File::Spec->catdir( $Bin, 'data', 'myapp', 'log' ) );
        is( $MyApp->path( 'public' ),    File::Spec->catdir( $Bin, 'data', 'myapp', 'public' ) );
        is( $MyApp->path( 'script' ),    File::Spec->catdir( $Bin, 'data', 'myapp', 'script' ) );
        is( $MyApp->path( 'templates' ), File::Spec->catdir( $Bin, 'data', 'myapp', 'templates' ) );
        is( $MyApp->path( 'tmp' ),       File::Spec->catdir( $Bin, 'data', 'myapp', 'tmp' ) );

        ok( -d $MyApp->path( 'base' ) );
        ok( -d $MyApp->path( 'cache' ) );
        ok( -d $MyApp->path( 'lib' ) );
        ok( -d $MyApp->path( 'log' ) );
        ok( -d $MyApp->path( 'public' ) );
        ok( -d $MyApp->path( 'script' ) );
        ok( -d $MyApp->path( 'templates' ) );
        ok( -d $MyApp->path( 'tmp' ) );

    }

    # Hooks
    {

        my @hooks = $MyApp->hooks;

        is_deeply( [ map { $_->name } @hooks ], \@HOOK_NAMES );

        for my $hook_name ( @HOOK_NAMES ) {
            my $hook = $MyApp->hook( $hook_name );
            isa_ok( $hook, 'GX::Callback::Hook' );
            is( $hook->name, $hook_name );
        }

    }

    # Handlers
    {

        my @handlers = $MyApp->handlers;

        is( scalar @handlers, 3 );

        is( refaddr( $handlers[0]->invocant ), refaddr( $MyApp ) );
        is( $handlers[0]->method, 'handler_1' );

        is( refaddr( $handlers[1]->invocant ), refaddr( $MyApp->router ) );
        is( $handlers[1]->method, 'resolve' );

        is( refaddr( $handlers[2]->invocant ), refaddr( $MyApp->dispatcher ) );
        is( $handlers[2]->method, 'dispatch' );

    }

    # Components
    {

        is_deeply( [ sort $MyApp->components ], \@COMPONENTS );

    }

    # Engine
    {

        my $engine = $MyApp->engine;

        is( ref $engine, 'MyApp::Engine' );
        isa_ok( $engine, 'GX::Engine' );
        is( refaddr( $engine->application ), refaddr( $MyApp ) );

    }

    # Dispatcher
    {

        my $dispatcher = $MyApp->dispatcher;

        is( ref $dispatcher, 'MyApp::Dispatcher' );
        isa_ok( $dispatcher, 'GX::Dispatcher' );
        is( refaddr( $dispatcher->application ), refaddr( $MyApp ) );

    }

    # Router
    {

        my $router = $MyApp->router;

        is( ref $router, 'MyApp::Router' );
        isa_ok( $router, 'GX::Router' );
        is( refaddr( $router->application ), refaddr( $MyApp ) );

    }

    # Caches
    {

        is_deeply( [ $MyApp->caches ], [] );

    }

    # Databases
    {

        is_deeply( [ $MyApp->databases ], [] );

    }

    # Controllers
    {

        is_deeply(
            [ sort( map { ref $_ } $MyApp->controllers ) ],
            \@CONTROLLER_COMPONENTS
        );

        for my $component ( @CONTROLLER_COMPONENTS ) {

            ( my $component_name = $component ) =~ s/^MyApp::Controller:://;

            my $controller = $MyApp->controller( $component_name );
            is( ref $controller, $component );
            isa_ok( $controller, 'GX::Controller' );
            is( refaddr( $controller->application ), refaddr( $MyApp ) );

            is( refaddr( $MyApp->controller( $component ) ), refaddr( $controller ) );

        }

    }

    # Loggers
    {

        is_deeply(
            [ sort( map { ref $_ } $MyApp->loggers ) ],
            \@LOGGER_COMPONENTS
        );

        for my $component ( @LOGGER_COMPONENTS ) {

            ( my $component_name = $component ) =~ s/^MyApp::Logger:://;

            my $logger = $MyApp->logger( $component_name );
            is( ref $logger, $component );
            isa_ok( $logger, 'GX::Logger' );
            is( refaddr( $logger->application ), refaddr( $MyApp ) );

            is( refaddr( $MyApp->logger( $component ) ), refaddr( $logger ) );

        }

        is( $MyApp->logger, MyApp::Logger::A->instance );

    }

    # Models
    {

        is_deeply( [ $MyApp->models ], [] );

    }

    # Sessions
    {

        is_deeply( [ $MyApp->sessions ], [] );

    }

    # Views
    {

        is_deeply( [ $MyApp->views ], [] );

    }

    # Actions
    {

        {

            my @actions = $MyApp->actions;

            is( scalar @actions, 3 );

            is_deeply(
                [ sort @actions ],
                [ sort map { $_->actions } @CONTROLLER_COMPONENTS ]
            )

        }
        
        # MyApp::Controller::A
        for ( 1 .. 3 ) {
            my $action = $MyApp->controller( 'A' )->action( "action_$_" );
            is( refaddr( $MyApp->action( 'A', "action_$_" ) ), refaddr( $action ) );
            is( refaddr( $MyApp->action( 'MyApp::Controller::A', "action_$_" ) ), refaddr( $action ) );
        }

    }

    # Mode
    is( $MyApp->mode, 'development', "run mode" );

    # Default encoding
    is( $MyApp->default_encoding, 'utf-8-strict', "default encoding" );

}

