# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Route.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Route;

use GX::Exception;
use GX::Route::Match;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub action {

    complain "Abstract method";

}

sub construct_path {

    complain "Abstract method";

}

sub construct_uri {

    complain "Abstract method";

}

sub is_reversible {

    complain "Abstract method";

}

sub match {

    complain "Abstract method";

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _construct_uri {

    my $self = shift;
    my %args = @_;

    my $uri;

    if ( ! defined $args{'scheme'} ) {
        $args{'scheme'} = 'http';
    }

    $uri = $args{'scheme'} . '://';

    if ( defined $args{'host'} ) {
        $uri .= $args{'host'};
    }
    else {
        throw "No host specified";
    }

    if ( defined $args{'port'} ) {

        if ( $args{'scheme'} eq 'http' ) {

            if ( $args{'port'} != 80 ) {
                $uri .= ':' . $args{'port'};
            }

        }
        elsif ( $args{'scheme'} eq 'https' ) {

            if ( $args{'port'} != 443 ) {
                $uri .= ':' . $args{'port'};
            }

        }

    }

    if ( defined $args{'path'} ) {
        $uri .= $args{'path'};
    }
    else {
        throw "No path specified";
    }

    if ( defined $args{'query'} ) {
        $uri .= '?' . $args{'query'};
    }

    if ( defined $args{'fragment'} ) {
        $uri .= '#' . $args{'fragment'};
    }

    return $uri;

}


1;

__END__

=head1 NAME

GX::Route - Base class for routes

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Route> class which extends the
L<GX::Class::Object> class.


=head1 SUBCLASSES

The following classes inherit directly from L<GX::Route>:

=over 4

=item * L<GX::Route::Dynamic>

=item * L<GX::Route::Static>

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Route::Match>

=item * L<GX::Router>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
