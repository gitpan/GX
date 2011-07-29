package MyApp::Controller::B;

use GX::Controller;

use GX::Callback;
use GX::Callback::Method;


our $Action_10_renderer = GX::Renderer->new;


__PACKAGE__->setup(

    render => {

        'action_1'  => 'C',
        'action_2'  => 'MyApp::View::C',
        'action_3'  => MyApp::View::C->instance,

        'action_4'  => [ view => 'C', 'k1' => 'v1' ],
        'action_5'  => [ view => 'C', 'k1' => 'v1', 'k2' => 'v2' ],
        'action_6'  => [ view => 'C', 'k1' => 'v1', 'k2' => 'v2', 'k3' => 'v3' ],

        'action_7'  => \&action_7_render_code,
        'action_8'  => GX::Callback->new( \&action_8_render_code ),
        'action_9'  => GX::Callback::Method->new( invocant => __PACKAGE__->instance, method => 'action_9_render_method' ),

        'action_10' => $Action_10_renderer,

        'action_11' => {
            'format_1'  => 'C',
            'format_2'  => 'MyApp::View::C',
            'format_3'  => MyApp::View::C->instance,
            'format_4'  => [ view => 'C', 'k1' => 'v1' ],
            'format_5'  => [ view => 'C', 'k1' => 'v1', 'k2' => 'v2' ],
            'format_6'  => { view => 'C', 'k1' => 'v1', 'k2' => 'v2', 'k3' => 'v3' },
            'format_7'  => \&action_11_format_7_render_code,
            'format_8'  => GX::Callback->new( \&action_11_format_8_render_code ),
            'format_9'  => GX::Callback::Method->new( invocant => __PACKAGE__->instance, method => 'action_11_format_9_render_method' )
        }

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
sub action_10 :Action {}
sub action_11 :Action {}

sub action_7_render_code             {}
sub action_8_render_code             {}
sub action_9_render_method           {}
sub action_11_format_7_render_code   {}
sub action_11_format_8_render_code   {}
sub action_11_format_9_render_method {}


1;

__END__
