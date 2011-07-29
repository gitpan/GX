# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Logger.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Logger;

use GX::Exception;

use IO::Handle ();


# ----------------------------------------------------------------------------------------------------------------------
# Class data
# ----------------------------------------------------------------------------------------------------------------------

my @LEVELS = qw( trace debug notice warning error fatal );
my %LEVELS = do { my $i; map { $_ => 1 << $i++ } @LEVELS };


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Component::Singleton';

has 'default_level' => (
    isa        => 'String',
    initialize => 1,
    default    => 'notice',
    accessors  => {
        '_get_default_level' => { type => 'get' },
        '_set_default_level' => { type => 'set' }
    }
);

has 'fh' => (
    isa        => 'Scalar',
    initialize => 1,
    accessor   => undef
);

has 'fh_pid' => (
    isa        => 'Scalar',
    initialize => 1,
    accessor   => undef
);

has 'level' => (
    isa        => 'Scalar',
    initialize => 1,
    default    => 0,
    accessors  => {
        '_get_level' => { type => 'get' },
        '_set_level' => { type => 'set' }
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

sub default_level {

    return $_[0]->instance->_get_default_level;

}

sub disable {

    my $self = shift->instance;

    for ( @_ ) {
        defined && exists $LEVELS{$_} or next;
        $self->{'level'} &= ~$LEVELS{$_};
    }

    return;

}

sub disable_all {

    my $self = shift->instance;

    $self->{'level'} = 0;

    return;

}

sub enable {

    my $self = shift->instance;

    for ( @_ ) {
        defined && exists $LEVELS{$_} or next;
        $self->{'level'} |= $LEVELS{$_};
    }

    return;

}

sub enable_all {

    my $self = shift->instance;

    $self->{'level'} |= $_ for values %LEVELS;

    return;

}

sub is_enabled {

    my $self = shift->instance;

    return defined $_[0] && exists $LEVELS{$_[0]} && $self->{'level'} & $LEVELS{$_[0]};

}

sub levels {

    my $self = shift->instance;

    if ( @_ ) {
        $self->disable_all;
        $self->enable( @_ );
    }

    return grep { $self->{'level'} & $LEVELS{$_} } @LEVELS;

}

sub log {

    my $self = shift->instance;

    my $level;

    if ( @_ > 1 ) {
        $level = shift;
        return unless defined $level && exists $LEVELS{$level}; 
    }
    else {
        $level = $self->_get_default_level;
    }

    return unless $self->_get_level & $LEVELS{$level};

    $self->_log( $level, @_ );

    return 1;

}

{

    for ( @LEVELS ) {

        my $name  = $_;
        my $level = $LEVELS{$name};

        __PACKAGE__->meta->add_method(
            $name => sub {
                my $self = shift->instance;
                $self->{'level'} & $level or return;
                $self->_log( $name, @_ );
                return 1;
            }
        );

    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub __finalize {

    my $self = shift;

    $self->enable_all;

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _clear_fh {

    my $self = shift;

    $self->{'fh'}     = undef;
    $self->{'fh_pid'} = undef;

    return;

}

sub _get_fh {

    my $self = shift;

    if ( ! $self->{'fh'} || $self->{'fh_pid'} != $$ ) {
        $self->{'fh'}     = $self->_initialize_fh;
        $self->{'fh_pid'} = $$;
    }

    return $self->{'fh'};

}

sub _initialize_fh {

    return \*STDERR;

}

sub _log {

    my $self  = shift;
    my $level = shift;

    my $prefix = '[' . ref( $self->application || $self ) . '] [' . $level . '] ';

    for ( @_ ) {

        my $message = $_ // next;

        $message =~ s/\n+$//;
        $message =~ s/\n/\\n/g;

        $self->_get_fh->print( $prefix . $message . "\n" );

    }

    return;

}

sub _setup_config {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'levels'} ) {

        my $levels = delete $args->{'levels'};

        if ( ref $levels ne 'ARRAY' ) {
            throw "Invalid option (\"levels\" must be an array reference)";
        }

        $self->levels( @$levels );

    }

    $self->SUPER::_setup_config( $args );

    return;

}

sub _start {

    my $self = shift;

    $self->_clear_fh;

    return;

}

sub _validate_class_name {

    return $_[1] =~ /^(?:[_a-zA-Z]\w*::)+?Logger(?:::[_a-zA-Z]\w*)+$/;

}


1;

__END__

=head1 NAME

GX::Logger - Default logger component

=head1 SYNOPSIS

    package MyApp::Logger;
    
    use GX::Logger;
    
    __PACKAGE__->setup(
        levels => [ qw( warning error fatal ) ]
    );
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Logger> class which extends the
L<GX::Component::Singleton> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the logger component instance.

    $logger = $logger_class->new;

=over 4

=item Returns:

=over 4

=item * C<$logger> ( L<GX::Logger> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

All public methods can be called both as instance and class methods.

=head3 C<debug>

Logs the given "debug"-level message(s).

    $logger->debug( @messages );

=over 4

=item Arguments:

=over 4

=item * C<@messages> ( strings )

=back

=back

=head3 C<default_level>

Returns the default log level.

    $level = $logger->default_level;

=over 4

=item Returns:

=over 4

=item * C<$level> ( string )

=back

=back

=head3 C<disable>

Disables the specified log levels.

    $logger->disable( @levels );

=over 4

=item Arguments:

=over 4

=item * C<@levels> ( strings )

=back

=back

=head3 C<disable_all>

Disables all logging.

    $logger->disable_all;

=head3 C<enable>

Enables the specified log levels.

    $logger->enable( @levels );

=over 4

=item Arguments:

=over 4

=item * C<@levels> ( strings )

=back

=back

=head3 C<enable_all>

Enables all log levels.

    $logger->enable_all;

=head3 C<error>

Logs the given "error"-level message(s).

    $logger->error( @messages );

=over 4

=item Arguments:

=over 4

=item * C<@messages> ( strings )

=back

=back

=head3 C<fatal>

Logs the given "fatal"-level message(s).

    $logger->fatal( @messages );

=over 4

=item Arguments:

=over 4

=item * C<@messages> ( strings )

=back

=back

=head3 C<is_enabled>

Returns true if the specified log level is active, otherwise false.

    $result = logger->is_enabled( $level );

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<levels>

Returns / sets the active log levels.

    @levels = $logger->levels;
    @levels = $logger->levels( @levels );

=over 4

=item Arguments:

=over 4

=item * C<@levels> ( strings ) [ optional ]

=back

=item Returns:

=over 4

=item * C<@levels> ( strings )

=back

=back

=head3 C<log>

Logs the given message.

    $logger->log( $message );

=over 4

=item Arguments:

=over 4

=item * C<$message> ( string )

=back

=back

Alternative syntax:

    $logger->log( $level, @messages );

=over 4

=item Arguments:

=over 4

=item * C<$level> ( string )

=item * C<@messages> ( strings )

=back

=back

=head3 C<notice>

Logs the given "notice"-level message(s).

    $logger->notice( @messages );

=over 4

=item Arguments:

=over 4

=item * C<@messages> ( strings )

=back

=back

=head3 C<setup>

Sets up the logger.

    $class->setup( %options );

=over 4

=item Options:

=over 4

=item * C<default_level> ( string )

The default log level. Defaults to "notice".

=item * C<levels> ( C<ARRAY> reference )

The active log levels.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<trace>

Logs the given "trace"-level message(s).

    $logger->trace( @messages );

=over 4

=item Arguments:

=over 4

=item * C<@messages> ( strings )

=back

=back

=head3 C<warning>

Logs the given "warning"-level message(s).

    $logger->warning( @messages );

=over 4

=item Arguments:

=over 4

=item * C<@messages> ( strings )

=back

=back

=head1 USAGE

=head2 Output

By default, all messages are written to C<STDERR>.

=head2 Log Levels

All log levels, listed in order of increasing importance:

    trace
    debug
    notice
    warning
    error
    fatal

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
