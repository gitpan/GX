# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/View/Template.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::View::Template;

use GX::Exception;
use GX::MIME::Util;

use Encode ();
use File::Find ();
use File::Spec ();
use File::Spec::Unix ();
use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant UNIX_PATHS => ( $File::Spec::ISA[0] eq 'File::Spec::Unix' ) ? 1 : 0;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::View';

has 'default_content_type' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_default_content_type' => { type => 'get' },
        '_set_default_content_type' => { type => 'set' }
    }
);

has 'default_encoding' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_default_encoding' => { type => 'get' },
        '_set_default_encoding' => { type => 'set' }
    }
);

has 'file_extensions' => (
    isa         => 'Array',
    initialize  => 1,
    initializer => '_initialize_file_extensions',
    accessors   => {
        '_get_file_extensions' => { type => 'get_reference' }
    }
);

has 'options' => (
    isa         => 'Hash',
    initialize  => 1,
    initializer => '_initialize_options',
    accessors   => {
        '_get_options' => { type => 'get_reference' }
    }
);

has 'template_encoding' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_template_encoding' => { type => 'get' },
        '_set_template_encoding' => { type => 'set' }
    }
);

has 'templates' => (
    isa        => 'Hash',
    initialize => 1,
    accessors  => {
        '_get_templates' => { type => 'get_reference' }
    }
);

has 'templates_directory' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_templates_directory' => { type => 'get' },
        '_set_templates_directory' => { type => 'set' }
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

sub default_content_type {

    return $_[0]->instance->_get_default_content_type;

}

sub default_encoding {

    return $_[0]->instance->_get_default_encoding;

}

sub file_extensions {

    return @{$_[0]->instance->_get_file_extensions};

}

sub options {

    return %{$_[0]->instance->_get_options};

}

sub preloaded_templates {

    my $self = shift->instance;

    my $templates = $self->_get_templates;

    return grep { $templates->{$_}{'preloaded'} } keys %$templates;

}

sub render {

    my $self = shift->instance;
    my %args = @_;

    if ( ! defined $args{'template'} ) {
        complain "Missing argument (\"template\")";
    }

    my $template_info = $self->_get_templates->{$args{'template'}};

    if ( ! $template_info ) {
        complain "Unknown template \"$args{'template'}\"";
    }

    my $encoding;
    my $encoder;

    if ( exists $args{'encoding'} ) {

        $encoding = $args{'encoding'};

        if ( defined $encoding ) {

            $encoder = Encode::find_encoding( $encoding );

            if ( ! $encoder ) {
                complain "Unsupported output encoding \"$encoding\"";
            }

        }

    }
    else {

        $encoding = $self->_get_default_encoding;

        if ( defined $encoding ) {
            $encoder = Encode::find_encoding( $encoding );
        }

    }

    my $context    = $args{'context'};
    my $parameters = $args{'parameters'};
    my $options    = $args{'options'};

    if ( defined $context ) {

        if ( ! blessed $context || ! $context->isa( 'GX::Context' ) ) {
            complain "Invalid argument (\"context\" must be a GX::Context object)";
        }

    }

    if ( defined $parameters ) {

        if ( ! ref $parameters eq 'HASH' ) {
            complain "Invalid argument (\"parameters\" must be hash reference)";
        }

    }

    if ( defined $options ) {

        if ( ! ref $options eq 'HASH' ) {
            complain "Invalid argument (\"options\" must be hash reference)";
        }

    }

    my $content;

    eval {

        $content = $self->_process_template_file(
            $template_info->{'file'},
            $self->_preprocess_template_parameters(
                $context,
                $parameters,
                {
                    'output_charset' => ( $encoder ? $encoder->mime_name : undef )
                }
            ),
            $options
        );

        if ( $encoder ) {
            $$content = $encoder->encode( $$content );
        }

    };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Render error",
            subexception => $@
        );
    }

    if ( defined wantarray ) {
        return $$content;
    }

    if ( ! defined $context ) {
        complain "Missing argument (\"context\")";
    }

    my $response = $context->response;

    if ( ! defined $response->content_type ) {

        my $content_type = $template_info->{'content_type'} // $self->_get_default_content_type;

        if ( defined $content_type ) {

            if ( $encoder && substr( $content_type, 0, 5 ) eq 'text/' ) {
                $content_type .= '; charset=' . $encoder->mime_name; 
            }

            $response->content_type( $content_type );

        }

    }

    $response->add( $content );

    return;

}

sub template_encoding {

    return $_[0]->instance->_get_template_encoding;

}

sub templates {

    return keys %{$_[0]->instance->_get_templates};

}

sub templates_directory {

    return $_[0]->instance->_get_templates_directory;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _canonicalize_template_name {

    my $self     = shift;
    my $template = shift;

    $template = File::Spec->canonpath( $template );

    if ( ! UNIX_PATHS ) {

        my @path = File::Spec->splitpath( $template );

        $template = File::Spec::Unix->catfile(
            File::Spec->splitdir( $path[1] ),
            $path[2]
        );

    }

    return $template;

}

sub _find_template_files {

    my $self      = shift;
    my $directory = shift;

    my @files;

    if ( defined $directory && -d $directory ) {

        if ( $self->file_extensions ) {

            my $file_regex = do {
                my $pattern = '[^.]+\.(?:' . join( '|', map { quotemeta } $self->file_extensions ) . ')$';
                qr/$pattern/;
            };

            File::Find::find(
                {
                    'wanted'   => sub { push @files, $_ if -f && -r && /$file_regex/ },
                    'no_chdir' => 1
                },
                $directory
            );

        }

    }

    return @files;

}

sub _index_templates {

    my $self = shift;

    my $directory = $self->_get_templates_directory;

    return unless defined $directory && File::Spec->file_name_is_absolute( $directory );

    my $templates = $self->_get_templates;

    for my $file ( $self->_find_template_files( $directory ) ) {

        my $template = $self->_canonicalize_template_name( File::Spec->abs2rel( $file, $directory ) );

        $templates->{$template} ||= {
            'file'         => $file,
            'content_type' => (
                $template =~ /[^.]+\.([^.]+)\.[^.]+$/ ? GX::MIME::Util::format_to_mime_type( $1 ) : undef
            )
        };

    }

    return;

}

sub _initialize_config {

    return {
        'preload' => 1
    };

}

sub _initialize_file_extensions {

    return [];

}

sub _initialize_options {

    return {};

}

sub _preload_template_file {

    # Abstract method

}

sub _preload_templates {

    my $self = shift;

    my $templates = $self->_get_templates;

    for my $template ( keys %$templates ) {
        $self->_preload_template_file( $templates->{$template}{'file'} );
        $templates->{$template}{'preloaded'} = 1;
    }

    return;

}

sub _preprocess_template_parameters {

    my $self              = shift;
    my $context           = shift;
    my $parameters        = shift;
    my $static_parameters = shift;

    return {
        ( $context ? ( %{$context->stash}, 'context' => $context ) : () ),
        ( $static_parameters ? %$static_parameters : () ),
        ( $parameters ? %$parameters : () )
    };

}

sub _process_template_file {

    # Abstract method

}

sub _register {

    my $self        = shift;
    my $application = shift;

    $self->SUPER::_register( $application );

    if ( ! defined $self->_get_default_encoding ) {
        $self->_set_default_encoding( $application->default_encoding );
    }

    if ( ! defined $self->_get_template_encoding ) {
        $self->_set_template_encoding( $application->default_encoding );
    }

    if ( defined $self->_get_templates_directory ) {

        if ( ! File::Spec->file_name_is_absolute( $self->_get_templates_directory ) ) {

            my $base_path = $application->path( 'base' );

            if ( defined $base_path ) {
                $self->_set_templates_directory( File::Spec->rel2abs( $self->_get_templates_directory, $base_path ) );
            }

        }

    }
    else {
        $self->_set_templates_directory( $application->path( 'templates' ) );
    }

    $self->_index_templates;

    return;

}

sub _setup {

    my $self   = shift;
    my $config = shift;

    $self->SUPER::_setup( $config );

    $self->_index_templates;

    return;

}

sub _setup_config {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'default_content_type'} ) {

        my $content_type = delete $args->{'default_content_type'};

        if ( defined $content_type ) {

            if ( $content_type !~ GX::MIME::Util::REGEX_MIME_TYPE ) {
                throw "Invalid option (\"default_content_type\" must be a valid MIME type)";
            }

            $self->_set_default_content_type( $content_type );

        }

    }

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

    if ( exists $args->{'file_extensions'} ) {

        my $file_extensions = delete $args->{'file_extensions'};

        if ( ref $file_extensions ne 'ARRAY' ) {
            throw "Invalid option (\"file_extensions\" must be an array reference)";
        }

        @{$self->_get_file_extensions} = map { $_ =~ s/^\.//; $_ } grep { defined } @$file_extensions;

    }

    if ( exists $args->{'options'} ) {

        my $options = delete $args->{'options'};

        if ( ref $options ne 'HASH' ) {
            throw "Invalid option (\"options\" must be a hash reference)";
        }

        %{$self->_get_options} = ( %{$self->_get_options}, %$options );

    }

    if ( exists $args->{'preload'} ) {
        $self->_get_config->{'preload'} = delete $args->{'preload'} ? 1 : 0;
    }

    if ( exists $args->{'template_encoding'} ) {

        my $encoding = delete $args->{'template_encoding'};

        if ( defined $encoding ) {

            my $encoder = Encode::find_encoding( $encoding );

            if ( ! $encoder ) {
                throw "Unsupported template encoding \"$encoding\"";
            }

            $self->_set_template_encoding( $encoder->name );

        }

    }

    if ( exists $args->{'templates_directory'} ) {

        my $directory = delete $args->{'templates_directory'};

        if ( defined $directory ) {
            $self->_set_templates_directory( File::Spec->canonpath( $directory ) );
        }

    }

    $self->SUPER::_setup_config( $args );

    return;

}

sub _start {

    my $self = shift;

    $self->SUPER::_start;

    if ( $self->_get_config->{'preload'} ) {
        $self->_preload_templates;
    }

    return;

}


1;

__END__

=head1 NAME

GX::View::Template - Base class for template-based view components

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::View::Template> class which extends the
L<GX::View> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the view component instance.

    $view = $view_class->new;

=over 4

=item Returns:

=over 4

=item * C<$view> ( L<GX::View::Template> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

All public methods can be called both as instance and class methods.

=head3 C<default_content_type>

Returns the default content type.

    $content_type = $view->default_content_type;

=over 4

=item Returns:

=over 4

=item * C<$content_type> ( string | C<undef> )

Returns the default content type, for example "text/html" or
"application/xhtml+xml", or C<undef> if the default content type is not
defined.

=back

=back

=head3 C<default_encoding>

Returns the name of the default output encoding.

    $encoding = $view->default_encoding;

=over 4

=item Returns:

=over 4

=item * C<$encoding> ( string | C<undef> )

An encoding name, for example "utf-8" or "iso-8859-1", or C<undef> if the
default output encoding is not defined.

=back

=back

=head3 C<file_extensions>

Returns a list with the associated template file extensions.

    @file_extensions = $view->file_extensions;

=over 4

=item Returns:

=over 4

=item * C<@file_extensions> ( strings )

A list of template file extensions, for example "htc" or "tt".

=back

=back

=head3 C<options>

Returns the setup options for the template engine as a list of key / value
pairs.

    %options = $view->options;

=over 4

=item Returns:

=over 4

=item * C<%options> ( named list )

=back

=back

=head3 C<preloaded_templates>

Returns a list with the file names of the preloaded templates.

    @templates = $view->preloaded_templates;

=over 4

=item Returns:

=over 4

=item * C<@templates> ( strings )

A list of UNIX-style paths relative to the
L<templates directory|/templates_directory>.

=back

=back

=head3 C<render>

If called in void context, C<render()> renders the specified template and adds
the result to the body of the response object that is associated with the
given context object. Additionally, it sets the "Content-Type" header of the
response to an appropriate value, unless that header has already been set.

    $view->render( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<context> ( L<GX::Context> object ) [ required ]

A context object. This argument is required in void context.

=item * C<encoding> ( string | C<undef> )

The name of the desired output encoding, for example "utf-8" or "iso-8859-1".
See L<Encode> for a list of supported encodings. If omitted, the default
encoding will be applied. If C<undef> is passed, the output will not be
encoded.

=item * C<options> ( C<HASH> reference )

A reference to a hash with additional render options for the template engine.

=item * C<parameters> ( C<HASH> reference )

A reference to a hash containing the template parameters.

=item * C<template> ( string ) [ required ]

The template to render. The given argument must be a UNIX-style path relative
to the L<templates directory|/templates_directory>, for example
"blog/posts.html.tt".

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

If called in non-void context, C<render()> returns the processed template.

    $output = $view->render( %arguments ); 

=over 4

=item Arguments:

=over 4

=item * C<context> ( L<GX::Context> object )

A context object. This argument is optional in non-void context.

=item * C<encoding> ( string | C<undef> )

See above.

=item * C<options> ( C<HASH> reference )

See above.

=item * C<parameters> ( C<HASH> reference )

See above.

=item * C<template> ( string ) [ required ]

See above.

=back

=item Returns:

=over 4

=item * C<$output> ( string | byte string )

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

=item * C<default_content_type> ( string )

The default content type, for example "text/html" or "application/xhtml+xml".
Used when the content type is not predetermined by the name of the template
file, i.e. for all template files not following the recommended
I<name.format.extension> naming scheme.

=item * C<default_encoding> ( string )

The name of the default output encoding, for example "utf-8" or "iso-8859-1".
See L<Encode> for a list of supported encodings. Defaults to the default
encoding of the application.

=item * C<file_extensions> ( C<ARRAY> reference )

A reference to an array containing the file extensions that should be
associated with the view.

=item * C<options> ( C<HASH> reference )

A reference to a hash with additional setup options for the template engine.

=item * C<preload> ( bool )

A boolean flag indicating whether or not to preload all template files located
in the templates directory. Defaults to C<true>.

=item * C<template_encoding> ( string )

The name of the encoding of the template files, for example "utf-8" or
"iso-8859-1". See L<Encode> for a list of supported encodings. Defaults to the
default encoding of the application.

=item * C<templates_directory> ( string )

The path to the directory that contains the template files. Defaults to the
application's I<./templates> directory. A relative path, if given, is assumed
to be relative to the application's base directory.

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<template_encoding>

Returns the name of the encoding of the template files.

    $encoding = $view->template_encoding;

=over 4

=item Returns:

=over 4

=item * C<$encoding> ( string | C<undef> )

An encoding name, for example "utf-8" or "iso-8859-1", or C<undef> if the
template encoding is not defined.

=back

=back

=head3 C<templates>

Returns a list with the file names of the available templates.

    @templates = $view->templates;

=over 4

=item Returns:

=over 4

=item * C<@templates> ( strings )

A list of UNIX-style paths relative to the
L<templates directory|/templates_directory>.

=back

=back

=head3 C<templates_directory>

Returns the path to the directory that contains the template files.

    $path = $view->templates_directory;

=over 4

=item Returns:

=over 4

=item * C<$path> ( string )

=back

=back

=head1 SUBCLASSES

The following classes inherit directly from L<GX::View::Template>:

=over 4

=item * L<GX::View::Template::HTC>

=item * L<GX::View::Template::TT>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
