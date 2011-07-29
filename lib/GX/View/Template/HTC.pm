# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/View/Template/HTC.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::View::Template::HTC;

use GX::Exception;

use HTML::Template::Compiled ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::View::Template';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _initialize_file_extensions {

    return [ 'htc' ];

}

sub _initialize_options {

    return {
        'cache' => 1  # enable in-memory caching
    };

}

sub _preload_template_file {

    my $self = shift;
    my $file = shift;

    my $htc = eval {
        HTML::Template::Compiled->new(
            %{$self->_get_options},
            filename => $file,
            cache    => 1
        );
    };

    if ( ! $htc ) {
        GX::Exception->throw(
            message      => "Cannot create the HTML::Template::Compiled instance",
            subexception => $@
        );
    }

    my $result = $htc->output;

    return;

}

sub _process_template_file {

    my $self       = shift;
    my $file       = shift;
    my $parameters = shift;
    my $options    = shift;

    my $htc = eval {
        HTML::Template::Compiled->new(
            %{$self->_get_options},
            ( $options ? %$options : () ),
            filename => $file
        );
    };

    if ( ! $htc ) {
        GX::Exception->throw(
            message      => "Cannot create the HTML::Template::Compiled instance",
            subexception => $@
        );
    }

    if ( $parameters ) {
        $htc->param( $parameters );
    }

    my $result = $htc->output;

    return \$result;

}

sub _register {

    my $self        = shift;
    my $application = shift;

    $self->SUPER::_register( $application );

    my $options = $self->_get_options;

    if ( ! exists $options->{'open_mode'} ) {

        if ( defined $self->_get_template_encoding ) {
            $options->{'open_mode'} = ':encoding(' . $self->_get_template_encoding  . ')';
        }

    }

    if ( ! exists $options->{'path'} ) {

        if ( defined $self->_get_templates_directory ) {
            $options->{'path'} = [ $self->_get_templates_directory ];
        }

    }

    return;

}


1;

__END__

=head1 NAME

GX::View::Template::HTC - HTML::Template::Compiled-based view

=head1 SYNOPSIS

    package MyApp::View::Template;
    
    use GX::View::Template::HTC;
    
    __PACKAGE__->setup(
        default_content_type => 'text/html',
        default_encoding     => 'utf-8',
        file_extensions      => [ 'htc' ],
        options              => { default_escape => 'HTML' },
        preload              => 1
    );
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::View::Template::HTC> class which extends the
L<GX::View::Template> class.

=head1 METHODS

See L<GX::View::Template>.

=head1 USAGE

=head2 Template Parameters

The following template parameters are provided automatically:

=over 4

=item * C<context>

The current context object, if available.

=item * C<output_charset>

The IANA charset name of the output encoding, e.g. "UTF-8" or "ISO-8859-1".
Only provided if the output is going to be encoded.

=back

=head2 File Extensions

The following file extensions are associated with L<GX::View::Template::HTC>:

=over 4

=item * C<.htc>

=back

=head1 SEE ALSO

=over 4

=item * L<HTML::Template::Compiled>

=item * L<HTML::Template::Compiled::Reference>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
