# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Cache/Memcached.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Cache::Memcached;

use GX::Exception;

use Cache::Memcached ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Cache';

has 'memcached' => (
    isa        => 'Object',
    constraint => sub { $_->isa( 'Cache::Memcached' ) },
    initialize => 1,
    accessors  => {
        '_get_memcached' => { type => 'get' },
        '_set_memcached' => { type => 'set' }
    }
);

has 'namespace' => (
    isa        => 'Scalar',
    initialize => 1,
    accessors  => {
        '_get_namespace' => { type => 'get' },
        '_set_namespace' => { type => 'set' }
    }
);

has 'options' => (
    isa        => 'Hash',
    initialize => 1,
    accessors  => {
        '_get_options' => { type => 'get_reference' }
    }
);

has 'servers' => (
    isa        => 'Array',
    initialize => 1,
    accessors  => {
        '_get_servers' => { type => 'get_reference' }
    }
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

__PACKAGE__->_install_import_method;


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add {

    return shift->memcached->add( @_ );

}

sub clear {

    return $_[0]->memcached->flush_all;

}

sub get {

    my $invocant = shift;

    if ( @_ > 1 ) {

        my $data = $invocant->memcached->get_multi( @_ );

        if ( $data ) {
            no warnings 'uninitialized';
            return wantarray ? @$data{@_} : $data;
        }
        else {
            return;
        }

    }
    else {
        return $invocant->memcached->get( $_[0] );
    }

}

sub memcached {

    return $_[0]->instance->_get_memcached;

}

sub namespace {

    return $_[0]->instance->_get_namespace;

}

sub options {

    return %{$_[0]->instance->_get_options};

}

sub remove {

    return shift->memcached->remove( @_ );

}

sub replace {

    return shift->memcached->replace( @_ );

}

sub set {

    return shift->memcached->set( @_ );

}

sub servers {

    return @{$_[0]->instance->_get_servers};

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _create_memcached {

    my $self = shift;

    my $memcached = eval {
        Cache::Memcached->new(
            $self->options,
            namespace => $self->namespace,
            servers   => [ $self->servers ]
        );
    };

    if ( ! $memcached ) {
        GX::Exception->throw(
            message      => "Cannot instantiate Cache::Memcached",
            subexception => $@
        );
    }

    return $memcached;

}

sub _setup {

    my $self = shift;
    my $args = shift;

    $self->SUPER::_setup( $args );

    $self->_setup_memcached;

    return;

}

sub _setup_memcached {

    my $self = shift;

    if ( ! $self->memcached ) {
        $self->_set_memcached( $self->_create_memcached );
    }

    return;

}

sub _setup_config {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'namespace'} ) {
        $self->_set_namespace( delete $args->{'namespace'} );
    }
    else {
        $self->_set_namespace( ref $self );
    }

    if ( exists $args->{'servers'} ) {

        my $servers = delete $args->{'servers'};

        if ( ref $servers ne 'ARRAY' ) {
            throw "Invalid option (\"servers\" must be an array reference)";
        }

        @{$self->_get_servers} = @$servers;

    }
    else {
        @{$self->_get_servers} = qw( 127.0.0.1:11211 );
    }

    if ( exists $args->{'options'} ) {

        my $options = delete $args->{'options'};

        if ( ref $options ne 'HASH' ) {
            throw "Invalid option (\"options\" must be a hash reference)";
        }

        %{$self->_get_options} = %$options;

    }

    $self->SUPER::_setup_config( $args );

    return;

}

sub _start {

    my $self = shift;

    $self->memcached->disconnect_all;

    return;

}


1;

__END__

=head1 NAME

GX::Cache::Memcached - Base class for Memcached-based cache components

=head1 SYNOPSIS

    package MyApp::Cache::Default;
    
    use GX::Cache::Memcached;
    
    __PACKAGE__->setup(
        servers => [ '127.0.0.1:11211' ]
    );
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Cache::Memcached> class which extends the
L<GX::Cache> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns the cache component instance.

    $cache = $cache_class->new;

=over 4

=item Returns:

=over 4

=item * C<$cache> ( L<GX::Cache::Memcached> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

All public methods can be called both as instance and class methods.

=head3 C<add>

Like C<< L<set()|/set> >>, but only stores the given value if the key does not
already exist.

    $result = $cache->add( $key, $value );
    $result = $cache->add( $key, $value, $expire_time );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=item * C<$value> ( scalar )

=item * C<$expire_time> ( integer ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<clear>

Clears the cache.

    $cache->clear;

=head3 C<get>

Retrieves the value(s) for the given key(s).

    $value = $cache->get( $key );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=back

=item Returns:

=over 4

=item * C<$value> ( scalar )

=back

=back

    @values = $cache->get( @keys );

=over 4

=item Arguments:

=over 4

=item * C<@keys> ( strings )

=back

=item Returns:

=over 4

=item * C<@values> ( scalars )

=back

=back

If C<get()> is called with more than one key but in scalar context, it returns
a reference to a hash with the retrieved key / value pairs.

    $pairs = $cache->get( @keys );

=over 4

=item Arguments:

=over 4

=item * C<@keys> ( strings )

=back

=item Returns:

=over 4

=item * C<$pairs> ( C<HASH> reference )

=back

=back

=head3 C<memcached>

Returns the associated L<Cache::Memcached> instance.

    $memcached = $cache->memcached;

=over 4

=item Returns:

=over 4

=item * C<$memcached> ( L<Cache::Memcached> object )

=back

=back

=head3 C<namespace>

Returns the namespace key prefix.

    $namespace = $cache->namespace;

=over 4

=item Returns:

=over 4

=item * C<$namespace> ( string | C<undef> )

=back

=back

=head3 C<options>

Returns a list with the additional options that are passed to the
L<Cache::Memcached> constructor.

    %options = $cache->options;

=over 4

=item Returns:

=over 4

=item * C<%options> ( named list )

=back

=back

=head3 C<remove>

Removes the specified key / value pair. Returns true if the pair was actually
stored and successfully removed, otherwise false.

    $result = $cache->remove( $key );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<replace>

Like C<< L<set()|/set> >>, but only stores the given value if the key already
exists.

    $result = $cache->replace( $key, $value );
    $result = $cache->replace( $key, $value, $expire_time );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=item * C<$value> ( scalar )

=item * C<$expire_time> ( integer ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<servers>

Returns a list with the memcached server addresses.

    @servers = $cache->servers;

=over 4

=item Returns:

=over 4

=item * C<@servers> ( strings )

=back

=back

=head3 C<set>

Unconditionally sets the specified key to the given value. Returns true on
success, otherwise false.

    $result = $cache->set( $key, $value );
    $result = $cache->set( $key, $value, $expire_time );

=over 4

=item Arguments:

=over 4

=item * C<$key> ( string )

=item * C<$value> ( scalar )

=item * C<$expire_time> ( integer ) [ optional ]

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<setup>

Sets up the component.

    $cache->setup( %options );

=over 4

=item Options:

=over 4

=item * C<namespace> ( string | C<undef> )

A key prefix. Defaults to the class name of the component.

=item * C<options> ( C<HASH> reference )

Additional options for the L<Cache::Memcached> constructor.

=item * C<servers> ( C<ARRAY> reference )

A list of memcached server addresses. Defaults to a single address:
"127.0.0.1:11211".

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head1 SEE ALSO

=over 4

=item * L<Cache::Memcached>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
