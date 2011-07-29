package MyApp::Cache::Memcached;

use GX::Cache::Memcached;


__PACKAGE__->setup(
    servers => [ '127.0.0.1:11211' ]
);


1;

__END__
