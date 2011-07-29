package GX::Session::Store::Dummy;

use Storable ();


# ----------------------------------------------------------------------------------------------------------------------
# Class setup
# ----------------------------------------------------------------------------------------------------------------------

use GX::Class;

extends 'GX::Session::Store';

has 'data' => (
    isa        => 'Hash',
    initialize => 1
);

build;


# ----------------------------------------------------------------------------------------------------------------------
# Public Methods
# ----------------------------------------------------------------------------------------------------------------------

sub delete {

    my $self       = shift;
    my $session_id = shift;

    return delete $self->{'data'}{$session_id} ? 1 : 0;

}

sub load {

    my $self       = shift;
    my $session_id = shift;

    return unless exists $self->{'data'}{$session_id};

    return @{ Storable::thaw( $self->{'data'}{$session_id} ) };

}

sub save {

    my $self         = shift;
    my $session_id   = shift;
    my $session_info = shift;
    my $session_data = shift;

    return if exists $self->{'data'}{$session_id};

    $self->{'data'}{$session_id} = Storable::nfreeze( [ $session_info, $session_data ] );

    return 1;

}

sub update {

    my $self         = shift;
    my $session_id   = shift;
    my $session_info = shift;
    my $session_data = shift;

    return unless exists $self->{'data'}{$session_id};

    $self->{'data'}{$session_id} = Storable::nfreeze( [ $session_info, $session_data ] );

    return 1;

}


1;

__END__

