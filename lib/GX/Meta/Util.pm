# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Util.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Util;

use strict;
use warnings;

use GX::Meta::Constants qw( REGEX_IDENTIFIER REGEX_MODULE_NAME REGEX_PACKAGE_NAME );
use GX::Meta::Exception;

use File::Find ();
use File::Spec ();
use File::Spec::Unix ();


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant UNIX_PATHS => ( $File::Spec::ISA[0] eq 'File::Spec::Unix' ) ? 1 : 0;


# ----------------------------------------------------------------------------------------------------------------------
# Public functions
# ----------------------------------------------------------------------------------------------------------------------

sub eval_code {

    my $code      = shift;
    my $variables = shift;

    if ( ref $code eq 'ARRAY' ) {
        $code = join( "\n", @$code );
    }

    my @EVAL_VARS;

    if ( defined $variables ) {

        my @code;

        my $i = 0;

        while ( my ( $name, $value ) = each %$variables ) {
            push @code, 'my ' . $name . ' = $EVAL_VARS[' . $i++ . '];';
            push @EVAL_VARS, $value;
        }

        $code = join( "\n", @code, $code );

    }

    my $result = eval $code;

    if ( $@ ) {
        die $@ . "\nCode:\n$code\n";
    }

    return $result;

}

sub file_to_module_name {

    my $file = shift;

    if ( ! defined $file ) {
        complain "Missing argument";
    }

    my @path = File::Spec->splitpath( File::Spec->canonpath( $file ) );

    $path[2] =~ s/\.pm$//;

    my $module = join(
        '::',
        File::Spec->splitdir( File::Spec->canonpath( $path[1] ) ),
        $path[2]
    );

    if ( $module !~ REGEX_MODULE_NAME ) {
        complain "Invalid argument (\"$file\" is not a valid module filename)";
    }

    return $module;

}

sub find_module_file {

    my $module = shift;

    my $key = eval { module_inc_key( $module ) };

    if ( $@ ) {
        complain $@;
    }

    for ( @INC ) {

        next if ! defined $_;
        next if ref $_;

        my $path = "$_/$key";

        next unless -f $path;

        return $path if UNIX_PATHS;

        my ( $volume, $directory, $filename ) = File::Spec::Unix->splitpath( $path );
        $directory = File::Spec->catdir( File::Spec->splitdir( $directory ) );

        return File::Spec->catpath( $volume, $directory, $filename );

    }

    return undef;

}

sub find_modules {

    my $search_path = shift;
    my $base_path   = shift;

    return unless -d $search_path;

    if ( ! defined $base_path ) {
        $base_path = $search_path;
    }

    my @files;

    File::Find::find(
        {
            'wanted'   => sub { push @files, $_ if /\.pm$/ },
            'no_chdir' => 1
        },
        $search_path
    );

    my @module_files = grep { defined } map {
        local $@;
        eval { file_to_module_name( File::Spec->abs2rel( $_, $base_path ) ) };
    } @files;

    return @module_files;

}

sub load_module {

    my $module = shift;

    if ( ! defined( $module ) || $module !~ REGEX_MODULE_NAME ) {
        complain "Invalid module name";
    }

    my ( $died, $error );

    {

        local $@;

        eval "require $module; 1;" or do {
            $died  = 1;
            $error = $@;
        };

    }

    if ( $died ) {

        if ( defined wantarray ) {
            my $module_file = join( '/', split( '::', $module ) ) . '.pm';
            return 0 if $error =~ /^Can't locate $module_file in \@INC /;
        }

        complain $error;

    }

    return 1;

}

sub module_inc_file {

    my $module = shift;

    my $value = eval { module_inc_value( $module ) };

    if ( $@ ) {
        complain $@;
    }

    return ref( $value ) ? undef : $value;

}

sub module_inc_key {

    my $module = shift;

    if ( ! defined( $module ) || $module !~ REGEX_MODULE_NAME ) {
        complain "Invalid module name";
    }

    return join( '/', split( /::/, $module ) ) . '.pm'

}

sub module_inc_value {

    my $module = shift;

    my $key = eval { module_inc_key( $module ) };

    if ( $@ ) {
        complain $@;
    }

    if ( @_ ) {
        $INC{$key} = $_[0];
    }

    return $INC{$key};

}

sub module_is_installed {

    my $module = shift;

    my $key = eval { module_inc_key( $module ) };

    if ( $@ ) {
        complain $@;
    }

    for ( @INC ) {
        next if ! defined( $_ ) || ref( $_ );
        return 1 if -f "$_/$key";
    }

    return 0;

}

sub module_is_loaded {

    my $module = shift;

    my $key = eval { module_inc_key( $module ) };

    if ( $@ ) {
        complain $@;
    }

    return exists( $INC{$key} ) ? 1 : 0;

}

sub module_to_file_name {

    my $module = shift;

    if ( ! defined( $module ) || $module !~ REGEX_MODULE_NAME ) {
        complain "Invalid module name";
    }

    return File::Spec->catfile( split( /::/, $module ) ) . '.pm';

}

sub subpackage_names {

    my $package = shift;

    if ( ! defined( $package ) || $package !~ REGEX_PACKAGE_NAME ) {
        complain "Invalid package name";
    }

    no strict 'refs';

    return grep { substr( $_, -2, 2, '' ) eq '::' && $_ =~ REGEX_IDENTIFIER } keys %{"${package}::"};

}

sub unload_module {

    my $module = shift;

    if ( ! defined( $module ) || $module !~ REGEX_MODULE_NAME ) {
        complain "Invalid module name";
    }

    wipe_package( $module );

    delete $INC{ module_inc_key( $module ) };

    return;

}

sub wipe_package {

    my $package = shift;

    if ( ! defined( $package ) || $package !~ REGEX_PACKAGE_NAME ) {
        complain "Invalid package name";
    }

    # NOTE: Symbol::delete_package() DOES NOT work!

    no strict 'refs';

    my $symbol_table = \%{"${package}::"};

    for my $symbol_name ( keys %$symbol_table ) {

        # Skip sub-packages
        next if substr( $symbol_name, -2 ) eq '::';

        my $full_name = "${package}::${symbol_name}";

        if ( *{$full_name}{'SCALAR'} ) {
            my $scalar;
            *{$full_name} = \$scalar;
            undef $$full_name;
        }

        if ( *{$full_name}{'ARRAY'} ) {
            *{$full_name} = [];
            undef @$full_name;
        }

        if ( *{$full_name}{'HASH'} ) {
            *{$full_name} = {};
            undef %$full_name;
        }

        if ( *{$full_name}{'CODE'} ) {

            no warnings 'redefine';

            if ( defined( my $prototype = prototype $full_name ) ) {

                local $SIG{__WARN__} = sub {
                    return if $_[0] =~ /^Constant subroutine [\w:]+ redefined at/;
                    return CORE::warn( @_ );
                };

                *{$full_name} = eval "sub ($prototype) {}";

            }
            else {
                *{$full_name} = sub {};
            }

            undef &$full_name;

        }

        delete $symbol_table->{$symbol_name};

    }

    return;

}


1;

__END__

=head1 NAME

GX::Meta::Util - Utility functions

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides various utility functions.

=head1 FUNCTIONS

=head2 Public Functions

=head3 C<eval_code>

Compiles the given Perl source code and returns the result.

    $result = eval_code( $source, $variables );

=over 4

=item Arguments:

=over 4

=item * C<$source> ( string )

=item * C<$variables> ( C<HASH> reference ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$result> ( scalar )

=back

=back

=head3 C<file_to_module_name>

Returns the module name for the given filename.

    $module = file_to_module_name( $file );

=over 4

=item Arguments:

=over 4

=item * C<$file> ( string )

=back

=item Returns:

=over 4

=item * C<$module> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<find_module_file>

Returns the absolute path to the file the specified module would currently be
loaded from, or C<undef> if the module file cannot be found in any of the
C<@INC> paths.

    $path = find_module_file( $module );

=over 4

=item Arguments:

=over 4

=item * C<$module> ( string )

=back

=item Returns:

=over 4

=item * C<$path> ( string | C<undef>  )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<find_modules>

Returns a list with the names of the modules located in the specified
directory.

    @modules = find_modules( $directory, $base_directory );

=over 4

=item Arguments:

=over 4

=item * C<$directory> ( string )

=item * C<$base_directory> ( string ) [ optional ]

=back

=item Returns:

=over 4

=item * C<@modules> ( strings )

=back

=back

=head3 C<load_module>

Tries to load the specified module, returning true on success and false on
failure. Compile errors are not trapped.

    $result = load_module( $module );

=over 4

=item Arguments:

=over 4

=item * C<$module> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

In void context, C<load_module()> throws a L<GX::Meta::Exception> if the
module cannot be loaded.

    load_module( $module );

=over 4

=item Arguments:

=over 4

=item * C<$module> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<module_inc_file>

Returns the absolute path to the file the specified module was loaded from, or
C<undef> if the module is not loaded or was not loaded from a file.

    $path = module_inc_file( $module );

=over 4

=item Arguments:

=over 4

=item * C<$module> ( string )

=back

=item Returns:

=over 4

=item * C<$path> ( string | C<undef> )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<module_inc_key>

Returns the C<%INC> key for the specified module.

    $key = module_inc_key( $module );

=over 4

=item Arguments:

=over 4

=item * C<$module> ( string )

=back

=item Returns:

=over 4

=item * C<$key> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<module_inc_value>

Returns / sets the C<%INC> value for the specified module.

    $value = module_inc_value( $module );
    $value = module_inc_value( $module, $value );

=over 4

=item Arguments:

=over 4

=item * C<$module> ( string )

=item * C<$value> ( string ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<module_is_installed>

Returns true if the specified module is installed, otherwise false.

    $result = module_is_installed( $module );

=over 4

=item Arguments:

=over 4

=item * C<$module> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<module_is_loaded>

Returns true if the specified module is loaded, otherwise false.

    $result = module_is_loaded( $module );

=over 4

=item Arguments:

=over 4

=item * C<$module> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<module_to_file_name>

Returns the localized filename for the specified module.

    $file = module_to_file_name( $module );

=over 4

=item Arguments:

=over 4

=item * C<$module> ( string )

=back

=item Returns:

=over 4

=item * C<$file> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<subpackage_names>

Returns a list with the (unqualified) names of the subpackages of the
specified package.

    @names = subpackage_names( $package );

=over 4

=item Arguments:

=over 4

=item * C<$package> ( string )

=back

=item Returns:

=over 4

=item * C<@names> ( strings )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<unload_module>

Unloads the specified module.

    unload_module( $module );

=over 4

=item Arguments:

=over 4

=item * C<$module> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<wipe_package>

Undefines every symbol that lives in the symbol table of the specified
package. Danger, Will Robinson!

    wipe_package( $package );

=over 4

=item Arguments:

=over 4

=item * C<$package> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

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
