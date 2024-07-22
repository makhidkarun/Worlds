package World;
use UWP;
use Star;
use Jenkins2rSmallPRNG qw/t5srand flux rand1d rand2d rand1d10/;
use strict;
=pod

@@@  @@@  @@@   @@@@@@   @@@@@@@   @@@       @@@@@@@             
@@@  @@@  @@@  @@@@@@@@  @@@@@@@@  @@@       @@@@@@@@            
@@!  @@!  @@!  @@!  @@@  @@!  @@@  @@!       @@!  @@@            
!@!  !@!  !@!  !@!  @!@  !@!  @!@  !@!       !@!  @!@            
@!!  !!@  @!@  @!@  !@!  @!@!!@!   @!!       @!@  !@!            
!@!  !!!  !@!  !@!  !!!  !!@!@!    !!!       !@!  !!!            
!!:  !!:  !!:  !!:  !!!  !!: :!!   !!:       !!:  !!!            
:!:  :!:  :!:  :!:  !:!  :!:  !:!   :!:      :!:  !:!            
 :::: :: :::   ::::: ::  ::   :::   :: ::::   :::: ::            
  :: :  : :     : :  :    :   : :  : :: : :  :: :  :             

=cut

sub init
{
   my $seed = shift;
   t5srand( $seed );
}

###############################################################################
#
#  Data
#
###############################################################################
my @ehex = (0..9, 'A'..'H', 'J'..'N', 'P'..'Z');

my @worldOrbit1 = qw/10  8  6  4  2  0  1  3 5 7 0/;
my @worldOrbit2 = qw/17 16 15 14 13 12 11 10 9 8 7/;

my %taintGreenhouseEffect = 
(
   chlorine  =>  0.01,
   'low oxy' => -0.05,
   methane   =>  0.1,
   nitrous   =>  0.05,
   sulfur    =>  0.05,
   'high carbon diox' => 0.1,
);

###############################################################################
#
#  Determines taint and world orbital zone.
#  $world is the target hash for data.
#
###############################################################################
sub analyzeUWP
{
   my $world = shift;
   my $uwp   = shift;

   UWP::decodeUWP( $world, $uwp );

#   $world->{ siz } = (rand2d()-1)/100.0 if $world->{ siz } == 0;

   # guess taint
   if ( $world->{ 'atm' } =~ /[2479]/ )
   {
      my $flux = flux();
      $world->{ 'taint' } = 'Chlorine'   if $flux == -5;
      $world->{ 'taint' } = 'Low Oxygen' if $flux == -4;
      $world->{ 'taint' } = 'Methane'    if $flux == -3;
      $world->{ 'taint' } = 'Nitrous Oxides' if $flux == -2;
      $world->{ 'taint' } = 'Fungi'      if $flux == -1;
      $world->{ 'taint' } = 'Microorganisms' if $flux == 0;
      $world->{ 'taint' } = 'Allergens'  if $flux == 1;
      $world->{ 'taint' } = 'Sulfur Compounds' if $flux == 2;
      $world->{ 'taint' } = 'High CO2'   if $flux == 3;
      $world->{ 'taint' } = 'High O2'    if $flux == 4;
      $world->{ 'taint' } = 'Radioactive gases' if $flux == 5;
   }

   $world->{ 'orbital zone' } = 'Habitable' unless $world->{ 'orbital zone' }; # default assumption
}

###############################################################################
#
#  Calculates orbital track.  Requires orbital radius.
#
###############################################################################
sub orbitalTrack
{
   my $world = shift;
   my $au    = $world->{ orbitalRadius };
   my $orbitalTrack;

   if    ( $au < 0.25 ) { $orbitalTrack = 0 }    # 0.3
   elsif ( $au < 0.45 ) { $orbitalTrack = 1 }    # 0.55
   elsif ( $au < 0.8  ) { $orbitalTrack = 2 }    # 0.85
   elsif ( $au < 1.3  ) { $orbitalTrack = 3 }    # 1.4
   elsif ( $au < 2.1  ) { $orbitalTrack = 4 }    # 2.1
   elsif ( $au < 3.7  ) { $orbitalTrack = 5 }    # 4
   elsif ( $au < 7.5  ) { $orbitalTrack = 6 }
   elsif ( $au < 15   ) { $orbitalTrack = 7 }
   elsif ( $au < 30   ) { $orbitalTrack = 8 }
   elsif ( $au < 60   ) { $orbitalTrack = 9 }
   elsif ( $au < 120  ) { $orbitalTrack = 10 }
   elsif ( $au < 240  ) { $orbitalTrack = 11 }
   elsif ( $au < 480  ) { $orbitalTrack = 12 }
   elsif ( $au < 960  ) { $orbitalTrack = 13 }
   elsif ( $au < 1900 ) { $orbitalTrack = 14 }
   elsif ( $au < 3800 ) { $orbitalTrack = 16 }
   else                 { $orbitalTrack = 17 }

   $world->{ orbitalTrack } = $orbitalTrack;
}

###############################################################################
#
#  Calculate the world Type and Density.
#
#  Depends on world Zone, UWP, and Trade Codes.
#
###############################################################################
sub densityAndType 
{
   my $world   = shift;
   my $zone    = $world->{ 'orbital zone' };
   my $atm     = $world->{ 'atm' };
   my $siz     = $world->{ 'siz' };

   my @density = qw/0.2  0.3  0.4  0.45 0.5  0.55 0.6  0.65 0.7  0.75 0.8  0.85 0.9  0.95 1   1.05 1.1  1.35 1.6 /;
   my @type    = qw/ Icy  Icy  Icy  Rocky Rocky Rocky Rocky Rocky Rocky Rocky Metal Metal Metal Metal Metal Metal Metal Stripped Stripped/;
   # my @ggdens  = qw/0.05 0.1  0.13 0.15 0.18 0.2  0.25 0.3  0.4  0.5  0.6  0.8  1    1.5  2 /;

   if ( $world->{ trade_codes } =~ /Ga|Ri|Pr|Tr|Tu/ ) # standard density
   {
      $world->{ type } = 'Rocky';
      $world->{ density } = 1.0 + flux()/100.0;
   }
   else
   {
      my $roll = rand1d() - 1;

      if ( $world->{ inhospitable } )
      {
         $roll = rand2d();
      }

      $roll -= 3 if $zone eq 'outer';
      $roll -= 1 if $zone eq 'middle';
      $roll += 2 if $zone eq 'inner';
      $roll -= 1 if $atm  =~ /[0123E]/;
      $roll += 2 if $atm  =~ /[6789ABCDF]/;

      $roll = 0 if $roll < 0;

      $world->{ density } = $density[ $roll ];
      $world->{ type    } = $type[ $roll ];
   }
   delete $world->{ radworld };

   # worlds with Density > 1.2 have high surface radiation emanating from the interior.
   # all such worlds should be marked Rw (Radworld).

   $world->{ radworld }++ if $world->{ density } > 1.2;
   $world->{ trade_codes } .= ' Rw' if $world->{ density } > 1.2;
}

###############################################################################
#
#  Determines gravity and mass.  Depends on UWP and Density.
#
###############################################################################
sub gravityAndMass
{
   my $world = shift;

   $world->{ gravity } = sprintf "%.2f", $world->{ density } * $world->{ siz } / 8;

   my $dia    = $world->{ siz };
   $world->{ mass } = sprintf "%.2f", $world->{ density } * (($dia/8) ** 3);

   # (but GG mass can't exceed 4200)
}

###############################################################################
#
#  Figures out the atmosphere type and pressure.  Depends on UWP and Primary Class.
#
###############################################################################
sub atmosphereTypeAndPressure
{
   my $world        = shift;
   my $primaryClass = $world->{ primary }->{ class };

   $world->{ air } = 'Oxygen';
   $world->{ air } = 'None' if $world->{ atm } == 0;

   my $flux = flux();
   if ( $world->{ atm } =~ /[ABC]/ )
   {
      $flux += 1 if $world->{ hyd } < 3;
      $flux -= 1 if $world->{ hyd } > 7;
      $flux -= 1 if $world->{ siz } > 10;
      $flux += 1 if $primaryClass =~ /F/;
      $flux -= 1 if $primaryClass =~ /M/;

      $world->{ air } = 'CO2';

      $world->{ air } = 'Neon'     if $flux <= -5;
      $world->{ air } = 'Chlorox'  if $flux > -5 && $flux < -2;
      $world->{ air } = 'Ammonia'  if $flux == -2;
      $world->{ air } = 'N2'       if $flux == 0;
      $world->{ air } = 'Carbonaceous' if $flux == 2;
      $world->{ air } = 'Nitroxy'  if $flux == 3;
      $world->{ air } = 'SO2'      if $flux == 4;
      $world->{ air } = 'Sulfuric Acid'  if $flux > 4;
   }

   $flux = flux();
   $flux += 2 if $world->{ atm } =~ /B/;
   $flux += 4 if $world->{ atm } =~ /C/;
   $flux -= 5 if $world->{ air } =~ /Ammonia|Oxygen/;

   $world->{ pressure } = 0.2 if $flux < -5;
   $world->{ pressure } = 0.4 if $flux == -5;
   $world->{ pressure } = 0.7 if $flux == -4;
   $world->{ pressure } = 0.7 if $flux == -3;
   $world->{ pressure } = 1.4 if $flux == -2;
   $world->{ pressure } = 1.4 if $flux == -1;
   $world->{ pressure } = 2.2 if $flux == 0;
   $world->{ pressure } = 4.0 if $flux == 1;
   $world->{ pressure } = 8.0 if $flux == 2;
   $world->{ pressure } = 15  if $flux == 3;
   $world->{ pressure } = 25  if $flux == 4;
   $world->{ pressure } = 50  if $flux == 5;
   $world->{ pressure } = 100 if $flux == 6;
   $world->{ pressure } = 150 if $flux >= 7;

   $world->{ pressure } *= (1 + (rand1d()-1)/6 );
   $world->{ pressure } = sprintf( "%.2f", $world->{ pressure } );
   $world->{ pressure } = 0 if $world->{ atm } == 0
}

###############################################################################
#
#  Determines E.  Requires trade codes.
#
###############################################################################
sub orbitalEccentricity
{
   my $world       = shift;
   my $trade_codes = $world->{ trade_codes };

   my $roll = rand2d();
   my $E;

   $E = 0 if $roll < 8;
   $E = 0.005 if $roll == 8;
   $E = 0.010 if $roll == 9;
   $E = 0.015 if $roll == 10;
   $E = 0.020 if $roll > 10;

   if ( $trade_codes !~ /Ga|Ri|Pr|Tr|Tu/ ) # i.e. not "habitable" worlds
   {
      if ( $roll == 12 )
      {
         $roll = rand1d();
         $E = 0.025 if $roll == 1;
         $E = 0.050 if $roll == 2;
         $E = 0.100 if $roll == 3;
         $E = 0.200 if $roll == 4;
         $E = 0.250 if $roll == 5;
         $E = 0.250 + 0.70 * (rand2d()-2) / 10 if $roll == 6;
      }
   }
   $world->{ eccentricity } = $E;
}

###############################################################################
#
#  Determines continental scatter and continental positions.  Requires UWP.
#
###############################################################################
sub continents
{
   my $world   = shift;
   my $hyd     = $world->{ hyd };

   if ( $world->{ siz } < 1 )
   {
      $world->{ 'continental_scatter' } = 'N/A';
      $world->{ 'continental_positions' } = 'N/A';
      return;
   }

   $world->{ 'continental_scatter'   } = 'Small to medium continents';
   $world->{ 'continental_scatter'   } = 'None' if $hyd > 8; # RJE - no continents in this case
   $world->{ 'continental_positions' } = 'No covered poles, but also no equatorial blocking of currents';

   my $scatterflux = flux();
      $scatterflux -= 2 if $hyd < 3;
      $scatterflux += 2 if $hyd > 7;
          $scatterflux += 2 if $hyd > 8;
          $scatterflux += rand1d() if $hyd > 8 && $scatterflux == 3; # RJE - can't allow continents in this case

   $world->{ 'continental_scatter' } = 'Breaking Supercontinent' if $scatterflux <= -5;
   $world->{ 'continental_scatter' } = 'Supercontinent(s)'       if $scatterflux == -4;
   $world->{ 'continental_scatter' } = 'Impacted Continents with uplift-a' if $scatterflux == -3;
   $world->{ 'continental_scatter' } = 'Large Continents' if $scatterflux == -2;
   $world->{ 'continental_scatter' } = 'Impacted Continents with uplift-b' if $scatterflux == 3;
   $world->{ 'continental_scatter' } = 'Large Scattered Islands' if $scatterflux == 4;
   $world->{ 'continental_scatter' } = 'Small Scattered Islands' if $scatterflux >= 5;

   my $positionflux = flux();
      $positionflux += 2 if $hyd < 3;

   $world->{ 'continental_positions' } = 'Both Poles covered' if $positionflux <= -5;
   $world->{ 'continental_positions' } = 'One Pole covered, one encircled' if $positionflux == -4;
   $world->{ 'continental_positions' } = 'Both Poles encircled' if $positionflux == -3;
   $world->{ 'continental_positions' } = 'One Pole encircled' if $positionflux == -2;
   $world->{ 'continental_positions' } = 'Small Polar-Equatorial Blocking' if $positionflux == 3;
   $world->{ 'continental_positions' } = 'Medium Polar-Equatorial Blocking' if $positionflux == 4;
   $world->{ 'continental_positions' } = 'Large Polar-Equatorial Blocking' if $positionflux == 5;
}

###############################################################################
#
#  Determines world albedo.  Requires continental data and UWP.
#
###############################################################################
sub albedo
{
   my $world  = shift;
   my $siz    = $world->{ siz };
   my $hyd    = $world->{ hyd };
   my $atm    = $world->{ atm };
   my $taint  = 1 if $atm =~ /[2479]/;
   my $albedo = 0;

   # $atm =~ /[0123F]/ (and E) as a default
   $albedo = 0.1 * ($hyd/2 + rand1d());

   if ( $atm =~ /[456789D]/ )
   {
      my $mods = 0;
      $mods++ if $taint;
      $mods -= 2 if $hyd == 0;
      $mods -= 2; # assume life present
      $mods++ if $world->{ pop } > 9;

      continents( $world );

      my $cae = 0; # continental albedo effects
      my $cs  = $world->{ 'continental_scatter' };
      my $cp  = $world->{ 'continental_positions' };

      # Continental Positions First
      $cae = 0.3  if $cp =~ /both poles covered/i;
      $cae = 0.25 if $cp =~ /one pole covered, one encircled/i;
      $cae = 0.2  if $cp =~ /both poles encircled/i;
      $cae = 0.15 if $cp =~ /one pole encircled/;
      $cae = 0.05 if $cp =~ /small polar-equatorial block/i;
      $cae = 0.1  if $cp =~ /medium polar-equatorial block/i;
      $cae = 0.2  if $cp =~ /large polar-equatorial block/i;
      $cae /= 2   if $hyd > 7;

      # Now Continental Scatter
      $cae += 0.2  if $cs =~ /breaking super/i;
      $cae -= 0.1  if $cs =~ /supercontinent.s./i;
      $cae += 0.1  if $cs =~ /uplift-a/i;
      $cae -= 0.05 if $cs =~ /large continents/;
      $cae += 0.15 if $cs =~ /uplift-b/i;
      $cae -= 0.05 if $cs =~ /large scattered/i;
      $cae -= 0.1  if $cs =~ /small scattered/i;

      $albedo = 0.5 + (flux() + $mods)/10 + $cae;
   }
   elsif ( $atm =~ /[ABC]/ )
   {
      $albedo = 0.1 * ($hyd/4 + rand1d());
   }

   $albedo = 0.1 if $albedo < 0.1;
   $albedo = 0.9 if $albedo > 0.9;

   $world->{ albedo } = $albedo;
}

###############################################################################
#
#  Determines Greenhouse Effect.  Requires UWP and atmospheric taint data.
#
###############################################################################
sub greenhouse
{
   my $world = shift;
   my $siz    = $world->{ 'siz' };
   my $atm    = $world->{ 'atm' };

   $world->{ 'greenhouse' } = 0;

   return if $siz < 1 && $atm == 0;

   my $greenhouseEffect = 1;
      $greenhouseEffect -= 0.05 if $world->{ 'type' } eq 'Molten';
      $greenhouseEffect += 0.1  if $world->{ 'orbital zone' } =~ /habitable/i;

   # Deal with specific atmosphere types.
   if ( $atm =~ /[456789]/ )
   {
      my $atmIndex = int($atm/2)*2; # 0, 2, 4, 6, 8, 10, etc.
      my $diaIndex = $siz;
         $diaIndex = 9 if $diaIndex > 9;

      my %ge = qw/ 4 1.2    5 1.15     6 1.1     7 1.05     8 1     9 1 /;
      $greenhouseEffect = $ge{$diaIndex};

      $greenhouseEffect += 0.05 if $atmIndex == 6;
      $greenhouseEffect += 0.1  if $atmIndex == 8;
   }
   elsif ( $atm =~ /[ABC]/ )
   {
      my @g = qw/0.9 0.95 1 1 1 1 1.05 1.1 1.2 1.4 1.7 2 3 4 5 6 7 8/;
      $greenhouseEffect = $g[ flux() + 5 ];
   }
   elsif ( $atm eq 'D' )
   {
      $greenhouseEffect = 1.15;
   }
   elsif ( $atm eq 'E' )
   {
      $greenhouseEffect = 1.1;
   }

   # Now deal with taint separately.
   if ( $atm =~ /[2479]/ )
   {
      my $taint  = $world->{ taint };
      $greenhouseEffect += $taintGreenhouseEffect{ $taint };
   }

   $world->{ greenhouse } = $greenhouseEffect;
}


###############################################################################
#
#  Determines axial tilt.  Requires trade codes.
#
###############################################################################
sub tilt 
{
   my $world = shift;
   my $roll  = rand2d();

   $world->{ tilt } = 0;

   if ( $world->{ trade_codes } =~ /Ga|Ri|Pr|Tr|Tu/ ) # i.e. "habitable" worlds
   {
      $world->{ tilt } = (rand1d()-1) * 4; #   0, 4, 8, 12, 16, 20
   }
   else
   {
      $world->{ tilt } = 40 if $roll < 5;
      $world->{ tilt } = 10 if $roll >= 5 && $roll <= 6;
      $world->{ tilt } = 20 if $roll >= 7 && $roll <= 8;
      $world->{ tilt } = 30 if $roll >= 9 && $roll <= 10;

      if ($roll == 12 )
      {
         $roll = rand1d();
         $world->{ tilt } = 50 if $roll < 3;
         $world->{ tilt } = 60 if $roll >= 3 && $roll <= 4;
         $world->{ tilt } = 70 if $roll == 5;
         $world->{ tilt } = 80 if $roll == 6;
      }
   }
   $world->{ tilt } += rand1d10() - 1;
}

###############################################################################
#
#  Determines temperature.  What temperature?  Global average I think.
#  Also determines hadley latitude.
#
#  Requires greenhouse, albedo, primary data, orbital radius, UWP.
#
###############################################################################
sub temperature
{
   my $world = shift;
   my $G     = $world->{ greenhouse } || 1;
   my $A     = $world->{ albedo }     || 1;
   my $sL    = $world->{ primary }->{ luminosity };
   my $qL    = sqrt($sL);
   my $D     = $world->{ orbitalRadius };
   my $sD    = sqrt($D);
   my $atm   = $world->{ atm };

   my $T = (375 + flux()) * $G * (1-$A) * $qL / $sD; # Kelvin

   $world->{ temperature } = int ($T - 273.15);

   my $BlackBody = $T / $G;
   my $P         = $world->{ rotationalPeriod };
   my $siz       = $world->{ siz } || 0.01;
   my $MM        = 29;

   if ( $atm =~ /[ABCE]/ ) # figure out molecular mass
   {
      my $air = $world->{ air };
      $MM = 28 if $air =~ /neon|carbonaceous|n2/i;
      $MM = 33 if $air =~ /chlorox/i;
      $MM = 26 if $air =~ /ammonia/i;
      $MM = 43 if $air =~ /co2/i;
      $MM = 30 if $air =~ /nitroxy/i;
      $MM = 50 if $air =~ /so2/i;
      $MM = 38 if $air =~ /sulfuric/i;
   }

   my $LAT = int( 49.96 * sqrt($P/$siz) * ($BlackBody/$MM) ** 1/4 );

   $world->{ hadley_latitude } = $LAT;
}

###############################################################################
#
#  Temperature wrong?  We can fix that.
#
###############################################################################
sub adjustTemperatureBetween
{
   my $world = shift;
   my $min   = shift;
   my $max   = shift;

   $world->{ starting_temp }  = $world->{ temperature };
   $world->{ starting_orbit } = $world->{ orbitalRadius };
   #print "Atm: ", $world->{ atm }, "\n";
   
   while( $world->{ temperature } >= $max || $world->{ temperature } <= $min )
   {
         #print "Temp: ", $world->{ temperature }, ", radius: ", $world->{ orbitalRadius }, "\n";
         $world->{ orbitalRadius } *= (1 + rand2d()/60) if $world->{ temperature } >= $max;
         $world->{ orbitalRadius } *= (1 - rand2d()/60) if $world->{ temperature } <= $min;
                 $world->{ orbitalRadius } = int($world->{ orbitalRadius } * 100) / 100;

         Star::orbitalPeriod( $world->{'stars'}->{ 'primary' }->{ 'mass' }, $world->{ 'orbitalRadius' } );
         Star::rotationalPeriod( $world->{'stars'}->{ 'primary' }->{ 'mass' }, $world->{ 'orbitalRadius' } );
         temperature( $world );
   }
   #print "Final Temp: ", $world->{ temperature }, ", radius: ", $world->{ orbitalRadius }, "\n";
}

###############################################################################
#
#  Determine details about the temperature.
#
###############################################################################
sub temperatureDetails
{
   my $world = shift;
   my $damage = "none";
   my $temp  = $world->{ temperature };
   my $dayInHours = $world->{ rotationalPeriod } * 24;

   my $nightTempIndex = 0;
   $nightTempIndex -= 0.25 if $dayInHours >= 1  && $dayInHours < 12;
   $nightTempIndex -= 0.5  if $dayInHours >= 12 && $dayInHours < 25;
   $nightTempIndex -= 1    if $dayInHours >= 25;

   my $seasonalTempIndex = 0;
   my $E = $world->{ eccentricity };
   $seasonalTempIndex = 0.5 if $E >= 0.01 && $E < 0.06;
   $seasonalTempIndex = 1   if $E >= 0.06 && $E < 0.10;
   $seasonalTempIndex = 1.5 if $E >= 0.10 && $E < 0.25;
   $seasonalTempIndex = 2   if $E >= 0.25;

   $world->{ nightTempIndex } = $nightTempIndex;
   $world->{ seasonalTempIndex } = $seasonalTempIndex;

   return;

   # calculate damage dice based on temp
}

sub describeWorld
{
   my $world = shift;

   my $name  = $world->{ 'worldname' };
   my $uwp   = UWP::encodeUWP( $world );
   if ( $world->{ 'hex' } )
   {
      $uwp = $world->{ 'hex' } . '/' . $uwp;
   }
   $uwp = "($uwp)";
   my $desc  = describeSAH( $world );
   my $diameter = UWP::describeSiz( $world->{ 'siz' } );
   my $circ  = UWP::circumference( $world->{ 'siz' } );
   my $atmosphere = describeAtmosphere( $world );
   my $seas  = describeSeas( $world );
   my $gravity = $world->{ 'gravity' };
   my $yearLength  = $world->{ 'orbitalPeriod' };
   my $day     = $world->{ 'hoursPerDay' };
   my $sats = 0;
   $sats = scalar( @{$world->{ 'satellite data' }} ) if $world->{ 'satellite data' };
   my $satellites = "are no satellites";
   $satellites = "are $sats satellites" if $sats > 0;
   my $temp = $world->{ 'temperature' };
   my $altitude = describeAltitudeChange( $world );
   my $pop = describePopulation( $world );
   my $gov = lc $world->{ 'gov_desc' };

   if ($gov !~ /^[aeiou]/i)
   {
      $gov = "is a $gov";
   }
   else
   {
      $gov = "is an $gov";
   }

   my $laws = lc $world->{ 'law_desc' };
   my $tech = UWP::describeTL( $world->{ 'tl' } );

   return<<END_OF_DESCRIPTION;
$name $uwp

$name is a $desc, with a diameter of $diameter km and a circumference of $circ km. It has ${atmosphere}  It has $seas, and its surface gravity is $gravity G. It has a year of $yearLength 24-hour days; its actual day length is $day hours. There $satellites. Average temperature is $temp C, with a temperature change of $altitude C per kilometre altitude.

$name $pop. It $gov, and its laws $laws. Its tech is equivalent to $tech.

END_OF_DESCRIPTION
}

sub describeSAH
{
   my $world = shift;
   my $sah   = "medium-sized";
      $sah   = "small" if $world->{ 'siz' } < 5;
      $sah   = "large" if $world->{ 'siz' } > 8;

      $sah  .= " water"  if $world->{ 'hyd' } == 10;
      $sah  .= " desert" if $world->{ 'hyd' } == 0
                         && $world->{ 'siz' } > 0
                         && $world->{ 'atm' } > 0;

   $sah  .= " planet";
   $sah  .= "oid" if $world->{ 'siz' } == 0;

   return $sah;
}

sub describeAtmosphere
{
   my $world = shift;
   my $atm = $world->{ 'atm' };

   my $desc = "";

   $desc .= "no" if $atm == 0;
   $desc .= "a trace" if $atm == 1;
   $desc .= "a very thin" if $atm >= 2 && $atm <= 3;
   $desc .= "a thin" if $atm >= 4 && $atm <= 5;
   $desc .= "a standard" if $atm >= 6 && $atm <= 7;
   $desc .= "a dense" if $atm > 7;

   $desc .= ", corrosive" if $atm == 11;
   $desc .= ", insidious" if $atm == 12;
   $desc .= "a dense, high" if $atm == 13;
   $desc .= "ellipsoid" if $atm == 14;
   $desc .= "a thin, low" if $atm == 15;

   $desc .= " atmosphere";

   $desc .= " with a standard gas mixture" if ($atm == 3 || $atm == 5 || $atm == 6 || $atm == 8);
   $desc .= " with a tainted gas mixture"  if ($atm == 2 || $atm == 4 || $atm == 7 );
   $desc .= " with a tainted, exotic gas mixture" if $atm == 9;
   $desc .= " with an exotic gas mixture"  if $atm == 10;

   if ( $world->{ 'taint' } )
   {
      my $hostile = lc $world->{ 'taint' };
      $desc .= " composed of $hostile";
   }

   my $pressure = $world->{ 'pressure' };
   $desc .= " and a pressure of $pressure.";
   return $desc;
}

sub describeSeas
{
   my $world = shift;
   my $atm   = $world->{ 'atm' };
   my $hyd   = $world->{ 'hyd' };

   my $desc = "";

   $desc = "seas of water covering " . ($hyd * 10) . "% of its surface"
      if $hyd > 0 && $hyd < 10 && $atm < 10;

   $desc = "non-water seas covering " . ($hyd * 10) . "% of its surface"
      if $hyd > 0 && $atm > 9;

   $desc = "no surface water" if $hyd == 0;

   if ( $hyd == 10 )
   {
      my $depth = int(10+rand(190)) * 100;
      $depth =~ s/(\d)(\d\d\d)$/$1,$2/;
      $desc = "an average depth of $depth metres";
      $world->{ 'sea_depth' } = $depth;
   }

   return $desc;
}


sub describeAltitudeChange
{
   my $world = shift;
   my $size  = $world->{ 'siz' };
   my $atm   = $world->{ 'atm' };
   my $hyd   = $world->{ 'hyd' };
   my $temp  = $world->{ 'temperature' };

   $atm = 1 if $atm == 0;
   $hyd = 1 if $hyd == 0;

   my $alt = int(10 * (12 - $size) / ( $atm + $hyd ));

   return -$alt;
}

sub describePopulation
{
   my $world = shift;

   my $pop = $world->{ 'pop' };
   return "is uninhabited" if $pop == 0;
   
   my $desc = "has a ";
   $desc .= 'transient ' if $pop < 6;
   $desc .= "population of " . $world->{ 'pop mult' };

   $desc .= '0'  if $pop == 7 || $pop == 10 || $pop == 13 || $pop == 16;
   $desc .= '00' if $pop == 8 || $pop == 11 || $pop == 14 || $pop == 17;

   $desc .= ' million'  if $pop == 6  || $pop == 7  || $pop == 8;
   $desc .= ' billion'  if $pop == 9  || $pop == 10 || $pop == 11;
   $desc .= ' trillion' if $pop == 12 || $pop == 13 || $pop == 14;
   $desc .= ' quadrillion' if $pop > 14;

   return $desc;
}


return 1; # as all good Perl modules should
