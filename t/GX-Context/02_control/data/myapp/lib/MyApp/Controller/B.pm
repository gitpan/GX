package MyApp::Controller::B;

use GX::Controller;


sub before_1 :Before {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::before_1';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::before_1'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub before_2 :Before {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::before_2';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::before_2'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub before_3 :Before {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::before_3';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::before_3'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub action_1 :Action {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::action_1';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::action_1'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub action_2 :Action {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::action_2';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::action_2'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub action_3 :Action {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::action_3';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::action_3'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub render_1 :Render {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::render_1';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::render_1'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub render_2 :Render {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::render_2';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::render_2'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub render_3 :Render {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::render_3';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::render_3'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub after_1 :After {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::after_1';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::after_1'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub after_2 :After {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::after_2';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::after_2'};
        $_->( $context ) for @$callbacks;
    }

    return;

}

sub after_3 :After {

    my ( $self, $context ) = @_;

    push @{$context->stash->{'_test_dispatch_trace'}}, 'MyApp::Controller::B::after_3';

    if ( $context->stash->{'_test_callbacks'} ) {
        my $callbacks = $context->stash->{'_test_callbacks'}{'MyApp::Controller::B::after_3'};
        $_->( $context ) for @$callbacks;
    }

    return;

}


1;

__END__
