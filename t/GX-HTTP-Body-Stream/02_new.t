#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::Stream;
use IO::File ();
use IO::Handle ();


use Test::More tests => 18;


my $CONTENT = "Hello World!";


# new( $fh )
{

    open my $fh, "<", \$CONTENT or die;

    my $body = GX::HTTP::Body::Stream->new( $fh );

    my $source = $body->source;
    isa_ok( $source, 'IO::Handle' );
    is( join( '', <$source> ), $CONTENT );

    close $fh;

}

# new( *FH )
{

    open FH, "<", \$CONTENT or die;

    my $body = GX::HTTP::Body::Stream->new( *FH );

    my $source = $body->source;
    isa_ok( $source, 'IO::Handle' );
    is( join( '', <$source> ), $CONTENT );

    close FH;

}

# new( \*FH )
{

    open FH, "<", \$CONTENT or die;

    my $body = GX::HTTP::Body::Stream->new( \*FH );

    my $source = $body->source;
    isa_ok( $source, 'IO::Handle' );
    is( join( '', <$source> ), $CONTENT );

    close FH;

}

# new( source => *FH )
{

    open FH, "<", \$CONTENT or die;

    my $body = GX::HTTP::Body::Stream->new( source => *FH );

    my $source = $body->source;
    isa_ok( $source, 'IO::Handle' );
    is( join( '', <$source> ), $CONTENT );

    close FH;

}

# new( source => \*FH )
{

    open FH, "<", \$CONTENT or die;

    my $body = GX::HTTP::Body::Stream->new( source => \*FH );

    my $source = $body->source;
    isa_ok( $source, 'IO::Handle' );
    is( join( '', <$source> ), $CONTENT );

    close FH;

}

# new( $object )
{

    open FH, "<", \$CONTENT or die;

    my $object = IO::Handle->new_from_fd( *FH, '<' );

    my $body = GX::HTTP::Body::Stream->new( $object );

    my $source = $body->source;
    is( $source, $object );
    is( join( '', <$source> ), $CONTENT );

    close FH;

}

# new( source => $object )
{

    open FH, "<", \$CONTENT or die;

    my $object = IO::Handle->new_from_fd( *FH, '<' );

    my $body = GX::HTTP::Body::Stream->new( source => $object );

    my $source = $body->source;
    is( $source, $object );
    is( join( '', <$source> ), $CONTENT );

    close FH;

}

# new( $callback )
{

    my $i = 0;
    my $callback = sub {
        return if $i > 9;
        $_[0]->print( $i );
        $i++;
        return 1;
    };

    my $body = GX::HTTP::Body::Stream->new( $callback );

    is( $body->source, $callback );

    my $output;
    my $outstream = IO::File->new( \$output, '>' );
    $body->print_to( $outstream );
    is( $output, '0123456789' );

}

# new( source => $callback )
{

    my $i = 0;
    my $callback = sub {
        return if $i > 9;
        $_[0]->print( $i );
        $i++;
        return 1;
    };

    my $body = GX::HTTP::Body::Stream->new( source => $callback );

    is( $body->source, $callback );

    my $output;
    my $outstream = IO::File->new( \$output, '>' );
    $body->print_to( $outstream );
    is( $output, '0123456789' );

}

