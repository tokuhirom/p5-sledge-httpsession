use strict;
use warnings;
use Test::More tests => 6;
use CGI;
use t::Pages;
use t::Request;
use HTTP::Session::State::URI;

my $r = t::Request->new(
    in => {
        Host => 'example.com'
    },
    params => {
        sid => 'deepturtle',
    },
);
my $store = HTTP::Session::Store::Test->new(
    data => {
        'deepturtle' => { },
    },
);

sub {
    my $page = t::Pages->new(
        r => $r,
        store => $store,
        state => HTTP::Session::State::URI->new(),
        callback => sub {
            my $self = shift;
            isa_ok $self->session, 'Sledge::HTTPSession::Session';
            is $self->session->session_id, 'deepturtle';
            $self->redirect('/');
        },
    );
    $page->dispatch;
    is $r->out->{'Location'}, q{http://example.com/?sid=deepturtle};
}->();
sub {
    my $page = t::Pages->new(
        r => $r,
        store => $store,
        state => HTTP::Session::State::URI->new(),
        callback => sub {
            my $self = shift;
            isa_ok $self->session, 'Sledge::HTTPSession::Session';
            is $self->session->session_id, 'deepturtle';
            $self->redirect('http://example.jp/');
        },
    );
    $page->dispatch;
    is $r->out->{'Location'}, q{http://example.jp/}, 'abs uri';
}->();
