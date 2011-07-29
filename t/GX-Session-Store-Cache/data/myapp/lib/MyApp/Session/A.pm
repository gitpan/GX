package MyApp::Session::A;

use GX::Session;


__PACKAGE__->setup(

    store => [
        'GX::Session::Store::Cache' => {
            cache => 'MyApp::Cache::Memcached'
        }
    ]

);


1;

__END__
