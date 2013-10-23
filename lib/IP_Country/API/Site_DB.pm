package IP_Country::API::Site_DB;

use 5.010;
use strict;
use warnings FATAL => 'all';

=head1 NAME

IP_Country::API::Site_DB - register country code to redis

  This module should be used on cron, or job queue,
  because the 'run' method would take a while.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

  ## call the parent constructer
  my $ipc = IP_Country::API::Site_DB->new;

  ## use default args
  $ipc->run; 

  ## set furl option args
  ## timeout and debug
  $ipc->run({ furl_args => { timeout => 360, }, debug => 1 });

=cut

our $VERSION = '0.01';

use Carp;
use NetAddr::IP ();
use Furl ();

our $apnic_uri = q{http://ftp.apnic.net/stats/apnic/delegated-apnic-latest};

sub new {
  my $class = shift;
  my $args  = shift;

  bless +{
    args => $args,
  }, $class;

}

sub get {
  my $self = shift;
  my $args = $self->{args};
  $args //= +{};

  my %furl_args = ( timeout => 120 );
  %furl_args    = ( %furl_args, %$args );

  my $furl = Furl->new( %furl_args );
  my $res  = $furl->get( $apnic_uri );

  if (! $res->is_success) {
    croak "content from $apnic_uri cannot get";
  }

  return $res->content;

}

=cut

=head1 AUTHOR

shin5ok, C<< <shin5ok at 55mp.com> >>

=cut

1; # End of IP_Country::API::Site_DB
