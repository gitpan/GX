# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Parser/Body.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Parser::Body;

use GX::Exception;


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'discard_uploads' => (
    isa => 'Bool'
);

has 'tmp_dir' => (
    isa => 'Scalar'
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Subclasses
# ----------------------------------------------------------------------------------------------------------------------

my %CONTENT_TYPE_TO_CLASS_MAP = (
    'application/x-www-form-urlencoded' => 'GX::HTTP::Parser::Body::URLEncoded',
    'multipart/form-data'               => 'GX::HTTP::Parser::Body::MultiPart'
);

{

    eval "require $_" or throw $@ for values %CONTENT_TYPE_TO_CLASS_MAP;

}


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;
    my %args  = ( @_ == 1 ) ? ( content_type => $_[0] ) : @_;

    if ( $class eq __PACKAGE__ ) {

        if ( defined $args{'content_type'} ) {

            my $content_type = lc $args{'content_type'};

            for ( keys %CONTENT_TYPE_TO_CLASS_MAP ) {

                if ( index( $content_type, $_ ) >= 0 ) {
                    return $CONTENT_TYPE_TO_CLASS_MAP{$_}->SUPER::new( %args );
                }

            }

        }

        return undef;

    }

    return $class->SUPER::new( %args );

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub parse {

    return undef;

}


1;

__END__

=head1 NAME

GX::HTTP::Parser::Body - HTTP message body parser base class

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Parser::Body> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new parser object or C<undef> if the specified content type is not
supported.

    $parser = GX::HTTP::Parser::Body->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<content_type> ( string ) [ required ]

Supported content types:

=over 4

=item * C<application/x-www-form-urlencoded>

=item * C<multipart/form-data>

=back

=item * C<discard_uploads> ( bool )

A boolean flag indicating whether or not to discard uploads. Defaults to
false.

=item * C<tmp_dir> ( string )

A path to the directory that should be used to store temporary data.

=back

=item Returns:

=over 4

=item * C<$parser> ( L<GX::HTTP::Parser::Body> object | C<undef> )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<parse>

Takes a body object, parses its content and returns a reference to a hash with
the result, or returns C<undef> if the body cannot be parsed.

    $result = $parser->parse( $body );

=over 4

=item Arguments:

=over 4

=item * C<$body> ( L<GX::HTTP::Body> object )

=back

=item Returns:

=over 4

=item * C<$result> ( C<HASH> reference | C<undef> )

    $result = {
        parameters => $parameters,  # GX::HTTP::Parameters object
        parts      => \@parts,      # ARRAY reference containing HASH references
        uploads    => $uploads      # GX::HTTP::Uploads object
    };

Any value of the result hash may be C<undef>.

=back

=back

=head1 SEE ALSO

=over 4

=item * L<GX::HTTP::Parser::Body::MultiPart>

=item * L<GX::HTTP::Parser::Body::URLEncoded>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
