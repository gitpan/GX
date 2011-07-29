#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use GX::Callback;
use GX::Renderer;


use Test::More tests => 62;


my $Handler_1 = GX::Callback->new( sub { my $result = shift; push @$result, 'handler_1', @_; } );
my $Handler_2 = GX::Callback->new( sub { my $result = shift; push @$result, 'handler_2', @_; } );
my $Handler_3 = GX::Callback->new( sub { my $result = shift; push @$result, 'handler_3', @_; } );
my $Handler_4 = GX::Callback->new( sub { my $result = shift; push @$result, 'handler_4', @_; } );
my $Handler_5 = GX::Callback->new( sub { my $result = shift; push @$result, 'handler_5', @_; } );


# new()
{

    my $renderer = GX::Renderer->new;

    isa_ok( $renderer, 'GX::Renderer' );

}

# can_render(), handler(), handlers(), formats()
{

    my $renderer = GX::Renderer->new;

    is_deeply( [ $renderer->formats ], [] );
    is_deeply( [ $renderer->handlers ], [] );
    is( $renderer->handler( 'format_x' ), undef );
    ok( ! $renderer->can_render( 'format_x' ) );

    $renderer->handler( 'format_1' => $Handler_1 );

    is_deeply( [ $renderer->formats ], [ 'format_1' ] );
    is_deeply( [ $renderer->handlers ], [ $Handler_1 ] );
    is( $renderer->handler( 'format_1' ), $Handler_1 );
    ok( $renderer->can_render( 'format_1' ) );

    $renderer->handler( 'format_2' => $Handler_2 );
    $renderer->handler( 'format_3' => $Handler_3 );

    is_deeply( [ $renderer->formats ], [ 'format_1', 'format_2', 'format_3' ] );
    is_deeply( [ $renderer->handlers ], [ $Handler_1, $Handler_2, $Handler_3 ] );
    is( $renderer->handler( 'format_1' ), $Handler_1 );
    is( $renderer->handler( 'format_2' ), $Handler_2 );
    is( $renderer->handler( 'format_3' ), $Handler_3 );
    ok( $renderer->can_render( 'format_1' ) );
    ok( $renderer->can_render( 'format_2' ) );
    ok( $renderer->can_render( 'format_3' ) );

    $renderer->handler( 'format_1' => $Handler_4 );

    is_deeply( [ $renderer->formats ], [ 'format_1', 'format_2', 'format_3' ] );
    is_deeply( [ $renderer->handlers ], [ $Handler_4, $Handler_2, $Handler_3 ] );
    is( $renderer->handler( 'format_1' ), $Handler_4 );
    is( $renderer->handler( 'format_2' ), $Handler_2 );
    is( $renderer->handler( 'format_3' ), $Handler_3 );
    ok( $renderer->can_render( 'format_1' ) );
    ok( $renderer->can_render( 'format_2' ) );
    ok( $renderer->can_render( 'format_3' ) );

    $renderer->handler( 'format_1' => undef );

    is_deeply( [ $renderer->formats ], [ 'format_2', 'format_3' ] );
    is_deeply( [ $renderer->handlers ], [ $Handler_2, $Handler_3 ] );
    is( $renderer->handler( 'format_1' ), undef );
    is( $renderer->handler( 'format_2' ), $Handler_2 );
    is( $renderer->handler( 'format_3' ), $Handler_3 );
    ok( ! $renderer->can_render( 'format_1' ) );
    ok( $renderer->can_render( 'format_2' ) );
    ok( $renderer->can_render( 'format_3' ) );

}

# render()
{

    my $renderer = GX::Renderer->new(
        handlers => {
            'format_1' => $Handler_1,
            'format_2' => $Handler_2,
            'format_3' => $Handler_3
        }
    );

    for ( 1 .. 3 ) {
        my $result = [];
        ok( $renderer->render( "format_$_" => ( $result, 1 .. 3 ) ) );
        is_deeply( $result, [ "handler_$_", 1 .. 3 ] );
    }

}

# clone()
{

    my $renderer = GX::Renderer->new(
        handlers => {
            'format_1' => $Handler_1,
            'format_2' => $Handler_2,
            'format_3' => $Handler_3
        }
    );

    is_deeply( $renderer->clone, $renderer );

}

# merge()
{

    my $renderer_1 = GX::Renderer->new(
        handlers => {
            'format_1' => $Handler_1,
            'format_2' => $Handler_2,
            'format_3' => $Handler_3
        }
    );

    my $renderer_2 = GX::Renderer->new(
        handlers => {
            'format_2' => $Handler_4,
            'format_3' => $Handler_4,
        }
    );

    my $renderer_3 = GX::Renderer->new(
        handlers => {
            'format_3' => $Handler_5
        }
    );

    $renderer_1->merge( $renderer_2, $renderer_3 );

    is_deeply( [ $renderer_1->formats ], [ 'format_1', 'format_2', 'format_3' ] );
    is_deeply( [ $renderer_1->handlers ], [ $Handler_1, $Handler_4, $Handler_5 ] );

}

# "*" as format
{

    my $renderer = GX::Renderer->new;

    $renderer->handler( '*' => $Handler_1 );
    $renderer->handler( 'format_2' => $Handler_2 );

    is( $renderer->handler( '*' ), $Handler_1 );
    is( $renderer->handler( 'format_x' ), undef );
    is( $renderer->handler( 'format_2' ), $Handler_2 );

    ok( $renderer->can_render( '*' ) );
    ok( $renderer->can_render( 'format_x' ) );
    ok( $renderer->can_render( 'format_2' ) );

    {
        my $result = [];
        ok( $renderer->render( '*', ( $result, 1 .. 3 ) ) );
        is_deeply( $result, [ 'handler_1', 1 .. 3 ] );
    }

    {
        my $result = [];
        ok( $renderer->render( 'format_x', ( $result, 1 .. 3 ) ) );
        is_deeply( $result, [ 'handler_1', 1 .. 3 ] );
    }

    {
        my $result = [];
        ok( $renderer->render( 'format_2', ( $result, 1 .. 3 ) ) );
        is_deeply( $result, [ 'handler_2', 1 .. 3 ] );
    }

}

# undef as format
{

    {

        my $renderer = GX::Renderer->new;

        local $@;

        eval {
            $renderer->handler( undef, $Handler_1 );
        };

        isa_ok( $@, 'GX::Exception' );

    }

    {

        my $renderer = GX::Renderer->new;

        is( $renderer->handler( undef ), undef );

        ok( ! $renderer->can_render( undef ) );

        ok( ! $renderer->render( undef ) );

    }

    {

        my $renderer = GX::Renderer->new;

        $renderer->handler( '*' => $Handler_1 );

        is( $renderer->handler( undef ), undef );

        ok( $renderer->can_render( undef ) );

        {
            my $result = [];
            ok( $renderer->render( undef, ( $result, 1 .. 3 ) ) );
            is_deeply( $result, [ 'handler_1', 1 .. 3 ] );
        }

    }

}

