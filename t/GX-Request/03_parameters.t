#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package MyApp::Request;
{

    use GX::Request;

}


package main;

use Scalar::Util qw( refaddr );


use Test::More tests => 57;


# body parameters
{

    my $request = MyApp::Request->new;

    $request->content_type( 'application/x-www-form-urlencoded' );
    $request->body->add( 'k0&k1=v11&k2=v21&k2=v22&k3=v31&k3=v32&k3=v33' );

    isa_ok( $request->body_parameters, 'GX::HTTP::Parameters' );

    is_deeply( [ $request->body_parameters->keys ], [ qw( k0 k1 k2 k3 ) ] );
    is_deeply( [ $request->body_parameters->get( 'kx' ) ], [] );
    is_deeply( [ $request->body_parameters->get( 'k0' ) ], [ '' ] );
    is_deeply( [ $request->body_parameters->get( 'k1' ) ], [ qw( v11 ) ] );
    is_deeply( [ $request->body_parameters->get( 'k2' ) ], [ qw( v21 v22 ) ] );
    is_deeply( [ $request->body_parameters->get( 'k3' ) ], [ qw( v31 v32 v33 ) ] );

    is_deeply( [ $request->parameters->keys ], [ qw( k0 k1 k2 k3 ) ] );
    is_deeply( [ $request->parameters->get( 'kx' ) ], [] );
    is_deeply( [ $request->parameters->get( 'k0' ) ], [ '' ] );
    is_deeply( [ $request->parameters->get( 'k1' ) ], [ qw( v11 ) ] );
    is_deeply( [ $request->parameters->get( 'k2' ) ], [ qw( v21 v22 ) ] );
    is_deeply( [ $request->parameters->get( 'k3' ) ], [ qw( v31 v32 v33 ) ] );

}

# path parameters
{

    my $path_parameters = GX::HTTP::Parameters->new;

    $path_parameters->add( 'k0', undef );
    $path_parameters->add( 'k1', 'v11' );
    $path_parameters->add( 'k2', 'v21', 'v22' );
    $path_parameters->add( 'k3', 'v31', 'v32', 'v33' );

    my $request = MyApp::Request->new( path_parameters => $path_parameters );

    is( refaddr( $request->path_parameters ), refaddr( $path_parameters ) );

    is_deeply( [ $request->path_parameters->keys ], [ qw( k0 k1 k2 k3 ) ] );
    is_deeply( [ $request->path_parameters->get( 'kx' ) ], [] );
    is_deeply( [ $request->path_parameters->get( 'k0' ) ], [ undef ] );
    is_deeply( [ $request->path_parameters->get( 'k1' ) ], [ qw( v11 ) ] );
    is_deeply( [ $request->path_parameters->get( 'k2' ) ], [ qw( v21 v22 ) ] );
    is_deeply( [ $request->path_parameters->get( 'k3' ) ], [ qw( v31 v32 v33 ) ] );

    is_deeply( [ $request->parameters->keys ], [ qw( k0 k1 k2 k3 ) ] );
    is_deeply( [ $request->parameters->get( 'kx' ) ], [] );
    is_deeply( [ $request->parameters->get( 'k0' ) ], [ undef ] );
    is_deeply( [ $request->parameters->get( 'k1' ) ], [ qw( v11 ) ] );
    is_deeply( [ $request->parameters->get( 'k2' ) ], [ qw( v21 v22 ) ] );
    is_deeply( [ $request->parameters->get( 'k3' ) ], [ qw( v31 v32 v33 ) ] );

}

# query parameters
{

    my $request = MyApp::Request->new( query => 'k0&k1=v11&k2=v21&k3=v31&k2=v22&k3=v32&k3=v33' );

    isa_ok( $request, 'GX::Request' );

    isa_ok( $request->parameters, 'GX::HTTP::Parameters' );
    isa_ok( $request->query_parameters, 'GX::HTTP::Parameters' );

    is_deeply( [ $request->query_parameters->keys ], [ qw( k0 k1 k2 k3 ) ] );
    is_deeply( [ $request->query_parameters->get( 'kx' ) ], [] );
    is_deeply( [ $request->query_parameters->get( 'k0' ) ], [ '' ] );
    is_deeply( [ $request->query_parameters->get( 'k1' ) ], [ qw( v11 ) ] );
    is_deeply( [ $request->query_parameters->get( 'k2' ) ], [ qw( v21 v22 ) ] );
    is_deeply( [ $request->query_parameters->get( 'k3' ) ], [ qw( v31 v32 v33 ) ] );

    is_deeply( [ $request->parameters->keys ], [ qw( k0 k1 k2 k3 ) ] );
    is_deeply( [ $request->parameters->get( 'kx' ) ], [] );
    is_deeply( [ $request->parameters->get( 'k0' ) ], [ '' ] );
    is_deeply( [ $request->parameters->get( 'k1' ) ], [ qw( v11 ) ] );
    is_deeply( [ $request->parameters->get( 'k2' ) ], [ qw( v21 v22 ) ] );
    is_deeply( [ $request->parameters->get( 'k3' ) ], [ qw( v31 v32 v33 ) ] );

}

# body, path and query parameters
{

    my $request = MyApp::Request->new;

    my $path_parameters = GX::HTTP::Parameters->new;
    $path_parameters->add( 'k0', undef );
    $path_parameters->add( 'k1', 'v11' );
    $path_parameters->add( 'k2', 'v21' );
    $path_parameters->add( 'k3', 'v31' );

    $request->path_parameters( $path_parameters );

    $request->query( 'k0&k1=v12&k2=v22&k3=v32' );

    $request->content_type( 'application/x-www-form-urlencoded' );
    $request->body->add( 'k0&k1=v13&k2=v23&k3=v33' );

    is_deeply( [ $request->parameters->keys ], [ qw( k0 k1 k2 k3 ) ] );
    is_deeply( [ $request->parameters->get( 'kx' ) ], [] );
    is_deeply( [ $request->parameters->get( 'k0' ) ], [ undef, '', '' ] );
    is_deeply( [ $request->parameters->get( 'k1' ) ], [ qw( v11 v12 v13 ) ] );
    is_deeply( [ $request->parameters->get( 'k2' ) ], [ qw( v21 v22 v23 ) ] );
    is_deeply( [ $request->parameters->get( 'k3' ) ], [ qw( v31 v32 v33 ) ] );

}

# parameter()
{

    my $request = MyApp::Request->new( query => 'k1=v11&k2=v21&k3=v31&k2=v22&k3=v32&k3=v33' );

    is( $request->parameter( 'k1' ), 'v11' );
    is( $request->parameter( 'k2' ), 'v21' );
    is( $request->parameter( 'k3' ), 'v31' );
    is( $request->parameter( 'kx' ), undef );

    is_deeply( [ $request->parameter( 'k1' ) ], [ qw( v11 ) ] );
    is_deeply( [ $request->parameter( 'k2' ) ], [ qw( v21 v22 ) ] );
    is_deeply( [ $request->parameter( 'k3' ) ], [ qw( v31 v32 v33 ) ] );
    is_deeply( [ $request->parameter( 'kx' ) ], [] );

}

# parameter(), empty parameters container
{

    my $request = MyApp::Request->new;

    is( $request->parameter( 'kx' ), undef );

    is_deeply( [ $request->parameter( 'kx' ) ], [] );

}

