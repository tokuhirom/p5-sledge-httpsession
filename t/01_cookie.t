use strict;
use warnings;
use Test::More tests => 3;
use CGI;
use t::Pages;
use t::Request;
use HTTP::Session::State::Cookie;

my $r = t::Request->new(
    in => {
        'Cookie' => 'http_session_sid=deadbeaf; path=/',
    },
);
my $store = HTTP::Session::Store::Test->new(
    data => {
        'deadbeaf' => { },
    },
);
my $page = t::Pages->new(
    r => $r,
    store => $store,
    state => HTTP::Session::State::Cookie->new(),
    callback => sub {
        my $self = shift;
        isa_ok $self->session, 'Sledge::HTTPSession::Session';
        is $self->session->session_id, 'deadbeaf';
        $self->session->param('foo' => 'bar');
        $self->content('foobar');
    },
);
$page->dispatch;
like $r->{out}->{'Set-Cookie'}, qr{^http_session_sid=deadbeaf; path=/$}, 'set-cookie header';
