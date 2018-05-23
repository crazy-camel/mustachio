#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use feature ':5.18';
use CGI::Fast;

use lib '.';
use Path::Tiny 'path';
use Mustachio::Application;

my $app = Mustachio::Application->new( base => path( $0 )->parent(2) );

while (my $q = CGI::Fast->new() )
{
	print $q->header;
	print $app->respond( $q );
}
