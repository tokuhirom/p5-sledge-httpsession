package Sledge::Pages::Base;
use Moose;
sub REDIRECT { 302 }
sub redirect {
    my ( $self, $url, $scheme ) = @_;
    unless ( $self->finished ) {
        my $uri = $self->make_absolute_url( $url, $scheme );
        $self->r->header_out( Location => $uri->as_string );
        $self->r->status(REDIRECT);
        $self->finished(1);
    }
}
sub make_absolute_url {
    my ( $self, $url, $scheme ) = @_;
    return URI->new_abs( $url, $self->current_url($scheme) );
}
sub current_url {
    my ( $self, $scheme ) = @_;
    $scheme ||= $ENV{HTTPS} ? 'https' : 'http';
    my $url = sprintf '%s://%s%s', $scheme, $self->r->header_in('Host'), $self->r->uri;
    $url .= '?' . $self->r->args if $self->r->args;
    return $url;
}
package t::Pages;
use Moose;
unshift @t::Pages::ISA, 'Sledge::Pages::Base';
use Class::Trigger qw/BEFORE_DISPATCH/;
use Sledge::HTTPSession::Plugin;
use Test::More;
use HTTP::Session::Store::Test;

has session => (
    is => 'rw',
);
has manager => (
    is => 'rw',
);
has r => (
    is => 'ro',
    requires => 1,
);
has state => (
    is => 'ro',
    does => 'HTTP::Session::Role::State',
    requires => 1,
);
has store => (
    is => 'ro',
    does => 'HTTP::Session::Role::Store',
    requires => 1,
);
has callback => (
    is       => 'ro',
    isa      => 'CodeRef',
    requires => 1,
);
has finished => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);
has content => (
    is => 'rw',
    isa => 'Str|Undef',
);

sub add_filter {
    my ($self, $filter) = @_;
    push @{$self->{filters}}, $filter;
}
sub dispatch {
    my ($self, $page) = @_;

    $self->manager( $self->create_manager );
    my $session = $self->manager()->get_session;
    $self->session( $session );
    $self->manager->set_session( $session ) if $session->is_fresh;

    $self->call_trigger('BEFORE_DISPATCH');
    $self->callback->($self);
    if (!$self->finished) {
        my $html = $self->content;
        for my $filter (@{$self->{filters}}) {
            $html = $filter->($self, $html);
        }
        $self->content($html);
    }
    $self->_destroy_me;
}
sub _destroy_me {
    my $self = shift;
    for (keys %$self) {
        next if /content/;
        delete $self->{$_};
    }
}
sub create_session_store {
    my ($self, ) = @_;
    $self->store;
}
sub create_session_state {
    my ($self, ) = @_;
    $self->state;
}


1;
