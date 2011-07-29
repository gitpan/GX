# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Headers.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Headers;

use GX::Exception;
use GX::HTTP::Constants qw( CRLF CRLFSP REGEX_CRLF );

use Storable ();


# ----------------------------------------------------------------------------------------------------------------------
# Header fields (see RFC 2616)
# ----------------------------------------------------------------------------------------------------------------------

use constant GENERAL_HEADERS => qw(
    Cache-Control
    Connection
    Date
    Pragma
    Trailer
    Transfer-Encoding
    Upgrade
    Via
    Warning
);

use constant REQUEST_HEADERS => qw(
    Accept
    Accept-Charset
    Accept-Encoding
    Accept-Language
    Authorization
    Expect
    From
    Host
    If-Match
    If-Modified-Since
    If-None-Match
    If-Range
    If-Unmodified-Since
    Max-Forwards
    Proxy-Authorization
    Range
    Referer
    TE
    User-Agent
);

use constant RESPONSE_HEADERS => qw(
    Accept-Ranges
    Age
    ETag
    Location
    Proxy-Authenticate
    Retry-After
    Server
    Vary
    WWW-Authenticate
);

use constant ENTITY_HEADERS => qw(
    Allow
    Content-Encoding
    Content-Language
    Content-Length
    Content-Location
    Content-MD5
    Content-Range
    Content-Type
    Expires
    Last-Modified
);

my %FIELD_NAMES;
my %FIELD_PRIORITIES;

{

    my $priority = 0;

    for my $field (
        GENERAL_HEADERS(),
        sort(
            REQUEST_HEADERS(),
            'Cookie'
        ),
        sort(
            RESPONSE_HEADERS(),
            'Set-Cookie',
            'Set-Cookie2'
        ),
        sort(
            ENTITY_HEADERS(),
            'Content-Disposition'
        )
    ) {

        my $key = uc $field;

        $FIELD_NAMES{$key}      = $field;
        $FIELD_PRIORITIES{$key} = ++$priority;

    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class::Object;

has 'headers' => (
    isa       => 'Hash::Ordered',
    accessors => {
        '_headers' => { type => 'get_reference' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    my $self  = shift;
    my $field = shift;

    if ( ! defined $field || ! length $field ) {
        complain "Invalid header name";
    }

    push @{$self->_headers->{ uc $field }}, @_;

    return;

}

sub as_hash {

    # UNDOCUMENTED

    my $self = shift;

    my %headers;
    my $headers = $self->_headers;

    for my $field ( keys %$headers ) {
        $headers{$field} = Storable::dclone( $headers->{$field} );
    }

    return wantarray ? %headers : \%headers;

}

sub as_string {

    my $self = shift;

    my $string = '';

    my $headers = $self->_headers;

    for my $key ( $self->_sorted_field_keys ) {

        my $field = $FIELD_NAMES{$key} || $key;

        for my $value ( grep { defined } @{$headers->{$key}} ) {

            # Handle newlines in the field value
            if ( $value =~ /\n/ ) {
                # A leading SP indicates folding [RFC 2616]
                $string .= "$field: " . join( CRLFSP, grep { length } split( /\n/, $value ) );
            }
            else {
                $string .= "$field: $value";
            }

            $string .= CRLF;

        }

    }

    return $string;

}

sub count {

    return scalar keys %{$_[0]->_headers};

}

sub field_names {

    return map { $FIELD_NAMES{$_} || $_ } keys %{$_[0]->_headers};

}

sub get {

    my $self  = shift;
    my $field = shift;

    defined $field or return;

    my $values = $self->_headers->{ uc $field } or return;

    return wantarray ? @$values : $values->[0];

}

sub parse {

    my $invocant = shift;
    my $string   = shift;

    my $self = ref $invocant ? $invocant : $invocant->new;

    return $self if ! defined $string;

    my @lines;

    for my $line ( split( REGEX_CRLF, $string ) ) {

        # An empty line (i.e., a line with nothing preceding the CRLF)
        # indicates the end of the header fields. [RFC 2616]
        last unless length $line;

        # Header fields can be extended over multiple lines by preceding each
        # extra line with at least one SP or HT. A recipient MAY replace any
        # linear white space with a single SP before interpreting the field
        # value or forwarding the message downstream. [RFC 2616]
        if ( $line =~ s/^[ \t]// ) {
            next unless @lines;
            $lines[-1] .= "\n$line";
        }
        else {
            push @lines, $line;
        }

    }

    for my $line ( @lines ) {
        my ( $field, $value ) = split( /:\s*/, $line, 2 );
        next unless defined $value;
        $value =~ s/\s+$//;
        $self->add( $field, $value );
    }

    return $self;

}

sub remove {

    my $self  = shift;
    my $field = shift;

    defined $field or return;

    return delete $self->_headers->{ uc $field } ? 1 : 0;

}

sub set {

    my $self  = shift;
    my $field = shift;

    if ( ! defined $field || ! length $field ) {
        complain "Invalid header name";
    }

    $self->_headers->{ uc $field } = [ @_ ];

    return;

}

sub sorted_field_names {

    return map { $FIELD_NAMES{$_} || $_ } $_[0]->_sorted_field_keys;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _install_field_accessors {

    my $class = shift;

    for my $field ( @_ ) {

        ( my $accessor = lc $field ) =~ tr/-/_/;

        my $key = uc $field;

        my $code = sub {

            my $self = shift;

            if ( @_ ) {
                $self->_headers->{$key} = [ @_ ];
                return;
            }

            my $values = $self->_headers->{$key} or return;

            return wantarray ? @$values : $values->[0];

        };

        $class->meta->add_method( $accessor, $code );

    }

    return;

}

sub _sorted_field_keys {

    my $self = shift;

    my @keys = sort {
        ( $FIELD_PRIORITIES{$a} || 999 ) <=> ( $FIELD_PRIORITIES{$b} || 999 ) || $a cmp $b
    } keys %{$self->_headers};

    return @keys;

}


# ----------------------------------------------------------------------------------------------------------------------
# Field accessors
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_field_accessors( qw(
    Content-Disposition
    Content-Encoding
    Content-Language
    Content-Length
    Content-Type
    Date
    Expires
    Last-Modified
) );


1;

__END__

=head1 NAME

GX::HTTP::Headers - HTTP message headers class

=head1 SYNOPSIS

    # Load the class
    use GX::HTTP::Headers;
    
    # Create a new headers object
    $headers = GX::HTTP::Headers->new;
    
    # Set the value of a header field
    $headers->set( 'Content-Type' => 'text/plain' );
    
    # Get the value of a header field
    $content_type = $headers->get( 'Content-Type' );
    
    # Print the headers
    print $headers->as_string;
    
    # Parse a HTTP message header
    $headers->parse(
        "Content-Length: 26971\015\012" .
        "Content-Type: text/html\015\012" .
        "Date: Fri, 02 Oct 2009 12:05:02 GMT"
    );

=head1 DESCRIPTION

This module provides the L<GX::HTTP::Headers> class which extends the
L<GX::Class::Object> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::HTTP::Headers> object.

    $headers = GX::HTTP::Headers->new;

=over 4

=item Returns:

=over 4

=item * C<$headers> ( L<GX::HTTP::Headers> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Also see C<< L<parse()|/parse> >>.

=head2 Basic Public API

=head3 C<add>

Adds the given value to the specified header field.

    $headers->add( $field, $value );

=over 4

=item Arguments:

=over 4

=item * C<$field> ( string )

=item * C<$value> ( string )

=back

=back

Multiple values can be passed as a list:

    $headers->add( $field, @values );

=over 4

=item Arguments:

=over 4

=item * C<$field> ( string )

=item * C<@values> ( strings )

=back

=back

=head3 C<as_string>

Returns the header fields formatted as a HTTP message header.

    $string = $headers->as_string;

=over 4

=item Returns:

=over 4

=item * C<$string> ( string )

=back

=back

=head3 C<clear>

Removes all header fields.

    $headers->clear;

=head3 C<count>

Returns the total number of header fields.

    $count = $headers->count;

=over 4

=item Returns:

=over 4

=item * C<$count> ( integer )

=back

=back

=head3 C<field_names>

Returns the names of the header fields.

    @fields = $headers->field_names;

=over 4

=item Returns:

=over 4

=item * C<@fields> ( strings )

=back

=back

=head3 C<get>

Returns the values of the specified header field in the order they were added.

    @values = $headers->get( $field );

=over 4

=item Arguments:

=over 4

=item * C<$field> ( string )

=back

=item Returns:

=over 4

=item * C<@values> ( strings )

=back

=back

In scalar context, the first of those values is returned.

    $value = $headers->get( $field );

=over 4

=item Arguments:

=over 4

=item * C<$field> ( string )

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

=head3 C<parse>

Parses the given message header and adds the resulting header field / value
pairs to the container.

    $headers->parse( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( string )

=back

=back

This method can also be used as a constructor.

    $headers = GX::HTTP::Headers->parse( $string );

=over 4

=item Arguments:

=over 4

=item * C<$string> ( string )

=back

=item Returns:

=over 4

=item * C<$headers> ( L<GX::HTTP::Headers> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head3 C<remove>

Removes the specified header field.

    $result = $headers->remove( $field );

=over 4

=item Arguments:

=over 4

=item * C<$field> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<set>

Same as C<< L<add()|/"add"> >>, but replaces any existing values for the
specified header field with the ones given.

    $headers->set( $field, $value );
    $headers->set( $field, @values );

=head3 C<sorted_field_names>

Returns the names of the header fields, sorted as suggested by
L<RFC 2616|http://tools.ietf.org/html/rfc2616>.

    @fields = $headers->sorted_field_names;

=over 4

=item Returns:

=over 4

=item * C<@fields> ( strings )

=back

=back

=head2 Public Field Accessors

=head3 C<content_disposition>

Returns / sets the value of the "Content-Disposition" header field.

    $value = $headers->content_disposition;
    $value = $headers->content_disposition( $value );

=over 4

=item Arguments:

=over 4

=item * C<$value> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

See L<RFC 2616, section 15.5|http://tools.ietf.org/html/rfc2616#section-15.5>.

=head3 C<content_encoding>

Returns / sets the value of the "Content-Encoding" header field.

    $value = $headers->content_encoding;
    $value = $headers->content_encoding( $value );

=over 4

=item Arguments:

=over 4

=item * C<$value> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

See L<RFC 2616, section 14.11|http://tools.ietf.org/html/rfc2616#section-14.11>.

=head3 C<content_language>

Returns / sets the value of the "Content-Language" header field.

    $value = $headers->content_language;
    $value = $headers->content_language( $value );

=over 4

=item Arguments:

=over 4

=item * C<$value> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

See L<RFC 2616, section 14.12|http://tools.ietf.org/html/rfc2616#section-14.12>.

=head3 C<content_length>

Returns / sets the value of the "Content-Length" header field.

    $value = $headers->content_length;
    $value = $headers->content_length( $value );

=over 4

=item Arguments:

=over 4

=item * C<$value> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

See L<RFC 2616, section 14.13|http://tools.ietf.org/html/rfc2616#section-14.13>.

=head3 C<content_type>

Returns / sets the value of the "Content-Type" header field.

    $value = $headers->content_type;
    $value = $headers->content_type( $value );

=over 4

=item Arguments:

=over 4

=item * C<$value> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

See L<RFC 2616, section 14.17|http://tools.ietf.org/html/rfc2616#section-14.17>.

=head3 C<date>

Returns / sets the value of the "Date" header field.

    $value = $headers->date;
    $value = $headers->date( $value );

=over 4

=item Arguments:

=over 4

=item * C<$value> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

See L<RFC 2616, section 14.18|http://tools.ietf.org/html/rfc2616#section-14.18>.

=head3 C<expires>

Returns / sets the value of the "Expires" header field.

    $value = $headers->expires;
    $value = $headers->expires( $value );

=over 4

=item Arguments:

=over 4

=item * C<$value> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

See L<RFC 2616, section 14.21|http://tools.ietf.org/html/rfc2616#section-14.21>.

=head3 C<last_modified>

Returns / sets the value of the "Last-Modified" header field.

    $value = $headers->last_modified;
    $value = $headers->last_modified( $value );

=over 4

=item Arguments:

=over 4

=item * C<$value> ( string | C<undef> ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$value> ( string | C<undef> )

=back

=back

See L<RFC 2616, section 14.29|http://tools.ietf.org/html/rfc2616#section-14.29>.

=head1 SUBCLASSES

The following classes inherit directly from L<GX::HTTP::Headers>:

=over 4

=item * L<GX::HTTP::Request::Headers>

=item * L<GX::HTTP::Response::Headers>

=back

=head1 SEE ALSO

=over 4

=item * L<RFC 2616|http://tools.ietf.org/html/rfc2616>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
