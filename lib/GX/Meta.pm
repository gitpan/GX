# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta;

use strict;
use warnings;


# ----------------------------------------------------------------------------------------------------------------------
# GX::Meta core modules
# ----------------------------------------------------------------------------------------------------------------------

require GX::Meta::Accessor;
require GX::Meta::Attribute;
require GX::Meta::Class;
require GX::Meta::Constants;
require GX::Meta::Delegator;
require GX::Meta::Exception;
require GX::Meta::Method;
require GX::Meta::Module;
require GX::Meta::Package;
require GX::Meta::Util;


1;

__END__

=head1 NAME

GX::Meta - A metaclass system for Perl

=head1 SYNOPSIS

    # Load the core GX::Meta modules
    use GX::Meta;

=head1 DESCRIPTION

This module loads the core GX::Meta modules:

=over 4

=item * L<GX::Meta::Accessor>

=item * L<GX::Meta::Attribute>

=item * L<GX::Meta::Class>

=item * L<GX::Meta::Constants>

=item * L<GX::Meta::Delegator>

=item * L<GX::Meta::Exception>

=item * L<GX::Meta::Method>

=item * L<GX::Meta::Module>

=item * L<GX::Meta::Package>

=item * L<GX::Meta::Util>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
