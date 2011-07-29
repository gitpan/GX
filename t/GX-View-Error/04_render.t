#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';

use Encode qw( decode encode );

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


use Test::More tests => 22;


require_ok( 'MyApp' );


# ----------------------------------------------------------------------------------------------------------------------
# MyApp::View::A
# ----------------------------------------------------------------------------------------------------------------------

# $view->render( context => $context )
{

    my $view = MyApp->instance->view( 'A' );

    my $context = _fake_context();
    $context->error( 'Oops.' );

    $view->render( context => $context );

    my $content_type = $context->response->content_type;
    my $content      = $context->response->body->as_string;

    is( $content_type, 'text/html; charset=UTF-8' );

    my $decoded_content = decode( 'utf-8-strict', $content );
    ok( index( $decoded_content, '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />' ) >= 0 );
    ok( index( $decoded_content, 'Oops.' ) >= 0 );

}

# $view->render( context => $context ), $context->error -> GX::Exception object
{

    my $view = MyApp->instance->view( 'A' );

    my $context = _fake_context();
    $context->error( GX::Exception->new( 'Oops.' ) );

    $view->render( context => $context );

    my $content_type  = $context->response->content_type;
    my $content       = $context->response->body->as_string;

    is( $content_type, 'text/html; charset=UTF-8' );

    my $decoded_content = decode( 'utf-8-strict', $content );
    ok( index( $decoded_content, '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />' ) >= 0 );
    ok( index( $decoded_content, 'Oops.' ) >= 0 );

}

# $view->render( context => $context, error => 'Oops.' )
{

    my $view = MyApp->instance->view( 'A' );

    my $context = _fake_context();

    $view->render( context => $context, error => 'Oops.' );

    my $content_type = $context->response->content_type;
    my $content      = $context->response->body->as_string;

    is( $content_type, 'text/html; charset=UTF-8' );

    my $decoded_content = decode( 'utf-8-strict', $content );
    ok( index( $decoded_content, '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />' ) >= 0 );
    ok( index( $decoded_content, 'Oops.' ) >= 0 );

}

# $view->render( context => $context, error => GX::Exception->new( 'Oops.' ) )
{

    my $view = MyApp->instance->view( 'A' );

    my $context = _fake_context();

    $view->render( context => $context, error => GX::Exception->new( 'Oops.' ) );

    my $content_type = $context->response->content_type;
    my $content      = $context->response->body->as_string;

    is( $content_type, 'text/html; charset=UTF-8' );

    my $decoded_content = decode( 'utf-8-strict', $content );
    ok( index( $decoded_content, '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />' ) >= 0 );
    ok( index( $decoded_content, 'Oops.' ) >= 0 );

}

# $view->render( context => $context, error => "\x{00E4} \x{00F6} \x{00FC}", encoding => 'iso-8859-1' )
{

    my $view = MyApp->instance->view( 'A' );

    my $context = _fake_context();

    $view->render( context => $context, error => "\x{00E4} \x{00F6} \x{00FC}", encoding => 'iso-8859-1' );

    my $content_type = $context->response->content_type;
    my $content      = $context->response->body->as_string;

    is( $content_type, 'text/html; charset=ISO-8859-1' );

    my $decoded_content = decode( 'iso-8859-1', $content );
    ok( index( $decoded_content, '<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />' ) >= 0 );
    ok( index( $decoded_content, "\x{00E4} \x{00F6} \x{00FC}" ) >= 0 );

}

# $output = $view->render( context => $context )
{

    my $view = MyApp->instance->view( 'A' );

    my $context = _fake_context();
    $context->error( 'Oops.' );

    my $output = $view->render( context => $context );

    is( $context->response->content_type, undef );
    is( $context->response->body->length, 0 );

    my $decoded_output = decode( 'utf-8-strict', $output );
    ok( index( $decoded_output, '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />' ) >= 0 );
    ok( index( $decoded_output, 'Oops.' ) >= 0 );

}

# $output = $view->render( error => 'Oops.' )
{

    my $view = MyApp->instance->view( 'A' );

    my $output = $view->render( error => 'Oops.' );

    my $decoded_output = decode( 'utf-8-strict', $output );
    ok( index( $decoded_output, '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />' ) >= 0 );
    ok( index( $decoded_output, 'Oops.' ) >= 0 );

}


# ----------------------------------------------------------------------------------------------------------------------

sub _fake_context {

    return MyApp::Context->new(
        request  => MyApp::Request->new,
        response => MyApp::Response->new,
        @_
    );

}

