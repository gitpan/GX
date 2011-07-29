# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Class/Util.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Class::Util;

use strict;
use warnings;

use GX::Exception;
use GX::Meta::Constants qw( REGEX_CLASS_NAME );
use GX::Meta::Util;


# ----------------------------------------------------------------------------------------------------------------------
# Public functions
# ----------------------------------------------------------------------------------------------------------------------

sub class_exists {

    my $class = shift;

    if ( ! defined $class || $class !~ REGEX_CLASS_NAME ) {
        complain "Undefined or invalid class name";
    }

    no strict 'refs';

    while ( my $symbol = each %{"${class}::"} ) {
        return 1 if substr( $symbol, -2, 2 ) ne '::';
    }

    return 0;

}

sub mixin {

    my $class  = shift;
    my @mixins = @_;

    if ( ! defined $class || $class !~ REGEX_CLASS_NAME ) {
        complain "Undefined or invalid class name";
    }

    for my $mixin ( @mixins ) {

        if ( ! defined $mixin || $mixin !~ REGEX_CLASS_NAME ) {
            complain "Undefined or invalid mixin name";
        }

        if ( ! class_exists( $mixin ) && ! GX::Meta::Util::load_module( $mixin ) ) {
            complain "Mixin package \"$mixin\" is empty";
        }

        no strict 'refs';

        for my $symbol ( keys %{"${mixin}::"} ) {
            local *glob = *{"${mixin}::${symbol}"};
            *{"${class}::${symbol}"} = *glob{'CODE'} if *glob{'CODE'};
        }

    }

    return;

}


1;

__END__

=head1 NAME

GX::Class::Util - Utility functions

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides various utility functions.

=head1 FUNCTIONS

=head2 Public Functions

=head3 C<class_exists>

Returns true if the specified class exists, otherwise false.

    $result = class_exists( $class );

=over 4

=item Arguments:

=over 4

=item * C<$class> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<mixin>

Mixes the given classes / packages.

    mixin( $class, @mixins );


=over 4

=item Arguments:

=over 4

=item * C<$class> ( string )

=item * C<@mixins> ( strings )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Class>

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
