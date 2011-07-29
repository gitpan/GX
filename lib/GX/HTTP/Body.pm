# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Body.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Body;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

build;


1;

__END__

=head1 NAME

GX::HTTP::Body - HTTP message body base class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Body> class which extends the
L<GX::Class::Object> class.

=head1 SUBCLASSES

The following classes inherit directly from L<GX::HTTP::Body>:

=over 4

=item * L<GX::HTTP::Body::File>

=item * L<GX::HTTP::Body::Scalar>

=item * L<GX::HTTP::Body::Stream>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
