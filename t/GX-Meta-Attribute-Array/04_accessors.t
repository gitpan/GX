#!/usr/bin/perl

use strict;
use warnings FATAL => 'all';


package My::Class::A;

use Scalar::Util qw( refaddr );

our $ATTRIBUTE_2_DEFAULT_VALUE = [ 1 .. 2 ];
our $ATTRIBUTE_6_DEFAULT_VALUE = [ 1 .. 6 ];

sub new { my $class = shift; return bless { @_ }, $class; }

sub attribute_3_initializer { [ refaddr( $_[0] ), 2 .. 3 ] }
sub attribute_7_initializer { [ refaddr( $_[0] ), 2 .. 7 ] }


package main;

use GX::Meta::Class;
use GX::Meta::Attribute::Array;

use Scalar::Util qw( isweak refaddr weaken );


use Test::More tests => 444;


my $CLASS_A = GX::Meta::Class->new( 'My::Class::A' );

my $ATTRIBUTE_1 = GX::Meta::Attribute::Array->new(
    class => $CLASS_A,
    name  => 'attribute_1'
);

my $ATTRIBUTE_2 = GX::Meta::Attribute::Array->new(
    class   => $CLASS_A,
    name    => 'attribute_2',
    default => $ATTRIBUTE_2_DEFAULT_VALUE
);

my $ATTRIBUTE_3 = GX::Meta::Attribute::Array->new(
    class       => $CLASS_A,
    name        => 'attribute_3',
    initializer => 'attribute_3_initializer'
);

my $ATTRIBUTE_4 = GX::Meta::Attribute::Array->new(
    class       => $CLASS_A,
    name        => 'attribute_4',
    initializer => sub { [ refaddr( $_[0] ), 2 .. 4 ] }
);

my $ATTRIBUTE_5 = GX::Meta::Attribute::Array->new(
    class  => $CLASS_A,
    name   => 'attribute_5',
    weaken => 1
);

my $ATTRIBUTE_6 = GX::Meta::Attribute::Array->new(
    class   => $CLASS_A,
    name    => 'attribute_6',
    default => $ATTRIBUTE_6_DEFAULT_VALUE,
    weaken  => 1
);

my $ATTRIBUTE_7 = GX::Meta::Attribute::Array->new(
    class       => $CLASS_A,
    name        => 'attribute_7',
    initializer => 'attribute_7_initializer',
    weaken      => 1
);

my $ATTRIBUTE_8 = GX::Meta::Attribute::Array->new(
    class       => $CLASS_A,
    name        => 'attribute_8',
    initializer => sub { [ refaddr( $_[0] ), 2 .. 8 ] },
    weaken      => 1
);

my @ATTRIBUTES = (
    $ATTRIBUTE_1,
    $ATTRIBUTE_2,
    $ATTRIBUTE_3,
    $ATTRIBUTE_4,
    $ATTRIBUTE_5,
    $ATTRIBUTE_6,
    $ATTRIBUTE_7,
    $ATTRIBUTE_8
);

my @ACCESSOR_TYPES = qw(
    clear
    default
    get
    get_list
    get_reference
    set
    size
);


# Accessor setup
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;

        for my $accessor_type ( @ACCESSOR_TYPES ) {

            my $accessor_name = "${attribute_name}_${accessor_type}";

            $attribute->add_accessor(
                name => $accessor_name,
                type => $accessor_type
            );

        }

        $attribute->install_accessors;

    }

}

# attribute_1, lazy initialization
{

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_1_get, $object->{'attribute_1'} );
        is_deeply( $object->{'attribute_1'}, [] );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_1_get ], [] );
        is_deeply( $object->{'attribute_1'}, [] );
    }

    # get_list(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_1_get_list, 0 );
        is_deeply( $object->{'attribute_1'}, [] );
    }

    # get_list(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_1_get_list ], [] );
        is_deeply( $object->{'attribute_1'}, [] );
    }

    # get_reference(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_1_get_reference, $object->{'attribute_1'} );
        is_deeply( $object->{'attribute_1'}, [] );
    }

    # get_reference(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_1_get_reference ], [ $object->{'attribute_1'} ] );
        is_deeply( $object->{'attribute_1'}, [] );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_1_size, 0 );
        is_deeply( $object->{'attribute_1'}, [] );
    }

}

# attribute_2, lazy initialization
{

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_2_get, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
        is( $object->{'attribute_2'}, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_2_get ], $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
        is( $object->{'attribute_2'}, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # get_list(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_2_get_list, 2 );
        is( $object->{'attribute_2'}, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # get_list(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_2_get_list ], $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
        is( $object->{'attribute_2'}, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # get_reference(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_2_get_reference, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
        is( $object->{'attribute_2'}, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # get_reference(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_2_get_reference ], [ $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE ] );
        is( $object->{'attribute_2'}, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_2_size, 2 );
        is( $object->{'attribute_2'}, $My::Class::A::ATTRIBUTE_2_DEFAULT_VALUE );
    }

}

# attribute_3, lazy initialization
{

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_3_get, $object->{'attribute_3'} );
        is_deeply( $object->{'attribute_3'}, [ refaddr( $object ), 2 .. 3 ] );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_3_get ], [ refaddr( $object ), 2 .. 3 ] );
        is_deeply( $object->{'attribute_3'}, [ refaddr( $object ), 2 .. 3 ] );
    }

    # get_list(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_3_get_list, 3 );
        is_deeply( $object->{'attribute_3'}, [ refaddr( $object ), 2 .. 3 ] );
    }

    # get_list(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_3_get_list ], [ refaddr( $object ), 2 .. 3 ] );
        is_deeply( $object->{'attribute_3'}, [ refaddr( $object ), 2 .. 3 ] );
    }

    # get_reference(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_3_get_reference, $object->{'attribute_3'} );
        is_deeply( $object->{'attribute_3'}, [ refaddr( $object ), 2 .. 3 ] );
    }

    # get_reference(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_3_get_reference ], [ $object->{'attribute_3'} ] );
        is_deeply( $object->{'attribute_3'}, [ refaddr( $object ), 2 .. 3 ] );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_3_size, 3 );
        is_deeply( $object->{'attribute_3'}, [ refaddr( $object ), 2 .. 3 ] );
    }

}

# attribute_4, lazy initialization
{

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_4_get, $object->{'attribute_4'} );
        is_deeply( $object->{'attribute_4'}, [ refaddr( $object ), 2 .. 4 ] );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_4_get ], [ refaddr( $object ), 2 .. 4 ] );
        is_deeply( $object->{'attribute_4'}, [ refaddr( $object ), 2 .. 4 ] );
    }

    # get_list(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_4_get_list, 4 );
        is_deeply( $object->{'attribute_4'}, [ refaddr( $object ), 2 .. 4 ] );
    }

    # get_list(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_4_get_list ], [ refaddr( $object ), 2 .. 4 ] );
        is_deeply( $object->{'attribute_4'}, [ refaddr( $object ), 2 .. 4 ] );
    }

    # get_reference(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_4_get_reference, $object->{'attribute_4'} );
        is_deeply( $object->{'attribute_4'}, [ refaddr( $object ), 2 .. 4 ] );
    }

    # get_reference(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_4_get_reference ], [ $object->{'attribute_4'} ] );
        is_deeply( $object->{'attribute_4'}, [ refaddr( $object ), 2 .. 4 ] );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_4_size, 4 );
        is_deeply( $object->{'attribute_4'}, [ refaddr( $object ), 2 .. 4 ] );
    }

}

# attribute_5, lazy initialization
{

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_5_get, $object->{'attribute_5'} );
        is_deeply( $object->{'attribute_5'}, [] );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_5_get ], [] );
        is_deeply( $object->{'attribute_5'}, [] );
    }

    # get_list(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_5_get_list, 0 );
        is_deeply( $object->{'attribute_5'}, [] );
    }

    # get_list(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_5_get_list ], [] );
        is_deeply( $object->{'attribute_5'}, [] );
    }

    # get_reference(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_5_get_reference, $object->{'attribute_5'} );
        is_deeply( $object->{'attribute_5'}, [] );
    }

    # get_reference(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_5_get_reference ], [ $object->{'attribute_5'} ] );
        is_deeply( $object->{'attribute_5'}, [] );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_5_size, 0 );
        is_deeply( $object->{'attribute_5'}, [] );
    }

}

# attribute_6, lazy initialization
{

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_6_get, $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE );
        is( $object->{'attribute_6'}, $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_6_get ], $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE );
        is( $object->{'attribute_6'}, $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE );
    }

    # get_list(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_6_get_list, 6 );
        is( $object->{'attribute_6'}, $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE );
    }

    # get_list(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_6_get_list ], $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE );
        is( $object->{'attribute_6'}, $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE );
    }

    # get_reference(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_6_get_reference, $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE );
        is( $object->{'attribute_6'}, $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE );
    }

    # get_reference(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_6_get_reference ], [ $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE ] );
        is( $object->{'attribute_6'}, $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_6_size, 6 );
        is( $object->{'attribute_6'}, $My::Class::A::ATTRIBUTE_6_DEFAULT_VALUE );
    }

}

# attribute_7, lazy initialization
{

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_7_get, $object->{'attribute_7'} );
        is_deeply( $object->{'attribute_7'}, [ refaddr( $object ), 2 .. 7 ] );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_7_get ], [ refaddr( $object ), 2 .. 7 ] );
        is_deeply( $object->{'attribute_7'}, [ refaddr( $object ), 2 .. 7 ] );
    }

    # get_list(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_7_get_list, 7 );
        is_deeply( $object->{'attribute_7'}, [ refaddr( $object ), 2 .. 7 ] );
    }

    # get_list(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_7_get_list ], [ refaddr( $object ), 2 .. 7 ] );
        is_deeply( $object->{'attribute_7'}, [ refaddr( $object ), 2 .. 7 ] );
    }

    # get_reference(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_7_get_reference, $object->{'attribute_7'} );
        is_deeply( $object->{'attribute_7'}, [ refaddr( $object ), 2 .. 7 ] );
    }

    # get_reference(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_7_get_reference ], [ $object->{'attribute_7'} ] );
        is_deeply( $object->{'attribute_7'}, [ refaddr( $object ), 2 .. 7 ] );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_7_size, 7 );
        is_deeply( $object->{'attribute_7'}, [ refaddr( $object ), 2 .. 7 ] );
    }

}

# attribute_8, lazy initialization
{

    # get(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_8_get, $object->{'attribute_8'} );
        is_deeply( $object->{'attribute_8'}, [ refaddr( $object ), 2 .. 8 ] );
    }

    # get(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_8_get ], [ refaddr( $object ), 2 .. 8 ] );
        is_deeply( $object->{'attribute_8'}, [ refaddr( $object ), 2 .. 8 ] );
    }

    # get_list(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_8_get_list, 8 );
        is_deeply( $object->{'attribute_8'}, [ refaddr( $object ), 2 .. 8 ] );
    }

    # get_list(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_8_get_list ], [ refaddr( $object ), 2 .. 8 ] );
        is_deeply( $object->{'attribute_8'}, [ refaddr( $object ), 2 .. 8 ] );
    }

    # get_reference(), scalar context
    {
        my $object = My::Class::A->new;
        is( scalar $object->attribute_8_get_reference, $object->{'attribute_8'} );
        is_deeply( $object->{'attribute_8'}, [ refaddr( $object ), 2 .. 8 ] );
    }

    # get_reference(), list context
    {
        my $object = My::Class::A->new;
        is_deeply( [ $object->attribute_8_get_reference ], [ $object->{'attribute_8'} ] );
        is_deeply( $object->{'attribute_8'}, [ refaddr( $object ), 2 .. 8 ] );
    }

    # size()
    {
        my $object = My::Class::A->new;
        is( $object->attribute_8_size, 8 );
        is_deeply( $object->{'attribute_8'}, [ refaddr( $object ), 2 .. 8 ] );
    }

}

# set(), get(), get_list(), get_reference(), size(), clear()
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;
        my $slot_key       = $attribute->slot_key;

        my $accessor_get           = "${attribute_name}_get";
        my $accessor_get_list      = "${attribute_name}_get_list";
        my $accessor_get_reference = "${attribute_name}_get_reference";
        my $accessor_set           = "${attribute_name}_set";
        my $accessor_size          = "${attribute_name}_size";
        my $accessor_clear         = "${attribute_name}_clear";

        my $object = My::Class::A->new;

        # set( 1 )
        is_deeply( [ $object->$accessor_set( 1 ) ], [] );
        is_deeply( $object->{$slot_key}, [ 1 ] );

        # get()
        is( scalar $object->$accessor_get, $object->{$slot_key} );
        is_deeply( [ $object->$accessor_get ], [ 1 ] );

        # get_list()
        is( scalar $object->$accessor_get_list, 1 );
        is_deeply( [ $object->$accessor_get_list ], [ 1 ] );

        # get_reference()
        is( scalar $object->$accessor_get_reference, $object->{$slot_key} );
        is_deeply( [ $object->$accessor_get_reference ], [ $object->{$slot_key} ] );

        # size()
        is( $object->$accessor_size, 1 );

        # set( 1 .. 3 )
        is_deeply( [ $object->$accessor_set( 1 .. 3 ) ], [] );
        is_deeply( $object->{$slot_key}, [ 1 .. 3 ] );

        # get()
        is( scalar $object->$accessor_get, $object->{$slot_key} );
        is_deeply( [ $object->$accessor_get ], [ 1 .. 3 ] );

        # get_list()
        is( scalar $object->$accessor_get_list, 3 );
        is_deeply( [ $object->$accessor_get_list ], [ 1 .. 3 ] );

        # get_reference()
        is( scalar $object->$accessor_get_reference, $object->{$slot_key} );
        is_deeply( [ $object->$accessor_get_reference ], [ $object->{$slot_key} ] );

        # size()
        is( $object->$accessor_size, 3 );

        # set()
        is_deeply( [ $object->$accessor_set() ], [] );
        is_deeply( $object->{$slot_key}, [] );

        # get()
        is( scalar $object->$accessor_get, $object->{$slot_key} );
        is_deeply( [ $object->$accessor_get ], [] );

        # get_list()
        is( scalar $object->$accessor_get_list, 0 );
        is_deeply( [ $object->$accessor_get_list ], [] );

        # get_reference()
        is( scalar $object->$accessor_get_reference, $object->{$slot_key} );
        is_deeply( [ $object->$accessor_get_reference ], [ $object->{$slot_key} ] );

        # size()
        is( $object->$accessor_size, 0 );

        # clear()
        $object->$accessor_clear;
        ok( ! exists $object->{$slot_key} );

    }

}

# default()
{

    for my $attribute ( @ATTRIBUTES ) {

        my $attribute_name = $attribute->name;
        my $slot_key       = $attribute->slot_key;

        my $accessor_default = "${attribute_name}_default";

        my $object = My::Class::A->new;

        # default( 1 ), scalar context
        is( scalar $object->$accessor_default( 1 ), $object->{$slot_key} );
        is_deeply( $object->{$slot_key}, [ 1 ] );

        # default(), scalar context
        is( scalar $object->$accessor_default, $object->{$slot_key} );

        # default( 1 .. 3 ), scalar context
        is( scalar $object->$accessor_default( 1 .. 3 ), $object->{$slot_key} );
        is_deeply( $object->{$slot_key}, [ 1 .. 3 ] );

        # default(), scalar context
        is( scalar $object->$accessor_default, $object->{$slot_key} );

        # default( 1 ), list context
        is_deeply( [ $object->$accessor_default( 1 ) ], [ 1 ] );
        is_deeply( $object->{$slot_key}, [ 1 ] );

        # default(), list context
        is_deeply( [ $object->$accessor_default ], [ 1 ] );

        # default( 1 .. 3 ), list context
        is_deeply( [ $object->$accessor_default( 1 .. 3 ) ], [ 1.. 3 ] );
        is_deeply( $object->{$slot_key}, [ 1 .. 3 ] );

        # default(), list context
        is_deeply( [ $object->$accessor_default ], [ 1 .. 3 ] );


    }

}

# Weaken
{

    for my $attribute (
        $ATTRIBUTE_5,
        $ATTRIBUTE_7,
        $ATTRIBUTE_8
    ) {

        my $attribute_name = $attribute->name;
        my $slot_key       = $attribute->slot_key;

        my $accessor_set     = "${attribute_name}_set";
        my $accessor_default = "${attribute_name}_default";

        {
            my $object = My::Class::A->new;
            my $value  = \'reference';
            $object->$accessor_default( $value );
            is_deeply( $object->{$slot_key}, [ $value ] );
            ok( isweak( $object->{$slot_key}[0] ) );
        }

        {
            my $object = My::Class::A->new;
            my $value  = \'reference';
            $object->$accessor_set( $value );
            is_deeply( $object->{$slot_key}, [ $value ] );
            ok( isweak( $object->{$slot_key}[0] ) );
        }

    }

}

