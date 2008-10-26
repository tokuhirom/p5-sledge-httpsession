use strict;
use warnings;
use Test::More tests => 3;
use CGI;
use t::Pages;
use t::Request;
use HTTP::Session::State::URI;

my $r = t::Request->new(
    in => {},
    params => {
        sid => 'deepturtle',
    },
);
my $store = HTTP::Session::Store::Test->new(
    data => {
        'deepturtle' => { },
    },
);
my $page = t::Pages->new(
    r => $r,
    store => $store,
    state => HTTP::Session::State::URI->new(),
    callback => sub {
        my $self = shift;
        isa_ok $self->session, 'Sledge::HTTPSession::Session';
        is $self->session->session_id, 'deepturtle';
        $self->session->param('foo' => 'bar');
        $self->content('<a href="/">foo</a>');
    },
);
$page->dispatch;
is $page->content, q{<a href="/?sid=deepturtle">foo</a>};

