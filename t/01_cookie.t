use strict;
use warnings;
use Test::More tests => 6;
use CGI;
use t::Pages;
use t::Request;
use HTTP::Session::State::Cookie;

sub {
    # first request
    my $r = t::Request->new(
        in => { },
    );
    my $store = HTTP::Session::Store::Test->new(
        data => { },
    );
    my $page = t::Pages->new(
        r => $r,
        store => $store,
        state => HTTP::Session::State::Cookie->new(),
        callback => sub {
            my $self = shift;
            isa_ok $self->session, 'Sledge::HTTPSession::Session';
            like $self->session->session_id, qr/^[a-z0-9]{32}$/;
            $self->session->param('foo' => 'bar');
            $self->content('foobar');
        },
    );
    $page->dispatch;
    like $r->{out}->{'Set-Cookie'}, qr{^http_session_sid=[a-z0-9]{32}; path=/$}, 'set-cookie header';
}->();

sub {
    # second request
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
    is $r->{out}->{'Set-Cookie'}, undef, "don't send set-cookie header";
}->();

