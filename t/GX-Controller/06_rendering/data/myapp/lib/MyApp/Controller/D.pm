package MyApp::Controller::D;

use GX::Controller;


__PACKAGE__->setup(

    render_all => {
        'format_1' => [ view => 'C', option => 'render_all', format => 'format_1' ],
        'format_2' => [ view => 'C', option => 'render_all', format => 'format_2' ],
        'format_3' => [ view => 'C', option => 'render_all', format => 'format_3' ]
    },

    render => {

        'action_1' => [ view => 'C', option => 'render', action => 'action_1', format => '*' ],

        'action_2' => {
            'format_1' => [ view => 'C', option => 'render', action => 'action_2', format => 'format_1' ]
        },
        'action_3' => {
            'format_1' => [ view => 'C', option => 'render', action => 'action_3', format => 'format_1' ],
            'format_2' => [ view => 'C', option => 'render', action => 'action_3', format => 'format_2' ]
        },
        'action_4' => {
            'format_1' => [ view => 'C', option => 'render', action => 'action_4', format => 'format_1' ],
            'format_2' => [ view => 'C', option => 'render', action => 'action_4', format => 'format_2' ],
            'format_3' => [ view => 'C', option => 'render', action => 'action_4', format => 'format_3' ]
        },
        'action_5' => {
            'format_1' => [ view => 'C', option => 'render', action => 'action_5', format => 'format_1' ],
            'format_2' => [ view => 'C', option => 'render', action => 'action_5', format => 'format_2' ],
            'format_3' => [ view => 'C', option => 'render', action => 'action_5', format => 'format_3' ],
            'format_4' => [ view => 'C', option => 'render', action => 'action_5', format => 'format_4' ]
        },

        'action_6' => {},

        'action_7' => GX::Renderer->new(
            handlers => {
                'format_3' => GX::Callback::Method->new(
                    invocant  => MyApp::View::C->instance,
                    method    => 'render',
                    arguments => [ option => 'render', action => 'action_7', format => 'format_3' ]
                ),
                'format_4' => GX::Callback::Method->new(
                    invocant  => MyApp::View::C->instance,
                    method    => 'render',
                    arguments => [ option => 'render', action => 'action_7', format => 'format_4' ]
                )
            }
        )

    }

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
