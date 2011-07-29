# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Script/Server/FCGI.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Script::Server::FCGI;

use FCGI ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Script';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub run {

    my $self = ref $_[0] ? shift : shift->new;

    $self->_process_run_args( @_ );
    $self->_process_argv;
    $self->_set_inc;

    $self->load_application;

    my $application = $self->application_class;
    my $options     = $self->options;

    my %env;
    my $request;

    if ( $options->{'listen'} ) {

        my $old_umask = umask;

        umask 0;

        my $socket = FCGI::OpenSocket( $options->{'listen'}, $options->{'queue-size'} );

        umask $old_umask;

        $socket or die "Cannot open FastCGI socket ($!)\n";

        $request = FCGI::Request(
            \*STDIN,
            \*STDOUT,
            \*STDERR,
            \%env,
            $socket,
            FCGI::FAIL_ACCEPT_ON_INTR()
        );

        $self->print_message( "Starting to listen on " . $options->{'listen'} . " for requests" );

    }
    else {

        $request = FCGI::Request(
            \*STDIN,
            \*STDOUT,
            \*STDERR,
            \%env
        );

    }

    my $daemonize = $options->{'daemonize'} && $options->{'listen'};

    if ( $daemonize ) {

        require POSIX;

        fork && exit;

    }

    my $manager;

    if ( $options->{'processes'} ) {

        $options->{'listen'} or die "No socket specified\n";

        $self->print_message( "Spawning " . $options->{'processes'} . " application processes" );

        require FCGI::ProcManager;

        FCGI::ProcManager->import;

        $manager = FCGI::ProcManager->new(
            {
                'n_processes' => $options->{'processes'},
                'pid_fname'   => $options->{'pidfile'}
            }
        );

    }

    if ( $daemonize ) {

        $self->print_message( "Detaching daemon (pid: $$)" );

        POSIX::setsid() or die "Cannot detach from controlling terminal\n";

        chdir '/';

        open( STDIN,  '/dev/null' );
        open( STDOUT, '> /dev/null' );
        open( STDERR, '> /dev/null' );

    }

    if ( $manager ) {

        $manager->pm_manage;

        while ( $request->Accept >= 0 ) {
            $manager->pm_pre_dispatch;
            $application->handler( \%env );
            $manager->pm_post_dispatch;
        }

    }
    else {

        while ( $request->Accept >= 0 ) {
            $application->handler( \%env );
        }

    }

    $self->exit;

}

sub show_help {

    my $self = shift;

    my $script_name = $self->script_name;

    ( my $socket = $self->application_class ) =~ s/::/_/g;
    $socket = File::Spec->rel2abs( lc( $socket ) . '.socket', File::Spec->tmpdir );

    $self->print_message( <<EOT );
NAME

    $script_name - Start a FastCGI Application Server 

USAGE

    $script_name [OPTIONS]

OPTIONS

    -d, --daemonize
        Daemonize the application server.

    -l <socket>, --listen <socket>
        Listen on <socket> for requests. The given value is passed to FCGI::OpenSocket().

    --pidfile <file>
        Use <file> as the pid file for FCGI::ProcManager.

    -p <n>, --processes <n>
        Spawn <n> application server processes using FCGI::ProcManager.

    --queue-size <n>
        The queue size for FCGI::OpenSocket().

MORE OPTIONS

    -h, --help
        Print this help and exit.

    -v, --version
        Print the version information for this script and exit.

    --copyright
        Print the copyright notice for this script and exit.

EXAMPLES

    $script_name --listen $socket
    $script_name --listen $socket --processes 5
    $script_name --listen $socket --processes 5 --daemonize
EOT

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _argv_options {

    my $self = shift;

    return (
        $self->SUPER::_argv_options,
        'daemonize|d',
        'listen|l=s',
        'pidfile=s',
        'processes|p=i',
        'queue-size|q=i'
    );

}

sub _initialize_options {

    my $self = shift;

    my $options = $self->SUPER::_initialize_options;

    $options->{'queue-size'} = 100;

    return $options;

}

sub _process_run_args {

    my $self = shift;
    my %args = @_;

    if ( defined $args{'application'} ) {
        $self->application_class( $args{'application'} );
    }
    elsif ( ! $self->application_class ) {
        die "No application specified\n";
    }

    return;

}


1;

__END__

=head1 NAME

GX::Script::Server::FCGI - Script class

=head1 SYNOPSIS

    #!/usr/bin/perl
    
    use GX::Script::Server::FCGI;
    
    GX::Script::Server::FCGI->run( application => 'MyApp' );

=head1 DESCRIPTION

This module provides the L<GX::Script::Server::FCGI> class which extends the
L<GX::Script> class.

=head1 SEE ALSO

=over 4

=item * L<GX::Engine::FCGI>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
