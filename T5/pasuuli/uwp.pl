#!/usr/local/bin/perl
sleep 1; # throttle
use CGI;
use UWP;
use Name2;
use strict;
=pod

   UWP Service
   
   Serves a completely random UWP.

=cut
use Data::Dumper;
$Data::Dumper::Pair = ": ";
$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Useqq = 1;

my $cgi = new CGI;
#print $cgi->header;
#print "<pre>";

my $name  = $cgi->param( 'name'  ) || undef;
my $UID   = $cgi->param( 'UID'   ) || localtime;
my $tlCap = $cgi->param( 'tlCap' ) || 21;
my $civil = $cgi->param( 'civ'   ) || 'Civilized';
my $SEC   = $cgi->param( 'SEC'   ) || 0;

my $hex = '0000';

my $uwp = UWP::create( $UID, $hex, $tlCap );
   $uwp->{ 'name' } = $name if $name;
   $uwp->{ 'meta' } = getMetadata( $UID );
   
# print Dumper $uwp unless $SEC;

printf "%-15s %8s %-2s %-15s  %3s\n",
	  $uwp->{ 'name' },
	  $uwp->{ 'uwp' },
	  $uwp->{ 'bases' },
	  $uwp->{ 'trade_codes' },
	  $uwp->{ 'pbg' }; # if $SEC;

sub getMetadata
{
   my $UID = shift;
   
   return
   {
      UID          => $UID,
	  tlCap        => $tlCap,
	  civilization => $civil,
	  generated    => scalar localtime,
	  prng         => 'burtle'	  
   };
}
