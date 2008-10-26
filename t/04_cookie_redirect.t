use strict;
use warnings;
use Test::More tests => 2;
use CGI;
use t::Pages;
use t::Request;
use HTTP::Session::State::Cookie;

my $r = t::Request->new(
    in => {
        Host => 'example.com',
        Cookie => '',
    },
    params => { },
);
my $store = HTTP::Session::Store::Test->new(
    data => {
        'deepturtle' => { },
    },
);
my $page = t::Pages->new(
    r => $r,
    store => $store,
    state => HTTP::Session::State::Cookie->new(),
    callback => sub {
        my $self = shift;
        isa_ok $self->session, 'Sledge::HTTPSession::Session';
        $self->redirect('/');
    },
);
$page->dispatch;
is $r->out->{'Location'}, q{http://example.com/};

