#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::Scalar;


use Test::More tests => 9;


# new()
{

    my $body = GX::HTTP::Body::Scalar->new;

    isa_ok( $body, 'GX::HTTP::Body::Scalar' );

}

# new( $string )
{

    my $string = 'Hello World!';

    my $body = GX::HTTP::Body::Scalar->new( $string );

    is( $body->as_string, $string );

}

# new( \$string )
{

    my $string = 'Hello World!';

    my $body = GX::HTTP::Body::Scalar->new( \$string );

    is( $body->as_string, $string );

}

# new( content => $string )
{

    my $string = 'Hello World!';

    my $body = GX::HTTP::Body::Scalar->new( content => $string );

    is( $body->as_string, $string );

}

# new( content => \$string )
{

    my $string = 'Hello World!';

    my $body = GX::HTTP::Body::Scalar->new( content => \$string );

    is( $body->as_string, $string );

}

# new( $utf8_string )
{

    local $@;

    my $utf8_string = "\x{263A}";

    eval {
        my $body = GX::HTTP::Body::Scalar->new( $utf8_string );
    };

    isa_ok( $@, 'GX::Exception' );

}

# new( \$utf8_string )
{

    local $@;

    my $utf8_string = "\x{263A}";

    eval {
        my $body = GX::HTTP::Body::Scalar->new( \$utf8_string );
    };

    isa_ok( $@, 'GX::Exception' );

}

# new( content => $utf8_string )
{

    local $@;

    my $utf8_string = "\x{263A}";

    eval {
        my $body = GX::HTTP::Body::Scalar->new( content => $utf8_string );
    };

    isa_ok( $@, 'GX::Exception' );

}

# new( content => \$utf8_string )
{

    local $@;

    my $utf8_string = "\x{263A}";

    eval {
        my $body = GX::HTTP::Body::Scalar->new( content => \$utf8_string );
    };

    isa_ok( $@, 'GX::Exception' );

}

