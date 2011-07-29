package MyApp::Database::A;

use GX::Database::SQLite;


__PACKAGE__->setup(
    file => File::Spec->rel2abs( 'a.sqlite', MyApp->instance->path( 'base' ) )
);


1;

__END__
