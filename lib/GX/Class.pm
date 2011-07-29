# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Class.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Class;

use strict;
use warnings;

use GX::Class::Util;
use GX::Exception ();
use GX::Meta;

use Scalar::Util ();


# ----------------------------------------------------------------------------------------------------------------------
# Export mechanism
# ----------------------------------------------------------------------------------------------------------------------

my %KEYWORD_FACTORY = (

    'build' => sub {

        my $class = shift;

        return sub {

            if ( caller ne $class ) {
                GX::Exception->complain( "Package mismatch" );
            }

            $class->__build if $class->can( '__build' );

            eval "package $class; no GX::Class;";

            return;

        };

    },

    'extends' => sub {

        my $class = shift;

        return sub {

            if ( caller ne $class ) {
                GX::Exception->complain( "Package mismatch" );
            }

            my @superclasses = @_;

            eval {
                $class->meta->inherit_from( @superclasses );
            };

            if ( $@ ) {
                GX::Exception->complain( $@ );
            }

            for ( @superclasses ) {
                GX::Class::Util::class_exists( $_ ) or GX::Meta::Util::load_module( $_ ) or next;
            }

            return;

        };

    },

    'has' => sub {

        my $class = shift;

        return sub {

            if ( caller ne $class ) {
                GX::Exception->complain( "Package mismatch" );
            }

            my $name = shift;

            if ( @_ % 2 ) {
                GX::Exception->complain( "Odd number of options" );
            }

            my %args = @_;

            eval {

                my $attribute = $class->meta->add_attribute( %args, name => $name );

                if ( ! exists $args{'accessor'} && ! exists $args{'accessors'} ) {

                    if (
                        $name =~ GX::Meta::Constants::REGEX_METHOD_NAME &&
                        ! $class->meta->has_method( $name )
                    ) {
                        $attribute->add_accessor( name => $name );
                    }

                }

                $attribute->install;

            };

            if ( $@ ) {
                GX::Exception->complain( $@ );
            }

            return;

        };

    },

    'static' => sub {

        my $class = shift;

        return sub {

            if ( caller ne $class ) {
                GX::Exception->complain( "Package mismatch" );
            }

            if ( ! defined wantarray ) {
                GX::Exception->complain( "Useless use of keyword \"static\" in void context" );
            }

            return ( @_, static => 1 );

        };

    },

    'with' => sub {

        my $class = shift;

        return sub {

            if ( caller ne $class ) {
                GX::Exception->complain( "Package mismatch" );
            }

            eval {
                GX::Class::Util::mixin( $class, @_ );
            };

            if ( $@ ) {
                GX::Exception->complain( $@ );
            }

            return;

        };

    }

);

sub import {

    my $package = shift;

    return unless $package eq __PACKAGE__;

    my $class = caller();

    if ( $class eq 'main' ) {
        GX::Exception->complain( "Cannot import \"$package\" into package \"main\"" );
    }

    if ( @_ % 2 ) {
        GX::Exception->complain( "Invalid number of arguments" );
    }

    my %args = @_;

    for my $pragma ( qw( strict warnings ) ) {
        $pragma->import;
    }

    my $meta;

    if ( exists $args{'meta'} ) {

        $meta = delete $args{'meta'};

        if ( ! Scalar::Util::blessed( $meta ) || ! $meta->isa( 'GX::Meta::Class' ) ) {
            GX::Exception->complain( "Invalid value for option \"meta\"" );
        }

        if ( $meta->name ne $class ) {
            GX::Exception->complain( "Metaobject mismatch" );
        }

        GX::Meta::Class::Registry->set( $class => $meta );

    }
    else {
        $meta = GX::Meta::Class->new( $class );
    }

    if ( exists $args{'superclass'} ) {

        eval {
            $meta->inherit_from( $args{'superclass'} );
        };

        if ( $@ ) {
            GX::Exception->complain(
                message      => "Cannot add superclass",
                subexception => $@,
                verbosity    => 1
            );
        }

        delete $args{'superclass'};

    }
    else {
        $meta->inherit_from( $package );
    }

    if ( exists $args{'extends'} ) {

        my @superclasses = ref $args{'extends'} eq 'ARRAY' ? @{$args{'extends'}} : $args{'extends'};

        eval {
            $meta->inherit_from( @superclasses );
        };

        if ( $@ ) {
            GX::Exception->complain(
                message      => "Cannot add superclasses",
                subexception => $@,
                verbosity    => 1
            );
        }

        for ( @superclasses ) {
            GX::Class::Util::class_exists( $_ ) or GX::Meta::Util::load_module( $_ ) or next;
        }

        delete $args{'extends'};

    }

    if ( exists $args{'code_attributes'} ) {

        if ( ref $args{'code_attributes'} eq 'ARRAY' ) {

            for my $code_attribute ( @{$args{'code_attributes'}} ) {

                eval {
                    $meta->add_code_attribute( $code_attribute );
                };

                if ( $@ ) {
                    GX::Exception->complain(
                        message      => "Cannot add code attribute",
                        subexception => $@,
                        verbosity    => 1
                    );
                }

            }

        }
        else {
            GX::Exception->complain( "Invalid argument (\"code_attributes\" must be an array reference)" );
        }

        delete $args{'code_attributes'};

    }

    if ( exists $args{'with'} ) {

        eval { 
            GX::Class::Util::mixin( $class, ref $args{'with'} eq 'ARRAY' ? @{$args{'with'}} : $args{'with'} );
        };

        if ( $@ ) {
            GX::Exception->complain(
                message      => "Mixin failed",
                subexception => $@,
                verbosity    => 1
            );
        }

        delete $args{'with'};

    }

    if ( keys %args ) {
        GX::Exception->complain(
            sprintf( "Unknown option (\"%s\")", ( sort keys %args )[0] )
        );
    }

    for my $keyword ( keys %KEYWORD_FACTORY ) {
        $meta->add_method( $keyword => $KEYWORD_FACTORY{$keyword}->( $class ) );
    }

    return;

}

sub unimport {

    my $package = shift;

    return unless $package eq __PACKAGE__;

    my $meta = caller->meta;

    for my $keyword ( keys %KEYWORD_FACTORY ) {
        $meta->remove_method( $keyword ) if $meta->method( $keyword );
    }

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub meta {

    return GX::Meta::Class->new( ref $_[0] || $_[0] );

}


# ----------------------------------------------------------------------------------------------------------------------
# Attribute magic
# ----------------------------------------------------------------------------------------------------------------------

sub FETCH_CODE_ATTRIBUTES {

    my $class          = shift;
    my $code_reference = shift;

    return @{ $class->meta->code_attribute_store->{$code_reference} || return };

}

sub MODIFY_CODE_ATTRIBUTES {

    my $class           = shift;
    my $code_reference  = shift;
    my @code_attributes = @_;

    for my $allowed_code_attribute ( $class->meta->all_code_attributes ) {

        my $code_attribute_regex = qr/^$allowed_code_attribute(?:\(.*\))?$/;

        my @unmatched_code_attributes;

        for my $code_attribute ( @code_attributes ) {

            if ( $code_attribute =~ $code_attribute_regex ) {
                push @{$class->meta->code_attribute_store->{$code_reference}}, $code_attribute;
            }
            else {
                push @unmatched_code_attributes, $code_attribute;
            }

        }

        @code_attributes = @unmatched_code_attributes;

        last if ! @code_attributes;

    }

    return @code_attributes;

}


1;

__END__

=head1 NAME

GX::Class - Universal base class

=head1 SYNOPSIS

    package My::Class;
    
    use GX::Class;
    
    # ...
    
    1;

=head1 DESCRIPTION

This module provides the L<GX::Class> class.

=head1 METHODS

=head2 Public Methods

=head3 C<meta>

Returns the L<GX::Meta::Class> metaobject that represents the class.

    $meta = $class->meta;

=over 4

=item Returns:

=over 4

=item * C<$meta> ( L<GX::Meta::Class> object )

=back

=back

=head2 Internal Methods

=head3 C<import>

Internal method.

    $class->import( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<code_attributes> ( C<ARRAY> reference )

A reference to an array containing the allowed code attributes. The given code
attributes must be simple names. See L<attributes> for details.

=item * C<extends> ( string | C<ARRAY> reference )

A class name or a reference to an array containing class names. See
C<< L<extends()|/extends> >> below.

=item * C<meta> ( L<GX::Meta::Class> object )

The class metaobject to associate with the class.

=item * C<superclass> ( string )

A class name. Prepended to the C<@ISA> array of the class before the
classes specified by C<extends>.

=item * C<with> ( string | C<ARRAY> reference )

A package name or a reference to an array containing package names. See
C<< L<with()|/with> >> below.

=back

=back

=head3 C<unimport>

Internal method.

    $class->unimport;

=head1 EXPORTS

=head2 Functions and Keywords

The following functions / keywords are exported by default.

=head3 C<build>

Builds the class.

    build;

If this function is called, it MUST be called after the class has been
completely defined but before any derived classes are loaded.

=head3 C<extends>

Loads the specified classes (if found in C<@INC>) and prepends them to the
C<@ISA> array of the class.

    extends @superclasses;

=over 4

=item Arguments:

=over 4

=item * C<@superclasses> ( strings )

A list of class names.

=back

=back

=head3 C<has>

Declares an attribute.

    has $attribute_name => %attribute_properties;

=over 4

=item Arguments:

=over 4

=item * C<$attribute_name> ( string )

The name of the attribute.

=item * C<%attribute_properties> ( named list ) [ optional ]

The attribute properties. See L<GX::Meta::Attribute> for details.

=back

=back

=head3 C<static>

A modifier for C<< L<has()|/has> >> that makes the respective attribute
static.

    has static $attribute_name => %attribute_properties;

=head3 C<with>

Mixes the specified classes / packages into the class.

    with @mixins;

=over 4

=item Arguments:

=over 4

=item * C<@mixins> ( strings )

A list of class / package names.

=back

=back

=head1 SUBCLASSES

The following classes inherit directly from L<GX::Class>:

=over 4

=item * L<GX::Class::Object>

=back

=head1 SEE ALSO

=over 4

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
