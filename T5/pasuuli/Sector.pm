package Sector;
use Jenkins2rSmallPRNG qw/t5srand flux rand1d rand2d rand1d10/;
use Name;
use Name2;
use UWP;
use World;
use Moon;
use strict;
=pod

  SSSSSS  EEEEEEE  CCCCCC  TTTTTTTT     OO     RRRRRRR 
 SS     S EE      CC    CC    TT      OO  OO    RR   RR
 SS       EE      CC          TT     OO    OO   RR   RR
   SS     EEEEEE  CC          TT    OO      OO  RRRRR  
     SS   EE      CC          TT    OO      OO  RR  RR 
       SS EE      CC          TT     OO    OO   RR   RR
 S     SS EE      CC    CC    TT      OO  OO    RR   RR
  SSSSSS  EEEEEEE  CCCCCC     TT        OO     RRR   RR

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
my %hex2dec = qw/ 0  0  1  1  2  2  3  3  4  4  5  5  6  6  7  7  8  8  9  9  A  10 10 10
                  B  11 11 11 C  12 12 12 D  13 13 13 E  14 14 14 F  15 15 15 G  16 16 16
                  H  17 17 17 J  18 18 18 K  19 19 19 L  20 20 20 M  21 21 21 N  22 22 22
                  P  23 23 23 Q  24 24 24 R  25 25 25 S  26 26 26 T  27 27 27 U  28 28 28
                  V  29 29 29 W  30 30 30 X  31 31 31 Y  32 32 32 Z  33 33 33
                /;

my %densityFunction =
(
   'extra galactic' => \sub { rand3d() <= 3  },
   'rift'           => \sub { rand2d() <= 2  },
   'sparse'         => \sub { rand1d() <= 1  },
   'scattered'      => \sub { rand1d() <= 2  },
   'standard'       => \sub { rand1d() <= 3  },
   'dense'          => \sub { rand1d() <= 4  },
   'cluster'        => \sub { rand1d() <= 5  },
   'core'           => \sub { rand2d() <= 11 },
);

my @mwtype   = ( 0,0, 'Far Satellite', 'Far Satellite', 'Close Satellite', ('Planet') x 10 );
my @hz       = qw/-2 -2 -1 -1 -1 0 0 0 0 0 +1 +1 +1 +2/;

###############################################################################
#
#  Utility.
#
###############################################################################
sub bounded
{
   my $num = shift;
   my $low = shift;
   my $high = shift;

   $num = $low if $num < $low;
   $num = $high if $num > $high;

   return $num;
}

###############################################################################
#
#  Generates a sector.
#
###############################################################################
sub sector
{
   my $sectorUID = shift; # a sector's unique name, or its unique ID.
   my $density   = lc shift || 'standard';
   my $tlCap     = shift;
   my $civ       = shift;

   my $UID = $sectorUID;
   t5srand( $UID );

   $density = $densityFunction{ $density };

   my %map;

   for my $col (1..32)
   {
      for my $row (1..40)
      {
         next unless &{$density}();

         my $hex    = sprintf "%02d%02d", $col, $row;
         my $system = basicData( $sectorUID, $hex, $tlCap, $civ );

         extensionData( $sectorUID, $hex, $system );
         Star::stellarData( $sectorUID, $hex, $system );
         gasGiantData( $sectorUID, $hex, $system );
         beltData( $sectorUID, $hex, $system );

         $map{ "_$hex" } = $system;
      }
   }

   return \%map;
}

###############################################################################
#
#  Generates UWP, bases, mainworld type, HZ variance, PBG, trade codes, 
#  and mainworld satellites.
#
###############################################################################
sub basicData
{
   my $sectorUID = shift; # a sector's unique name, or its unique ID.
   my $hex       = shift; # hex of system
   my $tlCap     = shift || 34;
   my $civ       = shift;
   my $uwp       = shift || ''; # entire UWP line

   my $UID = "$sectorUID/$hex";
   t5srand( $UID );

   my $world = 
   {
      name => "world$hex",
      hex  => $hex,
   };

   #
   #  This is for legacy data
   #
   if ( $uwp =~ /^(\w.*)\d\d\d\d (.)(.)(.)(.)(.)(.)(.)-(.)\s+(N|A|B)?(S|A|W)? .* (A|R)?\s(\d)(\d)(\d)/ )
   {
      UWP::decodeUWP( $world, $uwp );
   }
   else
   {
      my $name = Name2::name();
      $name = substr( $name, 0, 15 ) if length $name > 15;
      $world->{ 'name' } = $name;

      # Page 432

      my @starport = qw/. . A A A B B C C D E E X/;

      $world->{ 'starport' }   = $starport[ rand2d() ];

      my $siz = rand2d()-2;
         $siz = 9 + rand1d() if $siz == 10;
      my $atm = flux() + $siz;
         $atm = 0 if $atm < 0 || $siz == 0;
         $atm = bounded( $atm, 0, 15 );
      my $hyd = bounded( flux() + $siz, 0, 10 );
      my $pop = rand2d()-2;
         $pop = 9 + rand1d() if $pop == 10;
      my $gov = bounded( flux() + $pop, 0, 15 );
      my $law = bounded( flux() + $gov, 0, 18 );
      my $tl  = bounded( UWP::techLevel( $world, rand1d() ), 0, $tlCap );

      $world->{ siz } = $siz;
      $world->{ atm } = $atm;
      $world->{ hyd } = $hyd;
      $world->{ pop } = $pop;
      $world->{ gov } = $gov;
      $world->{ law } = $law;
      $world->{ tl  } = $tl;

      my %navytn   = qw/A 6 B 5 C 0 D 0 E 0 X 0/;
      my %scouttn  = qw/A 4 B 5 C 6 D 7 E 0 X 0/;

      $world->{ 'naval base' } = 1 if rand2d() < $navytn{ $world->{ 'starport' } };
      $world->{ 'scout base' } = 1 if rand2d() < $scouttn{ $world->{ 'starport' } };
      $world->{ 'tas' } = '';

      $world->{ 'pop_mult' } = 0;
      $world->{ 'pop_mult' } = rand1d9() if $pop > 0;

      $world->{ 'belts' } = bounded( rand1d()-3, 0, 6 );
      $world->{ 'ggs'   } = bounded( int(rand2d()/2-2), 0, 6 );
   }

   if ( $civ =~ /wild/i && $world->{ 'pop' } < 7 )
   {
      $world->{ 'pop' } = 0;
      $world->{ 'pop_mult' }    = 0;
      $world->{ 'gov' }  = 0;
      $world->{ 'law' }   = 0;
      $world->{ 'tl' }  = 0;

      $world->{ 'starport' } = 'X';
      $world->{ 'naval base' } = 0;
      $world->{ 'scout base' } = 0;
   }

   $world->{ 'name' } = uc $world->{ 'name' } if $world->{ 'pop' } >= 9;

   $world->{ 'mainworld type' } = $mwtype[ rand2d() ]; #  => flux(),
   $world->{ 'hz variance' } = $hz[ rand2d() ]; # flux()

   #############################################################
   #
   # Page 437
   #
   #############################################################
   $world->{ 'orbit' } = 3 + $world->{ 'hz variance' };

   my $satellites = rand1d()-4;
   if ( $satellites == 0 )
   {
      $world->{ 'ringed' } = 'ringed';
      $satellites = rand1d()-4;
   }

   for my $num (0..$satellites-1) # satellites
   {
      $world->{ "satellite data" }->[ $num ] = hospitableSatellite( $world );
   }

   $world->{ 'uwp'   } = UWP::encodeUWP( $world );
   $world->{ 'bases' } = '';
   $world->{ 'bases' } = 'N' if $world->{ 'naval base' };
   $world->{ 'bases' } .= 'S' if $world->{ 'scout base' };
   $world->{ 'trade_codes' } = UWP::tradeCodes( $uwp,
             $world->{ 'hz variance' },
             $world->{ 'orbit' },
             $world->{ 'tas' },
             $world->{ 'mainworld type' } );
 
   return $world;
}

##############################################################
#
#  Generates: Importance, Ex, Cx
#
##############################################################
sub extensionData
{
   my $sectorUID = shift; # a sector's unique name, or its unique ID.
   my $hex       = shift; # hex of system
   my $world     = shift;

   my $UID = "$sectorUID/$hex/ext";
   t5srand( $UID );

   my $importance = UWP::importance( $world );
   my $ix =
   {
      'importance' => $importance,
      'expected ship traffic' => int( rand1d9() * (10 ** $importance) ),
   };
   $world->{ 'importance extension' } = $ix;

   my %ex;

   $ex{ 'resources' } = rand2d();
   $ex{ 'resources' } += $world->{ 'ggs' } + $world->{ 'belts' }
                if $world->{ 'tl' } >= 8;

   $ex{ 'labor' } = bounded( $world->{ 'pop' } - 1, 0, 100 );
   $ex{ 'infrastructure' } = bounded( rand2d() + $ix->{ 'importance' }, 0, 20 );
   $ex{ 'infrastructure' } = rand1d() if $world->{ 'trade_codes' } =~ / Ni /;
   $ex{ 'infrastructure' } = 0 if $world->{ 'trade_codes' } =~ / Ba | Di | Lo /;
   $ex{ 'efficiency' }     = flux();

   my $RU = ($ex{ 'resources' } || 1)
          * ($ex{ 'labor' } || 1)
          * ($ex{ 'infrastructure' } || 1)
          * ($ex{ 'efficiency' } || 1);

   $ex{ 'ru' } = $RU;

   $world->{ 'economic extension' } = \%ex;

   my %cx;

   $cx{ 'homogeneity' } = bounded( flux() + $world->{ 'pop' }, 1, 100 );
   $cx{ 'acceptance'  } = bounded( $world->{ 'pop' } + $ix->{ 'importance' }, 1, 100 );
   $cx{ 'strangeness' } = bounded( 5 + flux(), 1, 20 );
   $cx{ 'symbols' }     = bounded( flux() + $world->{ 'tl' }, 1, 100 );

   $world->{ 'cultural extension' } = \%cx;
}

###############################################################
#
#  page 437
#
###############################################################
sub gasGiantData
{
   my $sectorUID = shift;
   my $hex       = shift;
   my $system    = shift;
   my $hz        = $system->{ 'hz' }; #getHabitableZone( $system->{ 'primary' } );

   my $UID = "$sectorUID/$hex/gg";
   t5srand( $UID );

   my @gg = ();
   my $number = 0;
   for my $ggNum (1..$system->{ 'gas giants' })
   {
      my $satellites = rand1d()-1;
      my $ringed = '';
      if ($satellites == 0)
      {
         $ringed = 'ringed';
         $satellites = rand1d()-1;
      }
      $satellites = 0 if $satellites < 0;

      my $code       = 'LGG';
      my $size       = 19 + rand2d();

      $number++ if $size < 23;
      $code = 'SGG' if $size < 23;
      $code = 'IGG' if $size < 23 && ($number % 2 == 1);

      my $orbit = rand2d() - 5;
      $orbit += 1 if $code eq 'SGG';
      $orbit += 4 if $code eq 'IGG';

      $orbit += $hz;
      $orbit = 0 if $orbit < 0;
      $orbit += rand1d9()/10.0 + rand1d9()/100.0; # gimme a couple decimal places

      my $ggref =
      {
         'number'     => $ggNum,
         'starport'   => 'Y',
         'code'       => $code,
         'siz'        => $size,
         'satellites' => $satellites,
         'ringed'     => $ringed,
         'orbit'      => $orbit,
      };
      $ggref->{ 'uwp' } = UWP::encodeGG( $ggref );

      push @gg, $ggref;
   }

   $system->{ 'gas giant data' } = \@gg;
}

sub beltData
{
   my $sectorUID = shift;
   my $hex       = shift;
   my $system    = shift;
   my $hz        = $system->{ 'hz' };

   my $UID = "$sectorUID/$hex/belts";
   t5srand( $UID );

   my @belts = ();
   for (1..$system->{ 'planetoid belts' })
   {
      my $orbit = rand2d() - 3 + $hz;
      my $pop = bounded( rand2d()-2, 0, $system->{ 'pop' }-1 );
      my $gov = bounded( $pop + flux(), 0, 15 );
      my $law = bounded( $gov + flux(), 0, 18 );
      my $spaceport = spaceport( $pop );
  
      my $beltref =
      {
         'orbit' => $orbit,
         'starport' => $spaceport,
         'siz' => 0,
         'atm' => 0,
         'hyd' => 0,
         'pop' => $pop,
         'gov' => $gov,
         'law'  => $law
      };
    
      my $tl = UWP::techLevel( $beltref, rand1d() );

      $beltref->{ 'tl' } = $tl;
      $beltref->{ 'uwp' } = UWP::encodeUWP( $beltref ) . "    Belt";

      push @belts, $beltref;
   }
   $system->{ 'belt data' } = \@belts;
}





1;
