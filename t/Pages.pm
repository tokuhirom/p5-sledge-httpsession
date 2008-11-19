use strict;
use warnings;

package Sledge::Pages::Base;
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
unshift @t::Pages::ISA, 'Class::Accessor::Fast', 'Sledge::Pages::Base';
use Class::Trigger qw/BEFORE_DISPATCH/;
use Sledge::HTTPSession::Plugin;
use Test::More;
use HTTP::Session::Store::Test;

__PACKAGE__->mk_accessors(qw/session manager r state store callback finished content/);

sub new {
    my $class = shift;
    bless {@_}, $class;
}

sub add_filter {
    my ($self, $filter) = @_;
    push @{$self->{filters}}, $filter;
}
sub init_dispatch {
    my ($self, $page) = @_;
    $self->construct_session();
    $self->manager( $self->create_manager);
}
sub dispatch {
    my ($self, $page) = @_;

    $self->init_dispatch();
    $self->call_trigger('BEFORE_DISPATCH') unless $self->finished;
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
