package MyApp::View::A;

use GX::View;


sub render {

    my $self = shift;
    my %args = @_;

    my $context = delete $args{'context'};

    $context->response->add( __PACKAGE__ );

    for my $key ( sort keys %args ) {
        $context->response->add( ' ' . $key . ' => ' . $args{$key} );
    }

    return;

}


1;

__END__
