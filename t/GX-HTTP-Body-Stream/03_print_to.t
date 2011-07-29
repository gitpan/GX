#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::HTTP::Body::Stream;
use IO::File ();


use Test::More tests => 16;


my $DATA = "Hello World!\n" x 8192;


# handle, print_to( $object )
{

    open CONTENT, "<", \$DATA or die;

    my $body = GX::HTTP::Body::Stream->new( *CONTENT );

    my $output = '';
    ok( $body->print_to( IO::File->new( \$output, '>' ) ) );
    is( $output, $DATA );

    close CONTENT;

}

# handle, print_to( *FH )
{

    open CONTENT, "<", \$DATA or die;

    my $body = GX::HTTP::Body::Stream->new( *CONTENT );

    my $output = '';
    open OUTPUT, '>', \$output;
    ok( $body->print_to( *OUTPUT ) );
    is( $output, $DATA );
    close OUTPUT;

    close CONTENT;

}

# handle, print_to( \*FH )
{

    open CONTENT, "<", \$DATA or die;

    my $body = GX::HTTP::Body::Stream->new( *CONTENT );

    my $output = '';
    open OUTPUT, '>', \$output;
    ok( $body->print_to( \*OUTPUT ) );
    is( $output, $DATA );
    close OUTPUT;

    close CONTENT;

}

# handle, print_to( $fh )
{

    open my $source, "<", \$DATA or die;

    my $body = GX::HTTP::Body::Stream->new( $source );

    open my $output_handle, '>', \( my $output = '' );
    ok( $body->print_to( $output_handle ) );
    is( $output, $DATA );
    close $output_handle;

    close $source;

}

# callback, print_to( $object )
{

    my $i = 0;
    my $callback = sub {
        return 0 if $i > 9;
        $_[0]->print( $i );
        $i++;
        return 1;
    };

    my $body = GX::HTTP::Body::Stream->new( $callback );

    my $output = '';
    ok( $body->print_to( IO::File->new( \$output, '>' ) ) );
    is( $output, '0123456789' );

}

# callback, print_to( *FH )
{

    my $i = 0;
    my $callback = sub {
        return 0 if $i > 9;
        $_[0]->print( $i );
        $i++;
        return 1;
    };

    my $body = GX::HTTP::Body::Stream->new( $callback );

    my $output = '';
    open OUTPUT, '>', \$output;
    ok( $body->print_to( *OUTPUT ) );
    is( $output, '0123456789' );
    close OUTPUT;

}

# callback, print_to( \*FH )
{

    my $i = 0;
    my $callback = sub {
        return 0 if $i > 9;
        $_[0]->print( $i );
        $i++;
        return 1;
    };

    my $body = GX::HTTP::Body::Stream->new( $callback );

    my $output = '';
    open OUTPUT, '>', \$output;
    ok( $body->print_to( \*OUTPUT ) );
    is( $output, '0123456789' );
    close OUTPUT;

}

# callback, print_to( $fh )
{

    my $i = 0;
    my $callback = sub {
        return 0 if $i > 9;
        $_[0]->print( $i );
        $i++;
        return 1;
    };

    my $body = GX::HTTP::Body::Stream->new( $callback );

    open my $output_handle, '>', \( my $output = '' );
    ok( $body->print_to( $output_handle ) );
    is( $output, '0123456789' );
    close $output_handle;

}

