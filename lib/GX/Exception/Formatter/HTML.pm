# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Exception/Formatter/HTML.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Exception::Formatter::HTML;

use GX::HTML::Util qw( escape_html );

use Scalar::Util qw( blessed );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub format {

    my $self      = ref $_[0] ? shift : shift->new;
    my $exception = shift;

    return unless blessed $exception && $exception->isa( 'GX::Exception' );

    my @html;

    push @html, '<div class="exception">';

    push @html, '<h1>' . ref( $exception ) . '</h1>';

    push @html,
        '<div class="message">',
        '<code>' . join( '<br />', split( /\n/, escape_html( $exception->as_string( 0 ) ) ) ) . '</code>',
        '</div>';

    my @subexceptions;

    for ( my $subexception = $exception->subexception; $subexception; $subexception = $subexception->subexception ) {
        push @subexceptions, $subexception;
    }

    if ( @subexceptions ) {

        push @html,
            '<div class="subexceptions">',
            '<h2>Subexceptions</h2>';

        for my $subexception ( @subexceptions ) {
            push @html,
                '<div class="message">',
                '<code>' . join( '<br />', split( /\n/, escape_html( $subexception->as_string( 0 ) ) ) ) . '</code>',
                '</div>';
        }

        push @html, '</div>';

    }

    if ( $exception->stack_trace ) {

        push @html,
            '<div class="stack_trace">',
            '<h2>Stack trace</h2>',
            '<ol>';

        for my $frame ( $exception->stack_trace ) {

            my $subroutine = $frame->subroutine or next;
            my $filename   = $frame->filename   or next;
            my $line       = $frame->line       or next;

            push @html, '<li>';

            if ( $subroutine eq '(eval)' ) {
                push @html, sprintf(
                    "<p><strong>(eval)</strong> in <strong>%s</strong> at line <strong>%s</strong></p>",
                    escape_html( $filename ),
                    escape_html( $line )
                );
            }
            else {
                push @html, sprintf(
                    "<p><strong>%s</strong> called in <strong>%s</strong> at line <strong>%s</strong></p>",
                    escape_html( $subroutine ),
                    escape_html( $filename ),
                    escape_html( $line )
                );
            }

            # We don't know the encoding of the source file, so we'll have to guess ...
            if ( -f $filename && open( my $fh, '<:encoding(utf8)', $filename ) ) {

                my $first_line = $line - 5;
                my $last_line  = $line + 5;

                $first_line = 1 if $first_line < 1;

                push @html,
                    '<div class="viewport">',
                    '<table class="source" summary="' . escape_html( $filename ) . '">',
                    '<tbody>';

                my $current_line = 0;

                while ( <$fh> ) {

                    $current_line++;

                    next if $current_line < $first_line;
                    last if $current_line > $last_line;

                    my $source = $_;

                    chomp( $source );
                    $source = escape_html( $source );
                    $source =~ s/\s/&nbsp;/g;

                    push @html,
                        '<tr' . ( $current_line == $line ? ' class="highlight"' : '' ) . '>',
                        '<td class="line"><code>' . $current_line . '</code></td>',
                        '<td class="code"><code>' . $source . '</code></td>',
                        '</tr>';

                }

                close $fh;

                push @html,
                    '</tbody>',
                    '</table>',
                    '</div>';

            }

            push @html, '</li>';
            
        }

        push @html,
            '</ol>',
            '</div>';

    }

    push @html, '</div>';

    return join( "\n", @html ) . "\n";

}


1;

__END__

=head1 NAME

GX::Exception::Formatter::HTML - Helper class for rendering exceptions as HTML

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Exception::Formatter::HTML> class which extends
the L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 new

Returns a new L<GX::Exception::Formatter::HTML> object.

    $formatter = GX::Exception::Formatter::HTML->new;

=over 4

=item Returns:

=over 4

=item * C<$formatter> ( L<GX::Exception::Formatter::HTML> object )

=back

=back

=head2 Public Methods

=head3 format

Renders the given exception object as HTML.

    $html = $formatter->format( $exception );

=over 4

=item Arguments:

=over 4

=item * C<$exception> ( L<GX::Exception> object )

=back

=item Returns:

=over 4

=item * C<$html> ( string )

=back

=back

This method can also be called as a class method.

=head1 SEE ALSO

=over 4

=item * L<GX::Exception>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
