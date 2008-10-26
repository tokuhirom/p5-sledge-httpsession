package Sledge::HTTPSession::SessionManager;
use strict;
use warnings;

sub new {
    my ( $class, $session ) = @_;
    bless { session => $session }, $class;
}

sub get_session {
    my ( $self, $page ) = @_;
    return $self->{session};
}

sub set_session { }    # nop

1;
