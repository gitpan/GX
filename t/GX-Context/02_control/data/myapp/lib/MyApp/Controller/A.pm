package MyApp::Controller::A;

use GX::Controller;


sub before_1 :Before {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::before_1';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::before_1'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub before_2 :Before {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::before_2';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::before_2'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub before_3 :Before {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::before_3';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::before_3'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

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

sub render_1 :Render {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::render_1';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::render_1'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub render_2 :Render {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::render_2';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::render_2'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub render_3 :Render {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::render_3';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::render_3'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub after_1 :After {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::after_1';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::after_1'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub after_2 :After {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::after_2';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::after_2'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub after_3 :After {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::A::after_3';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::A::after_3'};
        $_->( $context ) for @$callbacks;
    }

    return;

}


1;

__END__
