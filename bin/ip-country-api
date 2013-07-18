#!/usr/bin/env perl
use strict;
use warnings;
use Mojolicious::Lite;

use FindBin;
use lib "$FindBin::Bin/../lib";
use IP_Country::API;
app->renderer->default_format('json');

helper ip_country_obj => sub {
  IP_Country::API->new;
};

get '/ip/(*ip)' => sub {
  my ($self) = @_;

  my $obj = $self->ip_country_obj;

  my $data = $obj->get_country( $self->param('ip') );

  $self->render_json({ result => 1, data => { code => $data } });
};

get '/country/(*code)/(*ip)' => sub {
  my ($self) = @_;

  my $obj = $self->ip_country_obj;

  my $code = uc $self->param('code');
  my $ip   = $self->param('ip');

  my $data = { $code => 0 };
  if ($obj->is_country($ip, $code)) {
    $data->{$code} = 1;
  }

  $self->render_json({ result => 1, data => $data });
};

app->start;

__DATA__
@@ exception.json.ep
% use Mojo::JSON;
% return Mojo::JSON->new->encode( { result => 0, message => $exception } );
