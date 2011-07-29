package MyApp::Database::SQLite;

use GX::Database::SQLite;


__PACKAGE__->setup(
    file => ':memory:'
);


1;

__END__
