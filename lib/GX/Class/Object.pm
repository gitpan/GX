# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Class/Object.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Class::Object;

use strict;
use warnings;

use base 'GX::Class';

use GX::Exception ();


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

sub import {

    my $package = shift;

    return unless $package eq __PACKAGE__;

    my $caller = caller();

    if ( $caller eq 'main' ) {
        GX::Exception->complain( "Cannot import \"$package\" into package \"main\"" );
    }

    {
        no strict 'refs';
        *{"${caller}::__initialize_instance"} = \&__initialize_instance;
        *{"${caller}::__clear_instance"}      = \&__clear_instance;
    }

    unshift( @_, 'GX::Class', superclass => $package );

    goto &GX::Class::import;

}


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;

    my $self = bless {}, $class;

    eval {
        $self->__initialize_instance( @_ )
    };

    GX::Exception->complain( $@ ) if $@;

    return $self;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub clear {

    return shift->__clear_instance( @_ );

}

sub dump {

    my $self = shift;

    require Data::Dumper;

    my $string = Data::Dumper::Dumper( $self );

    if ( defined wantarray ) {
        return $string;
    }
    else {
        warn $string;
        return;
    }

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub __build {

    my $class = shift;

    if ( ref $class ) {
        GX::Exception->complain( "__build() is a class method" );
    }

    if ( $class eq __PACKAGE__ ) {
        GX::Exception->complain( "__build() cannot be called on $class" );
    }

    $class->__build_initialize_instance;

    $class->__build_clear_instance;

    return;

}

sub __build_clear_instance {

    my $class = shift;

    if ( ref $class ) {
        GX::Exception->complain( "__build_clear_instance() is a class method" );
    }

    if ( $class eq __PACKAGE__ ) {
        GX::Exception->complain( "__build_clear_instance() cannot be called on $class" );
    }

    my $code = [];
    my $vars = {};

    push @$code,
        'sub {',
        'my $self = shift;';

    for my $attribute ( $class->meta->all_instance_attributes ) {
        next if $attribute->is_sticky;
        my $data = { 'invocant' => '$self' };
        $attribute->inline_clear_instance_slot( $data, $code, $vars );
    }

    push @$code,
        'return;',
        '}';

    $class->meta->add_method( '__clear_instance' => GX::Meta::Util::eval_code( $code, $vars ) );

    return;

}

sub __build_initialize_instance {

    my $class = shift;

    if ( ref $class ) {
        GX::Exception->complain( "__build_initialize_instance() is a class method" );
    }

    if ( $class eq __PACKAGE__ ) {
        GX::Exception->complain( "__build_initialize_instance() cannot be called on $class" );
    }

    my $meta = $class->meta;

    my $code = [];
    my $vars = {};

    push @$code,
        'sub {',
        'my $self = shift;',
        'my $args = { @_ };';

    my %attributes;

    for my $attribute ( $meta->all_instance_attributes ) {
        push @{ $attributes{$attribute->class->name} }, $attribute;
    }

    for my $class_name ( grep { $_->isa( __PACKAGE__ ) && $_ ne __PACKAGE__ } reverse $meta->linearized_isa ) {

        if ( $class_name->meta->has_method( '__initialize' ) ) {
            push @$code, $class_name . '::__initialize( $self, $args );';
        }

        if ( $attributes{$class_name} ) {

            for my $attribute ( @{$attributes{$class_name}} ) {
                my $data = { 'invocant' => '$self', 'args' => '$args' };
                $attribute->inline_initialize_instance_slot( $data, $code, $vars );
            }

        }

        if ( $class_name->meta->has_method( '__finalize' ) ) {
            push @$code, $class_name . '::__finalize( $self, $args );';
        }

    }

    push @$code,
        'return;',
        '}';

    $meta->add_method( '__initialize_instance' => GX::Meta::Util::eval_code( $code, $vars ) );

    return;

}

sub __clear_instance {

    my $self = shift;

    for my $attribute ( $self->meta->all_instance_attributes ) {
        $attribute->clear_instance_slot( $self ) unless $attribute->is_sticky;
    }

    return;

}

sub __finalize {

    # Abstract method

}

sub __initialize {

    # Abstract method

}

sub __initialize_instance {

    my $self = shift;
    my %data = @_;

    my $meta = $self->meta;

    my %attributes;

    for my $attribute ( $meta->all_instance_attributes ) {
        push @{ $attributes{$attribute->class->name} }, $attribute;
    }

    for my $class_name ( grep { $_->isa( __PACKAGE__ ) && $_ ne __PACKAGE__ } reverse $meta->linearized_isa ) {

        if ( defined &{"${class_name}::__initialize"} ) {
            ( \&{"${class_name}::__initialize"} )->( $self, \%data );
        }

        if ( $attributes{$class_name} ) {

            for my $attribute ( @{ $attributes{$class_name} } ) {
                $attribute->initialize_instance_slot( $self, \%data );
            }

        }

        if ( defined &{"${class_name}::__finalize"} ) {
            ( \&{"${class_name}::__finalize"} )->( $self, \%data );
        }

    }

    return;

}


1;

__END__

=head1 NAME

GX::Class::Object - Universal base class for instantiable classes

=head1 SYNOPSIS

    package Person;
    
    use GX::Class::Object;
    
    has 'first_name' => (
        isa      => 'String',
        required => 1
    );
    
    has 'last_name' => (
        isa      => 'String',
        required => 1
    );
    
    build;
    
    my $person = Person->new(
        first_name => 'Peter',
        last_name  => 'Venkman'
    );
    
    print "Hello " . $person->first_name . "!";

=head1 DESCRIPTION

This module provides the L<GX::Class::Object> class which extends the
L<GX::Class> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new instance of the class.

    $object = $class->new( %attributes );

=over 4

=item Arguments:

=over 4

=item * C<%attributes> ( named list )

=back

=item Returns:

=over 4

=item * C<$object> ( L<GX::Class::Object> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Exception>

=back

=back

=head2 Public Methods

=head3 C<clear>

Resets the object's attributes to their uninitialized state.

    $object->clear;

=head3 C<dump>

Stringifies the object using L<Data::Dumper>.

    $string = $object->dump;

=over 4

=item Returns:

=over 4

=item * C<$string> ( string )

=back

=back

In void context, the resulting string is printed to C<STDERR>.

    $object->dump;

=head3 C<meta>

See L<GX::Class|GX::Class/meta>.

    $meta = $class->meta;
    $meta = $object->meta;

=head2 Internal Methods

=head3 C<import>

See L<GX::Class|GX::Class/import>.

    $class->import( %arguments );

=head3 C<unimport>

See L<GX::Class|GX::Class/unimport>.

    $class->unimport;

=head3 C<__build>

Internal method.

    $class->__build;

=head3 C<__build_clear_instance>

Internal method.

    $class->__build_clear_instance;

=head3 C<__build_initialize_instance>

Internal method.

    $class->__build_initialize_instance;

=head3 C<__clear_instance>

Internal method.

    $object->__clear_instance;

This method cannot be overridden.

=head3 C<__finalize>

Internal method.

    $object->__finalize( \%attributes );

=head3 C<__initialize>

Internal method.

    $object->__initialize( \%attributes );

=head3 C<__initialize_instance>

Internal method.

    $object->__initialize_instance( %attributes );

This method cannot be overridden.

=head1 EXPORTS

See L<GX::Class|GX::Class/"EXPORTS">.

=head1 SUBCLASSES

The following classes inherit directly from L<GX::Class::Object>:

=over 4

=item * L<GX::Class::Singleton>

=back

=head1 SEE ALSO

=over 4

=item * L<GX::Class>

=item * L<GX::Meta>

=back

=head1 AUTHOR

JE<ouml>rg A. Uzarek E<lt>uzarek@runlevelnull.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2009-2011 JE<ouml>rg A. Uzarek.

This module is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License Version 3 as published by the
Free Software Foundation.

=cut
