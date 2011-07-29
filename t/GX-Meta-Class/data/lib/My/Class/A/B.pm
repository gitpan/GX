package My::Class::A::B;

use strict;
use warnings;

use base qw( My::Class::A );


sub method_3 {

    return "My::Class::A::B::method_3", @_;

}

sub method_4 {

    return "My::Class::A::B::method_4", @_;

}

sub method_5 {

    return "My::Class::A::B::method_5", @_;

}


1;

__END__
