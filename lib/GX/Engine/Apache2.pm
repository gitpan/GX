# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Engine/Apache2.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Engine::Apache2;

use GX::Exception;
use GX::HTTP::Body::File;
use GX::HTTP::Body::Scalar;

use Apache2::Connection ();
use Apache2::Const '-compile' => qw( :common );
use Apache2::RequestIO ();
use Apache2::RequestRec ();
use Apache2::RequestUtil ();
use Apache2::Response ();
use APR::Table ();


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

    my $headers    = $context->request->headers;
    my $headers_in = $context->request_record->headers_in;

    while ( my ( $field_name, $field_value ) = each %$headers_in ) {
        $headers->add( $field_name, $field_value );
    }

    return;

}

sub send_response :Handler( SendResponse ) {

    my $self    = shift;
    my $context = shift;

    my $output_stream = $context->output_stream;

    my $response       = $context->response;
    my $request_record = $context->request_record;

    $request_record->status( $response->status );

    my $headers     = $response->headers;
    my $headers_out = $request_record->err_headers_out;

    for my $field_name ( $headers->field_names ) {

        for my $field_value ( $headers->get( $field_name ) ) {
            $headers_out->add( $field_name => $field_value );
        }

    }

    my $content_type = $headers->content_type;

    if ( defined $content_type ) {
        $request_record->content_type( $content_type );
    }

    my $body = $response->body;

    if ( my $length = $body->length ) {

        if ( $length > 0 ) {
            $request_record->set_content_length( $length );
        }

        if ( $body->isa( 'GX::HTTP::Body::Scalar' ) ) {
            $output_stream->print( ${$body->content} );
        }
        elsif ( $body->isa( 'GX::HTTP::Body::File' ) ) {
            $output_stream->sendfile( $body->file );
        }
        else {
            $body->print_to( $output_stream );
        }

    }

    $output_stream->flush;

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _create_mod_perl_handler {

    my $self        = shift;
    my $application = shift;

    my $context_class  = ref( $application ) . '::Context';
    my $request_class  = ref( $application ) . '::Request';
    my $response_class = ref( $application ) . '::Response';

    my $error_stream_class  = __PACKAGE__ . '::ErrorStream';
    my $input_stream_class  = __PACKAGE__ . '::InputStream';
    my $output_stream_class = __PACKAGE__ . '::OutputStream';

    my $handler = sub :method {

        my $application    = shift->instance;
        my $request_record = shift;

        local $@;

        eval {

            my $scheme = do {
                my $value = $request_record->subprocess_env( 'HTTPS' ); 
                ( defined $value && uc $value eq 'ON' ) ? 'https' : 'http';
            };

            my $context = $context_class->new(

                error_stream => $error_stream_class->new(
                    request_record => $request_record
                ),

                input_stream => $input_stream_class->new(
                    request_record => $request_record
                ),

                output_stream => $output_stream_class->new(
                    request_record => $request_record
                ),

                request => $request_class->new(
                    host           => $request_record->hostname,
                    method         => $request_record->method,
                    path           => $request_record->uri,
                    port           => $request_record->get_server_port,
                    protocol       => $request_record->protocol,
                    query          => $request_record->args,
                    remote_address => $request_record->connection->remote_ip,
                    scheme         => $scheme,
                    uri            => $request_record->unparsed_uri
                ),

                response => $response_class->new(
                    status => 200
                ),

                request_record => $request_record

            );

            $application->process( $context );

        };

        if ( $@ ) {
            return $application->engine->_handle_error( $request_record, $@ );
        }

        return Apache2::Const::OK;

    };

    if ( $application->mode eq 'development' ) {

        my $real_handler = $handler;

        $handler = sub :method {
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
        $self->_create_mod_perl_handler( $application )
    );

    $self->_export_attribute(
        ref( $application ) . '::Context',
        {
            name     => 'request_record',
            type     => 'Scalar',
            accessor => { type => 'get' }
        }
    );

    return;

}

sub _handle_error {

    my $self           = shift;
    my $request_record = shift;
    my $error          = shift;

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

        print STDERR "[" . ref( $self->application ) . "] [error] Uncaught error: $message\n";

    };

    return Apache2::Const::SERVER_ERROR;

}

sub _handle_reload_error {


    my $package           = shift;
    my $application_class = shift;
    my $request_record    = shift;
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
        print STDERR "[$application_class] [fatal] Reload failed, exiting ...\n";

        $request_record->status( 500 );
        $request_record->content_type( 'text/html; charset=UTF-8' );
        $request_record->print( $package->_render_reload_error( $error ) );
        $request_record->rflush;

    };

    CORE::exit( 1 );

}


# ----------------------------------------------------------------------------------------------------------------------
# I/O stream adaptors
# ----------------------------------------------------------------------------------------------------------------------

package GX::Engine::Apache2::InputStream;

use GX::Class::Object;

has 'request_record';

build;

sub read {

    my $self = shift;

    local $@;

    return eval { $self->{'request_record'}->read( @_ ) };

}


package GX::Engine::Apache2::OutputStream;

use GX::Class::Object;

has 'request_record';

build;

sub flush {

    my $self = shift;

    local $@;

    return eval { $self->{'request_record'}->rflush; 1 };

}

sub print {

    my $self = shift;

    local $@;

    return eval { $self->{'request_record'}->print( @_ ) };

}

sub sendfile {

    my $self = shift;

    local $@;

    return eval { $self->{'request_record'}->sendfile( @_ ) };

}


package GX::Engine::Apache2::ErrorStream;

use GX::Class::Object;

has 'request_record';

build;

sub print {

    shift;

    return print STDERR @_;

}


1;

__END__

=head1 NAME

GX::Engine::Apache2 - Apache2 / mod_perl 2.x engine component 

=head1 SYNOPSIS

    package MyApp::Engine;
    
    use GX::Engine::Apache2;
    
    MyApp::Engine->setup(
        max_request_size         => 1048576,
        max_request_memory_usage => 16384
    );
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Engine::Apache2> class which extends the
L<GX::Engine> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the engine component instance.

    $engine = $engine_class->new;

=over 4

=item Returns:

=over 4

=item * C<$engine> ( L<GX::Engine::Apache2> object )

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

    $application_class->handler( $request_record );

=over 4

=item Arguments:

=over 4

=item * C<$request_record> ( L<Apache2::RequestRec> object )

=back

=back

=head2 Context Class

=head3 C<request_record>

Returns the current request record.

    $request_record = $context->request_record;

=over 4

=item Returns:

=over 4

=item * C<$request_record> ( L<Apache2::RequestRec> object )

=back

=back

=head1 I/O ADAPTORS

For internal use only.

=over 4

=item * Input stream class

C<GX::Engine::Apache2::InputStream>

=item * Output stream class

C<GX::Engine::Apache2::OutputStream>

=item * Error stream class

C<GX::Engine::Apache2::ErrorStream>

=back

=head1 SERVER SETUP

Example (Apache/2.2.13 on openSUSE 11.2):

I</etc/apache2/default-server.conf>:

  LoadModule perl_module /usr/lib/apache2/mod_perl.so
  
  <VirtualHost *:80>
  
      ServerName localhost
  
      DocumentRoot /srv/www/myapp/public
  
      <Directory /srv/www/myapp/public>
          Order Deny,Allow
          Allow from All
      </Directory>
  
      PerlOptions +Parent
  
      PerlSwitches -I /srv/www/myapp/lib
  
      PerlModule MyApp
  
      <Location />
          SetHandler perl-script
          PerlResponseHandler MyApp
          DirectorySlash Off
      </Location>
  
      <Location /static>
          SetHandler None
      </Location>
  
      <Location /favicon.ico>
          SetHandler None
      </Location>
  
      <Location /error>
          SetHandler None
      </Location>
  
  </VirtualHost>

=head1 LIMITATIONS

This module currently only supports the Apache Prefork MPM
(mpm_prefork_module).

=head1 SEE ALSO

=over 4

=item * L<http://httpd.apache.org/>

=item * L<http://perl.apache.org/>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
