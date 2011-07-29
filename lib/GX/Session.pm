# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Session.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Session;

use GX::Exception;

use List::Util ();
use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant {
    STATE_INITIALIZED => 0,
    STATE_ACTIVE      => 1 << 0,
    STATE_NEW         => 1 << 1,
    STATE_RESUMED     => 1 << 2,
    STATE_STORED      => 1 << 3,
    STATE_UNKNOWN     => 1 << 4,
    STATE_EXPIRED     => 1 << 5,
    STATE_INVALID     => 1 << 6
};


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

extends 'GX::Component';

has static 'id_generator' => (
    isa        => 'Object',
    constraint => sub { $_->isa( 'GX::Session::ID::Generator' ) },
    accessors  => {
        'id_generator'      => { type => 'get' },
        '_set_id_generator' => { type => 'set' }
    }
);

has static 'initial_lifetime' => (
    isa        => 'Scalar',
    constraint => sub { defined && /^\d+$/ },
    accessors  => {
        '_get_initial_lifetime' => { type => 'get' },
        '_set_initial_lifetime' => { type => 'set' }
    }
);

has static 'lifetime' => (
    isa        => 'Scalar',
    constraint => sub { defined && /^\d+$/ },
    default    => 86400,
    accessors  => {
        'lifetime'      => { type => 'get' },
        '_set_lifetime' => { type => 'set' }
    }
);

has static 'options' => (
    isa         => 'Hash',
    initializer => '_initialize_options',
    accessors   => {
        'options'      => { type => 'get_list' },
        '_get_options' => { type => 'get_reference' },
        '_get_option'  => { type => 'get_value' },
        '_set_option'  => { type => 'set_value' }
    }
);

has static 'store' => (
    isa        => 'Object',
    constraint => sub { $_->isa( 'GX::Session::Store' ) },
    accessors  => {
        'store'      => { type => 'get' },
        '_set_store' => { type => 'set' }
    }
);

has static 'timeout' => (
    isa        => 'Scalar',
    constraint => sub { defined && /^\d+$/ },
    default    => 3600,
    accessors  => {
        'timeout'      => { type => 'get' },
        '_set_timeout' => { type => 'set' }
    }
);

has static 'tracker' => (
    isa        => 'Object',
    constraint => sub { $_->isa( 'GX::Session::Tracker' ) },
    accessors  => {
        'tracker'      => { type => 'get' },
        '_set_tracker' => { type => 'set' }
    }
);

has 'context' => (
    isa        => 'Object',
    constraint => sub { $_->isa( 'GX::Context' ) },
    required   => 1,
    weaken     => 1,
    sticky     => 1,
    accessors  => {
        'context' => { type => 'get' }
    }
);

has 'data' => (
    isa         => 'Scalar',
    initializer => sub { {} },
    accessors   => {
        '_get_data'   => { type => 'get' },
        '_set_data'   => { type => 'set' },
        '_clear_data' => { type => 'clear' }
    }
);

has 'id' => (
    isa       => 'Scalar',
    accessors => {
        'id'        => { type => 'get' },
        '_set_id'   => { type => 'set' },
        '_clear_id' => { type => 'clear' }
    }
);

has 'info' => (
    isa         => 'Scalar',
    initializer => sub { {} },
    accessors   => {
        '_get_info'   => { type => 'get' },
        '_set_info'   => { type => 'set' },
        '_clear_info' => { type => 'clear' }
    }
);

has 'state' => (
    isa       => 'Scalar',
    default   => STATE_INITIALIZED,
    accessors => {
        '_get_state'   => { type => 'get' },
        '_set_state'   => { type => 'set' },
        '_clear_state' => { type => 'clear' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods - Session state API
# ----------------------------------------------------------------------------------------------------------------------

sub expires_at {

    return $_[0]->_get_info->{'expires_at'};

}

sub is_active {

    return $_[0]->_get_state & STATE_ACTIVE;

}

sub is_expired {

    return $_[0]->_get_state & STATE_EXPIRED;

}

sub is_invalid {

    return $_[0]->_get_state & STATE_INVALID;

}

sub is_new {

    return $_[0]->_get_state & STATE_NEW;

}

sub is_resumed {

    return $_[0]->_get_state & STATE_RESUMED;

}

sub is_stored {

    return $_[0]->_get_state & STATE_STORED;

}

sub is_unknown {

    return $_[0]->_get_state & STATE_UNKNOWN;

}

sub remote_address {

    return $_[0]->_get_info->{'remote_address'};

}

sub started_at {

    return $_[0]->_get_info->{'started_at'};

}

sub updated_at {

    return $_[0]->_get_info->{'updated_at'};

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods - Session data API
# ----------------------------------------------------------------------------------------------------------------------

sub clear {

    my $self = shift;

    $self->_clear_data;

    return;

}

sub data {

    my $self = shift;

    if ( @_ ) {

        if ( @_ == 1 ) {

            if ( ref $_[0] ne 'HASH' ) {
                complain "Invalid argument";
            }

            $self->_set_data( $_[0] );

        }
        elsif ( ! ( @_ % 2 ) ) {
            %{$self->_get_data} = @_;
        }
        else {
            complain "Invalid number of arguments";
        }

    }

    return $self->_get_data;

}

sub delete_data {

    return delete $_[0]->_get_data->{$_[1]};

}

sub get_data {

    return $_[0]->_get_data->{$_[1]};

}

sub set_data {

    $_[0]->_get_data->{$_[1]} = $_[2];

    return;

}

sub variables {

    return keys %{$_[0]->_get_data};

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods - Session control API
# ----------------------------------------------------------------------------------------------------------------------

sub end {

    my $self = shift;

    if ( ! $self->is_active ) {
        return;
    }

    if ( $self->is_stored ) {

        eval {
            $self->store->delete( $self->id );
        };

        if ( $@ ) {
            GX::Exception->complain(
                message      => "Cannot end session " . ref( $self ),
                subexception => $@
            );
        }

    }

    $self->tracker->unset_id( $self->context );

    $self->reset;

    return 1;

}

sub reset {

    my $self = shift;

    $self->_clear_state;
    $self->_clear_id;
    $self->_clear_info;
    $self->_clear_data;

    return 1;

}

sub resume {

    my $self = shift;
    my $id   = shift;

    if ( $self->is_active ) {
        complain "Session " . ref( $self ) . " is already active";
    }

    $self->reset;

    if ( ! defined $id ) {

        $id = $self->tracker->get_id( $self->context );

        if ( ! defined $id ) {
            return;
        }

    }

    if ( ! $self->id_generator->validate_id( $id ) ) {
        $self->_set_state_flag( STATE_INVALID );
        return;
    }

    my ( $info, $data ) = eval {
        $self->store->load( $id );
    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot resume session " . ref( $self ),
            subexception => $@
        );
    }

    if ( ! $info ) {
        $self->_set_state_flag( STATE_UNKNOWN );
        return;
    }

    if ( defined $info->{'remote_address'} && length $info->{'remote_address'} ) {

        my $remote_address = $self->context->request->remote_address;

        if ( ! defined $remote_address || $info->{'remote_address'} ne $remote_address ) {
            $self->_set_state_flag( STATE_INVALID );
            return;
        }

    }

    if ( defined $info->{'expires_at'} ) {

        # Special values:
        #  0 => session never expires
        # -1 => session is expired

        if ( $info->{'expires_at'} != 0 ) {

            if ( ! ( $info->{'expires_at'} > $self->_get_current_time ) ) {
                $self->_set_state_flag( STATE_EXPIRED );
                return;
            }

        }

    }

    $self->_set_state_flag( STATE_ACTIVE | STATE_RESUMED | STATE_STORED );
    $self->_set_id( $id );
    $self->_set_info( $info );
    $self->_set_data( $data // {} );
 
    return 1;

}

sub save {

    my $self = shift;

    if ( ! $self->is_active ) {
        complain "Session " . ref( $self ) . " is not active";
    }

    my $info = { %{$self->_get_info}, 'updated_at' => $self->_get_current_time };

    if ( $self->timeout > 0 ) {

        my $expires_at = $self->_get_current_time + $self->timeout;

        if ( $self->lifetime > 0 ) {
            $expires_at = List::Util::min( $expires_at, $self->started_at + $self->lifetime );
        }

        $info->{'expires_at'} = $expires_at;

    }

    my $success = eval {

        if ( $self->is_stored ) {
            $self->store->update( $self->id, $info, $self->_get_data );
        }
        else {
            $self->store->save( $self->id, $info, $self->_get_data );
        }

    };

    if ( ! $success ) {
        GX::Exception->complain(
            message      => "Cannot save session " . ref( $self ),
            subexception => $@
        );
    }

    $self->_set_state_flag( STATE_STORED );
    $self->_set_info( $info );

    return 1;

}

sub start {

    my $self = shift;

    if ( $self->is_active ) {
        complain "Session " . ref( $self ) . " is already active";
    }

    $self->_clear_state;
    $self->_clear_id;
    $self->_clear_info;

    my $id   = $self->id_generator->generate_id;
    my $info = {};

    $info->{'started_at'} = $self->_get_current_time;

    if ( $self->_get_initial_lifetime > 0 ) {
        $info->{'expires_at'} = $info->{'started_at'} + $self->_get_initial_lifetime;
    }
    else {
        $info->{'expires_at'} = 0;
    }

    if ( $self->_get_option( 'bind_to_remote_address' ) ) {
        $info->{'remote_address'} = $self->context->request->remote_address;
    }

    my $success = eval {
        $self->store->save( $id, $info, $self->_get_data );
    };

    if ( ! $success ) {
        GX::Exception->complain(
            message      => "Cannot start session " . ref( $self ),
            subexception => $@
        );
    }

    $self->tracker->set_id( $self->context, $id );

    $self->_set_state_flag( STATE_ACTIVE | STATE_NEW | STATE_STORED );
    $self->_set_id( $id );
    $self->_set_info( $info );

    return 1;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods 
# ----------------------------------------------------------------------------------------------------------------------

sub _auto_resume_handler {

    my $class   = shift;
    my $context = shift;

    if ( my $session = $context->session( $class ) ) {

        if ( ! $session->is_active ) {

            try {
                $session->resume;
            }
            catch {
                $class->application->handle_error( $context, $_ );
            };

        }

    }

    return;

}

sub _auto_save_handler {

    my $class   = shift;
    my $context = shift;

    if ( my $session = $context->session( $class ) ) {

        if ( $session->is_active ) {

            try {
                $session->save;
            }
            catch {
                $class->application->handle_error( $context, $_ );
            };

        }

    }

    return;

}

sub _auto_start_handler {

    my $class   = shift;
    my $context = shift;

    if ( my $session = $context->session( $class ) ) {

        if ( ! $session->is_active ) {

            try {
                $session->resume or $session->start;
            }
            catch {
                $class->application->handle_error( $context, $_ );
            };

        }

    }

    return;

}

sub _get_current_time {

    return $_[0]->context->time;

}

sub _initialize_config {

    return {
        'id_generator' => undef,
        'store'        => undef,
        'tracker'      => undef
    };

}

sub _initialize_options {

    return {
        'auto_resume'            => 1,
        'auto_save'              => 1,
        'auto_start'             => 0,
        'bind_to_remote_address' => 1
    };

}

sub _set_state_flag {

    my $self = shift;
    my $flag = shift;

    ( my $new_state = $self->_get_state ) |= $flag;

    $self->_set_state( $new_state );

    return;

}

sub _setup {

    my $class = shift;

    $class->SUPER::_setup( @_ );

    $class->_setup_id_generator;
    $class->_setup_tracker;
    $class->_setup_store;

    return;

}

sub _setup_config {

    my $class = shift;
    my $args  = shift;

    my $config = $class->_get_config;

    for ( qw(
        id_generator
        store
        tracker
    ) ) {
        $config->{$_} = delete $args->{$_};
    }

    for ( qw(
        auto_resume
        auto_save
        auto_start
        bind_to_remote_address
    ) ) {
        $class->_set_option( $_ => delete $args->{$_} ? 1 : 0 ) if exists $args->{$_};
    }

    for ( qw(
        lifetime
        timeout
    ) ) {

        next unless exists $args->{$_};

        if ( ! defined $args->{$_} || $args->{$_} !~ /^\d+$/ ) {
            throw "Invalid option (\"$_\" must be a positive integer)";
        }

        my $accessor = "_set_$_";
        $class->$accessor( delete $args->{$_} );

    }

    $class->_set_initial_lifetime(
        List::Util::min( grep { $_ > 0 } $class->lifetime, $class->timeout ) // 0
    );

    $class->SUPER::_setup_config( $args );

    return;

}

sub _setup_handlers {

    my $class = shift;

    $class->SUPER::_setup_handlers;

    if ( $class->_get_option( 'auto_start' ) ) {
        $class->_add_handler( ProcessSessions => '_auto_start_handler' );
    }
    elsif ( $class->_get_option( 'auto_resume' ) ) {
        $class->_add_handler( ProcessSessions => '_auto_resume_handler' );
    }

    if ( $class->_get_option( 'auto_save' ) ) {
        $class->_add_handler( FinalizeSessions => '_auto_save_handler' );
    }

    return;

}

sub _setup_id_generator {

    my $class = shift;

    my $config = delete $class->_get_config->{'id_generator'} // 'GX::Session::ID::Generator::MD5';

    my $id_generator = eval {
        $class->_setup_subcomponent( 'GX::Session::ID::Generator', 'id_generator', $config );
    };

    if ( ! $id_generator ) {
        GX::Exception->throw(
            message      => "Cannot setup session ID generator",
            subexception => $@
        );
    }

    $class->_set_id_generator( $id_generator );

    return;

}

sub _setup_store {

    my $class = shift;

    my $config = delete $class->_get_config->{'store'};

    if ( ! defined $config ) {
        throw "Unspecified session store";
    }

    my $store = eval {
        $class->_setup_subcomponent( 'GX::Session::Store', 'store', $config );
    };

    if ( ! $store ) {
        GX::Exception->throw(
            message      => "Cannot setup session store",
            subexception => $@
        );
    }

    $class->_set_store( $store );

    return;

}

sub _setup_tracker {

    my $class = shift;

    my $config = delete $class->_get_config->{'tracker'} // [
        'GX::Session::Tracker::Cookie' => {
            cookie_attributes => {
                name => uc( join( '_', split( /::/, ( $class =~ /^.+?::Session::(.+)$/ )[0] ), 'SESSION_ID' ) ),
                ( $class->lifetime ? ( max_age => $class->lifetime ) : () )
            }
        }
    ];

    my $tracker = eval {
        $class->_setup_subcomponent( 'GX::Session::Tracker', 'tracker', $config );
    };

    if ( ! $tracker ) {
        GX::Exception->throw(
            message      => "Cannot setup session tracker",
            subexception => $@
        );
    }

    $class->_set_tracker( $tracker );

    return;

}

sub _setup_subcomponent {

    my $class             = shift;
    my $subcomponent_base = shift;
    my $config_key        = shift;
    my $config            = shift;

    my $subcomponent;

    if ( blessed $config ) {

        if ( $config->isa( $subcomponent_base ) ) {
            $subcomponent = $config;
        }
        else {
            throw "Invalid option (\"$config_key\")";
        }

    }
    else {

        my $subcomponent_class;
        my $subcomponent_options;

        if ( ref $config ) {

            if ( ref $config eq 'HASH' && keys %$config == 1 ) {
                $config = [ %$config ];
            }

            if ( ref $config eq 'ARRAY' && ( @$config == 1 || @$config == 2 ) ) {
                $subcomponent_class   = $config->[0];
                $subcomponent_options = $config->[1] // {};
            }
            else {
                throw "Invalid option (\"$config_key\")";
            }

        }
        else {
            $subcomponent_class   = "$config";
            $subcomponent_options = {};
        }

        if ( ! defined $subcomponent_class || $subcomponent_class !~ GX::Meta::Constants::REGEX_CLASS_NAME ) {
            throw "Invalid option (\"$config_key\")";
        }

        if ( ref $subcomponent_options ne 'HASH' ) {
            throw "Invalid option (\"$config_key\")";
        }

        if ( ! GX::Meta::Util::load_module( $subcomponent_class ) ) {
            throw "Cannot load $subcomponent_class";
        }

        if ( ! $subcomponent_class->isa( $subcomponent_base ) ) {
            throw "Subcomponent must inherit from $subcomponent_base";
        }

        $subcomponent = eval { $subcomponent_class->new( %$subcomponent_options ) };

        if ( ! $subcomponent ) {
            GX::Exception->throw(
                message      => "Cannot instantiate $subcomponent_class",
                subexception => $@
            );
        }

    }

    return $subcomponent;

}

sub _validate_class_name {

    return $_[1] =~ /^(?:[_a-zA-Z]\w*::)+?Session(?:::[_a-zA-Z]\w*)+$/;

}


1;

__END__

=head1 NAME

GX::Session - Session component

=head1 SYNOPSIS

    package MyApp::Session::Default;
    
    use GX::Session;
    
    __PACKAGE__->setup(
    
        store => [
            'GX::Session::Store::Database' => {
                database => 'MyApp::Database::Default',
                table    => 'sessions'
            }
        ],
    
        tracker => [
            'GX::Session::Tracker::Cookie' => {
                cookie_attributes => {
                    name   => 'SESSION_ID',
                    domain => 'mysite.com',
                    path   => '/',
                    secure => 1
                }
            }
        ],
    
        id_generator => 'GX::Session::ID::Generator::MD5',
    
        lifetime => 86400,
    
        timeout => 3600
    
    );
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Session> class which inherits directly from
L<GX::Component> and L<GX::Class::Object>.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new session object.

    $session = $session_class->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<context> ( L<GX::Context> object ) [ required ]

=back

=item Returns:

=over 4

=item * C<$session> ( L<GX::Session> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<clear>

Deletes the session data.

    $session->clear;

=head3 C<context>

Returns the associated context object.

    $context = $session->context;

=over 4

=item Returns:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=back

=head3 C<data>

Returns / sets the session data.

    $data = $session->data;
    $data = $session->data( $data );

=over 4

=item Arguments:

=over 4

=item * C<$data> ( C<HASH> reference ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$data> ( C<HASH> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Alternative syntax:

    $data = $session->data( %data );

=over 4

=item Arguments:

=over 4

=item * C<%data> ( named list )

=back

=item Returns:

=over 4

=item * C<$data> ( C<HASH> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<delete_data>

Deletes the specified session data key / value pair.

    $session->delete_data( $key );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=back

=back

=head3 C<end>

Ends the session.

    $session->end;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<expires_at>

Returns the expiration (Unix) time of the session.

    $time = $session->expires_at;

=over 4

=item Returns:

=over 4

=item * C<$time> ( integer | C<undef> )

=back

=back

=head3 C<get_data>

Returns the session data for the given key.

    $value = $session->get_data( $key );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=back

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<id>

Returns the session identifier.

    $id = $session->id;

=over 4

=item Returns:

=over 4

=item * C<$id> ( string | C<undef> )

=back

=back

=head3 C<id_generator>

Returns the session ID generator.

    $id_generator = $session->id_generator;

=over 4

=item Returns:

=over 4

=item * C<$id_generator> ( L<GX::Session::ID::Generator> object )

=back

=back

=head3 C<is_active>

Returns true if the session is active, otherwise false.

    $result = $session->is_active;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_expired>

Returns true if the session is expired, otherwise false.

    $result = $session->is_expired;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_invalid>

Returns true if the session is invalid, otherwise false.

    $result = $session->is_invalid;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_new>

Returns true if the session is new, otherwise false.

    $result = $session->is_new;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_resumed>

Returns true if the session is resumed, otherwise false.

    $result = $session->is_resumed;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_stored>

Returns true if the session is stored, otherwise false.

    $result = $session->is_stored;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_unknown>

Returns true if the session is unknown, otherwise false.

    $result = $session->is_unknown;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<lifetime>

Returns the maximum lifetime of the session in seconds.

    $seconds = $session->lifetime;

=over 4

=item Returns:

=over 4

=item * C<$seconds> ( integer )

=back

=back

=head3 C<options>

Returns the session options as a list of key / value pairs.

    %options = $session->options;

=over 4

=item Returns:

=over 4

=item * C<%options> ( named list )

=back

=back

=head3 C<remote_address>

Returns the remote address the session is bound to.

    $remote_address = $session->remote_address;

=over 4

=item Returns:

=over 4

=item * C<$remote_address> ( string | C<undef> )

=back

=back

=head3 C<reset>

Resets the session.

    $session->reset;

=head3 C<resume>

Resumes the (specified) session.

    $result = $session->resume;
    $result = $session->resume( $session_id );

=over 4

=item Arguments:

=over 4

=item * C<$session_id> ( string ) [ optional ]

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

=head3 C<save>

Saves the session.

    $session->save;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<set_data>

Sets the specified session data key / value pair.

    $session->set_data( $key => $value );


=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=item * C<$value> ( scalar )

=back

=back

=head3 C<setup>

Sets up the session component.

    $session_class->setup( %options );

=over 4

=item Options:

=over 4

=item * C<auto_resume> ( bool )

A boolean flag indicating whether or not to automatically try to resume the
session. Defaults to true.

=item * C<auto_save> ( bool )

A boolean flag indicating whether or not to automatically save the session.
Defaults to true.

=item * C<auto_start> ( bool )

A boolean flag indicating whether or not to automatically start the session.
Defaults to false.

=item * C<bind_to_remote_address> ( bool )

A boolean flag indicating whether or not to bind the session to the client's
IP address. Defaults to true.

=item * C<id_generator> ( L<GX::Session::ID::Generator> object or class | C<ARRAY> reference )

The session ID generator to use. Defaults to a
L<GX::Session::ID::Generator::MD5> instance.

=item * C<lifetime> ( integer )

The maximum lifetime of the session in seconds. Defaults to 86400 seconds
(1 day).

=item * C<store> ( L<GX::Session::Store> object or class | C<ARRAY> reference ) [ required ]

The session store to use.

=item * C<timeout> ( integer )

The session timeout in seconds. Defaults to 3600 seconds (1 hour).

=item * C<tracker> ( L<GX::Session::Tracker> object or class | C<ARRAY> reference )

The session tracker to use. Defaults to a L<GX::Session::Tracker::Cookie>
instance.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<start>

Starts the session.

    $session->start;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<started_at>

Returns the (Unix) time the session was started.

    $time = $session->started_at;

=over 4

=item Returns:

=over 4

=item * C<$time> ( integer | C<undef> )

=back

=back

=head3 C<store>

Returns the session store.

    $store = $session->store;

=over 4

=item Returns:

=over 4

=item * C<$store> ( L<GX::Session::Store> object )

=back

=back

=head3 C<timeout>

Returns the session timeout interval in seconds.

    $seconds = $session->timeout;

=over 4

=item Returns:

=over 4

=item * C<$seconds> ( integer )

=back

=back

=head3 C<tracker>

Returns the session tracker.

    $tracker = $session->tracker;

=over 4

=item Returns:

=over 4

=item * C<$tracker> ( L<GX::Session::Tracker> object )

=back

=back

=head3 C<updated_at>

Returns the (Unix) time the session was updated last.

    $time = $session->updated_at;

=over 4

=item Returns:

=over 4

=item * C<$time> ( integer | C<undef> )

=back

=back

=head3 C<variables>

Returns all session data keys.

    @keys = $session->variables;

=over 4

=item Returns:

=over 4

=item * C<@keys> ( strings )

=back

=back

=head1 SEE ALSO

Subcomponents:

=over 4

=item * L<GX::Session::ID::Generator>

=item * L<GX::Session::Store>

=item * L<GX::Session::Tracker>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
