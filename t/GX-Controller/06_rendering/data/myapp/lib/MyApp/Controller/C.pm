package MyApp::Controller::C;

use GX::Controller;


__PACKAGE__->setup(

    render_all => 'MyApp::View::C'

);


sub action_1  :Action {}
sub action_2  :Action {}
sub action_3  :Action {}


1;

__END__
