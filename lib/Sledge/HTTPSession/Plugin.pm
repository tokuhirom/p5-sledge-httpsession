package Sledge::HTTPSession::Plugin;
use strict;
use warnings;
use HTTP::Session;
use Sledge::HTTPSession::Session;
use Sledge::HTTPSession::Request;
use Sledge::HTTPSession::Response;

sub import {
    my $pkg = caller(0);

    $pkg->add_trigger(
        BEFORE_DISPATCH => sub {
            my $self = shift;
            $self->add_filter(
                sub {
                    my ( $page, $html ) = @_;
                    $page->session->html_filter($html);
                },
            );
        },
    );

    {
        no strict 'refs';
        *{"$pkg\::redirect"} = sub {
            my($self, $path, $scheme) = @_;
            my $super = 'Sledge::Pages::Base::redirect';
            if ( $path =~ /^http/ ) {
                # redirect to other server!
                return $self->$super( $path, $scheme );
            }
            my $uri = $self->make_absolute_url($path, $scheme);
            $uri = $self->session->redirect_filter($uri->as_string);
            return $self->$super( $uri, $scheme );

        };
        {
            # implement Sledge's create_manager.
            no warnings 'redefine';
            *{"$pkg\::create_manager"}    = \&_create_manager;
        }
        *{"$pkg\::construct_session"} = \&_construct_session;
    }
}

sub _create_manager { }

sub _construct_session {
    my $self    = shift;
    my $store   = $self->create_session_store();
    my $state   = $self->create_session_state();
    my $session = Sledge::HTTPSession::Session->new(
        state   => $state,
        store   => $store,
        request => Sledge::HTTPSession::Request->new( $self->r ),
        _page   => $self,
    );
    if ($session->is_fresh) {
        my $res = Sledge::HTTPSession::Response->new( $self->r );
        $session->header_filter($res);
    }
    $self->session($session);
}

sub HTTP::Session::param {
    my $self = shift;
    if ( @_ == 0 ) {
        $self->keys();
    }
    elsif ( @_ == 1 ) {
        $self->get(@_);
    }
    else {
        $self->set(@_);
    }
}

1;
