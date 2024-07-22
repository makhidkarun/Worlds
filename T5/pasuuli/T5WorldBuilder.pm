package T5WorldBuilder;
use UWP;
use Star;
#use strict;
use Jenkins2rSmallPRNG qw/t5srand flux rand1d rand2d rand1d10/;

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
                                                                 
                                                                 
@@@@@@@   @@@  @@@  @@@  @@@       @@@@@@@   @@@@@@@@  @@@@@@@   
@@@@@@@@  @@@  @@@  @@@  @@@       @@@@@@@@  @@@@@@@@  @@@@@@@@  
@@!  @@@  @@!  @@@  @@!  @@!       @@!  @@@  @@!       @@!  @@@  
!@   @!@  !@!  @!@  !@!  !@!       !@!  @!@  !@!       !@!  @!@  
@!@!@!@   @!@  !@!  !!@  @!!       @!@  !@!  @!!!:!    @!@!!@!   
!!!@!!!!  !@!  !!!  !!!  !!!       !@!  !!!  !!!!!:    !!@!@!    
!!:  !!!  !!:  !!!  !!:  !!:       !!:  !!!  !!:       !!: :!!   
:!:  !:!  :!:  !:!  :!:   :!:      :!:  !:!  :!:       :!:  !:!  
 :: ::::  ::::: ::   ::   :: ::::   :::: ::   :: ::::  ::   :::  
:: : ::    : :  :   :    : :: : :  :: :  :   : :: ::    :   : :  
                                                                 
=cut

sub new { bless {}, shift }

sub init
{
   my $self   = shift;
   my $seed   = shift;
   t5srand( $seed );
   flux();
}

sub parseUWP
{
   my $self  = shift;
   my $world = shift;
   my $uwp   = shift;

   $world = UWP::decodeUWP( $world, $uwp );

   $world->{ 'siz' } = (rand2d()-1)/100.0 if $world->{ 'siz' } == 0;

   # guess taint
   if ( $world->{ atm } =~ /[2479]/ )
   {
      my $flux = flux();
      $world->{ taint } = 'Chlorine'   if $flux == -5;
      $world->{ taint } = 'Low Oxygen' if $flux == -4;
      $world->{ taint } = 'Methane'    if $flux == -3;
      $world->{ taint } = 'Nitrous Oxides' if $flux == -2;
      $world->{ taint } = 'Fungi'      if $flux == -1;
      $world->{ taint } = 'Microorganisms' if $flux == 0;
      $world->{ taint } = 'Allergens'  if $flux == 1;
      $world->{ taint } = 'Sulfur Compounds' if $flux == 2;
      $world->{ taint } = 'High CO2'   if $flux == 3;
      $world->{ taint } = 'High O2'    if $flux == 4;
      $world->{ taint } = 'Radioactive gases' if $flux == 5;
   }

   $world->{ 'orbital zone' } = 'Habitable' unless $world->{ 'orbital zone' }; # default assumption

   return $world;
}

sub parsePrimary # L^0.5
{
   my $self  = shift;
   my $world = shift;
   my $class = shift || 'G0 V'; # $world->{ primary } || 'G0 V';
   
   $class =~ s/^(\w+ \w+).*$/$1/; # remove extra stars for now
   my $primary = $1;
   
   $world->{ primary } = $primary;
   $world->{ primaryRadius } = 0;
   $world->{ primaryRadius } = 0.01 if $primary =~ /A|F/ 
                                    || $primary =~ /(G|K)\s*IV/;
   $world->{ primaryMass } = 1; # for now

   if ( $class =~ /I|II|III/ )
   {
      my $flux = flux();
      my $l;
      $l =  sqrt( 230_000 ) if $flux == -5;
      $l =  sqrt( 190_000 ) if $flux == -4;
      $l =  sqrt(     870 ) if $flux == -3;
      $l =  sqrt(     138 ) if $flux == -2;
      $l =  sqrt(     435 ) if $flux == -1;
      $l =  sqrt(     690 ) if $flux ==  0;
      $l =  sqrt(   5_069 ) if $flux ==  1;
      $l =  sqrt(     118 ) if $flux ==  2;
      $l =  sqrt(   1_550 ) if $flux ==  3;
      $l =  sqrt(  15_400 ) if $flux ==  4;
      $l =  sqrt( 510_000 ) if $flux ==  5;
      $world->{ primaryLuminosity } = $l;

      my $r;
      $r = 0.20 if $flux == -5;
      $r = 0.10 if $flux == -4;
      $r = 0.10 if $flux == -3;
      $r = 0.09 if $flux == -2;
      $r = 0.24 if $flux == -1;
      $r = 0.37 if $flux == +0;
      $r = 0.92 if $flux == +1;
      $r = 0.06 if $flux == +2;
      $r = 0.50 if $flux == +3;
      $r = 0.64 if $flux == +4;
      $r = 17   if $flux == +5;
      $world->{ primaryRadius } = $r;

      my $m;
      $m = 40 if $flux == -5;
      $m = 34 if $flux == -4;
      $m = 7.1 if $flux == -3;
      $m = 2.3 if $flux == -2;
      $m = 2.8 if $flux == -1;
      $m = 5.6 if $flux == +0;
      $m = 4.2 if $flux == +1;
      $m = 2.0 if $flux == +2;
      $m = 2.6 if $flux == +3;
      $m = 12 if $flux == +4;
      $m = 8.4 if $flux == +5;
      $world->{ primaryMass } = $m;
   }

   if ( $class =~ /O|B/ )
   {
      my $roll = rand1d();

      $world->{ primaryLuminosity } = sqrt( 10_000_000 ) if $roll == 1;
      $world->{ primaryLuminosity } = sqrt( 100_000 ) if $roll == 2;
      $world->{ primaryLuminosity } = sqrt( 16_000 ) if $roll == 3;
      $world->{ primaryLuminosity } = sqrt( 8_300 ) if $roll == 4;
      $world->{ primaryLuminosity } = sqrt( 750 ) if $roll == 5;
      $world->{ primaryLuminosity } = sqrt( 130 ) if $roll == 6;

      $world->{ primaryRadius } = 0.60 if $roll == 1;
      $world->{ primaryRadius } = 0.10 if $roll == 2;
      $world->{ primaryRadius } = 0.03 if $roll == 3;
      $world->{ primaryRadius } = 0.02 if $roll == 4;
      $world->{ primaryRadius } = 0.02 if $roll == 5;
      $world->{ primaryRadius } = 0.01 if $roll == 6;

      $world->{ primaryMass } = 60 if $roll == 1;
      $world->{ primaryMass } = 20 if $roll == 2;
      $world->{ primaryMass } = 16 if $roll == 3;
      $world->{ primaryMass } = 10.5 if $roll == 4;
      $world->{ primaryMass } = 5.4 if $roll == 5;
      $world->{ primaryMass } = 3.5 if $roll == 6;
   }

   my %map =
   (
      'A0 V' => [ sqrt(63),    2.6 ],
      'A1 V' => [ sqrt(52),    2.4 ],
      'A2 V' => [ sqrt(40),    2.2 ],
      'A3 V' => [ sqrt(35),    2.1 ],
      'A4 V' => [ sqrt(30),    2.0 ],
      'A5 V' => [ sqrt(24),    1.9 ],
      'A6 V' => [ sqrt(18),    1.85 ],
      'A7 V' => [ sqrt(11),    1.8 ],
      'A8 V' => [ sqrt(11),    1.75],
      'A9 V' => [ sqrt(10),    1.7 ],
      'F0 V' => [ sqrt(9),     1.6 ],
      'F1 V' => [ sqrt(7),     1.55],
      'F2 V' => [ sqrt(6.3),   1.5 ],
      'F3 V' => [ sqrt(5.6),   1.45],
      'F4 V' => [ sqrt(4.8),   1.4 ],
      'F5 V' => [ sqrt(4),     1.35],
      'F6 V' => [ sqrt(3.5),   1.3 ],
      'F7 V' => [ sqrt(3),     1.25],
      'F8 V' => [ sqrt(2.5),   1.2 ],
      'F9 V' => [ sqrt(2),     1.14],
      'G0 V' => [ sqrt(1.45),  1.08],
      'G1 V' => [ sqrt(1.25),  1.04],
      'G2 V' => [ sqrt(1.1),   1.0 ],
      'G3 V' => [ sqrt(0.97),  0.99],
      'G4 V' => [ sqrt(0.85),  0.97],
      'G5 V' => [ sqrt(0.7),   0.95],
      'G6 V' => [ sqrt(0.6),   0.92],
      'G7 V' => [ sqrt(0.5),   0.88],
      'G8 V' => [ sqrt(0.44),  0.85],
      'G9 V' => [ sqrt(0.4),   0.84],
      'K0 V' => [ sqrt(0.36),  0.83],
      'K1 V' => [ sqrt(0.30),  0.80],
      'K2 V' => [ sqrt(0.28),  0.78],
      'K3 V' => [ sqrt(0.24),  0.74],
      'K4 V' => [ sqrt(0.21),  0.71],
      'K5 V' => [ sqrt(0.18),  0.68],
      'K6 V' => [ sqrt(0.16),  0.64],
      'K7 V' => [ sqrt(0.14),  0.61],
      'K8 V' => [ sqrt(0.12),  0.58],
      'K9 V' => [ sqrt(0.1),   0.52],
      'M0 V' => [ sqrt(0.075), 0.47],
      'M1 V' => [ sqrt(0.05),  0.40],
      'M2 V' => [ sqrt(0.03),  0.33],
      'M3 V' => [ sqrt(0.014), 0.26],
      'M4 V' => [ sqrt(0.005), 0.20],
      'M5 V' => [ sqrt(0.004), 0.15],
      'M6 V' => [ sqrt(0.003), 0.13],
      'M7 V' => [ sqrt(0.002), 0.11],
      'M8 V' => [ sqrt(0.0015), 0.09],
      'M9 V' => [ sqrt(0.001),  0.08],

      'A0 IV' => [ sqrt(88),    51  ],
      'A1 IV' => [ sqrt(72),    25  ],
      'A2 IV' => [ sqrt(60),    12  ],
      'A3 IV' => [ sqrt(49),    8   ],
      'A4 IV' => [ sqrt(38),    5   ],
      'A5 IV' => [ sqrt(27),    3.7 ],
      'F0 IV' => [ sqrt(11.5),  3.4 ],
      'F1 IV' => [ sqrt(11),    3.3 ], 
      'F2 IV' => [ sqrt(10.5),  3.2 ],
      'F3 IV' => [ sqrt(10),    3.1 ],
      'F4 IV' => [ sqrt(9.5),   3.0 ],
      'F5 IV' => [ sqrt(9),     2.8 ],
      'F6 IV' => [ sqrt(8.4),   2.6 ],
      'F7 IV' => [ sqrt(7.8),   2.3 ],
      'F8 IV' => [ sqrt(7.2),   2.0 ],
      'F9 IV' => [ sqrt(6.7),   1.7 ],
      'G0 IV' => [ sqrt(6.25),  1.4 ],
      'G1 IV' => [ sqrt(6.28),  1.4 ],
      'G2 IV' => [ sqrt(6.31),  1.4 ],
      'G3 IV' => [ sqrt(6.34),  1.4 ],
      'G4 IV' => [ sqrt(6.37),  1.4 ],
      'G5 IV' => [ sqrt(6.4),   1.5 ],
      'G6 IV' => [ sqrt(6.6),   1.5 ],
      'G7 IV' => [ sqrt(6.7),   1.5 ],
      'G8 IV' => [ sqrt(6.8),   1.5 ],
      'G9 IV' => [ sqrt(7.0),   1.5 ],
      'K0 IV' => [ sqrt(7.18),  1.6 ],
      'K1 IV' => [ sqrt(7.5),   1.6 ],
      'K2 IV' => [ sqrt(7.9),   1.6 ],
      'K3 IV' => [ sqrt(8.3),   1.7 ],
      'K4 IV' => [ sqrt(8.7),   1.7 ],
      'K5 IV' => [ sqrt(9),     1.8 ],
      'K6 IV' => [ sqrt(9.1),   1.8 ],
      'K7 IV' => [ sqrt(9.2),   1.8 ],
      'K8 IV' => [ sqrt(9.3),   1.8 ],
      'K9 IV' => [ sqrt(9.4),   1.8 ],
   );

   $world->{ primaryLuminosity } = $map{ $class }->[0] if $map{ $class };
   $world->{ primaryMass       } = $map{ $class }->[1] if $map{ $class };

   print "Unknown star class: [$class]\n" unless $world->{ primaryLuminosity } && $world->{ primaryMass       };

   $world->{ primaryRadius } = sprintf "%.1f", $world->{ primaryRadius };
   $world->{ primaryLuminosity } = sprintf "%.2f", $world->{ primaryLuminosity };

   #
   #  Zones
   #
 
   my $R       = $world->{ primaryRadius } || 0;
   my $sL      = $world->{ primaryLuminosity } || 1;

   $world->{ innerZone } = sprintf "%.02f", $R + 0.0111 * $sL;            # inner edge
   $world->{ habZone   } = sprintf "%.02f", $R + 0.95 * $sL;              # inner edge
   $world->{ midZone   } = sprintf "%.02f", $R + 1.35 * $sL;              # inner edge
   $world->{ outerZone } = sprintf "%.02f", 2.7 * $sL + (flux()-1)/5.0;   # inner edge = snowline
   $world->{ edgeZone  } = sprintf "%.02f", 30 * $sL + flux();            # outer edge of OZ

   $world->{ idealOrbit } = sprintf "%.02f", 0.8 + rand1d()/10 * $sL;
   my $midhab = sprintf "%.1f", $R + (1.0 + rand1d()/20) * $sL; # comfortably inside the hab zone
   
   $world->{ orbitalRadius } = $midhab unless $world->{ orbitalRadius };
   
   my $au = $world->{ orbitalRadius };
   my $ot = 0;

   if    ( $au < 0.3  ) { $ot = 0 }
   elsif ( $au < 0.55 ) { $ot = 1 }
   elsif ( $au < 0.85 ) { $ot = 2 }
   elsif ( $au < 1.3  ) { $ot = 3 }
   elsif ( $au < 2.2  ) { $ot = 4 }
   elsif ( $au < 4    ) { $ot = 5 }
   elsif ( $au < 7.6  ) { $ot = 6 }
   elsif ( $au < 15   ) { $ot = 7 }
   elsif ( $au < 30   ) { $ot = 8 }
   elsif ( $au < 60   ) { $ot = 9 }
   elsif ( $au < 120  ) { $ot = 10 } 
   elsif ( $au < 240  ) { $ot = 11 }
   elsif ( $au < 480  ) { $ot = 12 }
   elsif ( $au < 960  ) { $ot = 13 }
   elsif ( $au < 1900 ) { $ot = 14 }
   elsif ( $au < 3800 ) { $ot = 16 }
   else                 { $ot = 17 }

   $world->{ orbitalTrack } = $ot;
}

sub setZone
{
   my $self  = shift;
   my $world = shift;
   my $zone  = shift;
 
   $world->{ 'orbital zone' } = $zone;
}

sub rotationalPeriod
{
   my $self    = shift;
   my $world   = shift;
   my $hours   = 4 * (rand2d() - 2)
                 + 5 + ($world->{ primaryMass } / $world->{ orbitalRadius });
   my $days    = $hours/24;

   $world->{ rotationalPeriod } = $days;
}

sub density # depends on HZ and UWP and Trade Codes
{
   my $self    = shift;
   my $world   = shift;
   my $zone    = $world->{ 'orbital zone' };
   my $atm     = $world->{ atm  };
   my $siz     = $world->{ siz  };

   my @density = qw/0.2  0.3  0.4  0.45 0.5  0.55 0.6  0.65 0.7  0.75 0.8  0.85 0.9  0.95 1   1.05 1.1  1.35 1.6 /;
   my @type    = qw/ Icy  Icy  Icy  Rocky Rocky Rocky Rocky Rocky Rocky Rocky Metal Metal Metal Metal Metal Metal Metal Stripped Stripped/;
   # my @ggdens  = qw/0.05 0.1  0.13 0.15 0.18 0.2  0.25 0.3  0.4  0.5  0.6  0.8  1    1.5  2 /;

   # worlds with Density > 1.2 have high surface radiation emanating from the interior.
   # all such worlds should be marked Rw (Radworld).

   if ( $world->{ remarks } =~ /Ga|Ri|Pr|Tr|Tu/ ) # standard density
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
   $world->{ radworld }++ if $world->{ density } > 1.2;
}

sub gravity # depends on Density
{
   my $self    = shift;
   my $world   = shift;

   $world->{ gravity } = sprintf "%.2f", $world->{ density } * $world->{ siz } / 8;
}

sub mass # depends on Density
{
   my $self   = shift;
   my $world  = shift;
   my $dia    = $world->{ siz };
   
   $world->{ mass } = sprintf "%.2f", $world->{ density } * (($dia/8) ** 3);

   # but GG mass can't exceed 4200
}

sub atmosphere # depends on parsing the UWP and the primary
{
   my $self  = shift;
   my $world = shift;

   $world->{ air } = 'Oxygen';
   $world->{ air } = 'None' if $world->{ atm } == 0;

   my $flux = flux();
   if ( $world->{ atm } =~ /[ABC]/ )
   {
      $flux += 1 if $world->{ hyd } < 3;
      $flux -= 1 if $world->{ hyd } > 7;
      $flux -= 1 if $world->{ siz } > 10;
      $flux += 1 if $world->{ primary } =~ /F/;
      $flux -= 1 if $world->{ primary } =~ /M/;

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

sub orbitalPeriod # requires parsing Primary.  That's all.
{
   my $self   = shift;
   my $world  = shift;
   my $radius = $world->{ orbitalRadius }; # AU
   my $r3     = $radius ** 3;
   my $mass   = $world->{ primaryMass };   # stellar mass

   $world->{ orbitalPeriod } = int( 365.25 * sqrt($r3/$mass) );

   #
   #  TODO Re-figure Zone...
   #
}

sub orbitalEccentricity # requires trade codes.
{
   my $self   = shift;
   my $world  = shift;
   my $E      = shift || '';
   
   unless ($E)
   {
      my $roll = rand2d();

      $E = 0 if $roll < 8;
      $E = 0.005 if $roll == 8;
      $E = 0.010 if $roll == 9;
      $E = 0.015 if $roll == 10;
      $E = 0.020 if $roll > 10;
   
      if ( $world->{ remarks } !~ /Ga|Ri|Pr|Tr|Tu/ ) # i.e. not "habitable" worlds
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
   }
   $world->{ orbitalEccentricity } = $E;
}

sub continents
{
   my $self    = shift;
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

sub albedo
{
   my $self   = shift;
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

      $self->continents( $world );

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
   return $albedo;
}

sub greenhouse
{
   my $self = shift;
   my $world = shift;
   my $siz    = $world->{ siz };
   my $atm    = $world->{ atm };

   $world->{ greenhouse } = 0;
   
   return if $siz < 1 && $atm == 0;
  
   my $greenhouseEffect = 1;
      $greenhouseEffect -= 0.05 if $world->{ type } eq 'Molten';
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
     
      $greenhouseEffect += 0.01 if $taint =~ /chlorine/i;
      $greenhouseEffect -= 0.05 if $taint =~ /low oxy/i;
      $greenhouseEffect += 0.1  if $taint =~ /methane/i;
      $greenhouseEffect += 0.05 if $taint =~ /nitrous/i;
      $greenhouseEffect += 0.05 if $taint =~ /sulfur/i;
      $greenhouseEffect += 0.1  if $taint =~ /high carbon diox/i;
   }

   $world->{ greenhouse } = $greenhouseEffect;
}

sub tilt # depends on trade codes
{
   my $self  = shift;
   my $world = shift;
   my $tilt  = shift || '';

   $world->{ tilt } = $tilt;
   
   unless ($tilt)
   {
      my $roll  = rand2d();
      if ( $world->{ remarks } =~ /Ga|Ri|Pr|Tr|Tu/ ) # i.e. "habitable" worlds
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
}

sub temperature
{
   my $self  = shift;
   my $world = shift;
   my $G     = $world->{ greenhouse } || 1;
   my $A     = $world->{ albedo }     || 1;
   my $sL    = $world->{ primaryLuminosity };
   my $qL    = sqrt($sL);
   my $D     = $world->{ orbitalRadius };
   my $sD    = sqrt($D);
   my $atm   = $world->{ atm };

   my $T = (375 + flux()) * $G * (1-$A) * $qL / $sD; # Kelvin

   $world->{ temperature } = int ($T - 273.15);

   # 
   #  Hadley calculations will have to wait.
   #
 
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

sub adjustTemperatureBetween
{
   my $self  = shift;
   my $world = shift;
   my $min   = shift;
   my $max   = shift;
 
   ($min,$max) = ($max,$min) if $min > $max;
   
   $world->{ starting_temp }  = $world->{ temperature };
   $world->{ starting_orbit } = $world->{ orbitalRadius };
   #print "Atm: ", $world->{ atm }, "\n";
   while( $world->{ temperature } >= $max || $world->{ temperature } <= $min )
   {
         #print "Temp: ", $world->{ temperature }, ", target: [$min..$max], radius: ", $world->{ orbitalRadius }, "\n";
         $world->{ orbitalRadius } *= (1 + rand2d()/60) if $world->{ temperature } >= $max;
         $world->{ orbitalRadius } *= (1 - rand2d()/60) if $world->{ temperature } <= $min;
		 $world->{ orbitalRadius } = int($world->{ orbitalRadius } * 100) / 100;

         $self->orbitalPeriod( $world );
         $self->rotationalPeriod( $world );
         $self->temperature( $world );   
   }
   #print "Final Temp: ", $world->{ temperature }, ", radius: ", $world->{ orbitalRadius }, "\n";
}

sub autoAdjustTemperature
{
   my $self  = shift;
   my $world = shift;

   #print "Atm: ", $world->{ atm }, "\n";
   if ( $world->{ atm } =~ /[456789]/ )
   {
      #print "Temp: ", $world->{ temperature }, ", radius: ", $world->{ orbitalRadius }, "\n";
      while ( $world->{ temperature } >= 40 || $world->{ temperature } <= -30 )
      {
	     #print "Temp: ", $world->{ temperature }, ", radius: ", $world->{ orbitalRadius }, "\n";
         $world->{ orbitalRadius } *= (1 + rand2d()/60) if $world->{ temperature } >= 40;
         $world->{ orbitalRadius } *= (1 - rand2d()/60) if $world->{ temperature } <= -30;
		 $world->{ orbitalRadius } = int($world->{ orbitalRadius } * 100) / 100;

         $self->orbitalPeriod( $world );
         $self->rotationalPeriod( $world );
         $self->temperature( $world );
      }   
      #print "Final Temp: ", $world->{ temperature }, ", radius: ", $world->{ orbitalRadius }, "\n";
   }
}

sub temperatureDetails
{
   my $self  = shift;
   my $world = shift;
   my $damage = "none";
   my $temp  = $world->{ 'temperature' };
   my $dayInHours = $world->{ 'rotationalPeriod' } * 24;
   
   my $nightTempIndex = 0;
   $nightTempIndex -= 0.25 if $dayInHours >= 1  && $dayInHours < 12;
   $nightTempIndex -= 0.5  if $dayInHours >= 12 && $dayInHours < 25;
   $nightTempIndex -= 1    if $dayInHours >= 25;
   
   my $seasonalTempIndex = 0;
   my $E = $world->{ 'orbitalEccentricity' };
   $seasonalTempIndex = 0.5 if $E >= 0.01 && $E < 0.06;
   $seasonalTempIndex = 1   if $E >= 0.06 && $E < 0.10;
   $seasonalTempIndex = 1.5 if $E >= 0.10 && $E < 0.25;
   $seasonalTempIndex = 2   if $E >= 0.25;
   
   $world->{ 'nightTempIndex' } = $nightTempIndex;
   $world->{ 'seasonalTempIndex' } = $seasonalTempIndex;
   
   return;
   
   #
   #  Needs work
   #
   
   my @damage = ();
   
   $damage[ 273 ] = 40;
   $damage[ $_ ] = 35 for -272 .. -250;
   $damage[ $_ ] = 30 for -249 .. -225;
   $damage[ $_ ] = 25 for -224 .. -200;
   $damage[ $_ ] = 20 for -199 .. -175;
   $damage[ $_ ] = 15 for -174 .. -150;
   $damage[ $_ ] = 10 for -149 .. -125;
   $damage[ $_ ] = 7  for -124 .. -100;
   $damage[ $_ ] = 4  for -99 .. -75;
   $damage[ $_ ] = 3  for -74 .. -50;
   $damage[ $_ ] = 2  for -49 .. -25;
   $damage[ $_ ] = 1  for -24 .. 0;
   $damage[ $_ ] = 0  for 0 .. 49;
   $damage[ $_ ] = 1  for 50 .. 74;
   $damage[ $_ ] = 2  for 75 .. 99;
   $damage[ $_ ] = 3  for 100 .. 124;
   $damage[ $_ ] = 4  for 125 .. 149;
   $damage[ $_ ] = 7  for 150 .. 174;
   $damage[ $_ ] = 10 for 175 .. 199;
   $damage[ $_ ] = 15 for 200 .. 224;
   $damage[ $_ ] = 20 for 225 .. 249;
   $damage[ $_ ] = 25 for 250 .. 274;
   $damage[ $_ ] = 30 for 275 .. 299;
   $damage[ $_ ] = 35 for 300 .. 324;
   $damage[ $_ ] = 40 for 325 .. 424;
   $damage[ $_ ] = 100 for 425 .. 524;
   $damage[ $_ ] = 115 for 525 .. 624;
   $damage[ $_ ] = 130 for 625 .. 724;
   $damage[ $_ ] = 140 for 725 .. 1499;
   $damage[ $_ ] = 300 for 1500 .. 2000;

   
}



1; # return true as all good Perl modules should
