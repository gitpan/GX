# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Route/Dynamic.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Route::Dynamic;

use GX::Exception;
use GX::HTTP::Parameters;
use GX::HTTP::Util qw( url_decode url_encode );


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Route';

has 'action' => (
    isa        => 'Object',
    required   => 1,
    constraint => sub { $_->isa( 'GX::Action' ) },
    accessor   => { type => 'get' }
);

has 'constraints' => (
    isa        => 'Hash',
    initialize => 1,
    constraint => sub { defined && eval { qr/$_/ } or throw "Invalid constraint" for values %{$_}; 1 },
    accessor   => { type => 'get_list' }
);

has 'defaults' => (
    isa        => 'Hash',
    initialize => 1,
    accessor   => { type => 'get_list' }
);

has 'host' => (
    isa        => 'Scalar',
    initialize => 1,
    accessor   => { type => 'get' }
);

has 'host_regex' => (
    isa        => 'Scalar',
    initialize => 0,
    constraint => sub { ref eq 'Regexp' },
    accessor   => { type => 'get' }
);

has 'host_variables' => (
    isa        => 'Array',
    initialize => 0,
    accessor   => { type => 'get_list' }
);

has 'is_reversible' => (
    isa        => 'Bool',
    initialize => 1,
    default    => 1,
    accessor   => { type => 'get' }
);

has 'methods' => (
    isa        => 'Array',
    initialize => 1,
    constraint => sub { defined && length or throw "Invalid method name" for @{$_}; 1 },
    processor  => sub { @{$_} = map { uc } @{$_} },
    accessor   => { type => 'get_list' }
);

has 'methods_regex' => (
    isa        => 'Scalar',
    initialize => 0,
    constraint => sub { ref eq 'Regexp' },
    accessor   => { type => 'get' }
);

has 'path' => (
    isa        => 'Scalar',
    initialize => 1,
    accessor   => { type => 'get' }
);

has 'path_regex' => (
    isa        => 'Scalar',
    initialize => 0,
    constraint => sub { ref eq 'Regexp' },
    accessor   => { type => 'get' }
);

has 'path_variables' => (
    isa        => 'Array',
    initialize => 0,
    accessor   => { type => 'get_list' }
);

has 'reverse_host' => (
    isa        => 'Scalar',
    initialize => 0,
    accessor   => { type => 'get' }
);

has 'reverse_host_variables' => (
    isa        => 'Array',
    initialize => 0,
    accessor   => { type => 'get_list' }
);

has 'reverse_path' => (
    isa        => 'Scalar',
    initialize => 0,
    accessor   => { type => 'get' }
);

has 'reverse_path_variables' => (
    isa        => 'Array',
    initialize => 0,
    accessor   => { type => 'get_list' }
);

has 'reverse_scheme' => (
    isa        => 'Scalar',
    initialize => 0,
    accessor   => { type => 'get' }
);

has 'schemes' => (
    isa        => 'Array',
    initialize => 1,
    constraint => sub { defined && length or throw "Invalid URI scheme" for @{$_}; 1 },
    processor  => sub { @{$_} = map { lc } @{$_} },
    accessor   => { type => 'get_list' }
);

has 'schemes_regex' => (
    isa        => 'Scalar',
    initialize => 0,
    constraint => sub { ref eq 'Regexp' },
    accessor   => { type => 'get' }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub construct_path {

    my $self = shift;

    if ( ! $self->{'is_reversible'} ) {
        complain "Route is not reversible";
    }

    if ( ! defined $self->{'reverse_path'} ) {
        complain "Undefined reverse path";
    }

    my $path;

    if ( @{$self->{'reverse_path_variables'}} ) {

        my %parameters = ( %{$self->{'defaults'}}, @_ ); 

        my @parameters = map {
            $parameters{$_} // complain( "Missing value for path variable \"$_\"" )
        } @{$self->{'reverse_path_variables'}};

        $path = eval { sprintf( $self->{'reverse_path'}, map { url_encode( $_ ) } @parameters ) };

        if ( $@ ) {
            complain $@;
        }

    }
    else {
        $path = $self->{'reverse_path'};
    }

    return $path;

}

sub construct_uri {

    my $self = shift;
    my %args = @_;

    if ( ! $self->{'is_reversible'} ) {
        complain "Route is not reversible";
    }

    if ( ! exists $args{'path'} ) {

        my %parameters;

        if ( exists $args{'parameters'} ) {

            if ( ref $args{'parameters'} ne 'HASH' ) {
                complain "Invalid argument (\"parameters\" must be a hash reference)";
            }

            %parameters = %{ delete $args{'parameters'} };

        }

        $args{'path'} = eval { $self->construct_path( %parameters ) };

        if ( $@ ) {
            complain $@;
        }

    }

    if ( ! exists $args{'scheme'} ) {
        $args{'scheme'} = $self->{'reverse_scheme'};
    }

    if ( ! exists $args{'host'} ) {
        $args{'host'} = $self->{'reverse_host'};
    }

    my $uri = eval { $self->_construct_uri( %args ) };

    if ( $@ ) {
        complain $@;
    }

    return $uri;

}

sub match {

    my $self    = shift;
    my $context = shift;

    my $request = $context->request or return undef;

    no warnings 'uninitialized';

    if ( $self->{'methods_regex'} ) {
        return undef if $request->method !~ $self->{'methods_regex'};
    }

    if ( $self->{'schemes_regex'} ) {
        return undef if $request->scheme !~ $self->{'schemes_regex'};
    }

    my $parameters;

    if ( $self->{'host_regex'} ) {

        return undef if $request->host !~ $self->{'host_regex'};

        if ( @{$self->{'host_variables'}} ) {

            $parameters ||= GX::HTTP::Parameters->new;

            my $i = 1;
            for ( @{$self->{'host_variables'}} ) {
                no strict 'refs';
                $parameters->add( $_ => url_decode( ${$i} ) ) if defined ${$i};
                $i++;
            }

        }

    }

    if ( $self->{'path_regex'} ) {

        return undef if $request->path !~ $self->{'path_regex'};

        if ( @{$self->{'path_variables'}} ) {

            $parameters ||= GX::HTTP::Parameters->new;

            my $i = 1;
            for ( @{$self->{'path_variables'}} ) {
                no strict 'refs';
                $parameters->add( $_ => url_decode( ${$i} ) ) if defined ${$i};
                $i++;
            }

        }

    }

    if ( keys %{$self->{'defaults'}} ) {

        $parameters ||= GX::HTTP::Parameters->new;

        for ( keys %{$self->{'defaults'}} ) {
            $parameters->add( $_ => $self->{'defaults'}{$_} ) unless $parameters->exists( $_ );
        }
 
    }

    my $format = $parameters ? $parameters->get( 'format' ) : undef;

    return GX::Route::Match->new(
        action     => $self->{'action'},
        parameters => $parameters,
        format     => $format
    );

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub __finalize {

    my $self = shift;
    my $args = shift;

    if ( ! exists $self->{'methods_regex'} ) {

        if ( @{$self->{'methods'}} ) {
            my $pattern = join( '|', map { quotemeta } @{$self->{'methods'}} );
            $self->{'methods_regex'} = qr/^$pattern$/;
        }
        else {
            $self->{'methods_regex'} = undef;
        }

    }

    if ( ! exists $self->{'schemes_regex'} ) {

        if ( @{$self->{'schemes'}} ) {
            my $pattern = join( '|', map { quotemeta } @{$self->{'schemes'}} );
            $self->{'schemes_regex'} = qr/^$pattern$/;
        }
        else {
            $self->{'schemes_regex'} = undef;
        }

    }

    if ( ! exists $self->{'host_regex'} ) {

        if ( defined $self->{'host'} ) {

            my @variables;

            ( my $pattern = $self->{'host'} ) =~ s!
                \{((?:[^{}]+|\{[0-9,]+\})+)\} |
                (\*)                          |
                ([^{}*]+)
            !
                if ( $1 ) {
                    my ( $variable, $constraint ) = split( /:/, $1, 2 );
                    push @variables, $variable;
                    $constraint = $self->{'constraints'}{$variable} unless defined $constraint;
                    defined $constraint ? "($constraint)" : "([^.]+)";
                } elsif ( $2 ) {
                    "(?:[^.]+)";
                } else {
                    quotemeta( $3 );
                }
            !egx;

            $self->{'host_regex'} = eval { qr/^$pattern$/ };

            if ( $@ ) {
                throw "Invalid host pattern \"$$self{'host'}\"";
            }

            $self->{'host_variables'} = \@variables;

        }
        else {
            $self->{'host_regex'}     = undef;
            $self->{'host_variables'} = [];
        }

    }
    else {
        $self->{'host_variables'} ||= [];
    }

    if ( ! exists $self->{'path_regex'} ) {

        if ( defined $self->{'path'} ) {

            my @variables;

            ( my $pattern = $self->{'path'} ) =~ s!
                \{((?:[^{}]+|\{[0-9,]+\})+)\} |
                (\*)                          |
                ([^{}*]+)
            !
                if ( $1 ) {
                    my ( $variable, $constraint ) = split( /:/, $1, 2 );
                    push @variables, $variable;
                    $constraint = $self->{'constraints'}{$variable} unless defined $constraint;
                    defined $constraint ? "($constraint)" : "([^/]+)";
                } elsif ( $2 ) {
                    "(?:[^/]+)";
                } else {
                    quotemeta( $3 );
                }
            !egx;

            $self->{'path_regex'} = eval { qr/^$pattern$/ };

            if ( $@ ) {
                throw "Invalid path pattern \"$$self{'path'}\"";
            }

            $self->{'path_variables'} = \@variables;

        }
        else {
            $self->{'path_regex'}     = undef;
            $self->{'path_variables'} = [];
        }

    }
    else {
        $self->{'path_variables'} ||= [];
    }

    if ( $self->{'is_reversible'} ) {

        if ( ! exists $self->{'reverse_scheme'} ) {
            $self->{'reverse_scheme'} = $self->{'schemes'}[0];
        }

        if ( ! exists $self->{'reverse_host'} ) {

            $self->{'reverse_host'}           = undef;
            $self->{'reverse_host_variables'} = [];

            if ( defined $self->{'host'} ) {

                my $reversible = 1;

                my @reverse_host_variables;

                ( my $reverse_host = $self->{'host'} ) =~ s!
                    \{((?:[^{}]+|\{[0-9,]+\})+)\} |
                    (\*)                          |
                    ([^{}*]+)
                !
                    if ( $1 ) {
                        my ( $variable, undef ) = split( /:/, $1, 2 );
                        push @reverse_host_variables, $variable;
                        '%s';
                    } elsif ( $2 ) {
                        $reversible = 0;
                    } else {
                        $3;
                    }
                !egx;

                if ( $reversible ) {
                    $self->{'reverse_host'}           = $reverse_host;
                    $self->{'reverse_host_variables'} = \@reverse_host_variables;
                }

            }

        }
        else {
            $self->{'reverse_host_variables'} ||= [];
        }

        if ( ! exists $self->{'reverse_path'} ) {

            $self->{'reverse_path'}           = undef;
            $self->{'reverse_path_variables'} = [];

            if ( defined $self->{'path'} ) {

                my $reversible = 1;

                my @reverse_path_variables;

                ( my $reverse_path = $self->{'path'} ) =~ s!
                    \{((?:[^{}]+|\{[0-9,]+\})+)\} |
                    (\*)                          |
                    ([^{}*]+)
                !
                    if ( $1 ) {
                        my ( $variable, undef ) = split( /:/, $1, 2 );
                        push @reverse_path_variables, $variable;
                        '%s';
                    } elsif ( $2 ) {
                        $reversible = 0;
                    } else {
                        $3;
                    }
                !egx;

                if ( $reversible ) {
                    $self->{'reverse_path'}           = $reverse_path;
                    $self->{'reverse_path_variables'} = \@reverse_path_variables;
                }

            }

        }
        else {
            $self->{'reverse_path_variables'} ||= [];
        }

    }
    else {
        $self->{'reverse_scheme'}         = undef;
        $self->{'reverse_host'}           = undef;
        $self->{'reverse_host_variables'} = [];
        $self->{'reverse_path'}           = undef;
        $self->{'reverse_path_variables'} = [];
    }

    return;

}


1;

__END__

=head1 NAME

GX::Route::Dynamic - Dynamic route class

=head1 SYNOPSIS

    # Load the class
    use GX::Route::Dynamic;
    
    # Create a route object
    $route = GX::Route::Dynamic->new(
        action => $application->action( 'Blog', 'show' ),
        host   => 'myblog.com',
        path   => '/posts/{id:\d+}'
    );

=head1 DESCRIPTION

This module provides the L<GX::Route::Dynamic> class which extends the
L<GX::Route> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new L<GX::Route::Dynamic> object.

    $route = GX::Route::Dynamic->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<action> ( L<GX::Action> object ) [ required ]

The associated action.

=item * C<constraints> ( C<HASH> reference )

A reference to a hash with constraints for the route's dynamic parts.

=item * C<defaults> ( C<HASH> reference )

A reference to a hash with default values for the route's dynamic parts.

=item * C<host> ( string )

The hostname pattern to bind the route to. If omitted, the route will match
any hostname.

=item * C<is_reversible> ( bool )

A boolean flag indicating whether the route is reversible or not. Defaults to
true.

=item * C<methods> ( C<ARRAY> reference )

A reference to an array with the names of the HTTP methods to bind the route
to. If omitted, the route will match any method.

=item * C<path> ( string )

The path pattern to bind the route to. If omitted, the route will match any
path. Trailing slashes are significant.

=item * C<schemes> ( C<ARRAY> reference )

A reference to an array with the URI schemes to bind the route to. If omitted,
the route will match any scheme.

=back

=item Internal attributes:

=over 4

=item * C<host_regex> ( C<Regexp> )

=item * C<host_variables> ( C<ARRAY> reference )

=item * C<methods_regex> ( C<Regexp> )

=item * C<path_regex> ( C<Regexp> )

=item * C<path_variables> ( C<ARRAY> reference )

=item * C<reverse_host> ( string )

=item * C<reverse_host_variables> ( C<ARRAY> reference )

=item * C<reverse_path> ( string )

=item * C<reverse_path_variables> ( C<ARRAY> reference )

=item * C<reverse_scheme> ( string )

=item * C<schemes_regex> ( C<Regexp> )

=back

=item Returns:

=over 4

=item * C<$route> ( L<GX::Route::Dynamic> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<action>

Returns the associated action.

    $action = $route->action;

=over 4

=item Returns:

=over 4

=item * C<$action> ( L<GX::Action> object )

=back

=back

=head3 C<construct_path>

Constructs the path portion of an URI that would match the route.

    $path = $route->construct_path( %parameters );

=over 4

=item Arguments:

=over 4

=item * C<%parameters> ( named list )

Values for the dynamic parts of the path.

=back

=item Returns:

=over 4

=item * C<$path> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Also see L<Example #4|/"Example #4"> below.

=head3 C<construct_uri>

Constructs an URI that would match the route.

    $uri = $route->construct_uri( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<fragment> ( string )

The fragment identifier of the URI.

=item * C<host> ( string )

The hostname to use as the authority component of the URI. Defaults to the
C<reverse_host> attribute.

=item * C<parameters> ( C<HASH> reference )

A reference to a hash with values for the dynamic parts of the URI.

=item * C<path> ( string )

The path portion of the URI. Defaults to the C<reverse_path> attribute.

=item * C<port> ( integer )

The port number to append to the hostname.

=item * C<query> ( string )

The query component of the URI.

=item * C<scheme> ( string )

The scheme part of the URI. Defaults to the C<reverse_scheme> attribute.
"http" is assumed as a fallback. 

=back

=item Returns:

=over 4

=item * C<$uri> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

Also see L<Example #4|/"Example #4"> below.

=head3 C<is_reversible>

Returns true if the route is reversible, otherwise false.

    $result = $route->is_reversible;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<match>

Returns a L<GX::Route::Match> object if the route matches, otherwise C<undef>.

    $result = $route->match( $context );

=over 4

=item Arguments:

=over 4

=item * C<$context> ( L<GX::Context> object )

=back

=item Returns:

=over 4

=item * C<$result> ( L<GX::Route::Match> object | C<undef> )

=back

=back

=head2 Internal Methods

=head3 C<constraints>

Internal method.

    %constraints = $route->constraints;

=over 

=item Returns:

=over 4

=item * C<%constraints> ( named list )

=back

=back

=head3 C<defaults>

Internal method.

    %defaults = $route->defaults;

=over 

=item Returns:

=over 4

=item * C<%defaults> ( named list )

=back

=back

=head3 C<host>

Internal method.

    $host = $route->host;

=over 

=item Returns:

=over 4

=item * C<$host> ( string | C<undef> )

=back

=back

=head3 C<host_regex>

Internal method.

    $host_regex = $route->host_regex;

=over 

=item Returns:

=over 4

=item * C<$host_regex> ( C<Regexp> | C<undef> )

=back

=back

=head3 C<host_variables>

Internal method.

    @host_variables = $route->host_variables;

=over 

=item Returns:

=over 4

=item * C<@host_variables> ( strings )

=back

=back

=head3 C<methods>

Internal method.

    @methods = $route->methods;

=over 

=item Returns:

=over 4

=item * C<@methods> ( strings )

=back

=back

=head3 C<methods_regex>

Internal method.

    $methods_regex = $route->methods_regex;

=over 

=item Returns:

=over 4

=item * C<$methods_regex> ( C<Regexp> | C<undef> )

=back

=back

=head3 C<path>

Internal method.

    $path = $route->path;

=over 

=item Returns:

=over 4

=item * C<$path> ( string | C<undef> )

=back

=back

=head3 C<path_regex>

Internal method.

    $path_regex = $route->path_regex;

=over 

=item Returns:

=over 4

=item * C<$path_regex> ( C<Regexp> | C<undef> )

=back

=back

=head3 C<path_variables>

Internal method.

    @path_variables = $route->path_variables;

=over 

=item Returns:

=over 4

=item * C<@path_variables> ( strings )

=back

=back

=head3 C<reverse_host>

Internal method.

    $reverse_host = $route->reverse_host;

=over 

=item Returns:

=over 4

=item * C<$reverse_host> ( string | C<undef> )

=back

=back

=head3 C<reverse_host_variables>

Internal method.

    @reverse_host_variables = $route->reverse_host_variables;

=over 

=item Returns:

=over 4

=item * C<@reverse_host_variables> ( strings )

=back

=back

=head3 C<reverse_path>

Internal method.

    $reverse_path = $route->reverse_path;

=over 

=item Returns:

=over 4

=item * C<$reverse_path> ( string | C<undef> )

=back

=back

=head3 C<reverse_path_variables>

Internal method.

    @reverse_path_variables = $route->reverse_path_variables;

=over 

=item Returns:

=over 4

=item * C<@reverse_path_variables> ( strings )

=back

=back

=head3 C<reverse_scheme>

Internal method.

    $reverse_scheme = $route->reverse_scheme;

=over 

=item Returns:

=over 4

=item * C<$reverse_scheme> ( string | C<undef> )

=back

=back

=head3 C<schemes>

Internal method.

    @schemes = $route->schemes;

=over 

=item Returns:

=over 4

=item * C<@schemes> ( strings )

=back

=back

=head3 C<schemes_regex>

Internal method.

    $schemes_regex = $route->schemes_regex;

=over 

=item Returns:

=over 4

=item * C<$schemes_regex> ( C<Regexp> | C<undef> )

=back

=back

=head1 USAGE

=head2 Examples

=head3 Example #1

Host patterns:

    host => 'myblog.com'
    host => 'myblog.com:80'
    host => 'myblog.{domain:com|org}'
    host => 'myblog.*'
    host => '{author:\w+}.myblog.com'

=head3 Example #2

Path patterns:

    path => '/posts/{id}'
    path => '/posts/{id:\d+}'
    path => '/posts/{id:\d+}.{format:html|xml}'
    path => '/posts/{year}/{month}/{day}'
    path => '/posts/{year:\d{4}}/{month:\d{2}}/{day:\d{2}}'
    path => '/posts/*/{id}'

=head3 Example #3

Using the C<constraints> option:

    $route = GX::Route::Dynamic->new(
        action      => $application->action( 'Posts', 'show_by_month' ),
        path        => '/posts/{year}/{month}',
        constraints => { 'year' => '\d{4}', 'month' => '\d{2}' }
    );

=head3 Example #4

Path / URI construction:

    $route = GX::Route::Dynamic->new(
        action   => $application->action( 'Posts', 'show' ),
        path     => '/posts/{id:\d+}.{format:html|xml}',
        defaults => { 'format' => 'html' }
    );
    
    $path = $route->construct_path( 'id' => '123' );
    # $path is '/posts/123.html'
    
    $path = $route->construct_path( 'id' => '123', 'format' => 'xml' );
    # $path is '/posts/123.xml'
    
    $uri = $route->construct_uri( host => 'myblog.com', parameters => { 'id' => '123' } );
    # $uri is 'http://myblog.com/posts/123.html'

=head1 SEE ALSO

=over 4

=item * L<GX::Route::Match>

=item * L<GX::Router>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
