# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/View/Error.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::View::Error;

use GX::Callback::Method;
use GX::Exception;
use GX::Exception::Formatter::HTML;
use GX::HTML::Util qw( escape_html );

use Encode ();
use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::View';

has 'default_encoding' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_default_encoding' => { type => 'get' },
        '_set_default_encoding' => { type => 'set' }
    }
);

has 'default_format' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_default_format' => { type => 'get' },
        '_set_default_format' => { type => 'set' }
    }
);

has 'format_handlers' => (
    isa         => 'Hash',
    initialize  => 1,
    initializer => '_initialize_format_handlers',
    accessors   => {
        '_get_format_handler'  => { type => 'get_value' },
        '_set_format_handler'  => { type => 'set_value' },
        '_get_format_handlers' => { type => 'get_reference' }
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

sub default_encoding {

    return $_[0]->instance->_get_default_encoding;

}

sub default_format {

    return $_[0]->instance->_get_default_format;

}

sub render {

    my $self = shift->instance;
    my %args = @_;

    my $format = $args{'format'} // $self->_get_default_format;

    if ( ! defined $format ) {
        complain "Unspecified output format";
    }

    my $handler = $self->_get_format_handler( $format );

    if ( ! $handler ) {
        complain "Unsupported output format \"$format\"";
    }

    if ( defined wantarray ) {

        my $output;

        eval { $output = $handler->call( %args ) };

        if ( $@ ) {
            complain $@;
        }

        return $$output;

    }
    else {

        eval { $handler->call( %args ) };

        if ( $@ ) {
            complain $@;
        }

        return;

    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _generate_html {

    my $self    = shift;
    my $error   = shift;
    my $charset = shift;

    my $html;

    if ( $self->application->mode eq 'development' ) {

        my $title;
        my $error_html;

        if ( blessed $error && $error->isa( 'GX::Exception' ) ) {
            $title      = ref $error;
            $error_html = GX::Exception::Formatter::HTML->format( $error );
        }
        else {

            $title = 'Error';

            $error //= 'Unknown error';

            $error_html = join "\n",
                '<h1>Error</h1>',
                '<div class="exception">',
                '<div class="message">',
                '<code>' . join( '<br />', split( /\n/, escape_html( $error ) ) ) . '</code>',
                '</div>',
                '</div>' . "\n";

        }

        $html = <<HTML;
<?xml version="1.0" encoding="$charset"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>$title</title>
<meta http-equiv="Cache-Control" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=$charset" />
<meta http-equiv="Expires" content="0" />
<meta http-equiv="Pragma" content="no-cache" />
<meta name="robots" content="noindex, nofollow" />
<style type="text/css">
body, code, div, h1, h2, p, table, tbody, tr, td { margin:0; padding:0 }
body { padding:50px; font-size:15px; font-family:Arial, sans-serif; color:#333 }
h1 { margin:0 0 25px 0; font-size: 32px }
h2 { margin:0 0 25px 0; font-size: 24px }
li { margin-bottom:25px }
p { margin:15px 0 }
table { width:100%; empty-cells:show; border-spacing:1px }
code { font-family:"DejaVu Sans Mono", Monaco, "Lucida Console", "Andale Mono", monospace }
div.message { margin:25px 0; padding:15px; background:#F4CDCD }
div.subexceptions { margin:50px 0 }
div.stack_trace { margin:50px 0 }
div.stack_trace p strong { padding:3px 5px; background: #FEEFB3; font-size:13px; font-family:"DejaVu Sans Mono", Monaco, "Lucida Console", "Andale Mono", monospace }
div.viewport { overflow:auto }
table.source code { font-size:13px; color:#444 }
table.source td { padding:2px 5px; background:#EEE }
table.source td.line { text-align:right }
table.source td.code { width:100% }
table.source tr.highlight td { background:#E3E3E3 }
table.source tr.highlight td code { color:#333 }
</style>
</head>
<body>
$error_html</body>
</html>
HTML

    }
    else {

        $html = <<HTML;
<?xml version="1.0" encoding="$charset"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Server error!</title>
<meta http-equiv="Content-Type" content="text/html; charset=$charset" />
</head>
<body>
<h1>Server error!</h1>
<p>The server encountered an internal error and was unable to complete your request.</p>
</body>
</html>
HTML

    }

    return $html;

}

sub _initialize_format_handlers {

    my $self = shift;

    return {
        'html' => GX::Callback::Method->new( invocant => $self, method => '_render_html' )
    };

}

sub _register {

    my $self        = shift;
    my $application = shift;

    $self->SUPER::_register( $application );

    if ( ! defined $self->_get_default_encoding ) {
        $self->_set_default_encoding( $application->default_encoding );
    }

    return $self;

}

sub _render_html {

    my $self = shift;
    my %args = @_;

    my $context = $args{'context'};

    my $error = exists $args{'error'}
        ? $args{'error'}
        : $context
            ? $context->error
            : undef;

    my $encoding = $args{'encoding'} // $self->_get_default_encoding // 'utf-8';

    my $encoder = Encode::find_encoding( $encoding );

    if ( ! $encoder ) {
        throw "Unsupported output encoding \"$encoding\"";
    }

    my $charset = $encoder->mime_name;

    my $output = $encoder->encode( $self->_generate_html( $error, $charset ) );

    if ( defined wantarray ) {
        return \$output;
    }

    if ( ! defined $context ) {
        throw "Missing argument (\"context\")";
    }

    my $response = $context->response;

    if ( ! defined $response->content_type ) {
        $response->content_type( 'text/html; charset=' . $charset );
    }

    $response->add( \$output );

    return;


}

sub _setup_config {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'default_encoding'} ) {

        my $encoding = delete $args->{'default_encoding'};

        if ( defined $encoding ) {

            my $encoder = Encode::find_encoding( $encoding );

            if ( ! $encoder ) {
                throw "Unsupported default encoding \"$encoding\"";
            }

            $self->_set_default_encoding( $encoder->name );

        }

    }

    if ( exists $args->{'default_format'} ) {

        my $format = delete $args->{'default_format'};

        if ( defined $format ) {

            if ( ! $self->_get_format_handler( $format ) ) {
                throw "Unsupported default format \"$format\"";
            }

            $self->_set_default_format( $format );

        }

    }
    else {
        $self->_set_default_format( 'html' );
    }

    $self->SUPER::_setup_config( $args );

    return;

}


1;

__END__

=head1 NAME

GX::View::Error - Default error view

=head1 SYNOPSIS

    package MyApp::View::Error;
    
    use GX::View::Error;
    
    __PACKAGE__->setup(
        default_format   => 'html',
        default_encoding => 'utf-8'
    );
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::View::Error> class which extends the
L<GX::View> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the view component instance.

    $view = $view_class->new;

=over 4

=item Returns:

=over 4

=item * C<$view> ( L<GX::View::Error> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

All public methods can be called both as instance and class methods.

=head3 C<default_encoding>

Returns the name of the default output encoding.

    $encoding = $view->default_encoding;

=over 4

=item Returns:

=over 4

=item * C<$encoding> ( string | C<undef> )

An encoding name, for example "utf-8" or "iso-8859-1", or C<undef> if the
default output encoding is not defined. See L<Encode> for a list of supported
encodings.

=back

=back

=head3 C<default_format>

Returns the default render format.

    $format = $view->default_format;

=over 4

=item Returns:

=over 4

=item * C<$format> ( string | C<undef> )

A format identifier, for example "html", or C<undef> if the default render
format is not defined.

=back

=back

=head3 C<render>

If called in void context, C<render()> renders the given error message or
exception object and adds the result to the body of the response object that
is associated with the given context object. Additionally, it sets the
"Content-Type" header of the response to an appropriate value, unless that
header has already been set.

    $view->render( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<context> ( L<GX::Context> object ) [ required ]

A context object. This argument is required in void context.

=item * C<encoding> ( string )

The name of the desired output encoding, for example "utf-8" or "iso-8859-1".
See L<Encode> for a list of supported encodings. If omitted, the default
encoding (or "utf-8" as the final fallback) will be applied.

=item * C<error> ( L<GX::Exception> object | string )

The exception object or error message to render. If omitted, the C<error>
attribute of the given context object or, if that attribute is undefined, a
generic error message will be rendered.

=item * C<format> ( string )

The desired render format. Defaults to the default render format. Currently,
only "html" is supported out of the box. 

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

If called in non-void context, C<render()> returns the rendered error message
as a string of bytes.

    $output = $view->render( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<context> ( L<GX::Context> object )

A context object. This argument is optional in non-void context.

=item * C<encoding> ( string )

See above.

=item * C<error> ( L<GX::Exception> object | string )

See above.

=item * C<format> ( string )

See above.

=back

=item Returns:

=over 4

=item * C<$output> ( byte string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<setup>

Sets up the view.

    $view->setup( %options );

=over 4

=item Options:

=over 4

=item * C<default_encoding> ( string )

The name of the default output encoding, for example "utf-8" or "iso-8859-1".
See L<Encode> for a list of supported encodings. Defaults to the default
encoding of the application.

=item * C<default_format> ( string )

The default render format. Defaults to "html". Currently, only "html" is
supported out of the box.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Exception::Formatter::HTML>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
