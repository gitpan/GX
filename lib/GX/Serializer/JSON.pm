# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Serializer/JSON.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Serializer::JSON;

use GX::Exception ();

use JSON ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Serializer';

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub serialize {

    my $self = shift;
    my $data = shift;

    my $string = eval { JSON::encode_json( $data ) };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot serialize data",
            subexception => $@
        );
    }

    return $string;

}

sub unserialize {

    my $self   = shift;
    my $string = shift;

    my $data = eval { JSON::decode_json( $string ) };

    if ( $@ ) {
        GX::Exception->complain(
            message      => "Cannot unserialize data",
            subexception => $@
        );
    }

    return $data;

}


1;

__END__

=head1 NAME

GX::Serializer::JSON - JSON-based serializer

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Serializer::JSON> class which extends the
L<GX::Serializer> class.

=head1 METHODS

See L<GX::Serializer>.

=head1 SEE ALSO

=over 4

=item * L<JSON>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
