#!/usr/bin/env perl
use strict;
use warnings;

use NetAddr::IP;
use IP_Country::API::Site_DB;

my $site_db_obj = IP_Country::API::Site_DB->new({ env_proxy => 1});
my $content = $site_db_obj->get;

print <<"EOD";
Order Deny,Allow
Deny from All
EOD
for my $line (split /\n/, $content) {
  # apnic|JP|ipv4|1.1.64.0|16384|20110412|allocated
  $line =~ m{^[^\|]+\|([^\|]+)\|ipv4\|\d+} or next;
  my @p = split m{\|}, $line;

  my $country_code = $p[1];
  $country_code eq qq{JP} or next;

  my $mask    = 32 - log($p[4]) / log(2);
  my $ip_mask = sprintf "%s/%d", $p[3], $mask;
  print "Allow from $ip_mask\n";
  
}

