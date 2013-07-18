package IP_Country::API::Register;

use 5.010;
use strict;
use warnings FATAL => 'all';

=head1 NAME

IP_Country::API::Register - register country code to redis

  This module should be used on cron, or job queue,
  because the 'run' method would take a while.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

  ## call the parent constructer
  my $ipc = IP_Country::API::Register->new;

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

use base qw( IP_Country::API );

our $apnic_uri = q{http://ftp.apnic.net/stats/apnic/delegated-apnic-latest};

sub run {
  my $self = shift;
  my $args = shift;

  my $furl_option_args = exists $args->{furl_args}
                       ? $args->{furl_args}
                       : +{};
                    
  my %furl_args = ( timeout => 120 );
  %furl_args    = ( %furl_args, %{$furl_option_args} );

  my $furl = Furl->new( %furl_args );
  my $res  = $furl->get( $apnic_uri );

  for my $line (split /\n/, $res->content) {
    # apnic|JP|ipv4|1.1.64.0|16384|20110412|allocated
    $line =~ m{^[^\|]+\|([^\|]+)\|ipv4\|\d+} or next;
    my @p = split m{\|}, $line;

    my $country_code = $p[1];
    my $ip_mask = sprintf "%s/%d\n", $p[3], 32 - log($p[4]) / log(2);
    my $x = NetAddr::IP->new( $ip_mask );
  
    for my $v ( $x->split(24) ) {
      warn "$v => $country_code" if $self->debug;
      $self->redis->set( $v => $country_code );
  
    }
    
  }

}

=cut

=head1 AUTHOR

shin5ok, C<< <shin5ok at 55mp.com> >>

=cut

1; # End of IP_Country::API::Register
