package MyApp::Controller::B;

use GX::Controller;

__PACKAGE__->setup(

    routes => [

        'action_8' => '/b/action_8/custom/2',

        'action_9'  => '/b/action_9/custom',
        'action_10' => './action_10/custom',
        'action_11' => 'action_11/custom',

        'action_12' => '/b/action_12/custom/{parameter_1}',
        'action_13' => './action_13/custom/{parameter_1}',
        'action_14' => 'action_14/custom/{parameter_1}',

        'action_15' => '/b/action_15/custom/1',
        'action_15' => '/b/action_15/custom/2',

        'action_16' => { class => 'GX::Route::Static', path => '/b/action_16/custom' },
        'action_17' => { class => 'GX::Route::Dynamic', path => '/b/action_17/custom/{parameter_1}' },

        'action_18' => undef,

    ]

);


sub action_1  :Action( '/b/action_1/custom' ) {}
sub action_2  :Action( './action_2/custom' ) {}
sub action_3  :Action( 'action_3/custom' ) {}
sub action_4  :Action( '/b/action_4/custom/{parameter_1}' ) {}
sub action_5  :Action( './action_5/custom/{parameter_1}' ) {}
sub action_6  :Action( 'action_6/custom/{parameter_1}' ) {}
sub action_7  :Action( '/b/action_7/custom', '/b/action_7/custom/{parameter_1}' ) {}
sub action_8  :Action( '/b/action_8/custom/1' ) {}
sub action_9  :Action {}
sub action_10 :Action {}
sub action_11 :Action {}
sub action_12 :Action {}
sub action_13 :Action {}
sub action_14 :Action {}
sub action_15 :Action {}
sub action_16 :Action {}
sub action_17 :Action {}
sub action_18 :Action {}
sub action_19 :Action {}


1;

__END__
