package T5SystemGeneration;
use Jenkins2rSmallPRNG qw/t5srand rand1d rand2d rand3d rand1d9 rand1d10 flux/;
use Name2;
use T5Sysgen;
use UWP;
use Star;
use strict;
##############################################################
#
#  Useful data
#
##############################################################

        my @ehex = (0..9, 'A'..'H', 'J'..'N', 'P'..'Z');
        my %dehex = 
        ( 
           0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 6, 7 => 7,
           8 => 8, 9 => 9, 'A' => 10, 'B' => 11, 'C' => 12, 'D' => 13, 
           'E' => 14, 'F' => 15, 'G' => 16, 'H' => 17, 'J' => 18, 'K' => 19
        );

	my @spectral = qw/B A A F F G G K K M M M BD BD BD/;
	my %spectral =
	(
	   'B' => [ qw/Ia Ia Ib II III III III III V V IV D IV IV IV/ ],
	   'A' => [ qw/Ia Ia Ib II III IV V V V V V VI D VI VI VI/  ],
	   'F' => [ qw/II II III IV V V V V V V VI D VI VI VI/ ],
	   'G' => [ qw/II II III IV V V V V V V VI D VI VI VI/ ],
  	   'K' => [ qw/II II III IV V V V V V V VI D VI VI VI/ ],
  	   'M' => [ qw/II II II II III V V V V V VI D VI VI VI/ ],
	);

        my %starSizeIndex =
        (
           'Ia' => 0, 'Ib' => 1, 'II' => 2, 'III' => 3, 
           'IV' => 4, 'V'  => 5, 'VI' => 6, 'D'   => 7,
        );

        my %habitableZoneOrbit =
        (#                                   <----- Star Size Index ----->
           'A0 A1 A2 A3 A4 A5 A6 A7 A8' => [ 12, 11,  9, 8,  7,  7, '-', 0 ],
           'A9 F0 F1'                   => [ 12, 10,  8, 7,  6,  6, '-', 0 ],
           'F2 F3 F4 F5 F6'             => [ 12, 10,  8, 6,  6,  5,  3,  0 ],
           'F7 F8 F9 G0 G1'             => [ 11, 10,  8, 6,  5,  4,  3,  0 ],
           'G2 G3 G4 G5 G6 G7 G8'       => [ 12, 10,  8, 6,  5,  3,  2,  0 ],
           'G9 K0 K1 K2 K3'             => [ 12, 10,  8, 7,  5,  2,  1,  0 ],
           'K4 K5 K6 K7 K8'             => [ 12, 10,  9, 7, '-', 2,  0,  0 ],
           'K9 M0 M1 M2 M3'             => [ 12, 10,  9, 8, '-', 0,  0,  0 ],
           'M4 M5 M6 M7 M8'             => [ 12, 11, 10, 8, '-', 0,  0,  0 ],
           'M9'                         => [ 12, 11, 11, 9, '-', 0,  0,  0 ]
        );

        my @worldOrbit1 = qw/10  8  6  4  2  0  1  3 5 7 0/;
        my @worldOrbit2 = qw/17 16 15 14 13 12 11 10 9 8 7/;
        my @moonOrbit1  = qw/a b c d e f g h i j k l m/;
        my @moonOrbit2  = qw/n o p q r s t u v w x y z/;

##############################################################
#
#  Does it all
#
##############################################################
sub sector
{
   my $sectorUID = shift; # a sector's unique name, or its unique ID.
   my $density   = lc shift || 'standard';
   my $tlCap     = shift;
   my $civ       = shift;

   my $UID = $sectorUID;
   t5srand( $UID );

   $density = sub { rand3d() <= 3  } if $density eq 'extra galactic';
   $density = sub { rand2d() <= 2  } if $density eq 'rift';
   $density = sub { rand1d() <= 1  } if $density eq 'sparse';
   $density = sub { rand1d() <= 2  } if $density eq 'scattered';
   $density = sub { rand1d() <= 3  } if $density eq 'standard';
   $density = sub { rand1d() <= 4  } if $density eq 'dense';
   $density = sub { rand1d() <= 5  } if $density eq 'cluster';
   $density = sub { rand2d() <= 11 } if $density eq 'core';

   my %map;

   for my $col (1..32)
   {
      for my $row (1..40)
      {
         next unless &{$density}();

         my $hex    = sprintf "%02d%02d", $col, $row;
         my $system = basicData( $sectorUID, $hex, $tlCap, $civ );
            $system = T5SystemGeneration::extensionData( $sectorUID, $hex, $system );
            $system = T5SystemGeneration::stellarData( $sectorUID, $hex, $system );
            $system = T5SystemGeneration::gasGiantData( $sectorUID, $hex, $system );
            $system = T5SystemGeneration::beltData( $sectorUID, $hex, $system );

         $map{ "_$hex" } = $system;
      }
   }

   return \%map;
}

##############################################################
#
#  Generates:
#     UWP
#     bases
#     mainworld type
#     hz variance
#     PBG
#     trade codes
#     mainworld satellites
#
##############################################################
sub basicData
{
   my $sectorUID = shift; # a sector's unique name, or its unique ID.
   my $hex       = shift; # hex of system
   my $tlCap     = shift || 34;
   my $civ       = shift;
   my $uwp       = shift || ''; # entire UWP line
   
   my $UID = "$sectorUID/$hex";
   t5srand( $UID );
   
   my @starport = qw/. . A A A B B C C D E E X/;
   my %navytn   = qw/A 6 B 5 C 0 D 0 E 0 X 0/;
   my %scouttn  = qw/A 4 B 5 C 6 D 7 E 0 X 0/;
   my @mwtype   = ( 0,0, 'Far Satellite', 'Far Satellite', 'Close Satellite', ('Planet') x 10 );
   my @hz       = qw/-2 -2 -1 -1 -1 0 0 0 0 0 +1 +1 +1 +2/;
   
   my %data;

   $data{ 'name' } = "world$hex";
   $data{ 'hex'  } = $hex;

   #
   #  This is for LEGACY data formats.  I mean OLD STUFF.
   #
   if ( $uwp =~ /^(\w.*)\d\d\d\d (.)(.)(.)(.)(.)(.)(.)-(.)\s+(N|A|B)?(S|A|W)? .* (A|R)?\s(\d)(\d)(\d)/ )
   {
      $data{ 'name' }          = $1;
      $data{ 'starport' }      = $2;
      $data{ 'siz' }    = $dehex{ $3 };
      $data{ 'atm' }    = $dehex{ $4 };
      $data{ 'hyd' }    = $dehex{ $5 };
      $data{ 'pop' }    = $dehex{ $6 };
      $data{ 'gov' }    = $dehex{ $7 };
      $data{ 'law' }    = $dehex{ $8 };
      $data{ 'tl' }     = $dehex{ $9 };
      $data{ 'naval base' }    = 1 if $10;
      $data{ 'scout base' }    = 1 if $11;
      $data{ 'zone' }           = $12;
      $data{ 'pop_mult'   }    = $13;
      $data{ 'belts' } = $14;
      $data{ 'ggs'   }    = $15;
   }
   else
   {
      my $name = Name2::name();
      $name = substr( $name, 0, 15 ) if length $name > 15;
      $data{ 'name' } = $name;

      # Page 432

      $data{ 'starport' }   = $starport[ rand2d() ];

      $data{ 'siz' } = rand2d()-2;
      $data{ 'siz' } = 9 + rand1d() if $data{ 'siz' } == 10;
      $data{ 'atm' } = flux() + $data{ 'siz' };
      $data{ 'atm' } = 0 if $data{ 'atm' } < 0 
                             || $data{ 'siz' } == 0;
      $data{ 'atm' } = bounded( $data{ 'atm' }, 0, 15 );
      $data{ 'hyd' } = bounded( flux() + $data{ 'siz' }, 0, 10 );
      $data{ 'pop' } = rand2d()-2;
      $data{ 'pop' } = 9 + rand1d() if $data{ 'pop' } == 10;
      $data{ 'gov' } = bounded( flux() + $data{ 'pop' }, 0, 15 );
      $data{ 'law' } = bounded( flux() + $data{ 'gov' }, 0, 18 );
      $data{ 'tl' } = bounded( UWP::techLevel( \%data, rand1d() ), 0, $tlCap );
 
      $data{ 'naval base' } = 1 if rand2d() < $navytn{ $data{ 'starport' } };
      $data{ 'scout base' } = 1 if rand2d() < $scouttn{ $data{ 'starport' } };      
      $data{ 'zone' } = '';

      $data{ 'pop_mult' } = 0;
      $data{ 'pop_mult' } = rand1d9() if $data{ 'pop' } > 0;

      $data{ 'belts' } = bounded( rand1d()-3, 0, 6 );
      $data{ 'ggs'	} = bounded( int(rand2d()/2-2), 0, 6 );
   }

   if ( $civ =~ /wild/i && $data{ 'pop' } < 7 )
   {
      $data{ 'pop' } = 0;
      $data{ 'pop_mult' }    = 0;
      $data{ 'gov' }  = 0;
      $data{ 'law' }   = 0;
      $data{ 'tl' }  = 0;

      $data{ 'starport' } = 'X';
      $data{ 'naval base' } = 0;
      $data{ 'scout base' } = 0;
   }

   $data{ 'name' } = uc $data{ 'name' } if $data{ 'pop' } >= 9;

   $data{ 'mainworld type' } = $mwtype[ rand2d() ]; #  => flux(),
   $data{ 'hz variance'	} = $hz[ rand2d() ]; # flux()

   #############################################################
   #
   # Page 437
   #
   #############################################################
   $data{ 'orbit' } = 3 + $data{ 'hz variance' }; 

   my $satellites = rand1d()-4;
   if ( $satellites == 0 )
   {
      $data{ 'ringed' } = 'ringed';
      $satellites = rand1d()-4;
   }

   for my $num (0..$satellites-1) # satellites
   {
      $data{ "satellite data" }->[ $num ] = hospitableSatellite( \%data );
   }


   return generateSummaries( \%data );
}

sub generateSummaries
{
   my $dataref = shift;
   my %data = %$dataref;

   my $uwp   = UWP::encodeUWP( \%data );

   my $bases = '  ';
   $bases = 'N ' if $data{ 'naval base' };
   $bases =~ s/ $/S/ if $data{ 'scout base' };
   $data{ '_bases' } = $bases;

   $data{ 'remarks' } = UWP::tradeCodes( $uwp, 
                                         $data{ 'hz variance' },
				 	 $data{ 'orbit' },
					 $data{ 'zone' }, 
					 $data{ 'mainworld type' } );

   $data{ '_uwp' } = sprintf( "%s %-15s $uwp $bases %-21s   %d%d%d", 
                              $data{ 'hex' },
                              $data{ 'name' }, 
                              $data{ 'remarks' }, 
                              $data{ 'pop_mult' }, 
                              $data{ 'belts' }, 
                              $data{ 'ggs' } );

   return \%data;
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
   my $dataref = shift;
   my %data = %$dataref;
   
   my $UID = "$sectorUID/$hex/ext";
   t5srand( $UID );

   my $importance = UWP::importance( \%data );
   my %ix =
   ( 
      'I'       => $importance,
      'traffic' => int( rand1d9() * (10 ** $importance) ),
   );
   $data{ 'ix' } = \%ix;
   
   my %ex;
   
   $ex{ 'R' } = rand2d();
   $ex{ 'R' } += $data{ 'ggs' } + $data{ 'belts' }
		if $data{ 'tl' } >= 8;
   
   $ex{ 'L' } = bounded( $data{ 'pop' } - 1, 0, 100 );
   $ex{ 'I' } = bounded( rand2d() + $data{ 'importance' }, 0, 20 );
   $ex{ 'I' } = rand1d() if $data{ 'remarks' } =~ / Ni /;
   $ex{ 'I' } = 0 if $data{ 'remarks' } =~ / Ba | Di | Lo /;
   $ex{ 'E' }     = flux();
   
   my $RU = ($ex{ 'R' } || 1)
          * ($ex{ 'L' } || 1)
          * ($ex{ 'I' } || 1)
          * ($ex{ 'E' } || 1);

   $ex{ 'RU' } = $RU;

   $data{ 'ex' } = \%ex;
   
   my %cx;
   
   $cx{ 'H' } = bounded( flux() + $data{ 'pop' }, 1, 100 );
   $cx{ 'A' } = bounded( $data{ 'pop' } + $data{ 'importance' }, 1, 100 );
   $cx{ 'S' } = bounded( 5 + flux(), 1, 20 );
   $cx{ 'Y' } = bounded( flux() + $data{ 'tl' }, 1, 100 );
    
   $data{ 'cx' } = \%cx;
   
   my $summary = $importance;
   $summary = '+' . $importance if $importance >= 0;
   $summary = "{$summary} (" . $ehex[ $ex{ 'R' } ]
                             . $ehex[ $ex{ 'L' } ] 
                             . $ehex[ $ex{ 'I' } ];
   $summary .= '+' if $ex{ 'E' } >= 0;
   $summary .= $ex{ 'E' } . ')';
   $summary .= ' [' . $ehex[ $cx{ 'H' } ]
                    . $ehex[ $cx{ 'A' } ]
                    . $ehex[ $cx{ 'S' } ]
                    . $ehex[ $cx{ 'Y' } ] 
                    . ']';
   $data{ 'extensions' } = $summary;

   return \%data;
}

##############################################################
#
#  Generates all stellar data
#
##############################################################
sub stellarData
{
   my $sectorUID = shift; # a sector's unique name, or its unique ID.
   my $hex       = shift; # hex of system
   my $dataref = shift;
   my %data = %$dataref;
   
   my $UID = "$sectorUID/$hex/stars";
   t5srand( $UID );
  #############################################################
  #
  # Page 436
  #
  #############################################################
    
    my $pfspec = flux() + 6; # flux table based on -6
    my $pfsize = flux() + 6; # flux table based on -6
    my $ps = $spectral[ $pfspec ];

    my $pri = 
	{ 
      'position' => 'primary',
		'spectral' => $ps,
		'spectral flux' => $pfspec,
		'size flux' => $pfsize,
	};
    $pri->{  'class'    } = $spectral{ $ps }->[ $pfsize ];
    $pri->{  'decimal'  } = '';
    $pri->{  'decimal'  } = rand1d10()-1 if $ps ne 'D';
    $pri->{  '_uwp'     } = Star::encodeStar( $pri );

    $data{ 'primary' } = $pri;
	
    $data{ 'hz' } = getHabitableZone( $data{ 'primary' } );

    $data{ 'primary companion' } = otherStar( \%data, $pfspec, $pfsize ) if flux() >= 3;
	
    $data{ 'close star' } = otherStar( \%data, $pfspec, $pfsize, -1 ) if flux() >= 3;
    $data{ 'close companion' } = otherStar( \%data, $pfspec, $pfsize ) 
	                                 if  $data{ 'close star' }  
	                                 && ($data{ 'close star' }->{ 'spectral' } ne 'BD' )
					 && (flux() >= 3);
		
    $data{ 'near star' } = otherStar(  \%data, $pfspec, $pfsize, 5 ) if flux() >= 3;
    $data{ 'near companion' } = otherStar( \%data, $pfspec, $pfsize )
	                                 if  $data{ 'near star' }  
	                                 && ($data{ 'near star' }->{ 'spectral' } ne 'BD' )
					 && (flux() >= 3);

    $data{ 'far star' } = otherStar( \%data, $pfspec, $pfsize, 11 ) if flux() >= 3;
    $data{ 'far companion' } = otherStar( \%data, $pfspec, $pfsize )
	                                 if  $data{ 'far star' }  
	                                 && ($data{ 'far star' }->{ 'spectral' } ne 'BD' )
					 && (flux() >= 3);

  my @summary = ( $ps . $pri->{ 'decimal' }, $pri->{ 'class' } );

  for my $key ( 'primary companion', 'close star', 'close companion', 
                                     'near star', 'near companion', 
                                     'far star', 'far companion' )
  {
     my $unit = $data{ $key };
     next unless $unit;
     my $orbit = '';
     $orbit = $unit->{ 'orbit' } . ':' if $unit->{ 'orbit' }; 
     push @summary, $orbit . $unit->{ 'spectral' } . $unit->{ 'decimal' };
     push @summary, $unit->{ 'class' } if $unit->{ 'class' };
  }

  $data{ '_stellar' } = join ' ', @summary;

  return generateSummaries( \%data );
}

sub getStars
{
   my $sys = shift;
   my %data = %$sys;
   my @out;

   foreach my $key ( 'primary', 'close star', 'near star', 'far star' )
   {
      #print "[", $data{ $key }->{ '_uwp' }, "]\n" if $data{ $key };
      push @out, $data{ $key } if $data{ $key };
   }
   return @out;
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
   for (1..$system->{ 'belts' })
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
      $beltref->{ '_uwp' } = UWP::encodeUWP( $beltref ) . "    Belt";

      push @belts, $beltref;
   }
   $system->{ 'belt data' } = \@belts;
   return $system;
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
   for my $ggNum (1..$system->{ 'ggs' })
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
  
      $ggref->{ '_uwp' } = UWP::encodeGG( $ggref );
      
      push @gg, $ggref;
   }

   $system->{ 'gas giant data' } = \@gg;

   return $system;
}

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
#  Works for secondary stars and companion stars
# 
#  page 436
#
###############################################################################
sub otherStar
{
   my $data     = shift;
   my $specflux = shift;
   my $sizeflux = shift;
   my $orbitDM  = shift || undef;
   
   my $sp = $spectral[ $specflux + rand1d() - 1 ] || 'BD';
   my $star =
   {
      spectral  => $sp,
      decimal   => '',
      orbit     => '',
   };  

   if ( $orbitDM ) # i.e. not a companion star
   {
      $star->{ orbit } = rand1d() + $orbitDM;
      $star->{ hz } = -1;
      $star->{ hz } = getHabitableZone( $star ) if $sp ne 'BD';
   }

   if ( $sp ne 'BD' )
   {
      $star->{ 'siz' } = $spectral{ $sp }->[ $sizeflux + rand1d() + 2 ] || '';
      $star->{ 'decimal' } = rand1d10() - 1 if $star->{ 'siz' } ne 'D';
   }

   $star->{ '_uwp' } = Star::encodeStar( $star );

   return $star;
}

#########################################################
#
#  Generates a moon of a world in the habitable zone.
#
#########################################################
sub hospitableSatellite
{
   my $mainworld = shift;
   my $d6 = rand1d();

#  
#  Determine orbit number, please
#
   my $orbit = rand1d();
   if ( $orbit <= 3 )
   {
      $orbit = $moonOrbit1[ rand2d() ];
   }
   else
   {
      $orbit = $moonOrbit2[ rand2d() ];
   }

=pod
   my $size = 0;
   $size = rand1d() - 3 if $d6 <= 2;
   $size = rand2d()     if $d6 >= 3;
   $size -= 2           if $d6 == 4; # hospitable
=cut
   my $size = flux();

   $size = $mainworld->{ 'siz' }-3 if $size >= $mainworld->{ 'siz' };
   $size = 0 if $size < 0;

   my $atm = flux() + $size;
   $atm += 4 if $d6 == 5; # stormworld
   $atm = bounded( $atm, 0, 15 );
   $atm = 0 if $size == 0;

   my $hyd = flux() + $size;
   $hyd -= 4 if $d6 == 5; # stormworld
   $hyd = bounded( $hyd, 0, 10 );
   $hyd = 0 if $size == 0;

   my $pop = rand2d() - 2;
   $pop -= 6 if $d6 == 5; # stormworld
   $pop = bounded( $pop, 0, $mainworld->{ 'pop' }-1 );
   $pop = 0 if $d6 == 3; # inferno
   $pop = 0 if $d6 == 6; # radworld
   $pop = 0 if $mainworld->{ 'tl' } <= 7;

   my $gov = bounded( flux() + $pop, 0, 15 );
   $gov = 0 if $pop == 0;

   my $law = bounded( flux() + $gov, 0, 18 );
   $law = 0 if $pop == 0;

   my $starport = spaceport( $pop );
    
   my $sat = 
   {
      'orbit' => $orbit,
      'starport' => $starport,
      'siz' => $size,
      'atm' => $atm,
      'hyd' => $hyd,
      'pop' => $pop,
      'gov' => $gov,
      'law' => $law
   };

   $sat->{ 'tl' } = UWP::techLevel( $sat, rand1d() );

   my $s = $ehex[ $size ];

   my $uwp = UWP::encodeUWP( $sat );

   $uwp = "$uwp    As"         if $size == 0;
   $uwp = "$uwp    Worldlet"   if $d6 <= 2;
   $uwp = "$uwp    Inferno moon"    if $d6 == 3;
   $uwp = "$uwp    'Hospitable'" if $d6 == 4;
   $uwp = "$uwp    Stormworld" if $d6 == 5;
   $uwp = "$uwp    Radworld"   if $d6 == 6;

   $sat->{ '_uwp' } = $uwp;

   return $sat;
}

sub spaceport
{
   my $pop = shift;
   my $s = bounded( $pop - rand1d(), 0, 15 );
   my $spaceport = 'Y';
   $spaceport = 'H' if $s == 3; # 3
   $spaceport = 'G' if $s >= 4; # 4 and 5
   $spaceport = 'F' if $s >= 6; # 6 and up
   return $spaceport;
}

sub getHabitableZone
{
   my $primaryref = shift;
   my $spectral = $primaryref->{ 'spectral' };
   my $decimal  = $primaryref->{ 'decimal' };
   my $size     = $primaryref->{ 'siz' };
   my $sd       = $spectral . $decimal;

   my $hz = 0;
   foreach my $zone (keys %habitableZoneOrbit)
   {
      next unless $zone =~ /$sd/;
      my $orbitref = $habitableZoneOrbit{ $zone };
      my $starSizeIndex = $starSizeIndex{ $size };
      $hz = $orbitref->[ $starSizeIndex ];
      last;
   }
   #print "HZ=$hz\n";
   return $hz;
}

sub innerZone
{
   my $dm = shift;
   my $roll = rand1d() + $dm;

   return worldlet()   if $roll == 1;
   return worldlet()   if $roll == 2;
   return inferno()    if $roll == 3;
   return innerworld() if $roll == 4;
   return stormworld() if $roll == 5;
   return radworld()   if $roll == 6;
   return bigworld()   if $roll == 7;
}

sub hospitableZone
{
   my $dm = shift;
   my $roll = rand1d() + $dm;

   return worldlet()   if $roll == 1;
   return worldlet()   if $roll == 2;
   return inferno()    if $roll == 3;
   return hospitable() if $roll == 4;
   return stormworld() if $roll == 5;
   return radworld()   if $roll == 6;
   return bigworld()   if $roll == 7;
}

sub outerZone
{
   my $dm = shift;
   my $roll = rand1d() + $dm;

   return worldlet()   if $roll == 1;
   return worldlet()   if $roll == 2;
   return iceworld()   if $roll == 3;
   return iceworld()   if $roll == 4;
   return stormworld() if $roll == 5;
   return radworld()   if $roll == 6;
   return bigworld()   if $roll == 7;
}

sub worldlet
{
}

sub iceworld
{
}

sub inferno
{
}

sub hospitable
{
}

sub innerworld
{
}

sub stormworld
{
}

sub radworld
{
}

sub bigworld
{
}


=pod
###############################################################
#
#  generate rockball worlds
#
###############################################################
sub otherWorld
{
   my $system    = shift;
   my $last      = shift || 0; # last world in system
   my $rawSize   = shift || rand2d();
   my $atmDM     = shift || 0;
   my $hydDM     = shift || 0;
   my $popDM     = shift || 0;

   my $size = bounded( rand1d() - 3, 0, 12 );
   $size = bounded( $system->{ 'siz' }-3, 0, 12 ) if $size >= $system->{ 'siz' };
   my $atm = bounded( flux() + $size, 0, 15 );
   my $hyd = bounded( flux() + $size, 0, 10 );
   my $pop = bounded( rand2d()-2, 0, $system->{ 'pop' }-1 );
   
   my $spaceport = spaceport( $pop );

   my $gov = bounded( flux() + $pop, 0, 15 );
   my $law = bounded( flux() + $gov, 0, 18 );   

   my $orbit = $worldOrbit1[ rand2d() ] unless $last;
   $orbit = $worldOrbit1[ rand2d() ] if $last;

   my $hz = $system->{ 'hz' };
   my $worldType = rand1d();
   if ( $orbit < $hz )     # inner
   {
   }
   elsif ( $orbit == $hz ) # hospitable
   {
   }
   else #     $orbit > $hz => outer
   {
   }
}
=cut

1;

