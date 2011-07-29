package MyApp::Router;

use GX::Router;

__PACKAGE__->setup(

    routes => [
        {
            controller => 'C',
            action     => 'action_1',
            path       => '/router/static_1'
        },
        {
            controller => 'C',
            action     => 'action_2',
            path       => '/router/path_2/{k1}'
        }
    ],

    default_action => [ 'A', 'action_1' ]

);


1;

__END__
