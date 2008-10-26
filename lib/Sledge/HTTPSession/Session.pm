package Sledge::HTTPSession::Session;
use Moose;
extends 'HTTP::Session';

has _page => (
    is       => 'ro',
    isa      => 'Sledge::Pages::Base',
    required => 1,
);

sub regenerate_session_id {
    my $self = shift;
    $self->SUPER::regenerate_session_id(@_);

    # resend session_id
    my $res = Sledge::HTTPSession::Response->new( $self->_page->r );
    $self->_page->session->header_filter($res);
}

1;
