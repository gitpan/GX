# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Script/Build.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Script::Build;

use Config qw( %Config );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Script';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Class data
# ----------------------------------------------------------------------------------------------------------------------

my %TEMPLATES;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub load_template {

    my $self          = shift;
    my $template_name = shift;

    my $package = ref $self;

    if ( ! $TEMPLATES{$package} ) {

        my %templates;

        my $data = do {
            no strict 'refs';
            defined *{"${package}::DATA"} && *{"${package}::DATA"}{'GLOB'};
        } or return undef;

        my $template_name;

        for ( <$data> ) {

            my $line = $_;

            utf8::decode( $line );

            if ( $line =~ /^@@ (\w+)/ ) {
                $template_name = $1;
                $templates{$template_name} = '';
                next;
            }

            $template_name or next;

            $templates{$template_name} .= $line;

        }

        $TEMPLATES{$package} = \%templates;

    }

    return $TEMPLATES{$package}{$template_name};

}

sub render_template {

    my $self                = shift;
    my $template_name       = shift;
    my $template_parameters = shift;
    my $output_file         = shift;

    my $template = $self->load_template( $template_name );

    if ( ! defined $template ) {
        die "Template \"$template_name\" does not exist";
    }

    $template_parameters ||= {};

    $template_parameters->{'shebang'}           ||= "#!$Config{perlpath}";
    $template_parameters->{'application_class'} ||= $self->application_class;

    while ( my ( $key, $value ) = each %$template_parameters ) {
        next unless defined $value;
        $key = quotemeta $key;
        $template =~ s/\[% $key %\]/$value/eg;
    }

    if ( defined $output_file ) {
        utf8::encode( $template );
        return $self->create_file( $output_file, $template );
    }

    return $template;

}


1;

__END__

=head1 NAME

GX::Script::Build - Script class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Script::Build> class which extends the
L<GX::Script> class.

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
