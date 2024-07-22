#!/usr/local/bin/perl

$| = 1;

use T5WorldBuilder;
use T5Sysgen;
use T5SystemGeneration;
use UWP;
use Star;
use Sector;
use World;

use CGI;
use strict;

use Data::Dumper;
$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Pair = ": "; # JSON
$Data::Dumper::Useqq = 1;

my $cgi     = new CGI;

if ( $ARGV[0] ne 'sh' )
{
   print $cgi->header;
}

my $name          = $cgi->param( 'name' ) || 'world';
my $worldname     = $cgi->param( 'worldname' ) || 'world';
my $uwp           = $cgi->param( 'uwp' )  || 'C896755-4';
my $star          = $cgi->param( 'star' ) || 'G2 V';
my $albedo        = $cgi->param( 'albedo' );
my $density       = $cgi->param( 'density' );
my $greenhouse    = $cgi->param( 'greenhouse' );
my $orbit         = $cgi->param( 'orbit' ) || '';
my $tilt          = $cgi->param( 'tilt' )  || '';
my $eccentricity  = $cgi->param( 'eccentricity' ) || '';

$star =~ s/(\w\d)(\w+)/$1 $2/;

my $world = { 'worldname' => $worldname };

my $builder = new T5WorldBuilder();

$builder->init( "$name:$uwp:$star" );

$builder->parseUWP( $world, $uwp );
$builder->parsePrimary( $world, $star ); # sets initial orbital radius
$world->{ orbitalRadius } = $orbit   if $orbit   =~ /\w/;

$world->{ trade_codes } = UWP::tradeCodes( $world->{ uwp }, $world->{ hz }, $world->{ orbitalTrack } ) || '';

$builder->density( $world );
$world->{ density }       = $density if $density =~ /\w/;

$builder->gravity( $world );
$builder->mass( $world );
$builder->atmosphere( $world );
$builder->orbitalPeriod( $world );
$builder->rotationalPeriod( $world );
$builder->orbitalEccentricity( $world, $eccentricity );
$builder->continents( $world );

$builder->albedo( $world );
$world->{ albedo } = $albedo if $albedo =~ /\w/;

$builder->greenhouse( $world );
$world->{ greenhouse } = $greenhouse if $greenhouse =~ /\w/;

$builder->tilt( $world, $tilt );
$builder->temperature( $world );
$builder->temperatureDetails( $world );

if ( $world->{ trade_codes } =~ /Ga|Ri|Pr/ )
{
   $builder->adjustTemperatureBetween( $world, 25, 35 );
}
elsif ( $world->{ trade_codes } =~ /Tr/ )
{
   $builder->adjustTemperatureBetween( $world, 40, 90 );
}
elsif ( $world->{ trade_codes } =~ /Tu/ )
{
   $builder->adjustTemperatureBetween( $world, -20, 20 );
}
elsif ( $world->{ trade_codes } =~ /Ag|Pa|De|Na|Po/ )
{
   $builder->adjustTemperatureBetween( $world, 10, 90 );
}
elsif ( $world->{ trade_codes } =~ /Ic/ )
{
   print "Adjusting for Ic\n";
   $builder->adjustTemperatureBetween( $world, -10, -50 );
}
elsif ( $world->{ trade_codes } =~ /Fr/ )
{
   $builder->adjustTemperatureBetween( $world, -50, -500 );
}

#unless ( $cgi->param( 'orbit' ) =~ /\w/ ) # auto-adjust
#{  
#   $builder->autoAdjustTemperature( $world );
#}

#print "OK\n";

$albedo  = $cgi->param( 'albedo' );
$density = $cgi->param( 'density' );
$greenhouse   = $cgi->param( 'greenhouse' );
$orbit   = $cgi->param( 'orbit' );

my $sysgen = new T5Sysgen();
   $sysgen->init( "$name:$uwp:$star" );
   $sysgen->satellites( $world );

my $output = 
{
   data    => summary($world),
   name    => $name || "Foreven/3021-main",
   uwp     => $uwp  || "D867973-8",
   star    => $star || "G2 V",
   albedo  => $albedo || '',  
   density => $density || '',
   greenhouse   => $greenhouse || '',
   orbit   => $orbit || '',
};

my $outtxt = Dumper $output;
#my $desc   = $world->{ 'innerZone' } . ", " . $world->{ 'midZone' } . ", " . $world->{ 'idealOrbit' } . ", " . $world->{ 'outerZone' };
#print "$desc\n";
print $outtxt;

#   - Radius     : $world->{ 'primaryRadius' } AU
#   - Luminosity : $world->{ 'primaryLuminosity' }

sub summary
{
   my $kelvin = $world->{ 'temperature' } + 273;
   my $hours = int ( $world->{ 'rotationalPeriod' } * 240 ) / 10;

   my $satellites = 'No satellites.';
#   my $ringed     = '';
#      $ringed     = "\nRinged       : yes" if $world->{ ringed } eq 'ringed';
	  
   if ( $world->{ 'satellites' } )
   {
      my @sat = ();
	  foreach my $moon (@{$world->{ 'satellites' }})
	  {
	     push @sat, "Satellite(" . uc($moon->{ 'orbit' }) . ') ' . $moon->{ '_uwp' };
	  }
	  $satellites = join "\n   ", @sat;
   }
   
   $world->{ 'hoursPerDay' } = $hours;
   $world->{ 'temperatureKelvin' } = $kelvin;
   $world->{ 'name' } = $name;
   $world->{ 'satellites_stringified' } = $satellites;

   $world->{ 'starport_desc' } = UWP::describeStarport( $world->{ 'starport' } ) || '';
   $world->{ 'siz_desc' }      = UWP::describeSiz(      $world->{ 'siz' }      ) || '';
   $world->{ 'atm_desc' }      = UWP::describeAtm(      $world->{ 'atm' }      ) || '';
   
   $world->{ 'atm_desc' } .= ' (' . $world->{ taint } . ')' if $world->{ 'taint' };
   
   $world->{ 'hyd_desc' }      = UWP::describeHyd(      $world->{ 'hyd' }      ) || '';
   $world->{ 'pop_desc' }      = UWP::describePop(      $world->{ 'pop' }      ) || '';
   $world->{ 'gov_desc' }      = UWP::describeGov(      $world->{ 'gov' }      ) || '';
   $world->{ 'law_desc' }      = UWP::describeLaw(      $world->{ 'law' }      ) || '';
   $world->{ 'tl_desc'  }      = UWP::describeTL(       $world->{ 'tl' }       ) || '';

   $world->{ 'world_desc' }    = World::describeWorld( $world );

   return $world;
}

