# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Engine/FCGI.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Engine::FCGI;

use GX::Exception;
use GX::HTTP::Body::File;
use GX::HTTP::Body::Scalar;
use GX::HTTP::Constants qw( CRLF );
use GX::HTTP::Headers;

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class ( extends => 'GX::Engine' );

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Handlers
# ----------------------------------------------------------------------------------------------------------------------

sub finalize_response_headers :Handler( FinalizeResponseHeaders ) {

    my $self    = shift;
    my $context = shift;

    my $response = $context->response;

    for my $cookie ( $response->cookies->all ) {
        $response->headers->add( 'Set-Cookie' => $cookie->as_string );
    }

    return;

}

sub process_request_body :Handler( ProcessRequestBody ) {

    my $self    = shift;
    my $context = shift;

    my $request        = $context->request;
    my $content_length = $request->content_length;

    if ( ! $content_length ) {
        return;
    }

    if ( $content_length !~ /^\d+$/ ) {
        $context->send_response( status => 400 );
        return;
    }

    my $config = $self->_get_config;

    if ( $content_length > $config->{'max_request_size'} ) {
        $context->send_response( status => 413 );
        return;
    }

    my $body;

    if ( $content_length > $config->{'max_request_memory_usage'} ) {
        $body = GX::HTTP::Body::File->new;
    }
    else {
        $body = GX::HTTP::Body::Scalar->new;
    }

    my $body_fh       = $body->open( '>' );
    my $input_stream  = $context->input_stream;
    my $buffer_size   = $config->{'buffer_size'};
    my $bytes_read    = 0;
    my $read_callback = $request->read_callback;

    while ( ( my $bytes = $input_stream->read( my $buffer, $buffer_size ) ) > 0 ) {

        $bytes_read += $bytes;

        if ( ! $body_fh->print( $buffer ) ) {
            throw "Cannot write request body";
        }

        if ( $bytes_read > $content_length ) {
            last;
        }

        if ( $read_callback ) {
            $read_callback->( $context, $bytes_read, $content_length );
        }

    }

    $body_fh->close;

    if ( $bytes_read != $content_length ) {
        $context->send_response( status => 400 );
        return;
    }

    $request->body( $body );

    return;

}

sub process_request_headers :Handler( ProcessRequestHeaders ) {

    my $self    = shift;
    my $context = shift;

    my $fcgi    = $context->fcgi;
    my $headers = $context->request->headers;

    # "The server may exclude any headers which it has already processed, such
    # as Authorization, Content-Type, and Content-Length."

    for ( qw( CONTENT_LENGTH CONTENT_TYPE ) ) {
        next if ! exists( $fcgi->{$_} ) || exists( $fcgi->{"HTTP_$_"} );
        my $field_name = $_;
        $field_name =~ tr/_/-/;
        $headers->add( $field_name => $fcgi->{$_} );
    }

    for ( grep { /^HTTP_/ } keys %$fcgi ) {
        my $field_name = substr( $_, 5 );
        $field_name =~ tr/_/-/;
        $headers->add( $field_name => $fcgi->{$_} );
    }

    return;

}

sub send_response :Handler( SendResponse ) {

    my $self    = shift;
    my $context = shift;

    my $output_stream = $context->output_stream;

    my $response = $context->response;
    my $headers  = $response->headers;
    my $body     = $response->body;

    $headers->set( 'Status' => $response->status // 200 );

    if ( my $length = $body->length ) {

        if ( ! defined $headers->content_length ) {

            if ( $length > 0 ) {
                $headers->content_length( $length );
            }

        }

        $output_stream->print( $headers->as_string, CRLF );

        if ( $context->request->method ne 'HEAD' ) {
            $body->print_to( $output_stream );
        }

    }
    else {
        $output_stream->print( $headers->as_string, CRLF );
    }

    $output_stream->flush;

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _create_fcgi_handler {

    my $self        = shift;
    my $application = shift;

    my $context_class  = ref( $application ) . '::Context';
    my $request_class  = ref( $application ) . '::Request';
    my $response_class = ref( $application ) . '::Response';

    my $error_stream_class  = __PACKAGE__ . '::ErrorStream';
    my $input_stream_class  = __PACKAGE__ . '::InputStream';
    my $output_stream_class = __PACKAGE__ . '::OutputStream';

    my $handler = sub {

        my $application = shift->instance;
        my $fcgi        = shift;

        local $@;

        eval {

            my $scheme = ( defined $fcgi->{'HTTPS'} && uc $fcgi->{'HTTPS'} eq 'ON' ) ? 'https' : 'http';

            ( my $path = $fcgi->{'REQUEST_URI'} // '' ) =~ s/\?.*$//;

            my $context = $context_class->new(

                input_stream => $input_stream_class->new,

                output_stream => $output_stream_class->new,

                error_stream => $error_stream_class->new,

                request => $request_class->new(
                    host           => $fcgi->{'SERVER_NAME'},
                    method         => $fcgi->{'REQUEST_METHOD'},
                    path           => $path,
                    port           => $fcgi->{'SERVER_PORT'},
                    protocol       => $fcgi->{'SERVER_PROTOCOL'},
                    query          => $fcgi->{'QUERY_STRING'},
                    remote_address => $fcgi->{'REMOTE_ADDR'},
                    scheme         => $scheme,
                    uri            => $fcgi->{'REQUEST_URI'}
                ),

                response => $response_class->new(
                    status => 200
                ),

                fcgi => $fcgi

            );

            $application->process( $context );

        };

        if ( $@ ) {
            return $application->engine->_handle_error( $fcgi, $@ );
        }

        return;

    };

    if ( $application->mode eq 'development' ) {

        my $real_handler = $handler;

        $handler = sub {
            goto &{"$_[0]\::handler"} if eval { $_[0]->reload };
            __PACKAGE__->_handle_reload_error( $_[0], $_[1], $@ ) if $@;
            return $real_handler->( @_ );
        };

    }

    return $handler;

}

sub _deploy {

    my $self = shift;

    $self->SUPER::_deploy;

    my $application = $self->application;

    $self->_export_method(
        ref( $application ),
        'handler',
        $self->_create_fcgi_handler( $application )
    );

    $self->_export_attribute(
        ref( $application ) . '::Context',
        {
            name     => 'fcgi',
            type     => 'Scalar',
            accessor => { type => 'get' }
        }
    );

    return;

}

sub _handle_error {

    my $self  = shift;
    my $fcgi  = shift;
    my $error = shift;

    local $@;

    eval {

        my $message;

        if ( defined $error ) {
            $message = "$error";
            $message =~ s/\n*$//;
            $message =~ s/\n/\\n/g;
        }
        else {
            $message = 'Unknown error';
        }

        print STDERR "[" . $self->application . "] [error] Uncaught exception: $message\n";

    };

    return;

}

sub _handle_reload_error {

    my $package           = shift;
    my $application_class = shift;
    my $fcgi              = shift;
    my $error             = shift;

    eval {

        my $message;

        if ( defined $error ) {
            $message = "$error";
            $message =~ s/\n*$//;
            $message =~ s/\n/\\n/g;
        }
        else {
            $message = 'Unknown error';
        }

        print STDERR "[$application_class] [fatal] $message\n";
        print STDERR "[$application_class] [fatal] Reload failed, exiting ...";

        my $content = $package->_render_reload_error( $error );

        my $headers = GX::HTTP::Headers->new;
        $headers->set( 'Content-Type'   => 'text/html; charset=UTF-8' );
        $headers->set( 'Content-Length' => length $content );
        $headers->set( 'Status'         => 500 );

        print STDOUT $headers->as_string, CRLF, $content;

    };

    CORE::exit( 1 );

}


# ----------------------------------------------------------------------------------------------------------------------
# I/O stream adaptors
# ----------------------------------------------------------------------------------------------------------------------

package GX::Engine::FCGI::InputStream;

use GX::Class::Object;

build;

sub read {

    return read( STDIN, $_[1], $_[2] );

}


package GX::Engine::FCGI::OutputStream;

use GX::Class::Object;

build;

sub flush {

    my $fh = select STDOUT;

    my $hot = $|;

    $| = 1;

    print STDOUT '';

    $| = $hot;

    select $fh;

    return 1;

}

sub print {

    shift;

    return print( STDOUT @_ );

}


package GX::Engine::FCGI::ErrorStream;

use GX::Class::Object;

build;

sub print {

    shift;

    return print( STDERR @_ );

}


1;

__END__

=head1 NAME

GX::Engine::FCGI - FastCGI engine component

=head1 SYNOPSIS

    package MyApp::Engine;
    
    use GX::Engine::FCGI;
    
    MyApp::Engine->setup(
        max_request_size         => 1048576,
        max_request_memory_usage => 16384
    );
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Engine::FCGI> class which extends the
L<GX::Engine> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the engine component instance.

    $engine = $engine_class->new;

=over 4

=item Returns:

=over 4

=item * C<$engine> ( L<GX::Engine::FCGI> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<setup>

Sets up the engine component.

    $engine_class->setup( %options );

=over 4

=item Options:

=over 4

=item * C<buffer_size> ( integer )

Defaults to 8192 bytes.

=item * C<max_request_memory_usage> ( integer )

Defaults to 16384 bytes.

=item * C<max_request_size> ( integer )

Defaults to 1048576 bytes.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Internal Methods

=head3 C<finalize_response_headers>

Handler.

    $engine->finalize_response_headers( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=back

=head3 C<process_request_body>

Handler.

    $engine->process_request_body( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=back

=head3 C<process_request_headers>

Handler.

    $engine->process_request_headers( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=back

=head3 C<send_response>

Handler.

    $engine->send_response( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=back

=head1 EXPORTS

=head2 Application Class

=head3 C<handler>

Internal method.

    $application_class->handler( $fcgi );

=over 4

=item Arguments:

=over 4

=item * C<$fcgi> ( C<HASH> reference )

A reference to a hash with the current FastCGI environment variables.

=back

=back

=head2 Context Class

=head3 C<fcgi>

Returns a reference to a hash with the current FastCGI environment variables.

    $fcgi = $context->fcgi;

=over 4

=item Returns:

=over 4

=item * C<$fcgi> ( C<HASH> reference )

=back

=back

=head1 I/O ADAPTORS

For internal use only.

=over 4

=item * Input stream class

C<GX::Engine::FCGI::InputStream>

=item * Output stream class

C<GX::Engine::FCGI::OutputStream>

=item * Error stream class

C<GX::Engine::FCGI::ErrorStream>

=back

=head1 SERVER SETUP

=head2 Apache2 - Managed Mode with mod_fcgid

Example (Apache/2.2.13 on openSUSE 11.2):

I</etc/apache2/default-server.conf>:

  LoadModule fcgid_module /usr/lib/apache2/mod_fcgid.so
  SocketPath /tmp/fcgid.socket
  SharememPath /tmp/fcgid.shm
  
  Listen 8080
  
  <VirtualHost *:8080>
  
      DocumentRoot /srv/www/myapp/public
  
      <Directory /srv/www/myapp/public>
          Order Deny,Allow
          Allow from All
      </Directory>
  
      <Directory /srv/www/myapp/script/server>
          Options ExecCGI
          AddHandler fcgid-script .pl
          Order Deny,Allow
          Allow from All
      </Directory>
  
      Alias /favicon.ico /srv/www/myapp/public/favicon.ico
      Alias /static/     /srv/www/myapp/public/static/
      Alias /error/      /usr/share/apache2/error/  
      Alias /            /srv/www/myapp/script/server/fcgi.pl/
  
  </VirtualHost>

Start Apache:

      /etc/init.d/apache2 start

Note: Make sure that the I<apache2-mod_fcgid> package is installed.

For more information on using FastCGI under Apache2 with mod_fcgid visit
L<http://httpd.apache.org/mod_fcgid/>.

=head2 Lighttpd - Standalone Mode

Example (lighttpd/1.4.20 on openSUSE 11.2):

I</etc/lighttpd/modules.conf>:

  include "conf.d/fastcgi.conf"

I</etc/lighttpd/lighttpd.conf>:

  server.document-root = "/srv/www/myapp/public/"

I</etc/lighttpd/conf.d/fastcgi.conf>:

  $HTTP["url"] !~ "^/static/" {
      fastcgi.server = (
          "/" => (
              "MyApp" => (
                  "socket"      => "/tmp/myapp.socket",
                  "check-local" => "disable"
              )
          )
      )
  }

Use the F<myapp/script/server/fcgi.pl> script to start the application server,
e.g.:

      fcgi.pl --listen /tmp/myapp.socket --processes 5

Start lighttpd:

      /etc/init.d/lighttpd start

For more information on using FastCGI under Lighttpd visit
L<http://www.lighttpd.net>.

=head1 SEE ALSO

=over 4

=item * L<http://www.fastcgi.com/>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
