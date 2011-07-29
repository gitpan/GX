# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Context.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Context;

use GX::Callback::Hook::Queue;
use GX::Callback::Queue;
use GX::Exception;
use GX::HTTP::Body::File;

use File::Spec ();
use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

extends 'GX::Component';

has 'action_queue' => (
    isa         => 'Scalar',
    initializer => sub { GX::Callback::Queue->new }
);

has 'dispatch_stack' => (
    isa      => 'Array',
    accessor => { type => 'get_reference' }
);

has 'error' => (
    isa => 'Scalar'
);

has 'error_stream' => (
    isa => 'Scalar'
);

has 'handler_queue' => (
    isa         => 'Scalar',
    initializer => sub { GX::Callback::Hook::Queue->new }
);

has 'input_stream' => (
    isa => 'Scalar'
);

has 'output_stream' => (
    isa => 'Scalar'
);

has 'request' => (
    isa => 'Scalar'
);

has 'response' => (
    isa => 'Scalar'
);

has 'sessions' => (
    isa => 'Hash'
);

has 'stash' => (
    isa      => 'Hash',
    accessor => { type => 'get_reference' }
);

has 'time' => (
    isa         => 'Scalar',
    initializer => sub { time() }
);

has 'user' => (
    isa => 'Scalar'
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub abort {

    my $self = shift;

    $self->done;

    $_->[1]->remove_all for @{$self->dispatch_stack};

    return 1;

}

sub action {

    return ( $_[0]->dispatch_stack->[-1] || return undef )->[0];

}

sub bail_out {

    my $self = shift;

    $self->abort;

    if ( my $handler_queue = $self->handler_queue ) {
        $handler_queue->remove_all;
    }

    return 1;

}

sub controller {

    return ( $_[0]->action || return undef )->controller;

}

sub dispatch {

    my $self = shift;
    my %args = ( @_ == 1 ) ? ( 'action' => $_[0] ) : @_;

    my $action = $self->_get_action( $args{'controller'}, $args{'action'} );

    if ( ! $action ) {
        return if defined wantarray;
        complain "Unknown action";
    }

    my $action_queue = $self->action_queue;

    if ( ! $action_queue ) {
        return if defined wantarray;
        complain "Undefined action queue";
    }

    $action_queue->add( $action );

    return 1;

}

sub done {

    my $self = shift;

    if ( my $action_queue = $self->action_queue ) {
        $action_queue->remove_all;
    }

    return 1;

}

sub forward {

    my $self = shift;

    if ( @_ ) {

        my %args = ( @_ == 1 ) ? ( 'action' => $_[0] ) : @_;

        my $action = $self->_get_action( $args{'controller'}, $args{'action'} );

        if ( ! $action ) {
            return if defined wantarray;
            complain "Unknown action";
        }

        my $action_queue = $self->action_queue;

        if ( ! $action_queue ) {
            return if defined wantarray;
            complain "Undefined action queue";
        }

        $action_queue->replace_all( $action );

    }

    $_->[1]->remove_all for @{$self->dispatch_stack};

    return 1;

}

sub handler {

    return ( $_[0]->handler_queue || return undef )->current;

}

sub hook {

    return ( $_[0]->handler_queue || return undef )->current_hook;

}

sub path_for_action {

    my $self = shift;
    my %args = ( @_ == 1 ) ? ( 'action' => $_[0] ) : @_;

    if ( exists $args{'action'} || exists $args{'controller'} ) {

        $args{'action'} = $self->_get_action( delete @args{ qw( controller action ) } );

        if ( ! $args{'action'} ) {
            complain "Unknown action";
        }

    }
    else {

        $args{'action'} = $self->action;

        if ( ! $args{'action'} ) {
            complain "Unspecified action";
        }

    }

    my $path = eval {
        $self->application->router->path_for_action( %args );
    };

    if ( $@ ) {
        complain $@;
    }

    return $path;

}

sub redirect {

    my $self = shift;
    my %args = ( @_ == 1 ) ? ( 'location' => $_[0] ) : @_;

    my $handler_queue = $self->handler_queue;

    if ( ! $handler_queue ) {
        return if defined wantarray;
        complain "Undefined handler queue";
    }

    if ( ! $handler_queue->skip_to( 'FinalizeResponse' ) ) {
        return if defined wantarray;
        complain "Cannot skip to FinalizeResponse hook";
    }

    $self->abort;

    my $response = $self->response;
    $response->clear;
    $response->status( $args{'status'} // 302 );
    $response->location( $args{'location'} );

    return 1;

}

sub render {

    my $self = shift;
    my %args = ( @_ == 1 ) ? ( 'view' => @_ ) : @_;

    my $error; 

    if ( exists $args{'view'} ) {

        local $@;

        eval {

            my $view;

            if ( blessed $args{'view'} && $args{'view'}->isa( 'GX::View' ) ) {
                $view = $args{'view'};
            }
            else {

                $view = $self->application->view( $args{'view'} );

                if ( ! $view ) {
                    throw "Unknown view";
                }

            }

            delete $args{'view'};

            $view->render( %args, context => $self );

        };

        $error = $@;

    }
    else {

        my $action = $self->action;

        if ( ! $action ) {
            complain "render() cannot be called without a \"view\" argument outside the dispatch phase";
        }

        my $format = $self->request->format;

        if ( ! defined $format ) {
            $format = $action->controller->default_format;
        }

        {

            local $@;

            eval {
                $self->_render_action_as( $action, $format );
            };

            $error = $@;

        }

    }

    if ( $error ) {
        return if defined wantarray;
        complain $error;
    }

    return 1;


}

sub render_as {

    my $self   = shift;
    my $format = shift;

    if ( ! defined $format ) {
        complain "Missing argument";
    }

    my $action = $self->action;

    if ( ! $action ) {
        complain "render_as() cannot be called outside the dispatch phase";
    }

    my $error;

    {

        local $@;

        eval {
            $self->_render_action_as( $action, $format );
        };

        $error = $@;

    }

    if ( $error ) {
        return if defined wantarray;
        complain $error;
    }

    return 1;

}

sub renderer {

    my $self = shift;

    my $action = $self->action or return undef;

    return $action->controller->renderer( $action->name );

}

sub send_response {

    my $self = shift;

    my $handler_queue = $self->handler_queue;

    if ( ! $handler_queue ) {
        return if defined wantarray;
        complain "Undefined handler queue";
    }

    if ( ! $handler_queue->skip_to( 'FinalizeResponse' ) ) {
        return if defined wantarray;
        complain "Cannot skip to FinalizeResponse hook";
    }

    $self->abort;

    if ( @_ ) {

        my %args = @_;

        my $response = $self->response;

        $response->clear;

        eval {
            $response->status( $args{'status'} // 200 );
        };

        if ( $@ ) {
            GX::Exception->complain(
                message      => "Cannot set the response status",
                subexception => $@
            );
        }

        if ( defined $args{'headers'} ) {

            eval {

                if ( ref $args{'headers'} eq 'HASH' ) {

                    my $headers = $response->headers;

                    for my $field ( keys %{$args{'headers'}} ) {
                        my $value = $args{'headers'}{$field};
                        $headers->add( $field => ref $value eq 'ARRAY' ? @$value : $value );
                    }

                }
                else {
                    $response->headers( $args{'headers'} );
                }

            };

            if ( $@ ) {
                GX::Exception->complain(
                    message      => "Cannot set the response headers",
                    subexception => $@
                );
            }

        }

        if ( defined $args{'body'} ) {

            eval {
                $response->body( $args{'body'} );
            };

            if ( $@ ) {
                GX::Exception->complain(
                    message      => "Cannot set the response body",
                    subexception => $@
                );
            }

        }
        elsif ( defined $args{'file'} ) {

            my $file = $args{'file'};

            if ( ! File::Spec->file_name_is_absolute( $file ) ) {
                $file = File::Spec->rel2abs( $file, $self->application->path( 'public' ) );
            }

            if ( ! -f $file ) {
                complain "File \"$file\" does not exist";
            }

            $response->body(
                GX::HTTP::Body::File->new(
                    file     => $file,
                    readonly => 1
                )
            );

        }
        elsif ( defined $args{'render'} ) {

            my %render_args;

            if ( ref $args{'render'} eq 'ARRAY' ) {
                %render_args = @{$args{'render'}};
            }
            elsif ( ref $args{'render'} eq 'HASH' ) {
                %render_args = %{$args{'render'}};
            }
            else {
                $render_args{'view'} = $args{'render'};
            }

            eval {
                $self->render( %render_args );
            };

            if ( $@ ) {
                GX::Exception->complain(
                    message      => "Render error",
                    subexception => $@
                );
            }

        }
        elsif ( defined $args{'render_hint'} ) {

            my %render_args;

            if ( ref $args{'render_hint'} eq 'ARRAY' ) {
                %render_args = @{$args{'render_hint'}};
            }
            elsif ( ref $args{'render_hint'} eq 'HASH' ) {
                %render_args = %{$args{'render_hint'}};
            }
            else {
                $render_args{'view'} = $args{'render_hint'};
            }

            if ( my $view = $self->application->view( delete $render_args{'view'} ) ) {

                eval {
                    $self->render( view => $view, %render_args );
                };

                if ( $@ ) {
                    GX::Exception->complain(
                        message      => "Render error",
                        subexception => $@
                    );
                }

            }

        }

    }

    return 1;

}

sub session {

    my $self = shift;

    my $session_class = $self->application->session( @_ ) or return undef;

    $self->{'sessions'} ||= {};

    my $session = $self->{'sessions'}{$session_class} ||= $session_class->new( context => $self );

    return $session;

}

sub sessions {

    my $self = shift;

    $self->{'sessions'} ||= {};

    my @sessions;

    for my $session_class ( $self->application->sessions ) {
        my $session = $self->{'sessions'}{$session_class} ||= $session_class->new( context => $self );
        push @sessions, $session;
    }

    return @sessions;

}

sub uri_for_action {

    my $self = shift;
    my %args = ( @_ == 1 ) ? ( 'action' => $_[0] ) : @_;

    if ( exists $args{'action'} || exists $args{'controller'} ) {

        $args{'action'} = $self->_get_action( delete @args{ qw( controller action ) } );

        if ( ! $args{'action'} ) {
            complain "Unknown action";
        }

    }
    else {

        $args{'action'} = $self->action;

        if ( ! $args{'action'} ) {
            complain "Unspecified action";
        }

    }

    if ( ! exists $args{'scheme'} ) {

        if ( defined( my $scheme = $self->request->scheme ) ) {
            $args{'scheme'} = $scheme;
        }

    }

    if ( ! exists $args{'host'} ) {

        if ( defined( my $host = $self->request->host ) ) {
            $args{'host'} = $host;
        }

    }

    if ( ! exists $args{'port'} ) {

        if ( defined( my $port = $self->request->port ) ) {
            $args{'port'} = $port;
        }

    }

    my $uri = eval {
        $self->application->router->uri_for_action( %args );
    };

    if ( $@ ) {
        complain $@;
    }

    return $uri;

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub dispatch_queue {

    return ( $_[0]->dispatch_stack->[-1] || return undef )->[1];

}

sub DESTROY {

    my $self = shift;

    # Workaround for a memory leak in Scalar::Util::weaken() under 5.10
    %$self = ();

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _get_action {

    my $self       = shift;
    my $controller = shift;
    my $action     = shift;

    if ( defined $action ) {

        if ( blessed $action ) {

            if ( $action->isa( 'GX::Action' ) ) {
                return $action;
            }

        }
        else {

            if ( defined $controller ) {

                if ( blessed $controller ) {

                    if ( ! $controller->isa( 'GX::Controller' ) ) {
                        return undef;
                    }

                }
                else {
                    $controller = $self->application->controller( $controller );
                }

            }
            else {
                $controller = $self->controller;
            }

            if ( $controller ) {
                return $controller->action( $action );
            }

        }

    }

    return undef;

}

sub _render_action_as {

    my $self   = shift;
    my $action = shift;
    my $format = shift;

    my $renderer = $action->controller->renderer( $action->name );

    if ( ! $renderer ) {
        throw "No renderer associated with action";
    }

    if ( ! $renderer->can_render( $format ) ) {

        throw sprintf(
            "Unsupported render format \"%s\"%s",
            $format,
            do {
                my @formats = $renderer->formats;
                @formats ? ' (renderer supports: ' . join( ', ', map { "\"$_\"" } @formats ) . ')' : '';
            }
        );

    }

    $renderer->render( $format, context => $self );

    return;

}

sub _validate_class_name {

    return $_[1] =~ /^(?:[_a-zA-Z]\w*::)+Context$/;

}


1;

__END__

=head1 NAME

GX::Context - Context component

=head1 SYNOPSIS

    package MyApp::Context;
    
    use GX::Context;
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Context> class which inherits directly from
L<GX::Component> and L<GX::Class::Object>.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new context object.

    $context = $class->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<action_queue> ( L<GX::Callback::Queue> object )

An action queue object.

=item * C<dispatch_stack> ( C<ARRAY> reference )

An array reference.

=item * C<error> ( scalar )

An error message or object, preferably a L<GX::Exception> instance.

=item * C<error_stream> ( object )

An error stream object.

=item * C<handler_queue> ( L<GX::Callback::Hook::Queue> object )

A handler queue object.

=item * C<input_stream> ( object )

An input stream object.

=item * C<output_stream> ( object )

An output stream object.

=item * C<request> ( L<GX::Request> object )

A request object.

=item * C<response> ( L<GX::Response> object )

A response object.

=item * C<sessions> ( C<HASH> reference )

A reference to a hash of L<GX::Session> class / instance pairs.

=item * C<stash> ( C<HASH> reference )

A hash reference.

=item * C<time> ( integer )

The UNIX time associated with the request.

=item * C<user> ( object )

An user object.

=back

=item Returns:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<abort>

Aborts the dispatch phase after returning from the current callback.

    $context->abort;

Implementation details: Calling C<abort()> clears all dispatch queues in the
L<dispatch stack|/dispatch_stack> and the L<action queue|/action_queue>.

=head3 C<action>

Returns the action that is currently being dispatched, or C<undef> if called
outside the dispatch phase.

    $action = $context->action;

=over 4

=item Returns:

=over 4

=item * C<$action> ( L<GX::Action> object | C<undef> )

=back

=back

=head3 C<bail_out>

Aborts the processing of the current request after returning from the current
callback.

    $context->bail_out;

Implementation details: Calling C<bail_out()> clears all dispatch queues in
the L<dispatch stack|/dispatch_stack>, the L<action queue|/action_queue> and
the L<handler queue|/handler_queue>.

=head3 C<controller>

Returns the controller instance to which the currently dispatched action
belongs, or C<undef> if called outside the dispatch phase.

    $controller = $context->controller;

=over 4

=item Returns:

=over 4

=item * C<$controller> ( L<GX::Controller> object | C<undef> )

=back

=back

=head3 C<dispatch>

Adds the specified action to the end of the L<action queue|/action_queue>, so
it will be dispatched after any actions already in that queue.

    $context->dispatch( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<action> ( string | L<GX::Action> object ) [ required ]

An action name or action object.

=item * C<controller> ( string | L<GX::Controller> object )

A qualified or unqualified controller name or a controller instance. Optional.
Defaults to the controller to which the currently dispatched action belongs.
Discarded if an action object is passed for C<action>.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Alternative syntax:

    $context->dispatch( $action );

=over 4

=item Arguments:

=over 4

=item * C<$action> ( string | L<GX::Action> object )

An action name or action object. If an action name is passed, the action is
assumed to belong to the same controller as the currently dispatched action.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<done>

Ends the dispatch phase. 

    $context->done;

Implementation details: Calling C<done()> removes any undispatched actions
from the L<action queue|/action_queue>.

=head3 C<error>

Returns / sets the current error.

    $error = $context->error;
    $error = $context->error( $error );

=over 4

=item Arguments:

=over 4

=item * C<$error> ( scalar ) [ optional ]

An error message or object, preferably a L<GX::Exception> instance.

=back

=item Returns:

=over 4

=item * C<$error> ( scalar )

=back

=back

=head3 C<forward>

Forwards processing to the specified action after returning from the current
callback.

    $context->forward( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<action> ( string | L<GX::Action> object ) [ required ]

An action name or action object.

=item * C<controller> ( string | L<GX::Controller> object )

A qualified or unqualified controller name or a controller instance. Optional.
Defaults to the controller to which the currently dispatched action belongs.
Discarded if an action object is passed for C<action>.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Implementation details: Calling C<forward()> clears all dispatch queues in the
L<dispatch stack|/dispatch_stack> and replaces all actions in the
L<action queue|/action_queue> with the specified action.

Alternative syntax:

    $context->forward( $action );

=over 4

=item Arguments:

=over 4

=item * C<$action> ( string | L<GX::Action> object )

An action name or action object. If an action name is passed, the action is
assumed to belong to the same controller as the currently dispatched action.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

When called without arguments, C<forward()> forwards processing to the next
action in the L<action queue|/action_queue>.

    $context->forward;

Implementation details: In this case, calling C<forward()> only clears all
dispatch queues in the L<dispatch stack|/dispatch_stack>.

=head3 C<handler>

Returns the handler that is currently being executed.

    $handler = $context->handler;

=over 4

=item Returns:

=over 4

=item * C<$handler> ( L<GX::Callback> object | C<undef> )

=back

=back

=head3 C<hook>

Returns the hook to which the handler that is currently being executed
belongs.

    $hook = $context->hook;

=over 4

=item Returns:

=over 4

=item * C<$hook> ( L<GX::Callback::Hook> object | C<undef> )

=back

=back

=head3 C<path_for_action>

Constructs the path portion of an URI that would match the reverse route of
the specified action. Returns the constructed path or, if no reversible route
is associated with the respective action, C<undef>.

    $path = $context->path_for_action( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<action> ( string | L<GX::Action> object )

An action name or action object. Optional. Defaults to the currently
dispatched action.

=item * C<controller> ( string | L<GX::Controller> object )

A qualified or unqualified controller name or a controller instance. Optional.
Defaults to the controller to which the currently dispatched action belongs.
Discarded if an action object is passed for C<action>.

=item * C<parameters> ( C<HASH> reference )

A reference to a hash with values for the dynamic parts of the path.

=back

=item Returns:

=over 4

=item * C<$path> ( string | C<undef> )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

This method is basically a thin, context-aware wrapper around the
L<GX::Router> method of the same name.

Alternative syntax:

    $path = $context->path_for_action( $action );

=over 4

=item Arguments:

=over 4

=item * C<$action> ( string | L<GX::Action> object ) [ optional ]

An action name or action object. Optional. Defaults to the currently
dispatched action. If an action name is passed, the action is assumed to
belong to the same controller as the currently dispatched action.

=back

=item Returns:

=over 4

=item * C<$path> ( string | C<undef> )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<redirect>

Aborts the dispatch phase (see C<< L<abort()|/abort> >>) and redirects the
client to the specified URI.

    $context->redirect( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<status> ( integer )

The HTTP status code of the response. Defaults to "302".

=item * C<uri> ( string ) [ required ]

The URI to redirect the client to.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Implementation details: See C<< L<abort()|/abort> >>.

Alternative syntax:

    $context->redirect( $uri );

=over 4

=item Arguments:

=over 4

=item * C<$uri> ( string )

See above.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<render>

Renders the specified view.

    $context->render( view => $view, ... );

=over 4

=item Arguments:

=over 4

=item * C<view> ( string | L<GX::View> object )

A qualified or unqualified view name or a view instance.

=item * Any other arguments are passed through to the C<render()> method of
the specified view.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Alternative syntax:

    $context->render( $view );

=over 4

=item Arguments:

=over 4

=item * C<$view> ( string | L<GX::View> object )

A qualified or unqualified view name or a view instance.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

If called without arguments, C<render()> triggers the renderer that is
associated with the current action.

    $context->render;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<render_as>

Triggers the specified format handler of the renderer that is associated with
the current action.

    $context->render_as( $format );

=over 4

=item Arguments:

=over 4

=item * C<$format> ( string )

A format identifier.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<renderer>

Returns the renderer that is associated with the current action.

    $renderer = $context->renderer;

=over 4

=item Returns:

=over 4

=item * C<$renderer> ( L<GX::Renderer> object | C<undef> )

=back

=back

=head3 C<request>

Returns / sets the request object.

    $request = $context->request;
    $request = $context->request( $request );

=over 4

=item Arguments:

=over 4

=item * C<$request> ( L<GX::Request> object | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$request> ( L<GX::Request> object | C<undef> )

=back

=back

=head3 C<response>

Returns / sets the response object.

    $response = $context->response;
    $response = $context->response( $response );

=over 4

=item Arguments:

=over 4

=item * C<$response> ( L<GX::Response> object | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$response> ( L<GX::Response> object | C<undef> )

=back

=back

=head3 C<send_response>

Aborts further processing of the request and forces the response to be sent
immediately after returning from the current callback.

    $context->send_response;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

If C<send_response()> is called without arguments, the response will be sent
as is. Otherwise, the current response is discarded and a new response is
constructed based on the given arguments.

    $context->send_response( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<body> ( L<GX::HTTP::Body> object )

A body object containing the response body. This argument cannot be combined
with the C<file>, C<render> or C<render_hint> argument.

=item * C<file> ( string )

The path to a file to send as the response body. This argument cannot be
combined with the C<body>, C<render> or C<render_hint> argument.

=item * C<headers> ( L<GX::HTTP::Response::Headers> object | C<HASH> reference )

A response headers object or a reference to a hash containing header field / 
value pairs.

=item * C<render> ( string | L<GX::View> object | C<ARRAY> reference | C<HASH> reference )

A render directive. See L<render|/render> for details. This argument cannot be
combined with the C<body>, C<file> or C<render_hint> argument.

=item * C<render_hint> ( string | L<GX::View> object | C<ARRAY> reference | C<HASH> reference )

Same as C<render> above, but does not complain if the specified view does not
exist. This argument cannot be combined with the C<body>, C<file> or C<render>
argument.

=item * C<status> ( integer )

The HTTP status code of the response. Defaults to "200".

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Implementation details: Calling C<send_response()> clears all dispatch queues
in the L<dispatch stack|/dispatch_stack>, clears the L<action queue|/action_queue>
and skips all handlers in the L<handler queue|/handler_queue> up to the
C<FinalizeResponse> hook.

=head3 C<session>

Returns the instance of the specified session component or, if called without
arguments, of the default session component.

    $session = $context->session( $session_name );

=over 4

=item Arguments:

=over 4

=item * C<$session_name> ( string ) [ optional ]

A qualified or unqualified session component name.

=back

=item Returns:

=over 4

=item * C<$session> ( L<GX::Session> object | C<undef> )

The instance of the specified / default session component, or undef if the
application has no such component.

=back

=back

=head3 C<sessions>

Returns all session component instances.

    @sessions = $context->sessions;

=over 4

=item Returns:

=over 4

=item * C<@sessions> ( L<GX::Session> objects )

=back

=back

=head3 C<stash>

Returns a reference to the stash.

    $stash = $context->stash;

=over 4

=item Returns:

=over 4

=item * C<$stash> ( C<HASH> reference )

=back

=back

=head3 C<time>

Returns the UNIX time associated with the request.

    $time = $context->time;

=over 4

=item Returns:

=over 4

=item * C<$time> ( integer )

=back

=back

=head3 C<uri_for_action>

Constructs an URI that would match the reverse route of the specified action.
Returns the constructed URI or, if no reversible route is associated with the
respective action, C<undef>.

    $uri = $context->uri_for_action( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<action> ( string | L<GX::Action> object )

An action name or action object. Optional. Defaults to the currently
dispatched action.

=item * C<controller> ( string | L<GX::Controller> object )

A qualified or unqualified controller name or a controller instance. Optional.
Defaults to the controller to which the currently dispatched action belongs.
Discarded if an action object is passed for C<action>.

=back

=item Additional, route-dependent arguments:

=over 4

=item * C<fragment> ( string )

The fragment identifier of the URI.

=item * C<host> ( string )

The hostname to use as the authority component of the URI. Defaults to
C<< $context-E<gt>request-E<gt>host >>.

=item * C<parameters> ( C<HASH> reference )

A reference to a hash with values for the dynamic parts of the URI.

=item * C<path> ( string )

The path portion of the URI.

=item * C<port> ( integer )

The port number to append to the hostname. Defaults to
C<< $context-E<gt>request-E<gt>port >>.

=item * C<query> ( string )

The query component of the URI.

=item * C<scheme> ( string )

The scheme part of the URI. Defaults to C<< $context-E<gt>request-E<gt>scheme >>.

=back

=item Returns:

=over 4

=item * C<$uri> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

This method is basically a thin wrapper around the L<GX::Router> method of the
same name.

Alternative syntax:

    $uri = $context->uri_for_action( $action );

=over 4

=item Arguments:

=over 4

=item * C<$action> ( string | L<GX::Action> object ) [ optional ]

An action name or action object. Optional. Defaults to the currently
dispatched action. If an action name is passed, the action is assumed to
belong to the same controller as the currently dispatched action.

=back

=item Returns:

=over 4

=item * C<$uri> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<user>

Returns / sets the associated user object.

    $user = $context->user;
    $user = $context->user( $user );

=over 4

=item Arguments:

=over 4

=item * C<$user> ( object | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$user> ( object | C<undef> )

=back

=back

=head2 Internal Methods

=head3 C<action_queue>

Returns / sets the action queue object.

    $queue = $context->action_queue;
    $queue = $context->action_queue( $queue );

=over 4

=item Arguments:

=over 4

=item * C<$queue> ( L<GX::Callback::Queue> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$queue> ( L<GX::Callback::Queue> object )

=back

=back

=head3 C<dispatch_queue>

Returns the current dispatch queue object.

    $queue = $context->dispatch_queue;

=over 4

=item Returns:

=over 4

=item * C<$queue> ( L<GX::Callback::Queue> object )

=back

=back

=head3 C<dispatch_stack>

Returns a reference to the dispatch stack.

    $stack = $context->dispatch_stack;

=over 4

=item Returns:

=over 4

=item * C<$stack> ( C<ARRAY> reference )

=back

=back

=head3 C<error_stream>

Returns / sets the error stream object.

    $stream = $context->error_stream;
    $stream = $context->error_stream( $stream );

=over 4

=item Arguments:

=over 4

=item * C<$stream> ( object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$stream> ( object )

=back

=back

=head3 C<handler_queue>

Returns / sets the handler queue object.

    $queue = $context->handler_queue;
    $queue = $context->handler_queue( $queue );

=over 4

=item Arguments:

=over 4

=item * C<$queue> ( L<GX::Callback::Hook::Queue> object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$queue> ( L<GX::Callback::Hook::Queue> object )

=back

=back

=head3 C<input_stream>

Returns / sets the input stream object.

    $stream = $context->input_stream;
    $stream = $context->input_stream( $stream );

=over 4

=item Arguments:

=over 4

=item * C<$stream> ( object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$stream> ( object )

=back

=back

=head3 C<output_stream>

Returns / sets the output stream object.

    $stream = $context->output_stream;
    $stream = $context->output_stream( $stream );

=over 4

=item Arguments:

=over 4

=item * C<$stream> ( object ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$stream> ( object )

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
