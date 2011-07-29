# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Controller.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Controller;

use GX::Action;
use GX::Callback;
use GX::Callback::Hook;
use GX::Callback::Method;
use GX::Callback::Queue;
use GX::Exception;
use GX::Meta::Constants qw( REGEX_CLASS_NAME );
use GX::Renderer;
use GX::Route::Dynamic;
use GX::Route::Static;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class ( code_attributes => [ qw( Action After Before Render ) ] );

extends 'GX::Component::Singleton';

has 'actions' => (
    isa        => 'Hash',
    initialize => 1,
    accessors  => {
        '_get_action'       => { type => 'get_value' },
        '_set_action'       => { type => 'set_value' },
        '_get_actions'      => { type => 'get_reference' },
        '_get_action_names' => { type => 'get_keys' }
    }
);

has 'base_path' => (
    isa         => 'String',
    initialize  => 1,
    initializer => '_initialize_base_path',
    accessors   => {
        '_get_base_path' => { type => 'get' },
        '_set_base_path' => { type => 'set' }
    }
);

has 'default_format' => (
    isa        => 'Scalar',
    initialize => 1,
    default    => 'html',
    accessors  => {
        '_get_default_format' => { type => 'get' },
        '_set_default_format' => { type => 'set' }
    }
);

has 'filter_hooks' => (
    isa        => 'Hash',
    initialize => 1,
    accessors  => {
        '_get_filter_hook'  => { type => 'get_value' },
        '_set_filter_hook'  => { type => 'set_value' },
        '_get_filter_hooks' => { type => 'get_reference' }
    }
);

has 'name' => (
    isa         => 'Scalar',
    initialize  => 1,
    initializer => sub { ( /^.+?::Controller::(.+)$/ )[0] },
    accessors   => {
        '_get_name' => { type => 'get' }
    }
);

has 'post_dispatch_filter_hooks' => (
    isa        => 'Array',
    initialize => 1,
    accessors  => {
        '_get_post_dispatch_filter_hooks' => { type => 'get_reference' }
    }
);

has 'pre_dispatch_filter_hooks' => (
    isa        => 'Array',
    initialize => 1,
    accessors  => {
        '_get_pre_dispatch_filter_hooks' => { type => 'get_reference' }
    }
);

has 'renderers' => (
    isa        => 'Hash',
    initialize => 1,
    accessors  => {
        '_get_renderer'  => { type => 'get_value' },
        '_set_renderer'  => { type => 'set_value' },
        '_get_renderers' => { type => 'get_reference' }
    }      
);

has 'routes' => (
    isa        => 'Array',
    initialize => 1,
    accessors  => {
        '_get_routes' => { type => 'get_reference' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub action {

    return $_[0]->instance->_get_action( $_[1] );

}

sub actions {

    return values %{$_[0]->instance->_get_actions};

}

sub base_path {

    return $_[0]->instance->_get_base_path;

}

sub default_format {

    return $_[0]->instance->_get_default_format;

}

sub filter_hook {

    return $_[0]->instance->_get_filter_hooks->{$_[1]};

}

sub filter_hooks {

    return values %{$_[0]->instance->_get_filter_hooks};

}

sub filters {

    return $_[0]->instance->_get_filters;

}

sub name {

    return $_[0]->instance->_get_name;

}

sub post_dispatch_filter_hooks {

    return @{$_[0]->instance->_get_post_dispatch_filter_hooks};

}

sub post_dispatch_filters {

    return $_[0]->instance->_get_post_dispatch_filters;

}

sub pre_dispatch_filter_hooks {

    return @{$_[0]->instance->_get_pre_dispatch_filter_hooks};

}

sub pre_dispatch_filters {

    return $_[0]->instance->_get_pre_dispatch_filters;

}

sub renderer {

    my $self = shift->instance;

    if ( ! defined $_[0] ) {
        complain "Missing argument";
    }

    if ( blessed $_[0] ) {

        if ( $_[0]->isa( 'GX::Action' ) && $_[0]->controller == $self ) {
            return $self->_get_renderer( $_[0]->name );
        }

    }
    else {
        return $self->_get_renderer( $_[0] );
    }

    return undef;

}

sub routes {

    return @{$_[0]->instance->_get_routes};

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub dispatch {

    my $self    = shift;
    my $context = shift;
    my $action  = shift;

    my $dispatch_stack = $context->dispatch_stack;

    my $dispatch_queue = $self->_create_dispatch_queue( $action );

    push @$dispatch_stack, [ $action, $dispatch_queue ];

    my $error;

    {

        local $@;

        eval {

            while ( my $callback = $dispatch_queue->next ) {
                $callback->call( $context );
            }

        };

        if ( $@ ) {
            $error = $@;
        }

    }

    if ( $error ) {
        $self->handle_error( $context, $error );
    }

    pop @$dispatch_stack;

    return;

}

sub handle_error {

    my $self    = shift;
    my $context = shift;
    my $error   = shift;

    $self->application->handle_error( $context, $error );

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _add_action {

    my $self   = shift;
    my $action = shift;

    my $action_name = $action->name;

    if ( $self->_get_action( $action_name ) ) {
        throw "Cannot add action (duplicate action name: \"$action_name\")";
    }

    $self->_set_action( $action_name => $action );

    return;

}

sub _add_post_dispatch_filter_hook {

    my $self = shift;
    my $hook = shift;

    my $hook_name = $hook->name;

    if ( ! defined $hook_name ) {
        throw "Cannot add post-dispatch filter hook (undefined hook name)";
    }

    if ( $self->_get_filter_hook( $hook_name ) ) {
        throw "Cannot add post-dispatch filter hook (duplicate hook name: \"$hook_name\")";
    }

    $self->_set_filter_hook( $hook_name => $hook );

    push @{$self->_get_post_dispatch_filter_hooks}, $hook;

    return;

}

sub _add_pre_dispatch_filter_hook {

    my $self = shift;
    my $hook = shift;

    my $hook_name = $hook->name;

    if ( ! defined $hook_name ) {
        throw "Cannot add pre-dispatch filter hook (undefined hook name)";
    }

    if ( $self->_get_filter_hook( $hook_name ) ) {
        throw "Cannot add pre-dispatch filter hook (duplicate hook name: \"$hook_name\")";
    }

    $self->_set_filter_hook( $hook_name => $hook );

    push @{$self->_get_pre_dispatch_filter_hooks}, $hook;

    return;

}

sub _add_route {

    my $self  = shift;
    my $route = shift;

    push @{$self->_get_routes}, $route;

    return;

}

sub _auto_render_filter {

    my $self    = shift;
    my $context = shift;

    my $body = $context->response->body;

    if ( ! $body ) {
        return;
    }

    if ( $body->length || $body->readonly ) {
        return;
    }

    my $action = $context->action;

    if ( ! $action ) {
        return;
    }

    my $renderer = $self->_get_renderer( $action->name );

    if ( ! $renderer ) {
        return;
    }

    my $format = $context->request->format // $self->_get_default_format;

    if ( ! defined $format ) {
        return;
    }

    if ( $renderer->can_render( $format ) ) {
        $renderer->render( $format, context => $context );
    }
    else {
        $context->send_response( status => 406 );
    }

    return;

}

sub _create_action {

    my $self   = shift;
    my $method = shift;

    return GX::Action->new( controller => $self, method => $method );

}

sub _create_default_route {

    my $self   = shift;
    my $action = shift;

    my $path = $self->_get_base_path;

    if ( $action->name eq 'default' ) {
        chop $path if length( $path ) > 1 && substr( $path, -1 ) eq '/';
    }
    else {
        $path .= lc $action->name;
    }

    return $self->_create_route(
        class  => 'GX::Route::Static',
        action => $action,
        path   => $path
    );

}

sub _create_dispatch_queue {

    my $self   = shift;
    my $action = shift;

    my $queue = GX::Callback::Queue->new;

    $queue->add( $self->_get_pre_dispatch_filters, $action, $self->_get_post_dispatch_filters );

    return $queue;

}

sub _create_filter {

    my $self   = shift;
    my $method = shift;

    return GX::Callback::Method->new( invocant => $self, method => $method );

}

sub _create_filter_hook {

    my $self = shift;
    my $name = shift;

    return GX::Callback::Hook->new( name => $name );

}

sub _create_format_handler {

    my $self = shift;

    my $handler;

    if ( blessed $_[0] ) {

        if ( $_[0]->isa( 'GX::View' ) ) {
            $handler = GX::Callback::Method->new( invocant => $_[0], method => 'render' );
        }
        elsif ( $_[0]->isa( 'GX::Callback' ) ) {
            $handler = $_[0];
        }
        else {
            throw "Invalid handler definition";
        }

    }
    elsif ( ref $_[0] ) {

        if ( ref $_[0] eq 'ARRAY' || ref $_[0] eq 'HASH' ) {

            my %args;

            if ( ref $_[0] eq 'ARRAY' ) {

                if ( ! ( @{$_[0]} % 2 ) ) {
                    %args = @{$_[0]};
                }
                else {
                    throw "Invalid handler definition";
                }

            }
            else {
                %args = %{$_[0]};
            }

            my $view;

            if ( blessed $args{'view'} && $args{'view'}->isa( 'GX::View' ) ) {
                $view = $args{'view'};
            }
            elsif ( defined $args{'view'} ) {

                $view = $self->application->view( $args{'view'} );

                if ( ! $view ) {
                    throw "Invalid handler definition (unknown view \"$args{'view'}\")";
                }

            }
            else {
                throw "Invalid handler definition (unspecified view)";
            }

            delete $args{'view'};

            $handler = GX::Callback::Method->new(
                invocant  => $view,
                method    => 'render',
                arguments => [ %args ]
            );

        }
        elsif ( ref $_[0] eq 'CODE' ) {
            $handler = GX::Callback->new( $_[0] );
        }
        else {
            throw "Invalid handler definition";
        }

    }
    elsif ( defined $_[0] ) {

        my $view = $self->application->view( $_[0] );

        if ( ! $view ) {
            throw "Invalid handler definition (unknown view \"$_[0]\")";
        }

        $handler = GX::Callback::Method->new( invocant => $view, method => 'render' );

    }
    else {
        throw "Invalid handler definition";
    }

    return $handler;

}

sub _create_renderer {

    my $self = shift;

    my $renderer = GX::Renderer->new;

    if ( defined $_[0] ) {

        my %handler_config = ref $_[0] eq 'HASH' ? %{$_[0]} : ( '*' => $_[0] );

        for my $format ( keys %handler_config ) {

            my $handler = eval { $self->_create_format_handler( $handler_config{$format} ) };

            if ( $@ ) {
                GX::Exception->throw(
                    message      => "Cannot create \"$format\" format handler",
                    subexception => $@
                );
            }

            if ( $handler ) {
                $renderer->handler( $format => $handler );
            }

        }

    }

    return $renderer;

}

sub _create_route {

    my $self = shift;
    my %args = @_;

    my $route_class;

    if ( exists $args{'class'} ) {

        if ( defined $args{'class'} && $args{'class'} =~ REGEX_CLASS_NAME ) {
            $route_class = delete $args{'class'};
        }
        else {
            throw "Invalid route class";
        }

    }
    else {

        if (
            ( defined $args{'path'} && $args{'path'} =~ /[*{}]+/ ) ||
            ( defined $args{'host'} && $args{'host'} =~ /[*{}]+/ ) ||
            exists $args{'methods'} ||
            exists $args{'schemes'}
        ) {
            $route_class = 'GX::Route::Dynamic';
        }
        else {
            $route_class = 'GX::Route::Static';
        }

    }

    if ( defined $args{'path'} && ! ref $args{'path'} ) {

        if ( $args{'path'} =~ s/^\.\/// || $args{'path'} !~ /^\// ) {
            $args{'path'} = $self->_get_base_path . $args{'path'};
        }

    }

    return $route_class->new( %args );

}

sub _deploy {

    my $self = shift;

    $self->_deploy_renderers;

    if ( $self->_get_config->{'create_default_renderers'} ) {
        $self->_deploy_default_renderers;
    }

    return;

}

sub _deploy_default_renderers {

    my $self = shift;

    my @views = grep { $_->isa( 'GX::View::Template' ) } $self->application->views or return;

    my $template_regex = do {

        my $name = $self->_get_name;

        my $pattern =
            '^' .
            ( $name ne 'Root' ? join( '/', split( /::/, $name ) ) . '/' : '' ) .
            '([^.]+)(?:\.([^.]+))?\.[^.]+?' .
            '$';

        qr/$pattern/;

    };

    for my $view ( @views ) {

        for my $template ( $view->templates ) {

            $template =~ $template_regex or next;

            my $action_name = $1;
            my $format      = $2;

            my $action = $self->_get_action( $action_name ) or next;

            if ( ! defined $format ) {
                $format = '*';
            }

            my $renderer = $self->_get_renderer( $action_name );

            if ( ! $renderer ) {
                $renderer = $self->_create_renderer or next;
                $self->_set_renderer( $action_name => $renderer );
            }

            next if $renderer->handler( $format );

            $renderer->handler(
                $format => GX::Callback::Method->new(
                    invocant  => $view,
                    method    => 'render',
                    arguments => [ template => $template ]
                )
            );

        }

    }

    return;

}

sub _deploy_renderers {

    my $self = shift;

    my $config = $self->_get_config;

    if ( defined $config->{'render_all'} ) {

        my $renderer = eval { $self->_create_renderer( $config->{'render_all'} ) };

        if ( ! $renderer ) {
            GX::Exception->throw(
                message      => "Cannot create renderer",
                subexception => $@
            );
        }

        for my $action_name ( $self->_get_action_names ) {

            if ( my $existing_renderer = $self->_get_renderer( $action_name ) ) {
                $existing_renderer->merge( $renderer );
            }
            else {
                $self->_set_renderer( $action_name => $renderer->clone );
            }

        }

    }

    if ( defined $config->{'render'} ) {

        if ( ref $config->{'render'} ne 'HASH' ) {
            throw "Invalid option (\"render\" must be a hash reference)";
        }

        while ( my ( $action_name, $render_directive ) = each %{$config->{'render'}} ) {

            if ( ! $self->_get_action( $action_name ) ) {
                throw "Cannot create renderer ($self has no \"$action_name\" action)";
            }

            my $renderer;

            if ( blessed $render_directive && $render_directive->isa( 'GX::Renderer' ) ) {
                $renderer = $render_directive;
            }
            else {

                $renderer = eval { $self->_create_renderer( $render_directive ) };

                if ( ! $renderer ) {
                    GX::Exception->throw(
                        message      => "Cannot create renderer for action \"$action_name\"",
                        subexception => $@
                    );
                }

            }

            if ( my $existing_renderer = $self->_get_renderer( $action_name ) ) {
                $existing_renderer->merge( $renderer );
            }
            else {
                $self->_set_renderer( $action_name => $renderer );
            }

        }

    }

    return;

}

sub _get_filters {

    return map { $_->all } values %{$_[0]->_get_filter_hooks};

}

sub _get_post_dispatch_filters {

    return map { $_->all } @{$_[0]->_get_post_dispatch_filter_hooks};

}

sub _get_pre_dispatch_filters {

    return map { $_->all } @{$_[0]->_get_pre_dispatch_filter_hooks};

}

sub _initialize_base_path {

    my $self = shift;

    my $name = $self->_get_name;

    return $name eq 'Root' ? '/' : '/' . join( '/', split( '::', lc $name ) ) . '/';

}

sub _initialize_config {

    return {
        'auto_render'                => 1,
        'create_default_renderers'   => 1,
        'create_default_routes'      => 1,
        'inherit_actions'            => 1,
        'inherit_filters'            => 1,
        'post_dispatch_filter_hooks' => [ qw( Render After ) ],
        'pre_dispatch_filter_hooks'  => [ qw( Before ) ],
        'render'                     => undef,
        'render_all'                 => undef,
        'routes'                     => undef
    };

}

sub _setup {

    my $self   = shift;
    my $config = shift;

    $self->SUPER::_setup( $config );

    $self->_setup_filter_hooks;
    $self->_setup_filters;
    $self->_setup_auto_render_filter;
    $self->_setup_actions;
    $self->_setup_routes;

    return;

}

sub _setup_actions {

    my $self = shift;

    my @methods = $self->_get_config->{'inherit_actions'} ? $self->meta->all_methods : $self->meta->methods;

    METHOD:
    for my $method ( @methods ) {

        for my $code_attribute ( $method->code_attributes ) {

            if ( $code_attribute =~ /^Action(?:\(.*\))?$/ ) {
                $self->_add_action( $self->_create_action( $method->name ) );
                next METHOD;
            }

        }

    }

    return;

}

sub _setup_auto_render_filter {

    my $self = shift;

    if ( $self->_get_config->{'auto_render'} ) {

        if ( my $hook = $self->_get_filter_hook( 'Render' ) ) {
            $hook->add( $self->_create_filter( '_auto_render_filter' ) );
        }

    }

    return;

}

sub _setup_config {

    my $self = shift;
    my $args = shift;

    my $config = $self->_get_config;

    for my $option ( qw(
        render_all
    ) ) {
        next unless exists $args->{$option};
        $config->{$option} = delete $args->{$option};
    }

    for my $option ( qw(
        auto_render
        create_default_renderers
        create_default_routes
        inherit_actions
        inherit_filters
    ) ) {
        next unless exists $args->{$option};
        $config->{$option} = delete $args->{$option} ? 1 : 0;
    }

    for my $option ( qw(
        render
    ) ) {
        next unless exists $args->{$option};
        ref $args->{$option} eq 'HASH' or throw "Invalid option (\"$option\" must be a hash reference)";
        $config->{$option} = delete $args->{$option};
    }

    if ( exists $args->{'routes'} ) {

        if ( ref $args->{'routes'} eq 'ARRAY' ) {
            $config->{'routes'} = delete $args->{'routes'};
        }
        elsif ( ref $args->{'routes'} eq 'HASH' ) {
            $config->{'routes'} = [ %{ delete $args->{'routes'} } ];
        }
        else {
            throw "Invalid option (\"routes\" must be an array reference or a hash reference)";
        }

    }

    if ( exists $args->{'base_path'} ) {

        my $path = delete $args->{'base_path'};

        if ( ! defined $path || ! length $path || substr( $path, 0, 1 ) ne '/' ) {
            throw "Invalid option (\"base_path\" must be an absolute path)";
        }

        $path .= '/' if substr( $path, -1 ) ne '/';

        $self->{'base_path'} = $path;

    }

    if ( exists $args->{'default_format'} ) {
        $self->{'default_format'} = delete $args->{'default_format'};
    }

    $self->SUPER::_setup_config( $args );

    return;

}

sub _setup_filter_hooks {

    my $self = shift;

    for my $hook_name ( @{$self->_get_config->{'pre_dispatch_filter_hooks'}} ) {
        $self->_add_pre_dispatch_filter_hook( $self->_create_filter_hook( $hook_name ) );
    }

    for my $hook_name ( @{$self->_get_config->{'post_dispatch_filter_hooks'}} ) {
        $self->_add_post_dispatch_filter_hook( $self->_create_filter_hook( $hook_name ) );
    }

    return;

}

sub _setup_filters {

    my $self = shift;

    my @methods = $self->_get_config->{'inherit_filters'} ? $self->meta->all_methods : $self->meta->methods;

    @methods = sort { $a->name cmp $b->name } @methods;

    for my $method ( @methods ) {

        for my $code_attribute ( $method->code_attributes ) {

            if ( my $hook = $self->_get_filter_hook( $code_attribute ) ) {
                $hook->add( $self->_create_filter( $method->name ) );
            }

        }

    }

    return;

}

sub _setup_routes {

    my $self = shift;

    my $config = $self->_get_config;

    my %routed_actions;

    ACTION:
    for my $action_name ( sort $self->_get_action_names ) {

        my $action = $self->_get_action( $action_name );

        for my $code_attribute ( attributes::get( $action->code ) ) {

            if ( $code_attribute =~ /^Action\((.+)\)$/ ) {

                my @paths;

                eval "\@paths = ( $1 )";

                if ( $@ ) {
                    throw "Invalid :Action attribute for method \"$action_name\"";
                }

                PATH:
                for my $path ( @paths ) {

                    $routed_actions{$action_name}++;

                    my $route = eval {
                        $self->_create_route( action => $action, path => $path );
                    };

                    if ( $@ ) {
                        GX::Exception->throw(
                            message      => "Cannot create route for action \"$action_name\"",
                            subexception => $@
                        );
                    }

                    if ( $route ) {
                        $self->_add_route( $route );
                    }

                }

                next ACTION;

            }

        }

    }

    if ( $config->{'routes'} ) {

        my @routes_config = @{$config->{'routes'}};

        while ( @routes_config ) {

            my $action_name  = shift @routes_config;
            my $route_config = shift @routes_config;

            if ( ! defined $action_name ) {
                throw "Invalid route definition (undefined action name)";
            }

            my $action = $self->_get_action( $action_name );

            if ( ! $action ) {
                throw "Invalid route definition ($self has no \"$action_name\" action)";
            }

            $routed_actions{$action_name}++;

            next unless defined $route_config;

            if ( blessed $route_config && $route_config->isa( 'GX::Route' ) ) {
                $self->_add_route( $route_config );
            }
            else {

                my $route = eval {
                    $self->_create_route(
                        ( ref $route_config eq 'HASH' ? %$route_config : ( path => $route_config ) ),
                        action => $action
                    );
                };

                if ( $@ ) {
                    GX::Exception->throw(
                        message      => "Cannot create route for action \"$action_name\"",
                        subexception => $@
                    );
                }

                if ( $route ) {
                    $self->_add_route( $route );
                }

            }

        }

    }

    if ( $config->{'create_default_routes'} ) {

        for my $action_name ( sort $self->_get_action_names ) {

            next if $routed_actions{$action_name};

            my $route = $self->_create_default_route( $self->_get_action( $action_name ) );

            if ( $route ) {
                $self->_add_route( $route );
            }

        }

    }

    return;

}

sub _validate_class_name {

    return $_[1] =~ /^(?:[_a-zA-Z]\w*::)+?Controller(?:::[_a-zA-Z]\w*)+$/;

}


1;

__END__

=head1 NAME

GX::Controller - Controller component

=head1 SYNOPSIS

    package MyApp::Controller::Root;
    
    use GX::Controller;
    
    sub hello :Action {
        my ( $self, $context ) = @_;
        $context->response->content_type( 'text/plain' );
        $context->response->add( 'Hello World!' );
        return;
    }
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Controller> component class which extends the
L<GX::Component::Singleton> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the controller instance.

    $controller = $controller_class->new;

=over 4

=item Returns:

=over 4

=item * C<$controller> ( L<GX::Controller> object )

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

    $action = $controller->action( $action_name );

=over 4

=item Arguments:

=over 4

=item * C<$action_name> ( string )

=back

=item Returns:

=over 4

=item * C<$action> ( L<GX::Action> object | C<undef> )

=back

=back

=head3 C<actions>

Returns a list with the action objects that represent the controller's
actions.

    @actions = $controller->actions;

=over 4

=item Returns:

=over 4

=item * C<@actions> ( L<GX::Action> objects )

=back

=back

=head3 C<base_path>

Returns the controller's base path.

    $path = $controller->base_path;

=over 4

=item Returns:

=over 4

=item * C<$path> ( string )

A slash terminated string.

=back

=back

=head3 C<default_format>

Returns the default render format.

    $format = $controller->default_format;

=over 4

=item Returns:

=over 4

=item * C<$format> ( string | C<undef> )

=back

=back

=head3 C<filter_hook>

Returns the hook object that represents the specified filter hook.

    $hook = $controller->filter_hook( $hook_name );

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

=head3 C<filter_hooks>

Returns a list with the hook objects that represent the controller's filter
hooks.

    @hooks = $controller->filter_hooks;

=over 4

=item Returns:

=over 4

=item * C<@hooks> ( L<GX::Callback::Hook> objects )

=back

=back

=head3 C<filters>

Returns a list with the callback objects the represent the controller's
filters.

    @filters = $controller->filters;

=over 4

=item Returns:

=over 4

=item * C<@filters> ( L<GX::Callback> objects )

=back

=back

=head3 C<name>

Returns the name of the controller.

    $name = $controller->name;

=over 4

=item Returns:

=over 4

=item * C<$name> ( string )

=back

=back

=head3 C<post_dispatch_filter_hooks>

Returns a list with the hook objects that represent the controller's
post-dispatch filter hooks in order of execution.

    @hooks = $controller->post_dispatch_filter_hooks;

=over 4

=item Returns:

=over 4

=item * C<@hooks> ( L<GX::Callback::Hook> objects )

=back

=back

=head3 C<post_dispatch_filters>

Returns a list with the callback objects the represent the controller's
post-dispatch filters in order of execution.

    @filters = $controller->post_dispatch_filters;

=over 4

=item Returns:

=over 4

=item * C<@filters> ( L<GX::Callback> objects )

=back

=back

=head3 C<pre_dispatch_filter_hooks>

Returns a list with the hook objects that represent the controller's
pre-dispatch filter hooks in order of execution.

    @hooks = $controller->pre_dispatch_filter_hooks;

=over 4

=item Returns:

=over 4

=item * C<@hooks> ( L<GX::Callback::Hook> objects )

=back

=back

=head3 C<pre_dispatch_filters>

Returns a list with the callback objects the represent the controller's
pre-dispatch filters in order of execution.

    @filters = $controller->pre_dispatch_filters;

=over 4

=item Returns:

=over 4

=item * C<@filters> ( L<GX::Callback> objects )

=back

=back

=head3 C<renderer>

Returns the renderer that is associated with the specified action.

    $renderer = $controller->renderer( $action_name );

=over 4

=item Arguments:

=over 4

=item * C<$action_name> ( string )

=back

=item Returns:

=over 4

=item * C<$renderer> ( L<GX::Renderer> object | C<undef> )

=back

=back

=head3 C<routes>

Returns a list with the route objects that represent the routes for the
controller's actions.

    @routes = $controller->routes;

=over 4

=item Returns:

=over 4

=item * C<@routes> ( L<GX::Route> objects )

=back

=back

This method does B<not> return the effective routes for the controller's
actions. See L<GX::Router> for more information.

=head3 C<setup>

Sets up the controller.

    $controller_class->setup( %options );

=over 4

=item Options:

=over 4

=item * C<auto_render> ( bool )

A boolean flag indicating whether or not to enable automatic rendering.
Defaults to true.

=item * C<base_path> ( string )

A custom base path for the controller.

=item * C<create_default_renderers> ( bool )

A boolean flag indicating whether or not to create default renderers. Defaults
to true.

=item * C<create_default_routes> ( bool )

A boolean flag indicating whether or not to create default routes. Defaults to
true.

=item * C<default_format> ( string | C<undef> )

The default render format. Defaults to "html".

=item * C<inherit_actions> ( bool )

A boolean flag indicating whether the controller should inherit actions from
its base classes or not. Defaults to true.

=item * C<inherit_filters> ( bool )

A boolean flag indicating whether the controller should inherit filters from
its base classes or not. Defaults to true.

=item * C<render> ( C<HASH> reference )

A reference to a hash with rendering directives for the controller's actions.

=item * C<render_all> ( scalar )

A global rendering directive that is applied to all the controller's actions.
Also see the C<render> option. 

=item * C<routes> ( C<ARRAY> reference | C<HASH> reference )

A reference to an array or to a hash with route definitions.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Internal Methods

=head3 C<dispatch>

Internal method.

    $controller->dispatch( $context, $action );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=item * C<$action> ( L<GX::Action> object )

=back

=back

=head3 C<handle_error>

Internal method.

    $controller->handle_error( $context, $error );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=item * C<$error> ( L<GX::Exception> object | string )

=back

=back

=head1 EXAMPLES

=head2 Actions

B<Example #1>

Obligatory "Hello World" example:

    sub hello :Action {
        my ( $self, $context ) = @_;
        $context->response->content_type( 'text/plain' );
        $context->response->add( 'Hello World!' );
        return;
    }

=head2 Filters

B<Example #1>

Declaring a pre-dispatch filter using the C<:Before> method attribute:

    sub authenticate_client :Before {
        my ( $self, $context ) = @_;
        if ( $context->request->remote_address ne '127.0.0.1' ) {
            $context->send_response( status => 403 );
        }
        return;
    }

B<Example #2>

Declaring a post-dispatch filter using the C<:After> method attribute:

    sub log_success :After {
        my ( $self, $context ) = @_;
        $self->application->log( 'Success!' );
        return;
    }

B<Example #3>

Declaring a render filter using the C<:Render> method attribute:

    sub add_default_message :Render {
        my ( $self, $context ) = @_;
        $context->response->content_type( 'text/plain' );
        $context->response->add( 'Nothing to see here. Move along.' );
        return;
    }

=head2 Routing

B<Example #1>

Declaring simple path-based routes:

    MyBlog::Controller::Articles->setup(
        routes => [
            'home'   => '/articles',
            'search' => '/articles/search',
            'show'   => '/articles/archive/{id}'
        ],
        # ...
    );

Same as above (assuming the controller's base path is "/articles"):

    MyBlog::Controller::Articles->setup(
        routes => [
            'home'   => './',
            'search' => './search',
            'show'   => './archive/{id}'
        ],
        # ...
    );

B<Example #2>

Declaring complex routes:

    MyBlog::Controller::Articles->setup(
        routes => [
            'home' => {
                path => '/articles'
            },
            'search' => {
                methods => [ 'POST' ],
                path    => '/articles/search'
            },
            'show' => {
                host     => 'myblog.{domain:com|org}',
                path     => '/articles/archive/{id:\d+}.{format:html|xml}',
                defaults => { 'format' => 'html' }
            }
        ],
        # ...
    );

B<Example #3>

Using the C<:Action> method attribute to declare path-based routes:

    sub home :Action( '/articles' ) {
        # ...
    }
    
    sub search :Action( '/articles/search' ) {
        # ...
    }
    
    sub show :Action( '/articles/archive/{id}' ) {
        # ...
    }

=head2 Rendering

B<Example #1>

Simple example of the I<< action =E<gt> format =E<gt> handler >> configuration
syntax:

    MyBlog::Controller::Articles->setup(
        render => {
            'show' => {
                'html' => {
                    view     => 'MyBlog::View::TT',
                    template => 'articles/show.html.tt'
                },
                'txt' => {
                    view     => 'MyBlog::View::TT',
                    template => 'articles/show.txt.tt'
                }
            },
            'search' => {
                'html' => {
                    view     => 'MyBlog::View::TT',
                    template => 'articles/search.html.tt'
                }
            }
        },
        # ...
    );

B<Example #2>

Specifying a default format handler:

    MyBlog::Controller::Articles->setup(
        render => {
            'error' => {
                '*' => {
                    view     => 'MyBlog::View::TT',
                    template => 'error.html.tt'
                }
            }
        },
        # ...
    );

Shorthand notation for the above:

    MyBlog::Controller::Articles->setup(
        render => {
            'error' => [ view => 'MyBlog::View::TT', template => 'error.html.tt' ]
        },
        # ...
    );

A default format handler can be combined with one or more specific format
handlers:

    MyBlog::Controller::Articles->setup(
        render => {
            'error' => {
                'txt' => {
                    view     => 'MyBlog::View::TT',
                    template => 'error.txt.tt'
                },
                'xml' => {
                    view     => 'MyBlog::View::TT',
                    template => 'error.xml.tt'
                },
                '*' => {
                    view     => 'MyBlog::View::TT',
                    template => 'error.html.tt'
                }
            }
        },
        # ...
    );

In that case, the default format handler will handle the rendering of all
non-specified formats.

B<Example #3>

Assignment of arbitrary callbacks as format handlers:

    MyBlog::Controller::Articles->setup(
        render => {
            'show' => {
                'html' => GX::Callback->new( \&code )
            }
        },
        # ...
    );

B<Example #4>

Full low-level control by assigning renderers directly to actions:

    MyBlog::Controller::Articles->setup(
        render => {
            'show' => do {
                my $renderer = GX::Renderer->new;
                $renderer->handler(
                    'html' => GX::Callback::Method->new(
                        invocant  => MyBlog::View::TT->instance,
                        method    => 'render',
                        arguments => [ template => 'articles/show.html.tt' ]
                    )
                );
                $renderer->handler(
                    'txt' => GX::Callback::Method->new(
                        invocant  => MyBlog::View::TT->instance,
                        method    => 'render',
                        arguments => [ template => 'articles/show.txt.tt' ]
                    )
                );
                $renderer;
            },
            'search' => do {
                my $renderer = GX::Renderer->new;
                $renderer->handler(
                    'html' => GX::Callback::Method->new(
                        invocant  => MyBlog::View::TT->instance,
                        method    => 'render',
                        arguments => [ template => 'articles/search.html.tt' ]
                    )
                );
                $renderer;
            }
        },
        # ...
    );

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
