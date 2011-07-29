package My::Class::A::A;

use strict;
use warnings;

use base qw( My::Class::A );


sub method_2 {

    return "My::Class::A::A::method_2", @_;

}

sub method_3 {

    return "My::Class::A::A::method_3", @_;

}

sub method_4 {

    return "My::Class::A::A::method_4", @_;

}


1;

__END__
