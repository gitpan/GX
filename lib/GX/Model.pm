# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Model.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Model;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Component::Singleton';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Private Methods
# ----------------------------------------------------------------------------------------------------------------------

sub _validate_class_name {

    return $_[1] =~ /^(?:[_a-zA-Z]\w*::)+?Model(?:::[_a-zA-Z]\w*)+$/;

}


1;

__END__

=head1 NAME

GX::Model - Model component base class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Model> class which extends the
L<GX::Component::Singleton> class.

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
