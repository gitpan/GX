# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Parser/Body/URLEncoded.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Parser::Body::URLEncoded;

use GX::HTTP::Parameters;


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

    my $self = shift;
    my $body = shift;

    return { parameters => GX::HTTP::Parameters->parse( $body->as_string ) };

}


1;

__END__

=head1 NAME

GX::HTTP::Parser::Body::URLEncoded - HTTP message body parser class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Parser::Body::URLEncoded> class which
extends the L<GX::HTTP::Parser::Body> class.

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
