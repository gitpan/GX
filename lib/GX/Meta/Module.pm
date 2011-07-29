# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Module.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Module;

use strict;
use warnings;

use GX::Meta::Constants qw( REGEX_MODULE_NAME );
use GX::Meta::Exception;
use GX::Meta::Util;


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { $_[0]->{'name'} },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;
    my %args  = ( @_ == 1 ) ? ( 'name' => $_[0] ) : @_;

    if ( ! defined $args{'name'} ) {
        complain "Missing argument (\"name\")";
    }

    if ( $args{'name'} !~ REGEX_MODULE_NAME ) {
        complain "Invalid argument (\"$args{'name'}\" is not a valid module name)";
    }

    return bless {
        'name'    => $args{'name'},
        'inc_key' => GX::Meta::Util::module_inc_key( $args{'name'} )
    }, $class;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub filename {

    return GX::Meta::Util::module_to_file_name( $_[0]->{'name'} );

}

sub find_file {

    return GX::Meta::Util::find_module_file( $_[0]->{'name'} );

}

sub inc_file {

    return GX::Meta::Util::module_inc_file( $_[0]->{'name'} );

}

sub inc_key {

    return $_[0]->{'inc_key'};

}

sub inc_value {

    return GX::Meta::Util::module_inc_value( shift->{'name'}, @_ );

}

sub is_installed {

    return GX::Meta::Util::module_is_installed( $_[0]->{'name'} );

}

sub is_loaded {

    return GX::Meta::Util::module_is_loaded( $_[0]->{'name'} );

}

sub name {

    return $_[0]->{'name'};

}


1;

__END__

=head1 NAME

GX::Meta::Module - Module metaclass 

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Module> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Meta::Module> metaobject.

    $module = GX::Meta::Module->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<name> ( string ) [ required ]

The name of the module, for example "My::Module".

=back

=item Returns:

=over 4

=item * C<$module> ( L<GX::Meta::Module> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

Alternative syntax:

    $module = GX::Meta::Module->new( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

The name of the module, for example "My::Module".

=back

=item Returns:

=over 4

=item * C<$module> ( L<GX::Meta::Module> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head2 Public Methods

=head3 C<filename>

Returns the localized name of the module file, for example "My/Module.pm" on a
UNIX system.

    $filename = $module->filename;

=over 4

=item Returns:

=over 4

=item * C<$filename> ( string )

=back

=back

=head3 C<find_file>

Returns the absolute path to the file the module would currently be loaded
from, or C<undef> if the module file cannot be found in any of the C<@INC>
paths.

    $path = $module->find_file;

=over 4

=item Returns:

=over 4

=item * C<$path> ( string | C<undef> )

=back

=back

=head3 C<inc_file>

Returns the absolute path to the file the module was loaded from, or C<undef>
if the module is not loaded or was not loaded from a file.

    $path = $module->inc_file;

=over 4

=item Returns:

=over 4

=item * C<$path> ( string | C<undef> )

=back

=back

=head3 C<inc_key>

Returns the C<%INC> key for the module.

    $key = $module->inc_key;

=over 4

=item Returns:

=over 4

=item * C<$key> ( string )

=back

=back

=head3 C<inc_value>

Returns / sets the C<%INC> value for the module.

    $value = $module->inc_value;
    $value = $module->inc_value( $value );

=over 4

=item Arguments:

=over 4

=item * C<$value> ( scalar ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

=head3 C<is_installed>

Returns true if the module is installed, otherwise false.

    $result = $module->is_installed;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_loaded>

Returns true if the module is loaded, otherwise false.

    $result = $module->is_loaded;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<name>

Returns the name of the module, for example "My::Module".

    $name = $module->name;

=over 4

=item Returns:

=over 4

=item * C<$name> ( string )

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Meta>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
