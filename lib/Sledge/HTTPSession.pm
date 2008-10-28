package Sledge::HTTPSession;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';

1;
__END__

=encoding utf8

=head1 NAME

Sledge::HTTPSession - HTTP::Session to Sledge bindings

=head1 SYNOPSIS

    package Your::Pages;
    use Sledge::HTTPSession;
    use HTTP::Session::State::Cookie;
    use HTTP::Session::State::Store::Memcached;
    use Cache::Memcached;

    sub create_session_state {
        HTTP::Session::State::Cookie->new();
    }
    sub create_session_store {
        HTTP::Session::Store::Memcached->new(
            memd => Cache::Memcached->new(
                servers => ['127.0.0.1:11211']
            )
        );
    }

=head1 DESCRIPTION

Sledge::HTTPSession is HTTP::Session to Sledge bindings.

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom@gmail.comE<gt>

=head1 SEE ALSO

L<Sledge>, L<HTTP::Session>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
