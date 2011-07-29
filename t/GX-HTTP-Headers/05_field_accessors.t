#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Headers;


use Test::More tests => 50;


my %ACCESSORS = (
    'CONTENT-DISPOSITION' => 'content_disposition',
    'CONTENT-ENCODING'    => 'content_encoding',
    'CONTENT-LANGUAGE'    => 'content_language',
    'CONTENT-LENGTH'      => 'content_length',
    'CONTENT-TYPE'        => 'content_type',
    'DATE'                => 'date',
    'EXPIRES'             => 'expires',
    'LAST-MODIFIED'       => 'last_modified'
);


{

    my $headers = GX::HTTP::Headers->new;

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

    my $headers = GX::HTTP::Headers->new;

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

