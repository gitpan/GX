# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/View/Template/TT.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::View::Template::TT;

use GX::Exception;

use Scalar::Util qw( blessed );
use Template ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::View::Template';

has 'tt' => (
    isa        => 'Scalar',
    initialize => 1,
    constraint => sub { blessed $_ && $_->isa( 'Template' ) },
    accessors  => { 
        '_get_tt' => { type => 'get' },
        '_set_tt' => { type => 'set' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _create_tt {

    my $self = shift;

    my $tt = eval { Template->new( %{$self->_get_options} ) };

    if ( ! $tt ) {
        GX::Exception->throw(
            message      => "Cannot create the Template instance",
            subexception => $@
        );
    }

    return $tt;

}

sub _initialize_file_extensions {

    return [ 'tt' ];

}

sub _initialize_options {

    return {
        'ABSOLUTE'  => 1,
        'EVAL_PERL' => 0,
        'RELATIVE'  => 0,
        'STAT_TTL'  => 60 * 60 * 24 * 365  # disable cache check
    };

}

sub _preload_template_file {

    my $self = shift;
    my $file = shift;

    my $tt = $self->_get_tt;

    if ( ! $tt ) {
        throw "No Template instance";
    }

    $tt->process( $file, undef, \( my $result ) ) or throw $tt->error;

    return;

}

sub _process_template_file {

    my $self       = shift;
    my $file       = shift;
    my $parameters = shift;
    my $options    = shift;

    my $result = '';

    my $tt = $self->_get_tt;

    if ( ! $tt ) {
        throw "No Template instance";
    }

    $tt->process( $file, $parameters, \$result, ( $options ? $options : () ) ) or throw $tt->error;

    return \$result;

}

sub _register {

    my $self        = shift;
    my $application = shift;

    $self->SUPER::_register( $application );

    my $options = $self->_get_options;

    if ( ! exists $options->{'ENCODING'} ) {

        if ( defined $self->_get_template_encoding ) {
            $options->{'ENCODING'} = $self->_get_template_encoding;
        }

    }

    if ( ! exists $options->{'INCLUDE_PATH'} ) {

        if ( defined $self->_get_templates_directory ) {
            $options->{'INCLUDE_PATH'} = $self->_get_templates_directory;
        }

    }

    if ( ! $self->_get_tt ) {
        $self->_set_tt( $self->_create_tt );
    }

    return;

}


1;

__END__

=head1 NAME

GX::View::Template::TT - Template-based view

=head1 SYNOPSIS

    package MyApp::View::Template;
    
    use GX::View::Template::TT;
    
    __PACKAGE__->setup(
        default_content_type => 'text/html',
        default_encoding     => 'utf-8',
        file_extensions      => [ 'tt' ],
        options              => { TRIM => 1 },
        preload              => 1
    );
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::View::Template::TT> class which extends the
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

The following file extensions are associated with L<GX::View::Template::TT>:

=over 4

=item * C<.tt>

=back

=head1 SEE ALSO

=over 4

=item * L<Template>

=item * L<Template::Manual>

=item * L<Template::Tutorial>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
