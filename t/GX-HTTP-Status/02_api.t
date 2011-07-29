#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Test;

use Test::More tests => 112;

use GX::HTTP::Status qw(
    :constants
    is_client_error
    is_error
    is_informational
    is_redirection
    is_server_error
    is_success
    reason_phrase
);


my %STATUS_CODES = (
    HTTP_CONTINUE                      => 100,
    HTTP_SWITCHING_PROTOCOLS           => 101,
    HTTP_PROCESSING                    => 102,
    HTTP_OK                            => 200,
    HTTP_CREATED                       => 201,
    HTTP_ACCEPTED                      => 202,
    HTTP_NON_AUTHORITATIVE_INFORMATION => 203,
    HTTP_NO_CONTENT                    => 204,
    HTTP_RESET_CONTENT                 => 205,
    HTTP_PARTIAL_CONTENT               => 206,
    HTTP_MULTI_STATUS                  => 207,
    HTTP_MULTIPLE_CHOICES              => 300,
    HTTP_MOVED_PERMANENTLY             => 301,
    HTTP_FOUND                         => 302,
    HTTP_SEE_OTHER                     => 303,
    HTTP_NOT_MODIFIED                  => 304,
    HTTP_USE_PROXY                     => 305,
    HTTP_SWITCH_PROXY                  => 306,
    HTTP_TEMPORARY_REDIRECT            => 307,
    HTTP_BAD_REQUEST                   => 400,
    HTTP_UNAUTHORIZED                  => 401,
    HTTP_PAYMENT_REQUIRED              => 402,
    HTTP_FORBIDDEN                     => 403,
    HTTP_NOT_FOUND                     => 404,
    HTTP_METHOD_NOT_ALLOWED            => 405,
    HTTP_NOT_ACCEPTABLE                => 406,
    HTTP_PROXY_AUTHENTICATION_REQUIRED => 407,
    HTTP_REQUEST_TIMEOUT               => 408,
    HTTP_CONFLICT                      => 409,
    HTTP_GONE                          => 410,
    HTTP_LENGTH_REQUIRED               => 411,
    HTTP_PRECONDITION_FAILED           => 412,
    HTTP_REQUEST_ENTITY_TOO_LARGE      => 413,
    HTTP_REQUEST_URI_TOO_LONG          => 414,
    HTTP_UNSUPPORTED_MEDIA_TYPE        => 415,
    HTTP_REQUEST_RANGE_NOT_SATISFIABLE => 416,
    HTTP_EXPECTATION_FAILED            => 417,
    HTTP_UNPROCESSABLE_ENTITY          => 422,
    HTTP_LOCKED                        => 423,
    HTTP_FAILED_DEPENDENCY             => 424,
    HTTP_UNORDERED_COLLECTION          => 425,
    HTTP_UPGRADE_REQUIRED              => 426,
    HTTP_INTERNAL_SERVER_ERROR         => 500,
    HTTP_NOT_IMPLEMENTED               => 501,
    HTTP_BAD_GATEWAY                   => 502,
    HTTP_SERVICE_UNAVAILABLE           => 503,
    HTTP_GATEWAY_TIMEOUT               => 504,
    HTTP_HTTP_VERSION_NOT_SUPPORTED    => 505,
    HTTP_VARIANT_ALSO_NEGOTIATES       => 506,
    HTTP_INSUFFICIENT_STORAGE          => 507,
    HTTP_BANDWIDTH_LIMIT_EXCEEDED      => 509,
    HTTP_NOT_EXTENDED                  => 510
);


# Functions
{

    ok( defined &is_client_error );
    ok( defined &is_error );
    ok( defined &is_informational );
    ok( defined &is_redirection );
    ok( defined &is_server_error );
    ok( defined &is_success );
    ok( defined &reason_phrase );

}

# Constants
{

    while ( my ( $function, $status ) = each %STATUS_CODES ) {
        
        {
            no strict 'refs';
            is( &$function, $status, "$function => $status" );
        }

    }

}

# reason_phrase()
{

    for my $status ( values %STATUS_CODES ) {
        my $phrase = reason_phrase( $status );
        ok( defined $phrase && length $phrase, "reason_phrase( $status )" );
    }

    is( reason_phrase( 200 ), 'OK', "reason_phrase( 200 )")

}

