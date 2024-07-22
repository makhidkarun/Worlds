#!/usr/local/bin/perl
#sleep 1; # throttle
use CGI;
use Star;
use World;
use strict;
=pod

   World Service
   
   Serves a completely random World in JSON.

=cut
use Data::Dumper;
$Data::Dumper::Pair = ": ";
$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Useqq = 1;

my $cgi = new CGI;
print $cgi->header;
print "<pre>";

my $UID   = $cgi->param( 'UID'   ) || localtime;
my $hex   = $cgi->param( 'hex'   ) || '0000';
my $tag   = $cgi->param( 'tag'   ) || 'main';

my $stars = Star::buildStars( $UID, $hex );
my $world = UWP::create( $UID, $hex, $tag );
World::analyzeUWP( $world, $world->{ 'uwp' } );
$world->{ 'orbitalRadius' } = $stars->{ 'primary' }->{ 'midHabOrbit' };
World::orbitalTrack( $world );
$world->{ 'trade_codes' } = UWP::tradeCodes( $world->{ 'uwp' }, $world->{ 'hz' }, $world->{ 'orbitalTrack' } );
World::densityAndType( $world );
World::gravityAndMass( $world );
World::atmosphereTypeAndPressure( $world );
$world->{ 'orbitalPeriod' } = Star::orbitalPeriod( $stars->{ 'primary' }->{ 'mass' }, $world->{ 'orbitalRadius' } );
$world->{ 'rotationalPeriod' } = Star::rotationalPeriod( $stars->{ 'primary' }->{ 'mass' }, $world->{ 'orbitalRadius' } );	

World::orbitalEccentricity( $world );
World::continents( $world );
World::albedo( $world );
World::greenhouse( $world );
World::tilt( $world );
#World::temperature( $world );
#World::temperatureDetails( $world );

$world->{ 'stars' } = $stars;

=pod
	if ( $world->{ 'trade_codes'} =~ /Ga|Ri|Pr/ )
    {
       World::adjustTemperatureBetween( $world, 25, 35 );
    }
    elsif ( $world->{ 'trade_codes' } =~ /Tr/ )
    {
       World::adjustTemperatureBetween( $world, 40, 90 );
    }
    elsif ( $world->{ 'trade_codes' } =~ /Tu/ )
    {
       World::adjustTemperatureBetween( $world, -20, 20 );
    }
    elsif ( $world->{ 'trade_codes' } =~ /Ag|Pa|De|Na|Po/ )
    {
       World::adjustTemperatureBetween( $world, 10, 90 );
    }
    elsif ( $world->{ 'trade_codes' } =~ /Ic/ )
    {
       World::adjustTemperatureBetween( $world, -10, -50 );
    }
    elsif ( $world->{ 'trade_codes' } =~ /Fr/ )
    {
       World::adjustTemperatureBetween( $world, -50, -500 );
    }
=cut
	# add satellites

print Dumper $world;
