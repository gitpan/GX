# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/File/Watcher.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::File::Watcher;

use GX::Exception;

use File::Find ();
use File::Spec ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'directories' => (
    isa        => 'Hash',
    initialize => 1,
    accessors  => {
        'directories'  => { type => 'get_keys' },
        '_directories' => { type => 'get_reference' }
    }
);

has 'files' => (
    isa        => 'Hash',
    initialize => 1,
    accessors  => {
        'files'  => { type => 'get_keys' },
        '_files' => { type => 'get_reference' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub find_changes {

    my $self = shift;

    my $fast_mode = wantarray ? 0 : 1;

    my $directories = $self->_directories;
    my $files       = $self->_files;

    my @changes;

    CHECK:
    {

        while ( my ( $directory, $info ) = each %$directories ) {

            if ( ! -d $directory ) {
                push @changes, $directory;
                $fast_mode ? last CHECK : next;
            }

            my @stat = stat $directory or complain "Cannot stat \"$directory\"";

            if ( $stat[9] != $info->[0] ) {
                push @changes, $directory;
                $fast_mode ? last CHECK : next;
            }

            opendir DIR, $directory or complain "Cannot open \"$directory\" ($!)";
            my @content = readdir DIR;
            closedir DIR;

            if ( @content != $info->[1] ) {
                push @changes, $directory;
                $fast_mode ? last CHECK : next;
            }

        }

        while ( my ( $file, $info ) = each %$files ) {

            if ( ! -f $file ) {
                push @changes, $file;
                $fast_mode ? last CHECK : next;
            }

            my @stat = stat $file or complain "Cannot stat \"$file\"";

            if ( $stat[9] != $info->[0] || $stat[7] != $info->[1] ) {
                push @changes, $file;
                $fast_mode ? last CHECK : next;
            }

        }

    }

    if ( $fast_mode ) {
        keys %$directories;
        keys %$files;
        return @changes ? 1 : 0;
    }
    else {
        return @changes;
    }

}

sub watch {

    my $self = shift;

    my @files;
    my @directories;

    for ( @_ ) {
        -d && push( @directories, $_ ) && next;
        -f && push( @files, $_ )       && next;
        complain "Invalid argument";
    }

    if ( @directories ) {

        File::Find::find(
            {
                wanted => sub {
                    -f && push( @files, $_ )       && return;
                    -d && push( @directories, $_ ) && return;
                },
                no_chdir => 1
            },
            @directories
        )

    }

    my $directories = $self->_directories;

    for my $directory ( map { File::Spec->canonpath( $_ ) } @directories ) {

        my @stat = stat $directory or complain "Cannot stat \"$directory\"";

        opendir DIR, $directory or complain "Cannot open \"$directory\" ($!)";
        my @content = readdir DIR;
        closedir DIR;

        $directories->{$directory} = [ $stat[9], scalar @content ];

    }

    my $files = $self->_files;

    for my $file ( map { File::Spec->canonpath( $_ ) } @files ) {
        my @stat = stat $file or complain "Cannot stat \"$file\"";
        $files->{$file} = [ $stat[9], $stat[7] ];
    }

    return;

}


1;

__END__

=head1 NAME

GX::File::Watcher - Filesystem watcher

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::File::Watcher> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::File::Watcher> object.

    $watcher = GX::File::Watcher->new;

=over 4

=item Returns:

=over 4

=item * C<$watcher> ( L<GX::File::Watcher> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<directories>

Returns the monitored directory paths.

    @directories = $watcher->directories;

=over 4

=item Returns:

=over 4

=item * C<@directories> ( strings )

=back

=back

=head3 C<files>

Returns the monitored file paths.

    @files = $watcher->files;

=over 4

=item Returns:

=over 4

=item * C<@files> ( strings )

=back

=back

=head3 C<find_changes>

Checks the monitored files and directories for changes. When called in list
context, C<find_changes()> returns a list with the paths to the modified (or
deleted) files and directories.

    @paths = $watcher->find_changes;

=over 4

=item Returns:

=over 4

=item * C<@paths> ( strings )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

In scalar context, C<find_changes()> returns true if at least one of the
monitored files and directories has been modified (or deleted), otherwise
false.

    $result = $watcher->find_changes;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<watch>

Adds the given file / directory paths to the watchlist.

    $watcher->watch( @paths );

=over 4

=item Arguments:

=over 4

=item * C<@paths> ( strings )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
