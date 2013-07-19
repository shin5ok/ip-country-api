#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'IP_Country::API' ) || print "Bail out!\n";
}

diag( "Testing IP_Country::API $IP_Country::API::VERSION, Perl $], $^X" );
