#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Request::Headers;


use Test::More tests => 44;


my %ACCESSORS = (
    'COOKIE'              => 'cookie',
    'HOST'                => 'host',
    'IF-MODIFIED-SINCE'   => 'if_modified_since',
    'IF-UNMODIFIED-SINCE' => 'if_unmodified_since',
    'LAST-MODIFIED'       => 'last_modified',
    'REFERER'             => 'referer',
    'USER-AGENT'          => 'user_agent'
);


{

    my $headers = GX::HTTP::Request::Headers->new;

    for my $accessor ( values %ACCESSORS  ) {

        my $value = "$accessor value";

        is( scalar $headers->$accessor, undef );

        is_deeply( [ $headers->$accessor ], [] );

        $headers->$accessor( $value );

        is( scalar $headers->$accessor, $value );

        is_deeply( [ $headers->$accessor ], [ $value ] );

    }

    is_deeply(
        scalar $headers->_headers,
        {
            map {
                $_ => [ $ACCESSORS{$_} . ' value' ]
            } keys %ACCESSORS
        }
    );

}

{

    my $headers = GX::HTTP::Request::Headers->new;

    for my $accessor ( values %ACCESSORS  ) {

        my @values = map { "$accessor value $_" } 1 .. 2;

        $headers->$accessor( @values );

        is( scalar $headers->$accessor, $values[0] );

        is_deeply( [ $headers->$accessor ], \@values );

    }

    is_deeply(
        scalar $headers->_headers,
        {
            map {
                $_ => [ $ACCESSORS{$_} . ' value 1', $ACCESSORS{$_} . ' value 2' ]
            } keys %ACCESSORS
        }
    );

}

