package MyApp::Controller::A;

use GX::Controller;


sub action_1 :Action {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::action_1';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_1'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub action_2 :Action {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::action_2';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_2'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub action_3 :Action {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::action_3';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_3'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub action_4 :Action( 'action_4/{k1}' ) {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::action_4';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_4'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub action_5 :Action( 'action_5/{k1}/{k2}' ) {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::action_5';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::action_5'};
        $_->( $context ) for @$callbacks;
    }

    return;

}


1;

__END__
