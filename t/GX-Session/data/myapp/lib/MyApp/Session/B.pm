package MyApp::Session::B;

use GX::Session;
use GX::Session::ID::Generator::MD5;


__PACKAGE__->setup(

    store => 'GX::Session::Store::Dummy',

    tracker => [
        'GX::Session::Tracker::Cookie' => {
            cookie_attributes => {
                name => 'CUSTOM_COOKIE_NAME_B'
            } 
        }
    ],

    id_generator => GX::Session::ID::Generator::MD5->new,

    lifetime => 99999,

    timeout => 999,

    auto_resume => 0,

    auto_save => 0,

    auto_start => 1,

    bind_to_remote_address => 0

);


1;

__END__
