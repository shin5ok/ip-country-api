package IP_Country::API;

use 5.010;
use strict;
use warnings FATAL => 'all';

=head1 NAME

IP_Country::API - lookup country code for ip

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

  ## use redis on localhost
  my $ipc = IP_Country::API->new;

  ## use redis on another host via tcp
  my $ipc = IP_Country::API->new({
                                   redis_args => {
                                                   server => q{10.0.1.100:8000},
                                                 }
                                 });
  
  ## get country code
  $ipc->get_country('203.139.161.100');
  # return string 'JP'

  ## validate ip and country
  $ipc->is_country('203.139.161.100', 'JP');
  # return 'True'

  $ipc->is_country('203.139.161.100', 'KR');
  # return 'False'



=cut

our $VERSION = '0.01';

use Carp;
use Redis ();
use NetAddr::IP ();
use Class::Accessor::Lite ( rw => [ qw( redis debug ) ] );

sub new {
  my ($class, $args) = @_;

  my $redis;
  if (exists $args->{redis_args}) {
    $redis = Redis->new( %{$args->{redis_args}} );
  } else {
    $redis = Redis->new;
  }

  no strict 'refs';
  bless {
    redis => $redis,
    debug => $args->{debug} // 0,
  }, $class;

}


sub get_country {
  my ($self, $ip) = @_;

  my $formated_ip = class_c_format( $ip );

  my $code = $self->redis->get( $formated_ip );

  if (not defined $code) {
    croak "*** $formated_ip is not found";
  }

  return $code;

}


sub class_c_format {
  my $ip = shift || qq{};

  if ($ip =~ /^(\d+\.\d+\.\d+)\.\d+$/) {
    return $1 . ".0/24";
  } else {
    croak "*** ip format error";
  }

}


sub is_country {
  my ($self, $ip, $code) = @_;

  my $actual_code = $self->get_country( $ip );

  return $actual_code eq $code;


}


=cut

=head1 AUTHOR

shin5ok, C<< <shin5ok at 55mp.com> >>

=cut

1; # End of IP_Country::API
