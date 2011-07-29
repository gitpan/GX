package MyApp::Session::A;

use GX::Session;


__PACKAGE__->setup(

    store => [
        'GX::Session::Store::Database' => {
            database => 'MyApp::Database::SQLite',
            table    => 'sessions'
        }
    ]

);


1;

__END__
