# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Parser/Body/MultiPart.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Parser::Body::MultiPart;

use GX::Exception;
use GX::HTTP::Constants qw( CRLF CRLFCRLF );
use GX::HTTP::Headers;
use GX::HTTP::Parameters;
use GX::HTTP::Upload;
use GX::HTTP::Uploads;

use File::Temp ();


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant {
    BUFFER_SIZE   => 8192,
    STATE_PARSING => 1,
    STATE_DONE    => 2
};


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::HTTP::Parser::Body';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub parse {

    my $self        = shift;
    my $body        = shift;
    my $buffer_size = shift || BUFFER_SIZE;

    $self->{'boundary'} or return;

    my $content = $body->open or return;

    my $context = {
        'buffer' => CRLF,
        'state'  => STATE_PARSING,
        'parse'  => \&_parse_boundary,
        'part'   => undef,
        'result' => {}
    };

    READ:
    while ( $content->read( my $buffer, $buffer_size ) ) {

        $context->{'buffer'} .= $buffer;

        while ( $context->{'state'} == STATE_PARSING ) {
            $context->{'parse'}->( $self, $context ) or next READ;
        }

        last READ;

    }

    return $context->{'state'} == STATE_DONE ? $context->{'result'} : undef;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _parse_body {

    my $self    = shift;
    my $context = shift;

    my $part = $context->{'part'};

    my $index = index( $context->{'buffer'}, $self->{'delimiter'} );

    if ( $index < 0 ) {

        if ( $part->{'fh'} ) {
            $part->{'fh'}->print( substr( $context->{'buffer'}, 0, -76, '' ) );
        }
        else {
            $part->{'data'} .= substr( $context->{'buffer'}, 0, -76, '' );
        }

        return 0;

    }

    if ( $part->{'fh'} ) {

        my $fh = $part->{'fh'};

        $fh->print( substr( $context->{'buffer'}, 0, $index, '' ) );
        $fh->flush;

        my $upload = GX::HTTP::Upload->new(
            file     => $fh->filename,
            filename => $part->{'filename'},
            name     => $part->{'name'},
            headers  => $part->{'headers'},
            cleanup  => 1
        );

        $fh->unlink_on_destroy( 0 );

        %$part = ( 'upload' => $upload );

        $context->{'result'}{'uploads'} ||= GX::HTTP::Uploads->new;
        $context->{'result'}{'uploads'}->add( $upload );

    }
    else {

        $part->{'data'} .= substr( $context->{'buffer'}, 0, $index, '' );

        $context->{'result'}{'parameters'} ||= GX::HTTP::Parameters->new;
        $context->{'result'}{'parameters'}->add( $part->{'name'} => $part->{'data'} );

    }

    $context->{'part'}  = undef;
    $context->{'parse'} = \&_parse_boundary;

    return 1;

}

sub _parse_boundary {

    my $self    = shift;
    my $context = shift;

    my $index = index( $context->{'buffer'}, $self->{'delimiter'} );

    if ( $index < 0 ) {
        substr( $context->{'buffer'}, 0, -76, '' );
        return 0;
    }

    if ( $index > 0 ) {
        substr( $context->{'buffer'}, 0, $index, '' );
    }

    if ( length( $context->{'buffer'} ) < length( $self->{'delimiter_end'} ) ) {
        return 0;
    }

    if ( index( $context->{'buffer'}, $self->{'delimiter_end'} ) == 0 ) {
        $context->{'state'} = STATE_DONE;
        $context->{'parse'} = undef;
        return 1;
    }

    $index = index( $context->{'buffer'}, CRLF, 2 );

    if ( $index < 0 ) {
        return 0;
    }

    substr( $context->{'buffer'}, 0, $index + 2, '' );

    push( @{$context->{'result'}{'parts'}}, $context->{'part'} = {} );

    $context->{'parse'} = \&_parse_header;

    return 1;

}

sub _parse_header {

    my $self    = shift;
    my $context = shift;

    if ( length( $context->{'buffer'} ) < length( $self->{'delimiter'} ) ) {
        return 0;
    }

    # No header
    if ( substr( $context->{'buffer'}, 0, 2 ) eq CRLF ) {

        if ( substr( $context->{'buffer'}, 0, length( $self->{'delimiter'} ) ) eq $self->{'delimiter'} ) {
            $context->{'parse'} = \&_parse_boundary;
        }
        else {
            substr( $context->{'buffer'}, 0, 2, '' );
            $context->{'parse'} = \&_parse_body;
        }

        return 1;

    }

    my $index = index( $context->{'buffer'}, CRLFCRLF );

    if ( $index < 0 ) {
        return 0;
    }

    if ( length( $context->{'buffer'} ) < $index + length( $self->{'delimiter'} ) ) {
        return 0;
    }

    my $part = $context->{'part'};

    $part->{'headers'} = GX::HTTP::Headers->parse( substr( $context->{'buffer'}, 0, $index ) );

    substr( $context->{'buffer'}, 0, $index + 2, '' );

    my $content_disposition = $part->{'headers'}->content_disposition;

    if ( $content_disposition && $content_disposition =~ / name="?([^";\s]+)"?/i ) {
        $part->{'name'} = $1;
    }
    else {
        # Discard this part
        $context->{'parse'} = \&_parse_boundary;
        return 1;
    }

    if ( $content_disposition =~ / filename="?([^"]*)"?/i ) {

        if ( $self->{'discard_uploads'} ) {
            # Discard this part
            $context->{'parse'} = \&_parse_boundary;
            return 1;
        }

        $part->{'filename'} = $1;

        $part->{'fh'} = File::Temp->new(
            UNLINK => 1,
            $self->{'tmp_dir'} ? ( DIR => $self->{'tmp_dir'} ) : ()
        ) or throw "Cannot create temporary file ($!)";

    }

    if ( substr( $context->{'buffer'}, 0, length( $self->{'delimiter'} ) ) eq $self->{'delimiter'} ) {
        $context->{'parse'} = \&_parse_boundary;
    }
    else {
        substr( $context->{'buffer'}, 0, 2, '' );
        $context->{'parse'} = \&_parse_body;
    }

    return 1;

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub __initialize {

    my $self = shift;
    my $args = shift;

    if ( $args->{'content_type'} && $args->{'content_type'} =~ /boundary="?([^";,]+)"?/ ) {
        $self->{'boundary'}      = $1;
        $self->{'delimiter'}     = CRLF . '--' . $1;
        $self->{'delimiter_end'} = CRLF . '--' . $1 . '--';
    }

    return;

}


1;

__END__

=head1 NAME

GX::HTTP::Parser::Body::MultiPart - HTTP message body parser class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Parser::Body::MultiPart> class which
extends the L<GX::HTTP::Parser::Body> class.

=head1 SEE ALSO

=over 4

=item * L<RFC 2388|http://tools.ietf.org/html/rfc2388>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
