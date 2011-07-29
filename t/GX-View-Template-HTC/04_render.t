#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


use Test::More;

BEGIN {

    if( eval { require HTML::Template::Compiled } ) {
        plan tests => 49;
    }
    else {
        plan skip_all => "HTML::Template::Compiled is not installed";
    }

}


use Encode qw( encode );

use File::Spec ();
use FindBin qw( $Bin );
use lib File::Spec->catdir( $Bin, 'data', 'myapp', 'lib' );


require_ok( 'MyApp' );


my $MyApp  = MyApp->instance;
my $View_A = $MyApp->view( 'A' );
my $View_B = $MyApp->view( 'B' );
my $View_C = $MyApp->view( 'C' );
my $View_D = $MyApp->view( 'D' );
my $View_E = $MyApp->view( 'E' );


# $View_A->render( context => $context, template => 'template_1.htc' )
{

    my $context = _fake_context();

    $View_A->render( context => $context, template => 'template_1.htc' );

    is( $context->response->content_type, undef );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
Template file: template_1.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: 
var_2: 
var_3: 
EOT

}

# $View_A->render( context => $context, template => 'template_1.html.htc' )
{

    my $context = _fake_context();

    $View_A->render( context => $context, template => 'template_1.html.htc' );

    is( $context->response->content_type, 'text/html; charset=UTF-8' );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <title>template_1.html.htc</title>
</head>
    <body>
        <p>Template file: template_1.html.htc</p>
        <p>Template file encoding: UTF-8</p>
        <p>Euro: \x{20AC}</p>
        <p>Smiley: \x{263A}</p>
        <p>var_1: </p>
        <p>var_2: </p>
        <p>var_3: </p>
    </body>
</html>
EOT

}

# $View_A->render( context => $context, template => 'template_1.txt.htc' )
{

    my $context = _fake_context();

    $View_A->render( context => $context, template => 'template_1.txt.htc' );

    is( $context->response->content_type, 'text/plain; charset=UTF-8' );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
Template file: template_1.txt.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: 
var_2: 
var_3: 
EOT

}

# $View_A->render( context => $context, template => 'template_1.xhtml.htc' )
{

    my $context = _fake_context();

    $View_A->render( context => $context, template => 'template_1.xhtml.htc' );

    is( $context->response->content_type, 'application/xhtml+xml' );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>template_1.xhtml.htc</title>
</head>
    <body>
        <p>Template file: template_1.xhtml.htc</p>
        <p>Template file encoding: UTF-8</p>
        <p>Euro: \x{20AC}</p>
        <p>Smiley: \x{263A}</p>
        <p>var_1: </p>
        <p>var_2: </p>
        <p>var_3: </p>
    </body>
</html>
EOT

}

# $View_A->render( context => $context, template => 'template_1.htc' ) + stash
{

    my $context = _fake_context();

    $context->stash->{'var_1'} = 'stash_1';
    $context->stash->{'var_2'} = 'stash_2';

    $View_A->render( context => $context, template => 'template_1.htc' );

    is( $context->response->content_type, undef );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
Template file: template_1.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: stash_1
var_2: stash_2
var_3: 
EOT

}

# $View_A->render( context => $context, template => 'template_1.htc', parameters => \%parameters )
{

    my $context = _fake_context();

    $View_A->render( context => $context, template => 'template_1.htc', parameters => { 'var_1' => "\x{263A}" } );

    is( $context->response->content_type, undef );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
Template file: template_1.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: \x{263A}
var_2: 
var_3: 
EOT

}

# $View_A->render( context => $context, template => 'template_1.htc', parameters => \%parameters ) + stash
{

    my $context = _fake_context();

    $context->stash->{'var_1'} = 'stash_1';
    $context->stash->{'var_2'} = 'stash_2';

    $View_A->render( context => $context, template => 'template_1.htc', parameters => { 'var_1' => "\x{263A}" } );

    is( $context->response->content_type, undef );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
Template file: template_1.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: \x{263A}
var_2: stash_2
var_3: 
EOT

}

# $output = $View_A->render( template => 'template_1.htc' )
{

    my $output = $View_A->render( template => 'template_1.htc' );

    is( $output, encode( 'utf-8', <<EOT ) );
Template file: template_1.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: 
var_2: 
var_3: 
EOT

}

# $output = $View_A->render( template => 'template_1.htc', encoding => 'iso-8859-1' )
{

    my $output = $View_A->render( template => 'template_1.htc', encoding => 'iso-8859-1' );

    is( $output, encode( 'iso-8859-1', <<EOT ) );
Template file: template_1.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: 
var_2: 
var_3: 
EOT

}

# $output = $View_A->render( template => 'template_1.htc', encoding => 'windows-1252' )
{

    my $output = $View_A->render( template => 'template_1.htc', encoding => 'windows-1252' );

    is( $output, encode( 'windows-1252', <<EOT ) );
Template file: template_1.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: 
var_2: 
var_3: 
EOT

}

# $output = $View_A->render( context => $context, template => 'template_1.htc' )
{

    my $context = _fake_context();

    my $output = $View_A->render( context => $context, template => 'template_1.htc' );

    is( $context->response->content_type, undef );
    is( $context->response->body->length, 0 );

    is( $output, encode( 'utf-8', <<EOT ) );
Template file: template_1.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: 
var_2: 
var_3: 
EOT

}

# $output = $View_A->render( context => $context, template => 'template_1.txt.htc' )
{

    my $context = _fake_context();

    my $output = $View_A->render( context => $context, template => 'template_1.txt.htc' );

    is( $context->response->content_type, undef );
    is( $context->response->body->length, 0 );

    is( $output, encode( 'utf-8', <<EOT ) );
Template file: template_1.txt.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: 
var_2: 
var_3: 
EOT

}

# $output = $View_A->render( context => $context, template => 'template_1.htc', parameters => \%parameters ) + stash
{

    my $context = _fake_context();

    $context->stash->{'var_1'} = 'stash_1';
    $context->stash->{'var_2'} = 'stash_2';

    my $output = $View_A->render( context => $context, template => 'template_1.htc', parameters => { 'var_1' => "\x{263A}" } );

    is( $context->response->content_type, undef );
    is( $context->response->body->length, 0 );

    is( $output, encode( 'utf-8', <<EOT ) );
Template file: template_1.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: \x{263A}
var_2: stash_2
var_3: 
EOT

}


# $View_B->render( context => $context, template => 'B/template_1.htc' )
{

    my $context = _fake_context();

    $View_B->render( context => $context, template => 'B/template_1.htc' );

    is( $context->response->content_type, undef );

    is( $context->response->body->as_string, encode( 'iso-8859-1', <<EOT ) );
Template file: B/template_1.htc
Template file encoding: ISO-8859-1
Umlaute: \x{00E4} \x{00F6} \x{00FC}
var_1: 
var_2: 
var_3: 
EOT

}

# $View_B->render( context => $context, template => 'B/template_1.htc', encoding => 'utf-8' )
{

    my $context = _fake_context();

    $View_B->render( context => $context, template => 'B/template_1.htc', encoding => 'utf-8' );

    is( $context->response->content_type, undef );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
Template file: B/template_1.htc
Template file encoding: ISO-8859-1
Umlaute: \x{00E4} \x{00F6} \x{00FC}
var_1: 
var_2: 
var_3: 
EOT

}

# $View_B->render( context => $context, template => 'B/template_1.htc', parameters => \%parameters )
{

    my $context = _fake_context();

    $View_B->render( context => $context, template => 'B/template_1.htc', parameters => { 'var_1' => "\x{00E4} \x{00F6} \x{00FC}" } );

    is( $context->response->content_type, undef );

    is( $context->response->body->as_string, encode( 'iso-8859-1', <<EOT ) );
Template file: B/template_1.htc
Template file encoding: ISO-8859-1
Umlaute: \x{00E4} \x{00F6} \x{00FC}
var_1: \x{00E4} \x{00F6} \x{00FC}
var_2: 
var_3: 
EOT

}

# $View_B->render( context => $context, template => 'B/template_1.txt.htc' )
{

    my $context = _fake_context();

    $View_B->render( context => $context, template => 'B/template_1.txt.htc' );

    is( $context->response->content_type, 'text/plain; charset=ISO-8859-1' );

    is( $context->response->body->as_string, encode( 'iso-8859-1', <<EOT ) );
Template file: B/template_1.txt.htc
Template file encoding: ISO-8859-1
Umlaute: \x{00E4} \x{00F6} \x{00FC}
var_1: 
var_2: 
var_3: 
EOT

}

# $View_B->render( context => $context, template => 'B/template_1.txt.htc', encoding => 'utf-8' )
{

    my $context = _fake_context();

    $View_B->render( context => $context, template => 'B/template_1.txt.htc', encoding => 'utf-8' );

    is( $context->response->content_type, 'text/plain; charset=UTF-8' );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
Template file: B/template_1.txt.htc
Template file encoding: ISO-8859-1
Umlaute: \x{00E4} \x{00F6} \x{00FC}
var_1: 
var_2: 
var_3: 
EOT

}


# $View_C->render( context => $context, template => 'C/template_1.htc' )
{

    my $context = _fake_context();

    $View_C->render( context => $context, template => 'C/template_1.htc' );

    is( $context->response->content_type, undef );

    is( $context->response->body->as_string, encode( 'cp1252', <<EOT ) );
Template file: C/template_1.htc
Template file encoding: windows-1252
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
var_1: 
var_2: 
var_3: 
EOT

}

# $View_C->render( context => $context, template => 'C/template_1.htc', parameters => \%parameters )
{

    my $context = _fake_context();

    $View_C->render( context => $context, template => 'C/template_1.htc', parameters => { 'var_1' => "\x{00E4} \x{00F6} \x{00FC}" } );

    is( $context->response->content_type, undef );

    is( $context->response->body->as_string, encode( 'cp1252', <<EOT ) );
Template file: C/template_1.htc
Template file encoding: windows-1252
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
var_1: \x{00E4} \x{00F6} \x{00FC}
var_2: 
var_3: 
EOT

}

# $View_C->render( context => $context, template => 'C/template_1.htc', encoding => 'utf-8' )
{

    my $context = _fake_context();

    $View_C->render( context => $context, template => 'C/template_1.htc', encoding => 'utf8' );

    is( $context->response->content_type, undef );

    is( $context->response->body->as_string, encode( 'utf8', <<EOT ) );
Template file: C/template_1.htc
Template file encoding: windows-1252
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
var_1: 
var_2: 
var_3: 
EOT

}


# $View_D->render( context => $context, template => 'D/template_1.htc' ), context variable
{

    my $context = _fake_context();

    $context->stash->{'var_2'} = "\x{263A}";

    $View_D->render( context => $context, template => 'D/template_1.htc' );

    is( $context->response->content_type, 'text/plain; charset=UTF-8' );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
Template file: D/template_1.htc
Template file encoding: UTF-8
var_1: $context
var_2: \x{263A}
var_3: 
EOT

}


# $View_E->render( context => $context, template => 'template_1.htc' )
{

    my $context = _fake_context();

    $View_E->render( context => $context, template => 'template_1.htc' );

    is( $context->response->content_type, undef );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
Template file: E/template_1.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: 
var_2: 
var_3: 
EOT

}

# $View_E->render( context => $context, template => 'template_1.txt.htc' )
{

    my $context = _fake_context();

    $View_E->render( context => $context, template => 'template_1.txt.htc' );

    is( $context->response->content_type, 'text/plain; charset=UTF-8' );

    is( $context->response->body->as_string, encode( 'utf-8', <<EOT ) );
Template file: E/template_1.txt.htc
Template file encoding: UTF-8
Umlaute: \x{00E4} \x{00F6} \x{00FC}
Euro: \x{20AC}
Smiley: \x{263A}
var_1: 
var_2: 
var_3: 
EOT

}


# ----------------------------------------------------------------------------------------------------------------------

sub _fake_context {

    return MyApp::Context->new(
        request  => MyApp::Request->new,
        response => MyApp::Response->new,
        @_
    );

}

