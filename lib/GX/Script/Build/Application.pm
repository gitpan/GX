# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Script/Build/Application.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Script::Build::Application;

use GX::Meta::Constants qw( REGEX_CLASS_NAME );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Script::Build';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub build_application_module {

    my $self = shift;

    my $file = $self->construct_path( 'lib', split( /::/, $self->application_class ) ) . '.pm';

    $self->render_template(
        'application',
        {
            'engine' => $self->options->{'engine'} || 'FCGI'
        },
        $file
    );

    return;

}

sub build_default_controller {

    my $self = shift;

    my $file = $self->construct_path(
        'lib',
        split( /::/, $self->application_class ),
        'Controller',
        'Root.pm'
    );

    $self->render_template( 'default_controller', undef, $file );

    return;

}

sub build_default_error_view {

    my $self = shift;

    my $file = $self->construct_path(
        'lib',
        split( /::/, $self->application_class ),
        'View',
        'Error.pm'
    );

    $self->render_template( 'default_error_view', undef, $file );

    return;

}

sub build_default_logger {

    my $self = shift;

    my $file = $self->construct_path(
        'lib',
        split( /::/, $self->application_class ),
        'Logger',
        'Default.pm'
    );

    $self->render_template( 'default_logger', undef, $file );

    return;

}

sub build_default_template_view {

    my $self = shift;

    for my $subclass ( qw( TT HTC ) ) {

        my $base_class = "GX::View::Template::$subclass";

        local $@;

        if ( eval "require $base_class" ) {

            my $application_class =  $self->application_class;

            my $file = $self->construct_path(
                'lib',
                split( /::/, $application_class ),
                'View',
                $subclass . '.pm'
            );

            $self->render_template(
                'default_template_view',
                {
                    'class'      => "${application_class}::View::${subclass}",
                    'base_class' => $base_class
                },
                $file
            );

            last;

        }

    }

    return;

}

sub build_directory_structure {

    my $self = shift;

    my @directories;

    push @directories, $self->application_path;

    push @directories, map {
        $self->construct_path( $_ )
    } qw( cache lib log public script t templates tmp );

    push @directories, $self->construct_path( 'public', 'static' );

    my @lib_dir = ( 'lib', split( /::/, $self->application_class ) );

    push @directories, map {
        $self->construct_path( @lib_dir, $_ )
    } qw( Cache Controller Database Logger Model Session View );

    for ( sort @directories ) {
        $self->create_directory( $_ );
    }

    return;

}

sub build_fcgi_script {

    my $self = shift;

    my $file = $self->construct_path( 'script', 'server', 'fcgi.pl' );

    $self->render_template( 'fcgi_script', undef, $file ) or return;

    $self->chmod_file( $file, 0755 );

    return;

}

sub build_test_script {

    my $self = shift;

    my $file = $self->construct_path( 't', '01_load.t' );

    $self->render_template( 'test_script', undef, $file ) or return;

    $self->chmod_file( $file, 0755 );

    return;

}

sub build_welcome_html_file {

    my ( $self ) = @_;

    my $file = $self->construct_path( 'public', 'welcome.html' );

    $self->render_template( 'welcome_html_file', undef, $file );

    return;

}

sub run {

    my $self = ref $_[0] ? shift : shift->new;

    $self->_process_argv;

    $self->print_message(
        sprintf(
            "Creating '%s' in %s ...",
            $self->application_class,
            $self->application_path
        )
    );

    $self->build_directory_structure;
    $self->build_application_module;
    $self->build_default_controller;
    $self->build_default_logger;
    $self->build_default_error_view;
    $self->build_default_template_view;
    $self->build_fcgi_script;
    $self->build_test_script;
    $self->build_welcome_html_file;

    $self->print_message( "Done." );

    return;

}

sub show_help {

    my $self = shift;

    my $script_name = $self->script_name;

    $self->print_message( <<EOT );
NAME

    $script_name - Bootstrap a GX Application

USAGE

    $script_name <application> [OPTIONS]

OPTIONS

    <application>
        The class name of the application.

    -e <engine>, --engine <engine>
        The engine base class, e.g. "Apache2" or "FCGI". Defaults to "FCGI".

MORE OPTIONS

    -h, --help
        Print this help and exit.

    -v, --version
        Print the version information for this script and exit.

    --copyright
        Print the copyright notice for this script and exit.

EXAMPLE

    $script_name MyApp --engine FCGI
EOT

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _argv_options {

    my $self = shift;

    return (
        $self->SUPER::_argv_options,
        'engine=s'
    );

}

sub _process_argv {

    my $self = shift;

    my @argv = $self->SUPER::_process_argv( @_ );

    my $application_class = shift @argv;

    if ( ! defined $application_class || @argv ) {
        $self->show_help;
        $self->exit( 1 );
    }

    if ( $application_class !~ REGEX_CLASS_NAME ) {
        die "Invalid application class name. Aborting.\n";
    }

    $self->application_class( $application_class );

    my $application_path = File::Spec->rel2abs(
        join( '-', split( /::/, $application_class ) ),
        $self->cwd
    );

    $self->application_path( $application_path );

    if ( defined $self->options->{'engine'} ) {

        if ( $self->options->{'engine'} !~ REGEX_CLASS_NAME ) {
            die "Invalid engine class name. Aborting.\n";
        }

    }

    return;

}


1;

=head1 NAME

GX::Script::Build::Application - Script class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Script::Build::Application> class which extends
the L<GX::Script::Build> class.

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut

__DATA__
@@ application
package [% application_class %];

use GX;


[% application_class %]->setup(
    engine => '[% engine %]',
    mode   => 'development'
);

[% application_class %]->start;


1;
@@ default_controller
package [% application_class %]::Controller::Root;

use GX::Controller;


sub default :Action {

    my ( $self, $context ) = @_;

    $context->send_response(
        headers => { 'Content-Type' => 'text/html; charset=UTF-8' },
        file    => 'welcome.html'
    );

    return;

}


1;
@@ default_error_view
package [% application_class %]::View::Error;

use GX::View::Error;


1;
@@ default_template_view
package [% class %];

use [% base_class %];


1;
@@ default_logger
package [% application_class %]::Logger::Default;

use GX::Logger;


1;
@@ fcgi_script
[% shebang %]

use strict;
use warnings;

use GX::Script::Server::FCGI;


GX::Script::Server::FCGI->run( application => '[% application_class %]' );


__END__
@@ test_script
[% shebang %]

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";


use Test::More tests => 1;


require_ok( '[% application_class %]' );


__END__
@@ welcome_html_file
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head>
        <title>It works!</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <style media="screen" type="text/css">
            html { margin: 0; padding: 0; }
            body { margin: 0; padding: 32px; font-family: Arial, Helvetica, sans-serif; font-size: 16px; }
            h1 { margin: 0 0 16px 0; line-height: 1; font-size: 32px; color: #111; }
            h2 { margin: 0 0 16px 0; line-height: 1; font-size: 20px; font-weight: normal; color: #999; }
        </style>
    </head>
    <body>
        <h1>It works!</h1>
        <h2>Your application is up and running.</h2>
    </body>
</html>
