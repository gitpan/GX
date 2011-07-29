# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Class.pm
# ----------------------------------------------------------------------------------------------------------------------

use strict;
use warnings;

package GX::Meta::Class;

BEGIN {

    if ( $] < 5.009_005 ) {
        # mro::* interface compatibility for older Perls
        require MRO::Compat;
    }
    else {
        require mro;
    }

}

use GX::Meta::Attribute;
use GX::Meta::Constants qw( REGEX_CLASS_NAME REGEX_IDENTIFIER REGEX_METHOD_NAME );
use GX::Meta::Exception;
use GX::Meta::Method;
use GX::Meta::Module;
use GX::Meta::Package;
use GX::Meta::Util;

use Scalar::Util qw( blessed weaken );


# ----------------------------------------------------------------------------------------------------------------------
# Load Sub::Name if available
# ----------------------------------------------------------------------------------------------------------------------

my $USE_SUB_NAME;

BEGIN { local $@; $USE_SUB_NAME = eval "require Sub::Name; 1;"; }


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { $_[0]->name },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;
    my %args  = ( @_ == 1 ) ? ( 'name' => $_[0] ) : @_;

    my $class_name = $args{'name'};

    if ( ! defined $class_name ) {
        complain "Missing argument (\"name\")";
    }

    my $self = GX::Meta::Class::Registry->get( $class_name );

    if ( ! $self ) {

        if ( $class_name !~ REGEX_CLASS_NAME ) {
            complain "Invalid argument (\"name\")";
        }

        $self = bless {
            'attributes'           => [],
            'attributes_index'     => {},
            'code_attribute_store' => {},
            'code_attributes'      => [],
            'methods'              => {},
            'methods_pkg_gen'      => -1,
            'name'                 => $class_name,
            'package'              => undef
        }, $class;

        GX::Meta::Class::Registry->set( $class_name => $self );

    }

    return $self;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub add_attribute {

    my $self = shift;

    my $attribute;

    if ( @_ == 1 ) {

        $attribute = $_[0];

        if ( ! blessed $attribute || ! $attribute->isa( 'GX::Meta::Attribute' ) ) {
            complain "Invalid argument";
        }

        if ( $attribute->class && $attribute->class != $self ) {
            complain "Cannot add the attribute because it is already associated with another class"
        }

    }
    else {

        if ( @_ % 2 ) {
            complain "Invalid number of arguments";
        }

        $attribute = eval { $self->_create_attribute( @_ ) };

        if ( ! $attribute ) {
            GX::Exception->complain(
                message      => "Cannot create the attribute metaobject",
                subexception => $@
            );
        }

    }

    my $attribute_name = $attribute->name;

    if ( ! defined $attribute_name ) {
        complain "Cannot add the attribute (undefined attribute name)";
    }

    if ( $self->_get_attributes_index->{$attribute_name} ) {
        complain "Cannot add the attribute (duplicate attribute name: \"$attribute_name\")";
    }

    $self->_get_attributes_index->{$attribute_name} = $attribute;

    push @{$self->_get_attributes}, $attribute;

    return $attribute;

}

sub add_code_attribute {

    my $self      = shift;
    my $attribute = shift;

    if ( @_ ) {
        complain "Invalid number of arguments";
    }

    if ( ! defined $attribute || $attribute !~ REGEX_IDENTIFIER ) {
        complain "Invalid argument";
    }

    push @{$self->_get_code_attributes}, $attribute;

    return;

}

sub add_method {

    my $self           = shift;
    my $method_name    = shift;
    my $code_reference = shift;

    if ( @_ ) {
        complain "Invalid number of arguments";
    }

    if ( ! defined $method_name || $method_name !~ REGEX_METHOD_NAME ) {
        complain "Invalid argument";
    }

    if ( ref $code_reference ne 'CODE' ) {
        complain "Invalid argument";
    }

    $self->package->assign_to_typeglob( $method_name, $code_reference );

    if ( $USE_SUB_NAME ) {
        Sub::Name::subname( "${self}::${method_name}", $code_reference );
    }

    return;

}

sub all_attributes {

    my $self = shift;

    my @attributes;
    my %seen_attributes;

    for my $class ( $self->linearized_isa_classes ) {

        for my $attribute ( $class->attributes ) {
            push @attributes, $attribute unless $seen_attributes{$attribute->name}++;
        }

    }

    return @attributes;

}

sub all_class_attributes {

    return grep { $_->is_static } $_[0]->all_attributes;

}

sub all_code_attributes {

    return map { $_->code_attributes } $_[0]->linearized_isa_classes; 

}

sub all_instance_attributes {

    return grep { ! $_->is_static } $_[0]->all_attributes;

}

sub all_methods {

    my $self = shift;

    my %methods = map { %{$_->_get_methods} } reverse $self->linearized_isa_classes; 

    return values %methods;

}

sub all_methods_with_code_attribute {

    my $self = shift;

    my @result;

    if ( @_ ) {

        my $code_attribute = shift;

        if ( @_ ) {
            complain "Invalid number of arguments";
        }

        if ( ! defined $code_attribute || $code_attribute !~ REGEX_IDENTIFIER ) {
            complain "Invalid argument";
        }

        my $code_attribute_regex = qr/^$code_attribute(?:\(.*\))?$/;

        METHOD:
        for my $method ( $self->all_methods ) {

            for ( $method->code_attributes ) {
                push( @result, $method ), next METHOD if /$code_attribute_regex/;
            }

        }

    }
    else {
        @result = grep { $_->code_attributes } $self->all_methods;
    }

    return @result;

}

sub all_subclasses {

    my $self = shift;

    my $class_name = $self->name;

    my @subclass_names;

    my @package_names = grep { $_ ne 'main' } GX::Meta::Util::subpackage_names( 'main' );

    while ( @package_names ) {

        my $package_name = shift @package_names;

        local $@;

        if ( eval { $package_name->isa( $class_name ) } && $package_name ne $class_name ) {
            push @subclass_names, $package_name;
        }

        push @package_names, map { "${package_name}::$_" } GX::Meta::Util::subpackage_names( $package_name );

    }

    return map { GX::Meta::Class::Registry->get( $_ ) // __PACKAGE__->new( $_ ) } @subclass_names;

}

sub all_superclasses {

    my $self = shift;

    my @classes = $self->linearized_isa_classes;

    shift @classes;

    return @classes;

}

sub attribute {

    return $_[0]->_get_attributes_index->{$_[1]};

}

sub attributes {

    return @{$_[0]->_get_attributes};

}

sub class_attributes {

    return grep { $_->is_static } @{$_[0]->_get_attributes};

}

sub class_data {

    no strict 'refs';

    return \%{ $_[0]->name . '::' . $_[0]->class_data_identifier };

}

sub class_data_identifier {

    return 'CLASS_DATA';

}

sub code_attributes {

    return @{$_[0]->_get_code_attributes};

}

sub destroy {

    return GX::Meta::Class::Registry->remove( $_[0]->name );

}

sub has_attribute {

    return $_[0]->_get_attributes_index->{$_[1]} ? 1 : 0;

}

sub has_method {

    return $_[0]->_get_methods->{$_[1]} ? 1 : 0;

}

sub inherit_from {

    my $self = shift;

    my @class_names;

    for ( @_ ) {

        if ( blessed $_ && $_->isa( __PACKAGE__ ) ) {
            push @class_names, $_->name;
        }
        elsif ( defined $_ && $_ =~ REGEX_CLASS_NAME ) {
            push @class_names, $_;
        }
        else {
            complain "Invalid argument";
        }

    }

    $self->_set_isa( @class_names, $self->_get_isa );

    return;

}

sub inherited_methods {

    my $self = shift;

    return grep { $_->class != $self } $self->all_methods;

}

sub instance_attributes {

    return grep { ! $_->is_static } @{$_[0]->_get_attributes};

}

sub linearized_isa {

    return @{ mro::get_linear_isa( $_[0]->name ) };

}

sub linearized_isa_classes {

    return map {
        GX::Meta::Class::Registry->get( $_ ) // __PACKAGE__->new( $_ )
    } $_[0]->linearized_isa;

}

sub method {

    return $_[0]->_get_methods->{$_[1]}

}

sub method_names {

    return keys %{$_[0]->_get_methods};

}

sub methods {

    return values %{$_[0]->_get_methods};

}

sub methods_with_code_attribute {

    my $self = shift;

    my @result;

    if ( @_ ) {

        my $code_attribute = shift;

        if ( @_ ) {
            complain "Invalid number of arguments";
        }

        if ( ! defined $code_attribute || $code_attribute !~ REGEX_IDENTIFIER ) {
            complain "Invalid argument";
        }

        my $code_attribute_regex = qr/^$code_attribute(?:\(.*\))?$/;

        METHOD:
        for my $method ( $self->methods ) {

            for ( $method->code_attributes ) {
                push( @result, $method ), next METHOD if /$code_attribute_regex/;
            }

        }

    }
    else {
        @result = grep { $_->code_attributes } $self->methods;
    }

    return @result;

}

sub name {

    return $_[0]->{'name'};

}

sub package {

    return $_[0]->{'package'} //= GX::Meta::Package->new( $_[0]->name );

}

sub remove_method {

    my $self        = shift;
    my $method_name = shift;

    if ( @_ ) {
        complain "Invalid number of arguments";
    }

    if ( ! defined $method_name || $method_name !~ REGEX_METHOD_NAME ) {
        complain "Invalid argument";
    }

    return unless $self->has_method( $method_name );

    $self->package->clear_typeglob_slot( $method_name, 'CODE' );

    return 1;

}

sub subclasses {

    my $self = shift;

    my @subclasses;

    SUBCLASS:
    for my $subclass ( $self->all_subclasses ) {

        for my $superclass ( $subclass->superclasses ) {
            push( @subclasses, $subclass ), next SUBCLASS if $superclass == $self;
        }

    }

    return @subclasses;

}

sub superclasses {

    my $self = shift;

    if ( @_ ) {

        my @class_names;

        for ( @_ ) {

            if ( blessed $_ && $_->isa( __PACKAGE__ ) ) {
                push @class_names, $_->name;
            }
            elsif ( defined $_ && $_ =~ REGEX_CLASS_NAME ) {
                push @class_names, $_;
            }
            else {
                complain "Invalid argument";
            }

        }

        $self->_set_isa( @class_names );

        return unless defined wantarray;

    }

    return map {
        GX::Meta::Class::Registry->get( $_ ) // __PACKAGE__->new( $_ )
    } $self->_get_isa;

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub code_attribute_store {

    return $_[0]->{'code_attribute_store'};

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _create_attribute {

    my $self = shift;

    return GX::Meta::Attribute->new( @_, class => $self );

}

sub _create_method {

    my $self = shift;

    return GX::Meta::Method->new( @_, class => $self );

}

sub _get_attributes {

    return $_[0]->{'attributes'};

}

sub _get_attributes_index {

    return $_[0]->{'attributes_index'};

}

sub _get_code_attributes {

    return $_[0]->{'code_attributes'};

}

sub _get_isa {

    no strict 'refs';

    return @{ $_[0]->name . '::ISA' };

}

sub _get_methods {

    my $self = shift;

    my $pkg_gen = mro::get_pkg_gen( $self->name );

    return $self->{'methods'} if $pkg_gen == $self->{'methods_pkg_gen'};

    $self->{'methods_pkg_gen'} = $pkg_gen;

    my $methods    = $self->{'methods'};
    my $class_name = $self->name;

    %$methods = map {
        ( $_ => $methods->{$_} // $self->_create_method( class => $self, name => $_ ) )
    } grep {
        $_ =~ REGEX_METHOD_NAME && defined &{"$class_name\::$_"}
    } keys %{$self->package->symbol_table};

    return $methods;

}

sub _set_isa {

    my $self = shift;

    no strict 'refs';

    @{ $self->name . '::ISA' } = @_;

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Object registry
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Class::Registry;

{

    my %OBJECTS;

    sub clear {
        %OBJECTS = ();
        return;
    }

    sub get {
        return $OBJECTS{$_[1]};
    }

    sub remove {
        return delete $OBJECTS{$_[1]};
    }

    sub set {
        return $OBJECTS{$_[1]} = $_[2];
    }

}


1;

__END__

=head1 NAME

GX::Meta::Class - Class metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Class> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a L<GX::Meta::Class> metaobject representing the specified class.

    $class = GX::Meta::Class->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<name> ( string ) [ required ]

The name of the class, for example "My::Class".

=back

=item Returns:

=over 4

=item * C<$class> ( L<GX::Meta::Class> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

Alternative syntax:

    $class = GX::Meta::Class->new( $name );

=over 4

=item Arguments:

=over 4

=item * C<$name> ( string )

The name of the class, for example "My::Class".

=back

=item Returns:

=over 4

=item * C<$class> ( L<GX::Meta::Class> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head2 Public Methods

=head3 C<add_attribute>

Adds the given attribute metaobject to the class.

    $class->add_attribute( $attribute );

=over 4

=item Arguments:

=over 4

=item * C<$attribute> ( L<GX::Meta::Attribute> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

Alternatively, a list of named arguments can be passed to C<add_attribute()>.
The given arguments are passed through to the L<GX::Meta::Attribute> universal
constructor to create a new attribute metaobject which is then added to the
class.

    $attribute = $class->add_attribute( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<%arguments> ( named list )

Arguments to pass to the L<GX::Meta::Attribute> L<constructor|GX::Meta::Attribute/new>.

=back

=item Returns:

=over 4

=item * C<$attribute> ( L<GX::Meta::Attribute> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<add_code_attribute>

Adds the given code attribute to the list of allowed code attributes for the
class.

    $class->add_code_attribute( $code_attribute );

=over 4

=item Arguments:

=over 4

=item * C<$code_attribute> ( string )

A code attribute, which must be a simple name. See L<attributes> for details.

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<add_method>

Adds a method to the class.

    $class->add_method( $method_name, $code_reference );

=over 4

=item Arguments:

=over 4

=item * C<$method_name> ( string )

=item * C<$code_reference> ( C<CODE> reference )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<all_attributes>

Returns all attribute metaobjects.

    @attributes = $class->all_attributes;

=over 4

=item Returns:

=over 4

=item * C<@attributes> ( L<GX::Meta::Attribute> objects )

=back

=back

=head3 C<all_class_attributes>

Returns all class attribute metaobjects.

    @attributes = $class->all_class_attributes;

=over 4

=item Returns:

=over 4

=item * C<@attributes> ( L<GX::Meta::Attribute> objects )

=back

=back

=head3 C<all_code_attributes>

Returns the allowed code attributes for the class, including those allowed
through inheritance.

    @code_attributes = $class->all_code_attributes;

=over 4

=item Returns:

=over 4

=item * C<@code_attributes> ( strings )

A list of simple names. See L<attributes> for details.

=back

=back

=head3 C<all_instance_attributes>

Returns all instance attribute metaobjects.

    @attributes = $class->all_instance_attributes;

=over 4

=item Returns:

=over 4

=item * C<@attributes> ( L<GX::Meta::Attribute> objects )

=back

=back

=head3 C<all_methods>

Returns a list of method metaobjects representing all the methods of the 
class, including the inherited ones.

    @methods = $class->all_methods;

=over 4

=item Returns:

=over 4

=item * C<@methods> ( L<GX::Meta::Method> objects )

=back

=back

=head3 C<all_methods_with_code_attribute>

Does the same as C<< L<all_methods()|/all_methods> >>, but filters out all
methods without the specified code attribute.

    @methods = $class->all_methods_with_code_attribute( $code_attribute );

=over 4

=item Arguments:

=over 4

=item * C<$code_attribute> ( string )

A simple name. See L<attributes> for details.

=back

=item Returns:

=over 4

=item * C<@methods> ( L<GX::Meta::Method> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<all_subclasses>

Returns a list of class metaobjects representing the direct and indirect
subclasses of the class.

    @classes = $class->all_subclasses;

=over 4

=item Returns:

=over 4

=item * C<@classes> ( L<GX::Meta::Class> objects )

=back

=back

=head3 C<all_superclasses>

Returns a list of class metaobjects representing the direct and indirect
superclasses of the class.

    @classes = $class->all_superclasses;

=over 4

=item Returns:

=over 4

=item * C<@classes> ( L<GX::Meta::Class> objects )

=back

=back

=head3 C<attribute>

Returns an associated attribute metaobject by the represented attribute's
name, or C<undef> if the class has no such (non-inherited) attribute.

    $attribute = $class->attribute( $attribute_name );

=over 4

=item Arguments:

=over 4

=item * C<$attribute_name> ( string )

=back

=item Returns:

=over 4

=item * C<$attribute> ( L<GX::Meta::Attribute> object | C<undef> )

=back

=back

=head3 C<attributes>

Returns all non-inherited attribute metaobjects.

    @attributes = $class->attributes;

=over 4

=item Returns:

=over 4

=item * C<@attributes> ( L<GX::Meta::Attribute> objects )

=back

=back

=head3 C<class_attributes>

Returns all non-inherited class attribute metaobjects.

    @attributes = $class->class_attributes;

=over 4

=item Returns:

=over 4

=item * C<@attributes> ( L<GX::Meta::Attribute> objects )

=back

=back

=head3 C<class_data>

Returns a reference to the class data hash.

    $data = $class->class_data;

=over 4

=item Returns:

=over 4

=item * C<$data> ( C<HASH> reference )

=back

=back

=head3 C<class_data_identifier>

Returns the identifier that is used for storing the class data hash in the
symbol table.

    $identifier = $class->class_data_identifier;

=over 4

=item Returns:

=over 4

=item * C<$identifier> ( string )

Defaults to "CLASS_DATA".

=back

=back

=head3 C<code_attributes>

Returns the allowed code attributes for the class, not including those
allowed through inheritance.

    @code_attributes = $class->code_attributes;

=over 4

=item Returns:

=over 4

=item * C<@code_attributes> ( strings )

A list of simple names. See L<attributes> for details.

=back

=back

=head3 C<destroy>

Destroys the metaobject.

    $class->destroy;

=head3 C<has_attribute>

Returns true if the class has a non-inherited attribute with the given name,
otherwise false.

    $result = $class->has_attribute( $attribute_name );

=over 4

=item Arguments:

=over 4

=item * C<$attribute_name> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<has_method>

Returns true if the class has a non-inherited method with the given name,
otherwise false.

    $result = $class->has_method( $method_name );

=over 4

=item Arguments:

=over 4

=item * C<$method_name> ( string )

=back

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<inherit_from>

Prepends the specified classes to the C<@ISA> array of the class.

    $class->inherit_from( @classes );

=over 4

=item Arguments:

=over 4

=item * C<@classes> ( L<GX::Meta::Class> objects | strings )

Class metaobjects and / or class names.

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<inherited_methods>

Returns a list of method metaobjects representing the methods that the class
inherits.

    @methods = $class->inherited_methods;

=over 4

=item Returns:

=over 4

=item * C<@methods> ( L<GX::Meta::Method> objects )

=back

=back

=head3 C<instance_attributes>

Returns all non-inherited instance attribute metaobjects.

    @attributes = $class->instance_attributes;

=over 4

=item Returns:

=over 4

=item * C<@attributes> ( L<GX::Meta::Attribute> objects )

=back

=back

=head3 C<linearized_isa>

Returns a list with the names of all the classes that would be searched when
resolving a method call on the represented class, starting with the
represented class itself.

    @class_names = $class->linearized_isa;

=over 4

=item Returns:

=over 4

=item * C<@class_names> ( strings )

=back

=back

=head3 C<linearized_isa_classes>

Does the same as C<< L<linearized_isa()|/linearized_isa> >>, but returns class
metaobjects instead of class names.

    @classes = $class->linearized_isa_classes;

=over 4

=item Returns:

=over 4

=item * C<@classes> ( L<GX::Meta::Class> objects )

=back

=back

=head3 C<method>

Returns a method metaobject representing the non-inherited method with the
given name, or C<undef> if the class has no such method.

    $method = $class->method( $method_name );

=over 4

=item Arguments:

=over 4

=item * C<$method_name> ( string )

=back

=item Returns:

=over 4

=item * C<$method> ( L<GX::Meta::Method> object )

=back

=back

=head3 C<method_names>

Returns the names of the non-inherited methods of the class.

    @method_names = $class->method_names;

=over 4

=item Returns:

=over 4

=item * C<@method_names> ( strings )

=back

=back

=head3 C<methods>

Returns a list of method metaobjects representing the non-inherited methods of
the class.

    @methods = $class->methods;

=over 4

=item Returns:

=over 4

=item * C<@methods> ( L<GX::Meta::Method> objects )

=back

=back

=head3 C<methods_with_code_attribute>

Does the same as C<< L<methods()|/methods> >>, but filters out all methods
without the given code attribute.

    @methods = $class->methods_with_code_attribute( $code_attribute );

=over 4

=item Arguments:

=over 4

=item * C<$code_attribute> ( string )

A simple name. See L<attributes> for details.

=back

=item Returns:

=over 4

=item * C<@methods> ( L<GX::Meta::Method> objects )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<name>

Returns the name of the class.

    $name = $class->name;

=over 4

=item Returns:

=over 4

=item * C<$name> ( string )

=back

=back

=head3 C<package>

Returns the associated package metaobject.

    $package = $class->package;

=over 4

=item Returns:

=over 4

=item * C<$package> ( L<GX::Meta::Package> object )

=back

=back

=head3 C<remove_method>

Removes the specfied method.

    $class->remove_method( $method_name );

=over 4

=item Arguments:

=over 4

=item * C<$method_name> ( string )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<subclasses>

Returns a list of class metaobjects representing the direct subclasses of the
class.

    @classes = $class->subclasses;

=over 4

=item Returns:

=over 4

=item * C<@classes> ( L<GX::Meta::Class> objects )

=back

=back

=head3 C<superclasses>

Returns a list of class metaobjects representing the direct superclasses of
the class, i.e. the classes in the C<@ISA> array of the class.

    @classes = $class->superclasses;

=over 4

=item Returns:

=over 4

=item * C<@classes> ( L<GX::Meta::Class> objects )

=back

=back

If called with arguments, C<superclasses()> sets the C<@ISA> array of the
represented class.

    $class->superclasses( @classes );

=over 4

=item Arguments:

=over 4

=item * C<@classes> ( L<GX::Meta::Class> objects | strings )

Class metaobjects and / or class names.

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head2 Internal Methods

=head3 C<code_attribute_store>

Internal method.

    $store = $class->code_attribute_store;

=over 4

=item Returns:

=over 4

=item * C<$store> ( C<HASH> reference )

=back

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
