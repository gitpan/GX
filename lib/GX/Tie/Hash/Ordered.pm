# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Tie/Hash/Ordered.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Tie::Hash::Ordered;

use strict;
use warnings;

use base 'Tie::Hash';


# ----------------------------------------------------------------------------------------------------------------------
# Standard tie interface
# ----------------------------------------------------------------------------------------------------------------------

sub CLEAR {

    @{$_[0]} = ( {}, [], [], 0 );

    return;

}

sub DELETE {

    my $self = shift;

    if ( defined( my $i = $self->[0]{$_[0]} ) ) {

        for ( $i + 1 .. $#{$self->[1]} ) {
            $self->[0]{$self->[1][$_]}--;
        }

        delete $self->[0]{$_[0]};

        splice @{$self->[1]}, $i, 1;

        return ( splice( @{$self->[2]}, $i, 1 ) )[0];

    }

    return undef;

}

sub EXISTS {

    return exists $_[0]->[0]{$_[1]};

}

sub FETCH {

    return exists $_[0]->[0]{$_[1]} ? $_[0]->[2][ $_[0]->[0]{$_[1]} ] : undef;

}

sub FIRSTKEY {

    if ( @{$_[0][1]} ) {
        $_[0][3] = 1;
        return $_[0][1][0];
    }
    else {
        $_[0][3] = 0;
        return undef;
    }

}

sub NEXTKEY {

    return $_[0][3] <= $#{$_[0][1]} ? $_[0][1][$_[0][3]++] : undef;

}

sub SCALAR {

    return scalar @{$_[0][1]};

}

sub STORE {

    my $self = shift;

    if ( defined( my $i = $self->[0]{$_[0]} ) ) {

        $self->[1][$i] = $_[0];
        $self->[2][$i] = $_[1];

        $self->[0]{$_[0]} = $i;

    }
    else {

        push @{$self->[1]}, $_[0];
        push @{$self->[2]}, $_[1];

        $self->[0]{$_[0]} = $#{$self->[1]};

    }

    return;

}

sub TIEHASH {

    return bless(
        [
            {}, # hash key => index map
            [], # hash keys
            [], # hash values
            0   # iterator offet
        ],
        $_[0]
    );

}


1;

__END__

=head1 NAME

GX::Tie::Hash::Ordered - Ordered hash implementation

=head1 SYNOPSIS

    # Load the class
    use GX::Tie::Hash::Ordered;
    
    # Tie a hash
    tie %hash, 'GX::Tie::Hash::Ordered';

=head1 DESCRIPTION

This module provides the L<GX::Tie::Hash::Ordered> class.

=head1 LIMITATIONS

The current implementation does not support C<< L<weaken()|Scalar::Util/weaken> >>.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
