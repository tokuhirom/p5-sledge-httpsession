package Sledge::HTTPSession::Session;
use strict;
use warnings;
use base qw/HTTP::Session/;

__PACKAGE__->mk_ro_accessors(qw/_page/);

sub regenerate_session_id {
    my $self = shift;
    $self->SUPER::regenerate_session_id(@_);

    # resend session_id
    my $res = Sledge::HTTPSession::Response->new( $self->_page->r );
    $self->_page->session->header_filter($res);
}

sub remove_all {
    my $self = shift;
    for my $key ($self->keys) {
        $self->remove($key);
    }
}

1;

