package MyApp::Database::A;

use GX::Database::Pg;


__PACKAGE__->setup(
    database => 'gxtest',
    user     => 'gxuser',
    password => 'gxpassword'
);


1;

__END__
