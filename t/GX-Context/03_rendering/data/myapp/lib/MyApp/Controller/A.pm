package MyApp::Controller::A;

use GX::Controller;


__PACKAGE__->setup(

    render => {
        'action_2' => 'MyApp::View::A',
        'action_3' => {
            'format_1' => [ view => 'MyApp::View::A', format => 'format_1' ],
            'format_2' => [ view => 'MyApp::View::A', format => 'format_2' ],
        }
    }

);

sub action_1 :Action {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::action_1';

    if ( $context->stash->{'_test_callbacks'} ) {

        if ( my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'} ) {
            $_->( $context ) for @$callbacks;
        }

    }

    return;

}

sub action_2 :Action {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::action_2';

    if ( $context->stash->{'_test_callbacks'} ) {

        if ( my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_2'} ) {
            $_->( $context ) for @$callbacks;
        }

    }

    return;

}

sub action_3 :Action {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::action_3';

    if ( $context->stash->{'_test_callbacks'} ) {

        if ( my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_3'} ) {
            $_->( $context ) for @$callbacks;
        }

    }

    return;

}


1;

__END__
