# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/HTTP/Status.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::HTTP::Status;

use strict;
use warnings;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

require Exporter;

our @ISA = qw( Exporter );

our @EXPORT_OK = qw(
    is_client_error
    is_error
    is_informational
    is_redirection
    is_server_error
    is_success
    reason_phrase
);

our %EXPORT_TAGS = ( 'constants' => [] );


# ----------------------------------------------------------------------------------------------------------------------
# Status code constants
# ----------------------------------------------------------------------------------------------------------------------

my %STATUS_CODES = (
    100 => 'Continue',                        # RFC 2616 (since HTTP/1.1)
    101 => 'Switching Protocols',             # RFC 2616 (since HTTP/1.1)
    102 => 'Processing',                      # RFC 2518 (WebDAV)
    200 => 'OK',                              # RFC 2616
    201 => 'Created',                         # RFC 2616
    202 => 'Accepted',                        # RFC 2616
    203 => 'Non-Authoritative Information',   # RFC 2616 (since HTTP/1.1)
    204 => 'No Content',                      # RFC 2616
    205 => 'Reset Content',                   # RFC 2616
    206 => 'Partial Content',                 # RFC 2616
    207 => 'Multi-Status',                    # RFC 4918 (WebDAV)
    300 => 'Multiple Choices',                # RFC 2616
    301 => 'Moved Permanently',               # RFC 2616
    302 => 'Found',                           # RFC 2616
    303 => 'See Other',                       # RFC 2616 (since HTTP/1.1)
    304 => 'Not Modified',                    # RFC 2616
    305 => 'Use Proxy',                       # RFC 2616 (since HTTP/1.1)
    306 => 'Switch Proxy',                    # no longer used
    307 => 'Temporary Redirect',              # RFC 2616 (since HTTP/1.1)
    400 => 'Bad Request',                     # RFC 2616
    401 => 'Unauthorized',                    # RFC 2616
    402 => 'Payment Required',                # RFC 2616
    403 => 'Forbidden',                       # RFC 2616
    404 => 'Not Found',                       # RFC 2616
    405 => 'Method Not Allowed',              # RFC 2616
    406 => 'Not Acceptable',                  # RFC 2616
    407 => 'Proxy Authentication Required',   # RFC 2616
    408 => 'Request Timeout',                 # RFC 2616
    409 => 'Conflict',                        # RFC 2616
    410 => 'Gone',                            # RFC 2616
    411 => 'Length Required',                 # RFC 2616
    412 => 'Precondition Failed',             # RFC 2616
    413 => 'Request Entity Too Large',        # RFC 2616
    414 => 'Request-URI Too Long',            # RFC 2616
    415 => 'Unsupported Media Type',          # RFC 2616
    416 => 'Request Range Not Satisfiable',   # RFC 2616
    417 => 'Expectation Failed',              # RFC 2616
    422 => 'Unprocessable Entity',            # RFC 4918 (WebDAV)
    423 => 'Locked',                          # RFC 4918 (WebDAV)
    424 => 'Failed Dependency',               # RFC 4918 (WebDAV)
    425 => 'Unordered Collection',            # RFC 3648 (WebDAV)
    426 => 'Upgrade Required',                # RFC 2817 (TLS)
    500 => 'Internal Server Error',           # RFC 2616
    501 => 'Not Implemented',                 # RFC 2616
    502 => 'Bad Gateway',                     # RFC 2616
    503 => 'Service Unavailable',             # RFC 2616
    504 => 'Gateway Timeout',                 # RFC 2616
    505 => 'HTTP Version Not Supported',      # RFC 2616
    506 => 'Variant Also Negotiates',         # RFC 2295
    507 => 'Insufficient Storage',            # RFC 4918 (WebDAV)
    509 => 'Bandwidth Limit Exceeded',        # unofficial
    510 => 'Not Extended'                     # RFC 2774
);

{

    while ( my ( $status, $reason_phrase ) = each %STATUS_CODES ) {

        ( my $constant = uc $reason_phrase ) =~ tr/ \-/__/;

        $constant = "HTTP_$constant";

        eval "use constant $constant => $status; 1;" or die $@;

        push @EXPORT_OK, $constant;

        push @{$EXPORT_TAGS{'constants'}}, $constant;

    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Public functions
# ----------------------------------------------------------------------------------------------------------------------

sub is_client_error {

    return defined $_[0] && $_[0] >= 400 && $_[0] < 500;

}

sub is_error {

    return defined $_[0] && $_[0] >= 400 && $_[0] < 600;

}

sub is_informational {

    return defined $_[0] && $_[0] >= 100 && $_[0] < 200;

}

sub is_redirection {

    return defined $_[0] && $_[0] >= 300 && $_[0] < 400;

}

sub is_server_error {

    return defined $_[0] && $_[0] >= 500 && $_[0] < 600;

}

sub is_success {

    return defined $_[0] && $_[0] >= 200 && $_[0] < 300;

}

sub reason_phrase {

    return defined $_[0] ? $STATUS_CODES{$_[0]} : undef;

}


1;

__END__

=head1 NAME

GX::HTTP::Status - Constants and utility functions for dealing with HTTP status codes

=head1 SYNOPSIS

    # Load the module
    use GX::HTTP::Status qw( :constants is_error reason_phrase );
    
    # Check a HTTP status code
    die "Ooops" if is_error( $status );
    
    # Get the reason phrase for a HTTP status code
    print reason_phrase( HTTP_OK );

=head1 DESCRIPTION

This module provides various constants and utility functions.

=head1 FUNCTIONS

=head2 Public Functions

=head3 C<is_client_error>

Returns true if the given integer is a "Client Error" (4xx) HTTP status code,
otherwise false.

    $result = is_client_error( $status );

=over 4

=item Arguments:

=over 4

=item * C<$status> ( integer )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_error>

Returns true if the given integer is a "Client Error" (4xx) or a
"Server Error" (5xx) HTTP status code, otherwise false.

    $result = is_error( $status );

=over 4

=item Arguments:

=over 4

=item * C<$status> ( integer )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_informational>

Returns true if the given integer is an "Informational" (1xx) HTTP status
code, otherwise false.

    $result = is_informational( $status );

=over 4

=item Arguments:

=over 4

=item * C<$status> ( integer )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_redirection>

Returns true if the given integer is a "Redirection" (3xx) HTTP status code,
otherwise false.

    $result = is_redirection( $status );

=over 4

=item Arguments:

=over 4

=item * C<$status> ( integer )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_server_error>

Returns true if the given integer is a "Server Error" (5xx) HTTP status code,
otherwise false.

    $result = is_server_error( $status );

=over 4

=item Arguments:

=over 4

=item * C<$status> ( integer )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_success>

Returns true if the given integer is a "Success" (2xx) HTTP status code,
otherwise false.

    $result = is_success( $status );

=over 4

=item Arguments:

=over 4

=item * C<$status> ( integer )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<reason_phrase>

Returns the reason phrase for the given HTTP status code.

    $reason_phrase = reason_phrase( $status );

=over 4

=item Arguments:

=over 4

=item * C<$status> ( integer )

=back

=item Returns:

=over 4

=item * C<$reason_phrase> ( string | C<undef> )

=back

=back

=head1 CONSTANTS

The following constants are exported on demand, either individually or all at
once via the ":constants" export tag:

    HTTP_CONTINUE                      => 100
    HTTP_SWITCHING_PROTOCOLS           => 101
    HTTP_PROCESSING                    => 102
    HTTP_OK                            => 200
    HTTP_CREATED                       => 201
    HTTP_ACCEPTED                      => 202
    HTTP_NON_AUTHORITATIVE_INFORMATION => 203
    HTTP_NO_CONTENT                    => 204
    HTTP_RESET_CONTENT                 => 205
    HTTP_PARTIAL_CONTENT               => 206
    HTTP_MULTI_STATUS                  => 207
    HTTP_MULTIPLE_CHOICES              => 300
    HTTP_MOVED_PERMANENTLY             => 301
    HTTP_FOUND                         => 302
    HTTP_SEE_OTHER                     => 303
    HTTP_NOT_MODIFIED                  => 304
    HTTP_USE_PROXY                     => 305
    HTTP_SWITCH_PROXY                  => 306
    HTTP_TEMPORARY_REDIRECT            => 307
    HTTP_BAD_REQUEST                   => 400
    HTTP_UNAUTHORIZED                  => 401
    HTTP_PAYMENT_REQUIRED              => 402
    HTTP_FORBIDDEN                     => 403
    HTTP_NOT_FOUND                     => 404
    HTTP_METHOD_NOT_ALLOWED            => 405
    HTTP_NOT_ACCEPTABLE                => 406
    HTTP_PROXY_AUTHENTICATION_REQUIRED => 407
    HTTP_REQUEST_TIMEOUT               => 408
    HTTP_CONFLICT                      => 409
    HTTP_GONE                          => 410
    HTTP_LENGTH_REQUIRED               => 411
    HTTP_PRECONDITION_FAILED           => 412
    HTTP_REQUEST_ENTITY_TOO_LARGE      => 413
    HTTP_REQUEST_URI_TOO_LONG          => 414
    HTTP_UNSUPPORTED_MEDIA_TYPE        => 415
    HTTP_REQUEST_RANGE_NOT_SATISFIABLE => 416
    HTTP_EXPECTATION_FAILED            => 417
    HTTP_UNPROCESSABLE_ENTITY          => 422
    HTTP_LOCKED                        => 423
    HTTP_FAILED_DEPENDENCY             => 424
    HTTP_UNORDERED_COLLECTION          => 425
    HTTP_UPGRADE_REQUIRED              => 426
    HTTP_INTERNAL_SERVER_ERROR         => 500
    HTTP_NOT_IMPLEMENTED               => 501
    HTTP_BAD_GATEWAY                   => 502
    HTTP_SERVICE_UNAVAILABLE           => 503
    HTTP_GATEWAY_TIMEOUT               => 504
    HTTP_HTTP_VERSION_NOT_SUPPORTED    => 505
    HTTP_VARIANT_ALSO_NEGOTIATES       => 506
    HTTP_INSUFFICIENT_STORAGE          => 507
    HTTP_BANDWIDTH_LIMIT_EXCEEDED      => 509
    HTTP_NOT_EXTENDED                  => 510

=head1 SEE ALSO

=over 4

=item * L<RFC 2616, section 10|http://tools.ietf.org/html/rfc2616#section-10>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
