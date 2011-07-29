# ----------------------------------------------------------------------------------------------------------------------
# GX Framework (c) 2009-2011 Jörg A. Uzarek <uzarek@runlevelnull.de>
# File: GX/Meta/Attribute.pm
# ----------------------------------------------------------------------------------------------------------------------

package GX::Meta::Attribute;

use strict;
use warnings;

use GX::Meta::Accessor;
use GX::Meta::Constants qw( REGEX_CLASS_NAME REGEX_METHOD_NAME );
use GX::Meta::Delegator;
use GX::Meta::Exception;
use GX::Meta::Util;

use Scalar::Util qw( blessed weaken );


# ----------------------------------------------------------------------------------------------------------------------
# Constants
# ----------------------------------------------------------------------------------------------------------------------

use constant ACCESS_PUBLIC    => 1 << 0;
use constant ACCESS_PROTECTED => 1 << 1;
use constant ACCESS_PRIVATE   => 1 << 2;

sub TYPE_CONSTRAINT () {}


# ----------------------------------------------------------------------------------------------------------------------
# Overloading
# ----------------------------------------------------------------------------------------------------------------------

use overload
    'bool'     => sub { 1 },
    '0+'       => sub { $_[0] },
    '""'       => sub { $_[0]->name },
    'fallback' => 1;


# ----------------------------------------------------------------------------------------------------------------------
# Subclasses
# ----------------------------------------------------------------------------------------------------------------------

my %TYPE_REGISTRY;

sub __register_type {

    my $invocant            = shift;
    my $attribute_type      = shift;
    my $attribute_metaclass = shift;

    if ( $invocant ne __PACKAGE__ ) {
        complain "register_type() must be called on " . __PACKAGE__;
    }

    if ( $attribute_type !~ REGEX_CLASS_NAME ) {
        complain "Invalid attribute type identifier";
    }

    if ( $attribute_metaclass !~ REGEX_CLASS_NAME ) {
        complain "Invalid attribute metaclass name";
    }

    if ( defined $TYPE_REGISTRY{$attribute_type} ) {

        return if $TYPE_REGISTRY{$attribute_type} eq $attribute_metaclass;

        complain sprintf(
            "Attribute type \"%s\" is already mapped to class %s",
            $attribute_type,
            $TYPE_REGISTRY{$attribute_type}
        );

    }

    $TYPE_REGISTRY{$attribute_type} = $attribute_metaclass;

    return;

}

for ( qw(
    Array
    Bool
    Hash
    Hash::Ordered
    Object
    Scalar
    String
) ) {
    __PACKAGE__->__register_type( $_ => __PACKAGE__ . '::' . $_ );
}


# ----------------------------------------------------------------------------------------------------------------------
# Constructor
# ----------------------------------------------------------------------------------------------------------------------

sub new {

    my $class = shift;
    my %args  = @_;

    if ( $class eq __PACKAGE__ ) {

        if ( exists $args{'isa'} ) {

            if ( ! defined $args{'isa'} ) {
                complain "Invalid argument (\"isa\")";
            }

            $class = $TYPE_REGISTRY{$args{'isa'}};

            if ( ! defined $class ) {

                if ( $args{'isa'} !~ REGEX_CLASS_NAME ) {
                    complain "Invalid argument (\"isa\")";
                }

                $class = $args{'isa'};

            }

            delete $args{'isa'};

        }
        elsif ( exists $args{'type'} ) {

            if ( ! defined $args{'type'} ) {
                complain "Invalid argument (\"type\")";
            }

            $class = $TYPE_REGISTRY{$args{'type'}};

            if ( ! defined $class ) {
                complain "Unknown attribute type";
            }

            delete $args{'type'};

        }
        else {
            $class = $TYPE_REGISTRY{'Scalar'};
        }

    }

    if ( ! GX::Meta::Util::load_module( $class )  ) {
        complain "Cannot load attribute metaclass \"$class\"";
    }

    my $self = bless {}, $class;

    eval {
        $self->__initialize( \%args );
    };

    complain $@ if $@; 

    return $self;

}


# ----------------------------------------------------------------------------------------------------------------------
# Public methods
# ----------------------------------------------------------------------------------------------------------------------

sub accessors {

    return @{ $_[0]->{'accessors'} || return };

}

sub add_accessor {

    my $self = shift;

    my $accessor = eval {
        $self->create_accessor( @_ );
    };

    if ( ! $accessor ) {
        GX::Exception->complain(
            message      => "Cannot create accessor",
            subexception => $@
        );
    }

    push @{$self->{'accessors'}}, $accessor;

    return $accessor;

}

sub add_preprocessor {

    my $self      = shift;
    my $processor = shift;

    if ( ! $self->_validate_processor( $processor ) ) {
        complain "Bad attribute preprocessor";
    }

    push @{$self->{'preprocessors'}}, $processor;

    return $processor;

}

sub add_processor {

    my $self      = shift;
    my $processor = shift;

    if ( ! $self->_validate_processor( $processor ) ) {
        complain "Bad attribute processor";
    }

    push @{$self->{'processors'}}, $processor;

    return $processor;

}

sub add_type_constraint {

    my $self       = shift;
    my $constraint = shift;

    if ( ! $self->_validate_constraint( $constraint ) ) {
        complain "Bad attribute type constraint";
    }

    push @{$self->{'type_constraints'}}, $constraint;

    return $constraint;

}

sub add_value_constraint {

    my $self       = shift;
    my $constraint = shift;

    if ( ! $self->_validate_constraint( $constraint ) ) {
        complain "Bad attribute value constraint";
    }

    push @{$self->{'value_constraints'}}, $constraint;

    return $constraint;

}

sub class {

    return $_[0]->{'class'};

}

sub default_value {

    return $_[0]->{'default_value'};

}

sub has_default_value {

    return exists $_[0]->{'default_value'};

}

sub has_initializer {

    return defined $_[0]->{'initializer'};

}

sub initializer {

    return $_[0]->{'initializer'};

}

sub install {

    my $self = shift;

    eval {
        $self->install_accessors;
    };

    if ( $@ ) {
        complain $@;
    }

    return;

}

sub install_accessors {

    my $self = shift;

    for my $accessor ( $self->accessors ) {

        if ( my $method = $self->class->method( $accessor->name ) ) {
            next if $method->code == $accessor->code;
            complain sprintf( "Cannot install accessor (method &%s already exists)", $method->full_name );
        }

        $self->class->add_method( $accessor->name, $accessor->code );

    }

    return;

}

sub is_private {

    return $_[0]->{'access_specifier'} & ACCESS_PRIVATE;

}

sub is_protected {

    return $_[0]->{'access_specifier'} & ACCESS_PROTECTED;

}

sub is_public {

    return $_[0]->{'access_specifier'} & ACCESS_PUBLIC;

}

sub is_required {

    return $_[0]->{'options'}{'required'};

}

sub is_static {

    return $_[0]->{'static'};

}

sub is_sticky {

    return $_[0]->{'options'}{'sticky'};

}

sub name {

    return $_[0]->{'name'};

}

sub preprocessors {

    return @{ $_[0]->{'preprocessors'} || return };

}

sub processors {

    return @{ $_[0]->{'processors'} || return };

}

sub quoted_slot_key {

    my $self = shift;

    my $slot_key = $self->slot_key;

    $slot_key =~ s/'/\\'/g;

    return "'$slot_key'";

}

sub slot_key {

    return $_[0]->{'slot_key'};

}

sub type {

    complain "Abstract method";

}

sub type_constraints {

    return @{ $_[0]->{'type_constraints'} || return };

}

sub value_constraints {

    return @{ $_[0]->{'value_constraints'} || return };

}


# ----------------------------------------------------------------------------------------------------------------------
# Internal methods
# ----------------------------------------------------------------------------------------------------------------------

sub access_specifier {

    return $_[0]->{'access_specifier'};

}

sub assign_to_slot {

    my $self  = shift;
    my $store = shift;
    my $value = shift;

    $store->{$self->slot_key} = $value;

    return;

}

sub check_constraints {

    my $self = shift;

    my $exception;

    {

        local $@;

        eval {
            $self->check_type_constraints( @_ );
            $self->check_value_constraints( @_ );
        };

        $exception = $@;

    }

    if ( $exception ) {
        return if defined wantarray;
        complain $exception;
    }

    return 1;

}

sub check_type_constraints {

    my $self    = shift;
    my $context = shift;
    my $value   = shift;

    my $constraints = $self->_get_type_constraints or return 1;

    for my $constraint ( @$constraints ) {

        my $result;
        my $exception;

        {

            local $@;

            $result = eval {
                local $_ = $value;
                ref $constraint ? $constraint->( $constraint, $value ) : $context->$constraint( $value );
            };

            $exception = $@;

        }

        if ( ! $result ) {
            return if defined wantarray;
            complain( $exception || "Invalid value for attribute \"" . $self->name . "\"" );
        }

    }

    return 1;

}

sub check_value_constraints {

    my $self    = shift;
    my $context = shift;
    my $value   = shift;

    my $constraints = $self->_get_value_constraints or return 1;

    for my $constraint ( @$constraints ) {

        my $result;
        my $exception;

        {

            local $@;

            $result = eval {
                local $_ = $value;
                ref $constraint ? $constraint->( $constraint, $value ) : $context->$constraint( $value );
            };

            $exception = $@;

        }

        if ( ! $result ) {
            return if defined wantarray;
            complain( $exception || "Invalid value for attribute \"" . $self->name . "\"" );
        }

    }

    return 1;

}

sub clear_slot {

    my $self    = shift;
    my $context = shift;
    my $store   = shift;

    return delete $store->{$self->slot_key};

}

sub clear_class_data_slot {

    my $self = shift;

    my $class = $self->class;

    return $self->clear_slot( $class->name, $class->class_data );

}

sub clear_instance_slot {

    my $self   = shift;
    my $object = shift;

    return $self->clear_slot( $object, $object );

}

sub create_accessor {

    throw "Abstract method";

}

sub initialize_slot {

    my $self    = shift;
    my $context = shift;
    my $store   = shift;
    my $data    = shift;

    return if exists $store->{$self->slot_key};

    if ( $data && exists $data->{$self->name} ) {

        $self->set_value( $context, $store, $data->{$self->name} );

    } elsif ( $self->is_required ) {

        throw "Missing argument (\"$self\")";

    } elsif ( $self->_get_options->{'initialize'} ) {

        if ( my $initializer = $self->initializer ) {

            my $value;

            {
                local $_ = $context;
                $value = ref $initializer ? $initializer->( $context ) : $context->$initializer;
            }

            $self->assign_to_slot( $store, $value );

        }
        elsif ( $self->has_default_value ) {
            $self->assign_to_slot( $store, $self->default_value );
        }
        else {
            $self->assign_to_slot( $store, $self->native_value );
        }

    }
    else {
        return 0;
    }

    return 1;

}

sub initialize_class_data_slot {

    my $self = shift;
    my $data = shift;

    my $class = $self->class;

    return $self->initialize_slot( $class->name, $class->class_data, $data );

}

sub initialize_instance_slot {

    my $self   = shift;
    my $object = shift;
    my $data   = shift;

    return $self->initialize_slot( $object, $object, $data );

}

sub inline_clear_instance_slot {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    $data->{'slot'} //= $data->{'invocant'} . '->{' . $self->quoted_slot_key . '}';

    $self->_inline_delete_slot( $data, $code, $vars );

    return;

}

sub inline_initialize_instance_slot {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    $data->{'slot'} //= $data->{'invocant'} . '->{' . $self->quoted_slot_key . '}';

    my $var_value = $data->{'args'} . '->{' . $self->name . '}';

    push @$code, 'if ( ! exists ' . $data->{'slot'}  . ' ) {';

    push @$code, 'if ( exists ' . $var_value . ' ) {';
    $self->_inline_set_value( $data, $code, $vars, $var_value );
    push @$code, '}';

    if ( $self->is_required ) {

        push @$code,
            'else {',
            '    GX::Meta::Exception->complain( "Missing argument (\"' . $self->name . '\")" );',
            '}';

    }
    elsif ( $self->_get_options->{'initialize'} ) {

        push @$code, 'else {';
        $self->_inline_initialize_slot( $data, $code, $vars );
        push @$code, '}';

    }

    push @$code, '}';

    return;

}

sub native_value {

    return undef;

}

sub options {

    return %{$_[0]->{'options'}};

}

sub preprocess_value {

    my $self    = shift;
    my $context = shift;

    my $preprocessors = $self->_get_preprocessors or return;

    for my $processor ( @$preprocessors ) {
        ref $processor ? $processor->( $processor, $_ ) : $context->$processor( $_ ) for $_[0];
    }

    return 1;

}

sub process_value {

    my $self    = shift;
    my $context = shift;

    my $processors = $self->_get_processors or return;

    for my $processor ( @$processors ) {
        ref $processor ? $processor->( $processor, $_ ) : $context->$processor( $_ ) for $_[0];
    }

    return 1;

}

sub set_value {

    my $self    = shift;
    my $context = shift;
    my $store   = shift;
    my $value   = shift;

    $self->preprocess_value( $context, $value );
    $self->check_constraints( $context, $value );
    $self->process_value( $context, $value );
    $self->assign_to_slot( $store, $value );

    return;

}


# ----------------------------------------------------------------------------------------------------------------------
# Private methods
# ----------------------------------------------------------------------------------------------------------------------

sub _get_accessors {

    return $_[0]->{'accessors'};

}

sub _get_options {

    return $_[0]->{'options'};

}

sub _get_preprocessors {

    return $_[0]->{'preprocessors'};

}

sub _get_processors {

    return $_[0]->{'processors'};

}

sub _get_type_constraints {

    return $_[0]->{'type_constraints'};

}

sub _get_value_constraints {

    return $_[0]->{'value_constraints'};

}

sub _inline_accessor_prologue {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    $data->{'invocant'} //= '$_[0]';

    if ( $self->is_private ) {

        push @$code,
            'if ( caller ne \'' . $self->class->name .  '\' ) {',
            '    my $method = ( caller( 0 ) )[3];',
            '    GX::Meta::Exception->complain(',
            '        "Private method " . ',
            '        ( substr( $method, -8 ) ne \'__ANON__\' ? "&$method " : \'\' ) . ',
            '        "called"',
            '    );',
            '}';

    }
    elsif ( $self->is_protected ) {

        push @$code,
            'if ( ! caller->isa( \'' . $self->class->name .  '\' ) ) {',
            '    my $method = ( caller( 0 ) )[3];',
            '    GX::Meta::Exception->complain(',
            '        "Protected method " . ',
            '        ( substr( $method, -8 ) ne \'__ANON__\' ? "&$method " : \'\' ) . ',
            '        "called"',
            '    );',
            '}';

    }

    if ( $self->is_static ) {

        $data->{'class_data_identifier'} //= $self->class->class_data_identifier;

        push @$code,
            'my $CLASS_DATA = do {',
            '    no strict \'refs\';',
            '    \%{ ( ref ' . $data->{'invocant'} . ' || ' .
                 $data->{'invocant'} . ' ) . \'::' . $data->{'class_data_identifier'} . '\' };',
            '};';

        $data->{'slot'} = '$CLASS_DATA->{' . $self->quoted_slot_key . '}';

    }
    else {
        $data->{'slot'} = $data->{'invocant'} . '->{' . $self->quoted_slot_key . '}';
    }

    return;

}

sub _inline_assign_to_slot {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    push @$code, $data->{'slot'} . ' = ' . $var . ';';

    return;

}

sub _inline_check_constraints {

    my $self = shift;

    $self->_inline_check_type_constraints( @_ );
    $self->_inline_check_value_constraints( @_ );

    return;

}

sub _inline_check_type_constraints {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    if ( $self->_get_type_constraints ) {

        my $var_constraints = '$EVAL_VAR_' . keys %$vars;

        $vars->{$var_constraints} = $self->_get_type_constraints;

        push @$code,
            'for my $constraint ( @' . $var_constraints . ' ) {',
            '    eval { ',
            '        local $_ = ' . $var . ';',
            '        ref $constraint',
            '            ? $constraint->( $constraint, ' . $var . ' )',
            '            : ' . $data->{'invocant'} . '->$constraint( ' . $var . ' );',
            '    } or GX::Meta::Exception->complain(',
            '        $@ || "Invalid value for attribute \"' . $self->name . '\""',
            '    );',
            '}';

    }

    return;

}

sub _inline_check_value_constraints {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    if ( $self->_get_value_constraints ) {

        my $var_constraints = '$EVAL_VAR_' . keys %$vars;

        $vars->{$var_constraints} = $self->_get_value_constraints;

        push @$code,
            'for my $constraint ( @' . $var_constraints . ' ) {',
            '    eval { ',
            '        local $_ = ' . $var . ';',
            '        ref $constraint',
            '            ? $constraint->( $constraint, ' . $var . ' )',
            '            : ' . $data->{'invocant'} . '->$constraint( ' . $var . ' );',
            '    } or GX::Meta::Exception->complain(',
            '        $@ || "Invalid value for attribute \"' . $self->name . '\""',
            '    );',
            '}';

    }

    return;

}

sub _inline_delete_slot {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    push @$code, 'delete ' . $data->{'slot'} . ';';

    return;

}

sub _inline_initialize_slot {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    if ( $self->has_initializer ) {
        $self->_inline_set_slot_to_initializer_value( $data, $code, $vars );
    }
    elsif ( $self->has_default_value ) {
        $self->_inline_set_slot_to_default_value( $data, $code, $vars );
    }
    else {
        $self->_inline_set_slot_to_native_value( $data, $code, $vars );
    }

    return;

}

sub _inline_prepare_slot {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    push @$code, 'if ( ! exists ' . $data->{'slot'} . ' ) {';
    $self->_inline_initialize_slot( $data, $code, $vars );
    push @$code, '}';

    return;

}

sub _inline_preprocess_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    if ( $self->_get_preprocessors ) {

        my $var_preprocessors = '$EVAL_VAR_' . keys %$vars;

        $vars->{$var_preprocessors} = $self->_get_preprocessors;

        push @$code,
            'for my $processor ( @' . $var_preprocessors . ' ) {',
            '    ref( $processor )',
            '        ? $processor->( $processor, $_ )',
            '        : ' . $data->{'invocant'} . '->$processor( $_ )',
            '    for ' . $var . ';',
            '}';

    }

    return;

}

sub _inline_process_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    if ( $self->_get_processors ) {

        my $var_processors = '$EVAL_VAR_' . keys %$vars;

        $vars->{$var_processors} = $self->_get_processors;

        push @$code,
            'for my $processor ( @' . $var_processors . ' ) {',
            '    ref( $processor )',
            '        ? $processor->( $processor, $_ )',
            '        : ' . $data->{'invocant'} . '->$processor( $_ )',
            '    for ' . $var . ';',
            '}';

    }

    return;

}

sub _inline_return_slot {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    push @$code, 'return ' . $data->{'slot'} . ';';

    return;

}

sub _inline_set_slot_to_default_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    $self->_inline_set_slot_to_value( $data, $code, $vars, $self->default_value );

    return;

}

sub _inline_set_slot_to_initializer_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    my $initializer = $self->initializer;

    my $var_value;

    if ( ref $initializer ) {
        my $var_initializer = '$EVAL_VAR_' . keys %$vars;
        $vars->{$var_initializer} = $initializer;
        $var_value = $var_initializer . '->( ' . $data->{'invocant'} . ' )';
    }
    else {
        $var_value = $data->{'invocant'} . '->' . $initializer;
    }

    push @$code,
        '{',
        'local $_ = ' . $data->{'invocant'} . ';';

    $self->_inline_assign_to_slot( $data, $code, $vars, $var_value );

    push @$code,
        '}';

    return;

}

sub _inline_set_slot_to_native_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;

    $self->_inline_assign_to_slot( $data, $code, $vars, 'undef' );

    return;

}

sub _inline_set_slot_to_value {

    my $self  = shift;
    my $data  = shift;
    my $code  = shift;
    my $vars  = shift;
    my $value = shift;

    if ( defined $value ) {
        my $var_value = '$EVAL_VAR_' . keys %$vars;
        $vars->{$var_value} = $value;
        $self->_inline_assign_to_slot( $data, $code, $vars, $var_value );
    }
    else {
        $self->_inline_assign_to_slot( $data, $code, $vars, 'undef' );
    }

    return;

}

sub _inline_set_value {

    my $self = shift;
    my $data = shift;
    my $code = shift;
    my $vars = shift;
    my $var  = shift;

    if ( $self->_get_preprocessors || $self->_get_processors ) {
        push @$code, 'my $value = ' . $var . ';';
        $self->_inline_preprocess_value( $data, $code, $vars, '$value' );
        $self->_inline_check_constraints( $data, $code, $vars, '$value' );
        $self->_inline_process_value( $data, $code, $vars, '$value' );
        $self->_inline_assign_to_slot( $data, $code, $vars, '$value' );
    }
    else {
        $self->_inline_check_constraints( $data, $code, $vars, $var );
        $self->_inline_assign_to_slot( $data, $code, $vars, $var );
    }

    return;

}

sub _validate_constraint {

    return ref $_[1] eq 'CODE' || blessed $_[1] || $_[1] =~ REGEX_METHOD_NAME;

}

sub _validate_processor {

    return ref $_[1] eq 'CODE' || blessed $_[1] || $_[1] =~ REGEX_METHOD_NAME;

}


# ----------------------------------------------------------------------------------------------------------------------
# Object initialization
# ----------------------------------------------------------------------------------------------------------------------

sub __initialize {

    my $self = shift;
    my $args = shift;

    for ( qw( class name ) ) {
        defined $args->{$_} or throw "Missing argument (\"$_\")";
    }

    if ( ! blessed $args->{'class'} || ! $args->{'class'}->isa( 'GX::Meta::Class' ) ) {
        throw "Invalid argument (\"class\" must be a GX::Meta::Class object)";
    }

    if ( ! length $args->{'name'} || ref $args->{'name'} ) {
        throw "Invalid argument (\"name\" must be a non-empty string)";
    }

    $self->{'class'}   = delete $args->{'class'};
    $self->{'name'}    = delete $args->{'name'};
    $self->{'static'}  = delete $args->{'static'} ? 1 : 0;
    $self->{'options'} = {};

    if ( exists $args->{'slot'} ) {

        if ( ! defined $args->{'slot'} || ! length $args->{'slot'} || ref $args->{'slot'} ) {
            throw "Invalid argument (\"slot\" must be a non-empty string)";
        }

        $self->{'slot_key'} = delete $args->{'slot'};

    }
    else {
        $self->{'slot_key'} = $self->{'name'};
    }

    weaken $self->{'class'};

    $self->__initialize_options( $args );
    $self->__initialize_type_constraints( $args );
    $self->__initialize_value_constraints( $args );
    $self->__initialize_preprocessors( $args );
    $self->__initialize_processors( $args );
    $self->__initialize_default_value( $args );
    $self->__initialize_initializer( $args );
    $self->__initialize_access_specifier( $args );
    $self->__initialize_accessors( $args );
    $self->__initialize_other( $args );

    if ( keys %$args ) {
        throw sprintf( "Unknown argument (\"%s\")", ( sort keys %$args )[0] );
    }

    return;

}

sub __initialize_access_specifier {

    my $self = shift;
    my $args = shift;

    if ( $args->{'private'} ) {
        $self->{'access_specifier'} = ACCESS_PRIVATE;
    }
    elsif ( $args->{'protected'} ) {
        $self->{'access_specifier'} = ACCESS_PROTECTED;
    }
    else {
        $self->{'access_specifier'} = ACCESS_PUBLIC;
    }

    delete @$args{ qw( public protected private ) };

    return;

}

sub __initialize_accessors {

    my $self = shift;
    my $args = shift;

    my @accessors;

    if ( exists $args->{'accessor'} ) {

        if ( defined $args->{'accessor'} ) {

            if ( ref $args->{'accessor'} eq 'HASH' ) {
                push @accessors, { name => $self->name, %{$args->{'accessor'}} };
            }
            elsif ( $args->{'accessor'} =~ REGEX_METHOD_NAME ) {
                push @accessors, { name => $args->{'accessor'} };
            }
            else {
                throw "Invalid accessor definition";
            }

        }

        delete $args->{'accessor'};

    }

    if ( exists $args->{'accessors'} ) {

        if ( defined $args->{'accessors'} ) {

            if ( ref $args->{'accessors'} eq 'HASH' ) {

                while ( my ( $name, $options ) = each %{$args->{'accessors'}} ) {

                    if ( ref $options ne 'HASH' ) {
                        throw "Invalid accessor definition";
                    }

                    push @accessors, { %$options, name => $name };

                }

            }
            elsif ( ref $args->{'accessors'} eq 'ARRAY' ) {

                for ( @{$args->{'accessors'}} ) {

                    if ( ref $_ eq 'HASH' ) {
                        push @accessors, { name => $self->name, %$_ };
                    }
                    elsif ( ! ref $_ ) {
                        push @accessors, { name => $_ };
                    }
                    else {
                        throw "Invalid accessor definition";
                    }

                }

            }
            else {
                throw "Invalid argument (\"accessors\" must be an array or a hash reference)";
            }

        }

        delete $args->{'accessors'};

    }

    for ( @accessors ) {
        $self->add_accessor( %$_ );
    }

    return;

}

sub __initialize_default_value {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'default'} ) {

        eval {
            $self->check_constraints( $self->class->name, $args->{'default'} );
        } or throw "Invalid default value";

        $self->{'default_value'} = delete $args->{'default'};

    }

    return;

}

sub __initialize_initializer {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'initializer'} ) {

        if ( defined $args->{'initializer'} ) {

            if ( ref $args->{'initializer'} ne 'CODE' && $args->{'initializer'} !~ REGEX_METHOD_NAME ) {
                throw "Bad attribute initializer";
            }

            $self->{'initializer'} = $args->{'initializer'};

        }

        delete $args->{'initializer'};

    }

    return;

}

sub __initialize_options {

    my $self = shift;
    my $args = shift;

    for ( qw( initialize required sticky ) ) {
        $self->_get_options->{$_} = 1 if delete $args->{$_};
    }

    return;

}

sub __initialize_other {

    # Abstract method

}

sub __initialize_processors {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'processor'} ) {

        if ( defined $args->{'processor'} ) {
            $self->add_processor( $args->{'processor'} );
        }

        delete $args->{'processor'};

    }

    return;

}

sub __initialize_preprocessors {

    my $self = shift;
    my $args = shift;

    if ( exists $args->{'preprocessor'} ) {

        if ( defined $args->{'preprocessor'} ) {
            $self->add_preprocessor( $args->{'preprocessor'} );
        }

        delete $args->{'preprocessor'};

    }

    return;

}

sub __initialize_type_constraints {

    my $self = shift;
    my $args = shift;

    if ( $self->TYPE_CONSTRAINT ) {
        $self->add_type_constraint( $self->TYPE_CONSTRAINT );
    }

    return;

}

sub __initialize_value_constraints {

    my $self = shift;
    my $args = shift;

    my @constraints;

    if ( exists $args->{'constraint'} ) {

        if ( defined $args->{'constraint'} ) {
            push @constraints, $args->{'constraint'};
        }

        delete $args->{'constraint'};

    }

    if ( exists $args->{'constraints'} ) {

        if ( ref $args->{'constraints'} ne 'ARRAY' ) {
            throw "Invalid argument (\"constraints\" must be an array reference)";
        }

        push @constraints, @{$args->{'constraints'}};

        delete $args->{'constraints'};

    }

    for ( @constraints ) {
        $self->add_value_constraint( $_ );
    }

    return;

}


1;

__END__

=head1 NAME

GX::Meta::Attribute - Attribute metaclass

=head1 SYNOPSIS

None.

=head1 DESCRIPTION

This module provides the L<GX::Meta::Attribute> class.

=head1 METHODS

=head2 Constructor

=head3 C<new>

Returns a new attribute metaobject.

    $attribute = GX::Meta::Attribute->new( %attributes );

=over 4

=item Attributes:

=over 4

=item * C<accessor> ( string | C<HASH> reference )

An accessor definition.

=item * C<accessors> ( C<ARRAY> reference )

A reference to an array of accessor definitions (see above).

=item * C<class> ( L<GX::Meta::Class> object ) [ required ]

The associated class metaobject.

=item * C<constraint> ( string | C<CODE> reference )

A constraint.

=item * C<constraints> ( C<ARRAY> reference )

A reference to an array with constraints (see above).

=item * C<default> ( scalar )

A default value for the attribute slot.

=item * C<initialize> ( bool )

A boolean value indicating whether or not to initialize the attribute on
object construction. Defaults to false, which means that the attribute is
initialized only on demand, i.e. when it is actually accessed through a
generated accessor method.

=item * C<initializer> ( string | C<CODE> reference )

An initializer.

=item * C<isa> ( string )

The attribute type (for example "Scalar", "Array" or "Hash"; see
L<ATTRIBUTE TYPES|/"ATTRIBUTE TYPES"> below) or attribute class (for example
"GX::Meta::Attribute::Scalar"). Defaults to "Scalar".

=item * C<name> ( string ) [ required ]

The name of the attribute.

=item * C<preprocessor> ( string | C<CODE> reference )

A preprocessor.

=item * C<private> ( bool )

A boolean value indicating whether the attribute is private or not. Defaults
to false. 

=item * C<processor> ( string | C<CODE> reference )

A processor.

=item * C<protected> ( bool )

A boolean value indicating whether the attribute is protected or not. Defaults
to false. 

=item * C<public> ( bool )

A boolean value indicating whether the attribute is public or not. Defaults
to true. 

=item * C<required> ( bool )

A boolean value indicating whether the attribute is required or not. Defaults
to false. 

=item * C<slot> ( string )

The name of the attribute slot. Defaults to the name of the attribute.

=item * C<static> ( bool )

A boolean value indicating whether the attribute is a static (class) attribute
or not. Defaults to false.

=item * C<sticky> ( bool )

A boolean value indicating whether the attribute is sticky or not. Defaults to
false.

=item * C<type> ( string )

The attribute type, for example "Scalar", "Array" or "Hash" (see
L<ATTRIBUTE TYPES|/"ATTRIBUTE TYPES"> below).

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

=head2 Public Methods

=head3 C<accessors>

Returns the associated accessor metaobjects.

    @accessors = $attribute->accessors;

=over 4

=item Returns:

=over 4

=item * C<@accessors> ( L<GX::Meta::Accessor> objects )

=back

=back

=head3 C<add_accessor>

Creates a new accessor metaobject for the attribute and adds it.

    $accessor = $attribute->add_accessor( %arguments );

=over 4

=item Arguments:

=over 4

=item * C<%arguments> ( named list )

Arguments to pass to the L<GX::Meta::Accessor> L<constructor|GX::Meta::Accessor/new>.

=back

=item Returns:

=over 4

=item * C<$accessor> ( L<GX::Meta::Accessor> object )

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<add_preprocessor>

Adds a preprocessor.

    $attribute->add_preprocessor( $preprocessor );

=over 4

=item Arguments:

=over 4

=item * C<$preprocessor> ( string | C<CODE> reference )

A code reference or method name.

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<add_processor>

Adds a processor.

    $attribute->add_processor( $processor );

=over 4

=item Arguments:

=over 4

=item * C<$processor> ( string | C<CODE> reference )

A code reference or method name.

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<add_type_constraint>

Adds a type constraint.

    $attribute->add_type_constraint( $constraint );

=over 4

=item Arguments:

=over 4

=item * C<$constraint> ( string | C<CODE> reference )

A code reference or method name.

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<add_value_constraint>

Adds a value constraint.

    $attribute->add_value_constraint( $constraint );

=over 4

=item Arguments:

=over 4

=item * C<$constraint> ( string | C<CODE> reference )

A code reference or method name.

=back

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<class>

Returns the associated class metaobject.

    $class = $attribute->class;

=over 4

=item Returns:

=over 4

=item * C<$class> ( L<GX::Meta::Class> object )

=back

=back

=head3 C<default_value>

Returns the default attribute value.

    $default_value = $attribute->default_value;

=over 4

=item Returns:

=over 4

=item * C<$default_value> ( scalar )

=back

=back

=head3 C<has_default_value>

Returns true if the attribute has a default value, otherwise false.

    $result = $attribute->has_default_value;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<has_initializer>

Returns true if the attribute has an initializer, otherwise false.

    $result = $attribute->has_initializer;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<initializer>

Returns the initializer, or C<undef> if the attribute does not have one.

    $initializer = $attribute->initializer;

=over 4

=item Returns:

=over 4

=item * C<$initializer> ( string | C<CODE> reference | C<undef> )

=back

=back

=head3 C<install>

Installs the attribute.

    $attribute->install;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<install_accessors>

Installs the accessors.

    $attribute->install_accessors;

=over 4

=item Exceptions:

=over 4

=item * L<GX::Meta::Exception>

=back

=back

=head3 C<is_private>

Returns true if the attribute is private, otherwise false.

    $result = $attribute->is_private;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_protected>

Returns true if the attribute is protected, otherwise false.

    $result = $attribute->is_protected;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_public>

Returns true if the attribute is public, otherwise false.

    $result = $attribute->is_public;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_required>

Returns true if the attribute is required, otherwise false.

    $result = $attribute->is_required;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_static>

Returns true if the attribute is static, otherwise false.

    $result = $attribute->is_static;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<is_sticky>

Returns true if the attribute is sticky, otherwise false.

    $result = $attribute->is_sticky;

=over 4

=item Returns:

=over 4

=item * C<$result> ( bool )

=back

=back

=head3 C<name>

Returns the name of the attribute.

    $name = $attribute->name;

=over 4

=item Returns:

=over 4

=item * C<$name> ( string )

=back

=back

=head3 C<preprocessors>

Returns the preprocessors.

    @preprocessors = $attribute->preprocessors;

=over 4

=item Returns:

=over 4

=item * C<@preprocessors> ( strings | C<CODE> references )

=back

=back

=head3 C<processors>

Returns the processors.

    @processors = $attribute->processors;

=over 4

=item Returns:

=over 4

=item * C<@processors> ( strings | C<CODE> references )

=back

=back

=head3 C<quoted_slot_key>

Returns the quoted slot key.

    $quoted_slot_key = $attribute->quoted_slot_key;

=over 4

=item Returns:

=over 4

=item * C<$quoted_slot_key> ( string )

=back

=back

=head3 C<slot_key>

Returns the slot key.

    $slot_key = $attribute->slot_key;

=over 4

=item Returns:

=over 4

=item * C<$slot_key> ( string )

=back

=back

=head3 C<type>

Returns a string identifying the attribute type.

    $type = $attribute->type;

=over 4

=item Returns:

=over 4

=item * C<$type> ( string )

=back

=back

=head3 C<type_constraints>

Returns the type constraints.

    @constraints = $attribute->type_constraints;

=over 4

=item Returns:

=over 4

=item * C<@constraints> ( strings | C<CODE> references )

=back

=back

=head3 C<value_constraints>

Returns the value constraints.

    @constraints = $attribute->value_constraints;

=over 4

=item Returns:

=over 4

=item * C<@constraints> ( strings | C<CODE> references )

=back

=back

=head1 ATTRIBUTE TYPES

=over 4

=item * C<Array>

See L<GX::Meta::Attribute::Array>.

=item * C<Bool>

See L<GX::Meta::Attribute::Bool>.

=item * C<Hash>

See L<GX::Meta::Attribute::Hash>.

=item * C<Hash::Ordered>

See L<GX::Meta::Attribute::Hash::Ordered>.

=item * C<Object>

See L<GX::Meta::Attribute::Object>.

=item * C<Scalar>

See L<GX::Meta::Attribute::Scalar>.

=item * C<String>

See L<GX::Meta::Attribute::String>.

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
