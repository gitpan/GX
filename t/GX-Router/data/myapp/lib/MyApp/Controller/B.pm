package MyApp::Controller::B;

use GX::Controller;


__PACKAGE__->setup(

    routes => [
        'action_4'  => '/b/static_4',
        'action_5'  => 'static_5',
        'action_6'  => './static_6',
        'action_7'  => '/b/path_7/{k1}',
        'action_8'  => 'path_8/{k1}',
        'action_9'  => './path_9/{k1}'
    ]

);


sub action_1  :Action {}
sub action_2  :Action {}
sub action_3  :Action {}
sub action_4  :Action {}
sub action_5  :Action {}
sub action_6  :Action {}
sub action_7  :Action {}
sub action_8  :Action {}
sub action_9  :Action {}


1;

__END__
