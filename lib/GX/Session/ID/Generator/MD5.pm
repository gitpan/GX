# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Session/ID/Generator/MD5.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Session::ID::Generator::MD5;

use Digest::MD5 ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Session::ID::Generator';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub generate_id {

    return Digest::MD5::md5_hex( rand(), $_[0], time(), $$ );

}

sub validate_id {

    return defined $_[1] && $_[1] =~ /^[0-9a-fA-F]{32}$/ ? 1 : 0;

}


1;

__END__

=head1 NAME

GX::Session::ID::Generator::MD5 - Default session ID generator

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Session::ID::Generator::MD5> class which
extends the L<GX::Session::ID::Generator> class.

=head1 METHODS

See L<GX::Session::ID::Generator>.

=head1 SEE ALSO

=over 4

=item * L<GX::Session>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
