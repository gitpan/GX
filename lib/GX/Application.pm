# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Application.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Application;

use GX::Callback::Hook;
use GX::Callback::Hook::Queue;
use GX::Callback::Method;
use GX::Exception;
use GX::Meta::Constants qw( REGEX_CLASS_NAME REGEX_MODULE_NAME );

use Encode ();
use File::Spec ();
use Scalar::Util qw( blessed weaken );


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant {
    STATE_RELOADING   => -1,
    STATE_INITIALIZED => 0,
    STATE_SETUP       => 1,
    STATE_RUNNING     => 2
};

use constant {
    MODE_DEVELOPMENT => 'development',
    MODE_PRODUCTION  => 'production'
};

use constant DEFAULT_HOOKS => qw(
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


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Singleton ( code_attributes => [ 'Handler' ] );

has 'component_regex' => (
    isa         => 'Scalar',
    initialize  => 1,
    initializer => '_initialize_component_regex',
    accessors   => {
        '_get_component_regex' => { type => 'get' }
    }
);

has 'component_registry' => (
    isa         => 'Hash',
    initialize  => 1,
    initializer => '_initialize_component_registry',
    accessors   => {
        '_get_component_registry' => { type => 'get_reference' }
    }
);

has 'components' => (
    isa        => 'Hash::Ordered',
    initialize => 1,
    accessors   => {
        '_get_components' => { type => 'get_reference' },
    }
);

has 'config' => (
    isa         => 'Hash',
    initialize  => 1,
    accessors   => {
        '_get_config' => { type => 'get_reference' }
    }
);

has 'default_components' => (
    isa        => 'Hash',
    initialize => 1,
    accessors  => {
        '_get_default_components' => { type => 'get_reference' }
    }
);

has 'default_encoding' => (
    isa        => 'String',
    default    => 'utf-8-strict',
    initialize => 1,
    accessors  => {
        '_get_default_encoding' => { type => 'get' },
        '_set_default_encoding' => { type => 'set' }
    }
);

has 'handler_queue' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_handler_queue' => { type => 'get' },
        '_set_handler_queue' => { type => 'set' }
    }
);

has 'hook_registry' => (
    isa        => 'Hash::Ordered',
    initialize => 1,
    accessors  => {
        '_get_hook'          => { type => 'get_value' },
        '_set_hook'          => { type => 'set_value' },
        '_get_hook_names'    => { type => 'get_keys' },
        '_get_hooks'         => { type => 'get_values' },
        '_get_hook_registry' => { type => 'get_reference' }
    }
);

has 'mode' => (
    isa        => 'String',
    default    => MODE_PRODUCTION,
    initialize => 1,
    accessors  => {
        '_get_mode' => { type => 'get' },
        '_set_mode' => { type => 'set' }
    }
);

has 'paths' => (
    isa         => 'Hash',
    initialize  => 1,
    initializer => '_initialize_paths',
    accessors   => {
        '_get_path'  => { type => 'get_value' },
        '_set_path'  => { type => 'set_value' },
        '_get_paths' => { type => 'get_reference' }
    }
);

has 'state' => (
    isa        => 'Scalar',
    initialize => 1,
    default    => STATE_INITIALIZED,
    accessors  => {
        '_get_state' => { type => 'get' },
        '_set_state' => { type => 'set' }
    }
);

has 'watcher' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_watcher' => { type => 'get' },
        '_set_watcher' => { type => 'set' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

sub import {

    my $package = shift;

    return if $package ne __PACKAGE__;

    my $class = caller();

    return if $class eq 'main';

    my $meta = GX::Meta::Class->new( $class );
    $meta->inherit_from( $package );

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { ref $_[0] },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub action {

    return ( $_[0]->controller( $_[1] ) || return undef )->action( $_[2] );

}

sub actions {

    return map { $_->actions } $_[0]->controllers;

}

sub components {

    return keys %{$_[0]->instance->_get_components};

}

sub default_encoding {

    return $_[0]->instance->_get_default_encoding;

}

sub handlers {

    return map { $_->all } $_[0]->hooks;

}

sub hook {

    return $_[0]->instance->_get_hook( $_[1] );

}

sub hooks {

    return $_[0]->instance->_get_hooks;

}

sub log {

    my $self = shift->instance;

    if ( my $logger = $self->logger ) {

        $logger->log( @_ );

    }
    else {

        my $level;

        if ( @_ > 1 ) {
            $level = shift // 'notice';
        }
        else {
            $level = 'notice';
        }

        for ( @_ ) {

            defined or next;

            my $message = $_;
            $message =~ s/\n+$//;
            $message =~ s/\n/\\n/g;

            print STDERR "[$self] [$level] $message\n";
    
        }

    }

    return;

}

sub setup {

    my $self = shift->instance;

    if ( @_ % 2 ) {
        complain "Invalid number of arguments";
    }

    if ( $self->_is_setup ) {
        complain "$self has already been setup";
    }

    eval {

        $self->_setup_config( @_ );
        $self->_setup_inc;
        $self->_setup_watcher;
        $self->_setup_hooks;
        $self->_setup_handlers;
        $self->_setup_plugins;
        $self->_setup_components;
        $self->_setup_default_components;

        $self->_deploy_plugins;
        $self->_deploy_components;

    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "$self setup failed",
            subexception => $@,
            verbosity    => 1
        );
    }

    $self->_is_setup( 1 );

    return;

}

sub mode {

    return $_[0]->instance->_get_mode;

}

sub path {

    return $_[0]->instance->_get_path( $_[1] );

}

sub paths {

    return %{$_[0]->instance->_get_paths};

}

sub start {

    my $self = shift->instance;

    if ( $self->_is_running ) {
        complain "$self is already running";
    }

    if ( ! $self->_is_setup ) {
        complain "$self has not been set up properly";
    }

    eval {

        $self->_start_plugins;
        $self->_start_components;

        $self->_compile_handler_queue;

    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot start $self",
            subexception => $@,
            verbosity    => 1
        );
    }

    $self->_is_running( 1 );

    return;

}

sub watcher {

    return $_[0]->instance->_get_watcher;

}

{

    for ( qw( cache controller database logger model session view ) ) {

        my $accessor_name = $_ . 's';

        my $accessor_code = eval join( "\n",
            'sub {',
            '    return values %{$_[0]->instance->_get_component_registry->{' . $_ . '}};',
            '}'
        );

        __PACKAGE__->meta->add_method( $accessor_name, $accessor_code );

    }

    for ( qw( controller model view ) ) {

        my $accessor_name = $_;

        my $accessor_code = eval join( "\n",
            'sub {',
            '    my $self = shift->instance;',
            '    return undef unless defined $_[0];',
            '    my $components = $self->_get_component_registry->{' . $_ . '};',
            '    return $components->{$_[0]} // $components->{ ref( $self ) . \'::' . ucfirst( $_ ) . '::\' . $_[0] };',
            '}'
        );

        __PACKAGE__->meta->add_method( $accessor_name, $accessor_code );

    }

    for ( qw( cache database logger session ) ) {

        my $accessor_name = $_;

        my $accessor_code = eval join( "\n",
            'sub {',
            '    my $self = shift->instance;',
            '    return $self->_get_default_components->{' . $_ . '} unless @_;',
            '    return undef unless defined $_[0];',
            '    my $components = $self->_get_component_registry->{' . $_ . '};',
            '    return $components->{$_[0]} // $components->{ ref( $self ) . \'::' . ucfirst( $_ ) . '::\' . $_[0] };',
            '}'
        );

        __PACKAGE__->meta->add_method( $accessor_name, $accessor_code );

    }

    for my $component_type ( qw( dispatcher engine router ) ) {

        my $accessor_name = $component_type;

        my $accessor_code = eval join( "\n",
            'sub {',
            '    return $_[0]->instance->_get_component_registry->{\'' . $component_type . '\'};',
            '}'
        );

        __PACKAGE__->meta->add_method( $accessor_name, $accessor_code );

    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub add_hook {

    my $self = shift;
    my $hook = shift;

    if ( ! blessed $hook || ! $hook->isa( 'GX::Callback::Hook' ) ) {
        complain "Missing or invalid argument";
    }

    my $hook_name = $hook->name;

    if ( ! defined $hook_name ) {
        complain "Undefined hook name";
    }

    my $hook_registry = $self->_get_hook_registry;

    if ( $hook_registry->{$hook_name} ) {
        complain "Duplicate hook name \"$hook_name\"";
    }

    $hook_registry->{$hook_name} = $hook;

    return;

}

sub handle_error {

    my $self    = shift;
    my $context = shift;
    my $error   = shift;

    $self->log( error => $error );

    $context->error( $error );

    $context->send_response( status => 500, render_hint => 'Error' ) or $context->bail_out;

    return;

}

sub process {

    my $self    = shift;
    my $context = shift;

    my $handler_queue = $self->_clone_handler_queue || $self->_create_handler_queue;

    $context->handler_queue( $handler_queue );

    while ( my $handler = $handler_queue->next ) {
        $handler->call( $context );
    }

    $context->handler_queue( undef );

    return;

}

sub reload {

    my $self  = shift->instance;
    my $force = shift;

    if ( $force || ( $self->_get_watcher || return )->find_changes ) {

        $self->log( 'Reloading' );

        $self->_is_reloading( 1 );

        my $class = ref $self;

        undef $self;

        $class->_unload;

        eval "require $class" or throw $@;

        return 1;

    }

    return;

}

sub remove_hook {

    my $self = shift;

    if ( ! @_ ) {
        complain "Missing argument";
    }

    my $hook_registry = $self->_get_hook_registry;

    if ( ref $_[0] ) {

        if ( ! blessed $_[0] || ! $_[0]->isa( 'GX::Callback::Hook' ) ) {
            complain "Invalid argument";
        }

        my $hook_name = $_[0]->name;

        if ( ! defined $hook_name ) {
            complain "Undefined hook name";
        }

        my $hook = $hook_registry->{$hook_name};

        if ( $hook && $hook == $_[0] ) {
            delete $hook_registry->{$hook_name};
            return 1;
        }

    }
    elsif ( defined $_[0] ) {

        if ( delete $hook_registry->{$_[0]} ) {
            return 1;
        }

    }
    else {
        complain "Invalid argument";
    }

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _bootstrap_component {

    my $self       = shift;
    my $component  = shift;
    my $base_class = shift;

    if ( ! defined $component || ! defined $base_class ) {
        throw "Missing or invalid argument";
    }

    if ( $component !~ REGEX_CLASS_NAME ) {
        throw "Cannot bootstrap component (invalid component class name)";
    }

    if ( $base_class !~ REGEX_CLASS_NAME ) {
        throw "Cannot bootstrap $component (invalid base class name)";
    }

    my $inc_key = GX::Meta::Util::module_inc_key( $component );

    if ( exists $INC{$inc_key} ) {
        throw "Cannot bootstrap $component (module is already loaded)";
    }

    if ( GX::Class::Util::class_exists( $component ) ) {
        throw "Cannot bootstrap $component (namespace is not empty)";
    }

    eval join( "\n",
        "package $component;",
        "use $base_class;",
        "1;"
    );

    if ( $@ ) {
        GX::Exception->throw(
            message      => "Cannot bootstrap $component",
            subexception => $@
        );
    }

    $INC{$inc_key} = \__PACKAGE__;

    return;

}

sub _clone_handler_queue {

    return ( $_[0]->_get_handler_queue || return undef )->clone;

}

sub _compile_handler_queue {

    my $self = shift;

    $self->_set_handler_queue( $self->_create_handler_queue );

    return;

}

sub _create_handler {

    my $self   = shift;
    my $method = shift;

    return GX::Callback::Method->new( invocant => $self, method => $method );

}

sub _create_handler_queue {

    my $self = shift;

    my $queue = GX::Callback::Hook::Queue->new;

    $queue->add( $self->_get_hooks );

    return $queue;

}

sub _create_hook {

    my $self = shift;
    my $name = shift;

    return GX::Callback::Hook->new( name => $name );

}

sub _deploy_components {

    my $self = shift;

    for my $component ( $self->components ) {
        $component->__deploy;
    }

    return;

}

sub _deploy_plugins {

    # Reserved method name

}

sub _initialize_component_regex {

    my $self = shift;

    return qr/
        ^
        ($self)
        ::
        (
            ?|
            (Context|Dispatcher|Engine|Request|Response|Router)
            () # workaround for branch reset bug under perl v5.10.0
            |
            (Cache|Controller|Database|Logger|Model|Session|View)::(.*)
        )
        $
    /x;

}

sub _initialize_component_registry {

    return {

        'dispatcher' => undef,
        'engine'     => undef,
        'router'     => undef,

        'context'    => undef,
        'request'    => undef,
        'response'   => undef,

        'cache'      => {},
        'controller' => {},
        'database'   => {},
        'logger'     => {},
        'model'      => {},
        'session'    => {},
        'view'       => {}

    };

}

sub _initialize_paths {

    my $self = shift;

    my %paths;

    if ( my $file = GX::Meta::Util::module_inc_file( ref $self ) ) {

        my $base_path = do {
            my ( $volume, $dirs, undef ) = File::Spec->splitpath( $file );
            my @dirs = File::Spec->splitdir( $dirs );
            pop @dirs for split( /::/, ref $self );
            pop @dirs;
            File::Spec->catpath( $volume, File::Spec->catdir( @dirs ), '' );
        };

        %paths = (
            'base' => $base_path,
            (
                map {
                    $_ => File::Spec->rel2abs( $_, $base_path )
                } qw(
                    cache
                    lib
                    log
                    public
                    script
                    templates
                    tmp
                )
            )
        );

    }

    if ( ! defined $paths{'tmp'} || ! -d $paths{'tmp'} ) {
        $paths{'tmp'} = File::Spec->tmpdir;
    }

    return \%paths;

}

sub _is_reloading {

    my $self = shift;

    if ( $_[0] ) {
        $self->_set_state( STATE_RELOADING );
        return;
    }

    return $self->_get_state == STATE_RELOADING;

}

sub _is_running {

    my $self = shift;

    if ( $_[0] ) {
        $self->_set_state( STATE_RUNNING );
        return;
    }

    return $self->_get_state >= STATE_RUNNING;

}

sub _is_setup {

    my $self = shift;

    if ( $_[0] ) {
        $self->_set_state( STATE_SETUP );
        return;
    }

    return $self->_get_state >= STATE_SETUP;

}

sub _load_module {

    my $self   = shift;
    my $module = shift;

    my $inc_key = GX::Meta::Util::module_inc_key( $module );

    if ( ! exists $INC{$inc_key} )  {

        my $lib_path = $self->_get_path( 'lib' );

        if ( ! -d $lib_path ) {
            return if defined wantarray;
            throw "Cannot load $module (undefined application \"lib\" path)";
        }

        my $module_file = File::Spec->rel2abs(
            GX::Meta::Util::module_to_file_name( $module ),
            $lib_path
        );

        if ( ! -f $module_file ) {
            return if defined wantarray;
            throw "Cannot load $module (module was not found in \"$lib_path\")";
        }

        my $result = do $module_file;

        delete $INC{$module_file};

        if ( ! $result ) {

            if ( $@ ) {

                $INC{$inc_key} = undef;

                GX::Exception->throw(
                    message      => "Cannot compile $module",
                    subexception => $@
                );

            }
            elsif ( $! ) {

                delete $INC{$inc_key};

                GX::Exception->throw(
                    message      => "Cannot load $module",
                    subexception => $!
                );

            }
            else {

                delete $INC{$inc_key};

                throw "Cannot run $module (module did not return a true value)";

            }

        }

        $INC{$inc_key} = $module_file;

    }
    elsif ( ! $INC{$inc_key} ) {
        throw "Compilation of $module failed";
    }
    
    return 1;

}

sub _register_component {

    my $self      = shift;
    my $component = shift;

    if ( ! defined $component ) {
        throw "Missing argument";
    }

    if ( $component !~ $self->_get_component_regex ) {
        throw "Cannot register component (\"$component\" is not a valid component class name)";
    }

    my $component_type       = lc $2;
    my $component_base_class = "GX::$2";

    if ( ! $component->isa( $component_base_class ) ) {
        throw "Cannot register $component (not a $component_base_class subclass)";
    }

    my $components         = $self->_get_components;
    my $component_registry = $self->_get_component_registry;

    if ( $components->{$component} ) {
        throw "Cannot register $component (already registered)";
    }

    if ( ! exists $component_registry->{$component_type} ) {
        throw "Cannot register $component (unsupported component type)";
    }

    my $component_interface = $component->__register( $self );

    if ( ! $component_interface ) {
        throw "Cannot register $component (undefined component interface)";
    }

    $components->{$component} = $component_interface;

    if ( ref $component_registry->{$component_type} eq 'HASH' ) {
        $component_registry->{$component_type}{$component} = $component_interface;
    }
    else {
        $component_registry->{$component_type} = $component_interface;
    }

    return;

}

sub _setup_components {

    my $self = shift;

    my $class  = ref $self;
    my $config = $self->_get_config;

    for my $type ( qw( dispatcher engine router ) ) {

        my $component = $class . '::' . ucfirst( $type );

        if ( ! $self->_load_module( $component ) ) {

            my $base_class;

            if ( defined $config->{$type} ) {
                $base_class = 'GX::' . ucfirst( $type ) . '::' . $config->{$type};
            }
            elsif ( defined $config->{"${type}_base_class"} ) {
                $base_class = $config->{"${type}_base_class"};
            }
            else {
                $base_class = 'GX::' . ucfirst( $type );
            }

            $self->_bootstrap_component( $component, $base_class );

        }

        $self->_register_component( $component );

    }

    for my $type ( qw( context request response ) ) {

        my $component = $class . '::' . ucfirst( $type );

        if ( ! $self->_load_module( $component ) ) {
            $self->_bootstrap_component( $component, 'GX::' . ucfirst( $type ) );
        }

        $self->_register_component( $component );

    }

    if ( my $lib_path = $self->_get_path( 'lib' ) ) {
 
        for my $type ( qw( logger cache database model session view controller ) ) {

            my $search_path = File::Spec->rel2abs(
                File::Spec->catdir( split( /::/, $class ), ucfirst( $type ) ),
                $lib_path
            );

            next unless -d $search_path;

            for my $component ( GX::Meta::Util::find_modules( $search_path, $lib_path ) ) {
                $self->_load_module( $component );
                $self->_register_component( $component );
            }

        }

    }

    return;

}

sub _setup_config {

    my $self = shift;
    my %args = @_;

    for ( qw(
        default_cache
        default_database
        default_logger
        default_session
        dispatcher
        dispatcher_base_class
        engine
        engine_base_class
        router
        router_base_class
    ) ) {

        next unless exists $args{$_};

        if ( ! defined $args{$_} || $args{$_} !~ REGEX_CLASS_NAME ) {
            throw "Invalid option (\"$_\")";
        }

        $self->{'config'}{$_} = delete $args{$_};

    }

    if ( exists $args{'default_encoding'} ) {

        my $encoding = delete $args{'default_encoding'};

        if ( ! defined $encoding ) {
            throw "Invalid option (\"default_encoding\")";
        }

        my $encode_object = Encode::find_encoding( $encoding );

        if ( ! $encode_object ) {
            throw "Invalid option (\"default_encoding\" must be an encoding supported by Encode)";
        }

        $self->_set_default_encoding( $encode_object->name );

    }

    if ( exists $args{'mode'} ) {

        my $mode = delete $args{'mode'};

        if ( ! defined $mode || ( $mode ne MODE_DEVELOPMENT && $mode ne MODE_PRODUCTION ) ) {
            throw "Invalid option (\"mode\" must be \"" . MODE_DEVELOPMENT . "\" or \"" . MODE_PRODUCTION . "\")";
        }

        $self->_set_mode( $mode );

    }

    if ( %args ) {
        throw sprintf( "Unrecognized setup option (\"%s\")", ( sort keys %args )[0] );
    }

    return;

}

sub _setup_default_components {

    my $self = shift;

    my $config             = $self->_get_config;
    my $default_components = $self->_get_default_components;
    my $component_registry = $self->_get_component_registry;

    for my $component_type ( qw( cache database logger session ) ) {

        my $config_key = "default_$component_type";

        if ( exists $config->{$config_key} ) {

            if ( defined $config->{$config_key} ) {

                my $component_interface = $self->$component_type( $config->{$config_key} );

                if ( ! $component_interface ) {
                    throw "Invalid option (unkown \"$config_key\")";
                }

                $default_components->{$component_type} = $component_interface;

            }
            else {
                $default_components->{$component_type} = undef;
            }

        }
        elsif ( keys %{$component_registry->{$component_type}} == 1 ) {
            $default_components->{$component_type} = ( values %{$component_registry->{$component_type}} )[0];
        }
        else {
            next;
        }

    }

    return;

}

sub _setup_handlers {

    my $self = shift;

    for my $method ( $self->meta->all_methods ) {

        for my $attribute ( $method->code_attributes ) {

            if ( $attribute =~ /^Handler\(\s?(\w+?)\s?\)$/ ) {

                if ( my $hook = $self->_get_hook( $1 ) ) {
                    $hook->add( $self->_create_handler( $method->name ) );
                }

            }

        }

    }

    return;

}

sub _setup_hooks {

    my $self = shift;

    my @hook_names = DEFAULT_HOOKS;

    for my $hook_name ( @hook_names ) {
        $self->add_hook( $self->_create_hook( $hook_name ) );
    }

    return;

}

sub _setup_inc {

    my $self = shift;

    my $path = $self->_get_path( 'lib' );

    if ( defined $path && -d $path && ! grep { $_ eq $path } @INC ) {
        unshift @INC, $path;
    }

    return;

}

sub _setup_plugins {

    # Reserved method name

}

sub _setup_watcher {

    my $self = shift;

    if ( $self->_get_mode eq MODE_DEVELOPMENT ) {

        my $watcher = $self->_get_watcher;

        if ( ! $watcher ) {
            require GX::File::Watcher;
            $watcher = GX::File::Watcher->new;
            $self->_set_watcher( $watcher );
        }

        $watcher->watch(
            grep { defined && -d } map { $self->_get_path( $_ ) } qw( lib templates )
        );

    }

    return;

}

sub _start_components {

    my $self = shift;

    for my $component ( $self->components ) {
        $component->__start;
    }

    return;

}

sub _start_plugins {

    # Reserved method name

}

sub _unload {

    my $self = shift->instance;

    my @components = reverse $self->components;

    for my $component ( @components ) {
        $self->_unregister_component( $component );
    }

    for my $component ( @components ) {
        $component->__unload;
        $component->meta->destroy;
        GX::Meta::Util::unload_module( $component );
    }

    my $class = ref $self;

    $self->destroy;

    weaken $self;

    if ( $self ) {
        warn "$class was not destroyed as expected (possible memory leak)";
    }

    $class->meta->destroy;

    GX::Meta::Util::unload_module( $class );

    return;

}

sub _unregister_component {

    my $self      = shift;
    my $component = shift;

    if ( ! defined $component ) {
        throw "Missing argument";
    }

    if ( $component !~ $self->_get_component_regex ) {
        throw "Cannot unregister component (\"$component\" is not a valid component class name)";
    }

    my $component_type = lc $2;

    my $components = $self->_get_components;

    if ( ! $components->{$component} ) {
        return;
    }

    $component->__unregister;

    delete $components->{$component};

    my $component_registry = $self->_get_component_registry;

    if ( ref $component_registry->{$component_type} eq 'HASH' ) {
        delete $component_registry->{$component_type}{$component};
    }
    else {
        $component_registry->{$component_type} = undef;
    }

    my $default_components = $self->_get_default_components;

    if ( $default_components->{$component_type} && $default_components->{$component_type} eq $component ) {
        delete $default_components->{$component_type};
    }

    return 1;

}


1;

__END__

=head1 NAME

GX::Application - Base class for applications

=head1 SYNOPSIS

    package MyApp;
    
    use GX::Application;
    
    MyApp->setup(
        engine => 'Apache2',
        mode   => 'development'
    );
    
    MyApp->start;
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Application> class which extends the
L<GX::Class::Singleton> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the application instance.

    $application = $application_class->new;

=over 4

=item Returns:

=over 4

=item * C<$application> ( L<GX::Application> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

All public methods can be called both as instance and class methods.

=head3 C<action>

Returns the action object that represents the specified action.

    $action = $application->action( $controller_name, $action_name );

=over 4

=item Arguments:

=over 4

=item * C<$controller_name> ( string )

The qualified or unqualified name of the controller component the action
belongs to.

=item * C<$action_name> ( string )

The name of the action.

=back

=item Returns:

=over 4

=item * C<$action> ( L<GX::Action> object | C<undef> )

=back

=back

=head3 C<actions>

Returns all action objects.

    @actions = $application->actions;

=over 4

=item Returns:

=over 4

=item * C<@actions> ( L<GX::Action> objects )

=back

=back

=head3 C<cache>

Returns the instance of the specified cache component or, if called without
arguments, the default cache component.

    $cache = $application->cache( $cache_name );

=over 4

=item Arguments:

=over 4

=item * C<$cache_name> ( string ) [ optional ]

A qualified or unqualified cache component name.

=back

=item Returns:

=over 4

=item * C<$cache> ( L<GX::Cache> object | C<undef> )

=back

=back

=head3 C<caches>

Returns all cache component instances.

    @caches = $application->caches;

=over 4

=item Returns:

=over 4

=item * C<@caches> ( L<GX::Cache> objects )

=back

=back

=head3 C<components>

Returns a list with the class names of the application's components in the
order they were registered.

    @components = $application->components;

=over 4

=item Returns:

=over 4

=item * C<@components> ( strings )

=back

=back

=head3 C<controller>

Returns the instance of the specified controller component.

    $controller = $application->controller( $controller_name );

=over 4

=item Arguments:

=over 4

=item * C<$controller_name> ( string )

A qualified or unqualified controller component name.

=back

=item Returns:

=over 4

=item * C<$controller> ( L<GX::Controller> object | C<undef> )

=back

=back

=head3 C<controllers>

Returns all controller component instances.

    @controllers = $application->controllers;

=over 4

=item Returns:

=over 4

=item * C<@controllers> ( L<GX::Controller> objects )

=back

=back

=head3 C<database>

Returns the instance of the specified database component or, if called without
arguments, the default database component.

    $database = $application->database( $database_name );

=over 4

=item Arguments:

=over 4

=item * C<$database_name> ( string ) [ optional ]

A qualified or unqualified database component name.

=back

=item Returns:

=over 4

=item * C<$database> ( L<GX::Database> object | C<undef> )

=back

=back

=head3 C<databases>

Returns all database component instances.

    @databases = $application->databases;

=over 4

=item Returns:

=over 4

=item * C<@databases> ( L<GX::Database> objects )

=back

=back

=head3 C<default_encoding>

Returns the application-wide default encoding.

    $encoding = $application->default_encoding;

=over 4

=item Returns:

=over 4

=item * C<$encoding> ( string )

=back

=back

=head3 C<dispatcher>

Returns the dispatcher component instance.

    $dispatcher = $application->dispatcher;

=over 4

=item Returns:

=over 4

=item * C<$dispatcher> ( L<GX::Dispatcher> object | C<undef> )

=back

=back

=head3 C<engine>

Returns the engine component instance.

    $engine = $application->engine;

=over 4

=item Returns:

=over 4

=item * C<$engine> ( L<GX::Engine> object | C<undef> )

=back

=back

=head3 C<handlers>

Returns all handler objects.

    @handlers = $application->handlers;

=over 4

=item Returns:

=over 4

=item * C<@handlers> ( L<GX::Callback> objects )

=back

=back

=head3 C<hook>

Returns the specified hook object.

    $hook = $application->hook( $hook_name );

=over 4

=item Arguments:

=over 4

=item * C<$hook_name> ( string )

=back

=item Returns:

=over 4

=item * C<$hook> ( L<GX::Callback::Hook> object | C<undef> )

=back

=back

=head3 C<hooks>

Returns all hooks in order of execution.

    @hooks = $application->hooks;

=over 4

=item Returns:

=over 4

=item * C<@hooks> ( L<GX::Callback::Hook> objects )

=back

=back

=head3 C<log>

Writes the given message to the default log (or C<STDERR> as fallback).

    $application->log( $message );

=over 4

=item Arguments:

=over 4

=item * C<$message> ( string )

The message to log.

=back

=back

Alternative syntax:

    $application->log( $log_level, @messages );

=over 4

=item Arguments:

=over 4

=item * C<$log_level> ( string | C<undef> )

A string identifying the log level, for example "notice" or "error". Defaults
to "notice". See L<GX::Logger> for more information. 

=item * C<@messages> ( strings )

A list with the messages to log.

=back

=back

=head3 C<logger>

Returns the instance of the specified logger component or, if called without
arguments, the default logger component.

    $logger = $application->logger( $logger_name );

=over 4

=item Arguments:

=over 4

=item * C<$logger_name> ( string ) [ optional ]

A qualified or unqualified logger component name.

=back

=item Returns:

=over 4

=item * C<$logger> ( L<GX::Logger> object | C<undef> )

=back

=back

=head3 C<loggers>

Returns all logger component instances.

    @loggers = $application->loggers;

=over 4

=item Returns:

=over 4

=item * C<@loggers> ( L<GX::Logger> objects )

=back

=back

=head3 C<mode>

Returns the run mode of the application.

    $mode = $application->mode;

=over 4

=item Returns:

=over 4

=item * C<$mode> ( string )

A string identifying the run mode, for example "production" or "development".

=back

=back

=head3 C<model>

Returns the instance of the specified model component.

    $model = $application->model( $model_name );

=over 4

=item Arguments:

=over 4

=item * C<$model_name> ( string )

A qualified or unqualified model component name.

=back

=item Returns:

=over 4

=item * C<$model> ( L<GX::Model> object | C<undef> )

=back

=back

=head3 C<models>

Returns all model component instances.

    @models = $application->models;

=over 4

=item Returns:

=over 4

=item * C<@models> ( L<GX::Model> objects )

=back

=back

=head3 C<path>

Returns the absolute path to the specified application directory.

    $path = $application->path( $directory );

=over 4

=item Arguments:

=over 4

=item * C<$directory> ( string )

A application directory name, for example "base", "lib" or "templates".

=back

=item Returns:

=over 4

=item * C<$path> ( string | C<undef> )

=back

=back

=head3 C<paths>

Returns all paths as a list of directory name / path pairs.

    %paths = $application->paths;

=over 4

=item Returns:

=over 4

=item * C<%paths> ( named list of strings )

=back

=back

=head3 C<router>

Returns the router component instance.

    $router = $application->router;

=over 4

=item Returns:

=over 4

=item * C<$router> ( L<GX::Router> object )

=back

=back

=head3 C<session>

Returns the specified session component or, if called without arguments, the
default session component.

    $session = $application->session( $session_name );

=over 4

=item Arguments:

=over 4

=item * C<$session_name> ( string ) [ optional ]

A qualified or unqualified session component name.

=back

=item Returns:

=over 4

=item * C<$session> ( string | C<undef> )

The class name of the specified / default session component, or C<undef> if
the application has no such component.

=back

=back

=head3 C<sessions>

Returns all session components.

    @sessions = $application->sessions;

=over 4

=item Returns:

=over 4

=item * C<@sessions> ( strings )

A list with the class names of the application's session components.

=back

=back

=head3 C<setup>

Sets up the application.

    $application->setup( %options );

=over 4

=item Options:

=over 4

=item * C<default_cache> ( string )

The qualified or unqualified name of the cache component to use as the default
cache component.

=item * C<default_database> ( string )

The qualified or unqualified name of the database component to use as the
default database component.

=item * C<default_encoding> ( string )

The name of the application-wide default encoding, for example "utf-8" or
"iso-8859-1". See L<Encode> for a list of supported encodings. Defaults to
"utf-8-strict".

=item * C<default_logger> ( string )

The qualified or unqualified name of the logger component to use as the
default logger component.

=item * C<default_session> ( string )

The qualified or unqualified name of the session component to use as the
default session component.

=item * C<engine> ( string )

The L<GX::Engine::*|GX::Engine> class to use as the base class for the
application's engine component, for example "Apache2" or "FCGI". This option
is only relevant if the application's engine component is bootstrapped.

=item * C<mode> ( string )

The application run mode which can be either "production" or "development".
Defaults to "production". Setting this option to "development" enables the
reload mechanism.

=back

=item Advanced options:

=over 4

=item * C<dispatcher> ( string )

For internal use only.

=item * C<dispatcher_base_class> ( string )

For internal use only.

=item * C<engine_base_class> ( string )

For internal use only.

=item * C<router> ( string )

For internal use only.

=item * C<router_base_class> ( string )

For internal use only.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<start>

Starts the application.

    $application->start;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<view>

Returns the instance of the specified view component.

    $view = $application->view( $view_name );

=over 4

=item Arguments:

=over 4

=item * C<$view_name> ( string )

A qualified or unqualified view component name.

=back

=item Returns:

=over 4

=item * C<$view> ( L<GX::View> object | C<undef> )

=back

=back

=head3 C<views>

Returns all view component instances.

    @views = $application->views;

=over 4

=item Returns:

=over 4

=item * C<@views> ( L<GX::View> objects )

=back

=back

=head2 Internal Methods

=head3 C<add_hook>

Internal method.

    $application->add_hook( $hook );

=over 4

=item Arguments:

=over 4

=item * C<$hook> ( L<GX::Callback::Hook> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<handle_error>

Internal method.

    $application->handle_error( $context, $error );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=item * C<$error> ( L<GX::Exception> object | string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<process>

Internal method.

    $application->process( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<reload>

Internal method.

    $result = $application->reload( $force );

=over 4

=item Arguments:

=over 4

=item * C<$force> ( bool ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<remove_hook>

Internal method.

    $result = $application->remove_hook( $hook );
    $result = $application->remove_hook( $hook_name );

=over 4

=item Arguments:

=over 4

=item * C<$hook> ( L<GX::Callback::Hook> object )

=item * C<$hook_name> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<watcher>

Internal method.

    $watcher = $application->watcher;

=over 4

=item Returns:

=over 4

=item * C<$watcher> ( L<GX::File::Watcher> object | C<undef> )

=back

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
