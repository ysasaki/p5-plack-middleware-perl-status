package Plack::Middleware::Perl::Info;
use strict;
use warnings;
use parent qw(Plack::Middleware);
use Plack::Util::Accessor qw(board base_dir path);
use Parallel::Scoreboard;
use Data::MessagePack;

our $VERSION = '0.002';

sub prepare_app {
    my $self = shift;

    if ( $self->base_dir ) {
        $self->board(
            Parallel::Scoreboard->new( base_dir => $self->base_dir ) );
    }
    else {
        die "Perl::Info require base_dir option";
    }
}

sub call {
    my ( $self, $env ) = @_;

    my $res;
    if ( $self->path && $env->{PATH_INFO} eq $self->path ) {
        $res = $self->_handle_perl_info($env);
    }
    else {
        $res = $self->app->($env);
    }

    $self->set_state;

    return $res;
}

sub set_state {
    my $self = shift;
    my $dat = [ keys %INC ];
    $self->board->update( Data::MessagePack->pack($dat) );
}

sub _handle_perl_info {
    my ( $self, $env ) = @_;

    my @body;
    my $stats = $self->board->read_all();
	my %modules;
    for my $pid ( sort { $a <=> $b } keys %$stats ) {
        my $dat = Data::MessagePack->unpack( $stats->{$pid} );
		if ( $dat and ref $dat eq 'ARRAY' ) {
			$modules{$_} = 1 for @$dat;
		}
    }
	push @body, "Loaded Modules\n";
	for my $module ( sort keys %modules ) {
		$module =~ s/\.pm$//;
		$module =~ s/\//::/g;
		push @body, "    $module\n";
	}

    return [ 200, [ 'Cotnent-Type' => 'text/plain; charset=utf-8' ], \@body ];
}

1;
__END__

=head1 NAME

Plack::Middleware::Perl::Info -

=head1 SYNOPSIS

  use Plack::Builder;

  builder {
      enable "Plack::Middleware::Perl::Info",
          path => '/perl-info',
          base_dir => '/tmp/my-server';
      $app;
  };

=head1 DESCRIPTION

Plack::Middleware::Perl::Info is

=head1 AUTHOR

Yoshihiro Sasaki E<lt>aloelight {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
