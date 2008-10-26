package Sledge::HTTPSession::Response;
use strict;
use warnings;

# wrapper class

sub new {
    my ( $class, $r ) = @_;
    bless { r => $r }, $class;
}

sub header {
    my ( $self, $key, $val ) = @_;
    $self->{r}->header_out( $key, $val );
}

1;

