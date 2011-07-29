package MyApp::Controller::A;

use GX::Controller;


sub action_1 :Action {}
sub action_2 :Action {}
sub action_3 :Action {}

sub action_4 :Action( '/a/static_4' ) {}
sub action_5 :Action( 'static_5' )    {}
sub action_6 :Action( './static_6' )  {}

sub action_7 :Action( '/a/path_7/{k1}' ) {}
sub action_8 :Action( 'path_8/{k1}' )    {}
sub action_9 :Action( './path_9/{k1}' )  {}


1;

__END__
