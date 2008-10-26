package Sledge::HTTPSession::Request;
use strict;
use warnings;
use base qw/HTTP::Request/;

# wrapper class

sub new {
    my ( $class, $r ) = @_;
    bless { r => $r }, $class;
}

sub header {
    my ( $self, $key ) = @_;
    $self->{r}->header_in($key);
}

sub param {
    my ( $self, @args ) = @_;
    $self->{r}->param(@args);
}

1;
