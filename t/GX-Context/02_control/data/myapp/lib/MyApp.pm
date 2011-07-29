package MyApp;

use GX;


MyApp->setup;


for my $hook ( MyApp->instance->hooks ) {

    my $handler_name = $hook->name . '_handler';

    *{"MyApp::$handler_name"} = sub {

        my ( $application, $context ) = @_;

        push @{$context->stash->{'_test_hook_trace'}}, $context->hook->name;

        if ( $context->stash->{'_test_callbacks'} ) {
            my $callbacks = $context->stash->{'_test_callbacks'}{$context->hook->name};
            $_->( $context ) for @$callbacks;
        }

        return;

    };

    $hook->add(
        GX::Callback::Method->new(
            invocant => MyApp->instance,
            method   => $handler_name
        )
    );

}


MyApp->start;


1;

__END__
