package MyApp;

use GX;


MyApp->setup(
    mode => 'development'
);

MyApp->start;


sub handler_1 :Handler( Initialize ) {}


1;

__END__
