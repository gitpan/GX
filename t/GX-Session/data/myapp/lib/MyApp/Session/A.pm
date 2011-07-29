package MyApp::Session::A;

use GX::Session;


__PACKAGE__->setup(

    store => 'GX::Session::Store::Dummy'

);


1;

__END__
