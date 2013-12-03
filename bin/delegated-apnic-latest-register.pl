#!/usr/bin/env perl
use strict;
use warnings;
use NetAddr::IP;
use LWP::UserAgent;

use Redis;
my $r  = Redis->new;
my $ua = LWP::UserAgent->new;

my $response = $ua->get(qq{http://ftp.apnic.net/stats/apnic/delegated-apnic-latest});
my $content  = $response->content;

# awk -F '|' 'BEGIN{log2=log(2)}{if($2=="JP" && $3=="ipv4"){print $4"/"32 - log($5) / log2}}' delegated-apnic-latest
for (split /\n/, $content) {
  # apnic|JP|ipv4|1.1.64.0|16384|20110412|allocated
  m{^[^\|]+\|([^\|]+)\|ipv4\|\d+} or next;
  my @p = split /\|/, $_;
  my $country_code = $p[1];
  my $ip_mask = sprintf "%s/%d\n", $p[3], 32 - log($p[4]) / log(2);
  my $x = NetAddr::IP->new( $ip_mask );

  for my $v ( $x->split(24) ) {
    warn "$v => $country_code";
    $r->set( $v => $country_code );

  }
  
}

