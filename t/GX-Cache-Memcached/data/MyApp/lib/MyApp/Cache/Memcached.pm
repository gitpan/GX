package MyApp::Cache::Memcached;

use GX::Cache::Memcached;


__PACKAGE__->setup(
    servers => [ $ENV{'GX_MEMCACHED_SERVER'} || '127.0.0.1:11211' ]
);


1;

__END__
