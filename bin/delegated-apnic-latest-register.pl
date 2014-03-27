#!/usr/bin/env perl
use strict;
use warnings;
use NetAddr::IP;
use LWP::UserAgent;
use File::Basename;
use Time::Piece;
require Geo::IP;

use Redis;

my $r  = Redis->new;
my $ua = LWP::UserAgent->new;

my $response = $ua->get(qq{http://ftp.apnic.net/stats/apnic/delegated-apnic-latest});
my $content  = $response->content;

my $geoip_obj = Geo::IP->new;

no strict 'refs';
local $| = 1;
# awk -F '|' 'BEGIN{log2=log(2)}{if($2=="JP" && $3=="ipv4"){print $4"/"32 - log($5) / log2}}' delegated-apnic-latest
my $count = 0;
for (split /\n/, $content) {
  # apnic|JP|ipv4|1.1.64.0|16384|20110412|allocated
  m{^[^\|]+\|([^\|]+)\|ipv4\|\d+} or next;
  my @p = split /\|/, $_;
  my $country_code = $p[1] // "unknown";
  my $ip_mask = sprintf "%s/%d\n", $p[3], 32 - log($p[4]) / log(2);
  my $x = NetAddr::IP->new( $ip_mask );

  for my $v ( $x->split(24) ) {
    my $t = $v;
    $t =~ s{/24$}{};
    my $geoip_code = $geoip_obj->country_code_by_addr( $t ) // "unknown";
    printf "%16d(%s)\r", $count++, $geoip_code;
    if ($geoip_code ne $country_code) {
      my $log = sprintf "%s is unmatch(geoip:%s != apnic:%s)", 
                        $v,
                        $geoip_code,
                        $country_code;
      logging( $log );
    }
    $r->set( $v => $country_code );

  }
 
}

sub logging {
  open my $fh, ">>", basename $0 . ".log";
  my $log = shift // qq{};
  flock $fh, 2;
  my $t = localtime;
  $log = sprintf "%s: $log", $t->strftime("%Y-%m-%d %H:%M:%S");
  print {$fh} $log, "\n";
  print       $log, "\n";
  close $fh;
}
