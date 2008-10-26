package t::Request;
use Moose;

has in => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);
has out => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);
has params => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);
has uri => (
    is => 'rw',
    isa => 'Str',
    default => '/',
);
has args => (
    is => 'rw',
    isa => 'Str',
    default => '',
);
has status => (
    is => 'rw',
    isa => 'Int',
);

sub param {
    my ($self, $key) = @_;
    $self->params->{$key};
}

sub header_in {
    my ($self, $key) = @_;
    $self->in->{$key};
}
sub header_out {
    my ($self, $key, $val) = @_;
    $self->out->{$key} = $val;
}

1;
