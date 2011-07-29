package MyApp::Controller::A::C;

use base 'MyApp::Controller::A';


__PACKAGE__->setup(
    inherit_filters => 0
);


sub action_3 :Action {}
sub action_4 :Action {}
sub action_5 :Action {}

sub render_2 :Render {}

sub after_3 :After {}
sub after_4 :After {}

sub method_3 {}
sub method_4 {}
sub method_5 {}


1;

__END__
