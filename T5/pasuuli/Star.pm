package Star;
use Jenkins2rSmallPRNG qw/t5srand flux rand1d rand2d rand1d10/;
use strict;

=pod

  SSSSSS  TTTTTTTT    AA    RRRRRRR 
 SS     S    TT      AAAA    RR   RR
 SS          TT     AA  AA   RR   RR
   SS        TT    AA    AA  RRRRR  
     SS      TT    AAAAAAAA  RR  RR 
       SS    TT    AA    AA  RR   RR
 S     SS    TT    AA    AA  RR   RR
  SSSSSS     TT    AA    AA RRR   RR

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
#  Given a star structure, return the habitable zone.
#
###############################################################################
sub getHabitableZone
{
   my $primaryref = shift;
   my $spectral   = $primaryref->{ 'spectral' };
   my $decimal    = $primaryref->{ 'decimal' };
   my $class      = $primaryref->{ 'class' };
   my $sd         = $spectral . $decimal;

   my $hz = 0;
   foreach my $zone (keys %habitableZoneOrbit)
   {
      next unless $zone =~ /$sd/;
      my $orbitref = $habitableZoneOrbit{ $zone };
      my $starClassIndex = $starSizeIndex{ $class };
      $hz = $orbitref->[ $starClassIndex ];
      last;
   }
   return $hz;
}


###############################################################################
#
#  Given a star mass and orbital radius, calculate rotational period, in days.
#
###############################################################################
sub rotationalPeriod
{
   my $primaryMass   = shift; # Sols
   my $orbitalRadius = shift; # AU

   my $hours   = 4 * (rand2d() - 2)
                 + 5 + ($primaryMass / $orbitalRadius );

   my $days    = $hours/24;

   return $days;
}

###############################################################################
#
#  Given a star mass and orbital radius, calculate orbital period, in days.
#
###############################################################################
sub orbitalPeriod # requires parsing Primary.  That's all.
{
   my $primaryMass   = shift;   # Sols
   my $orbitalRadius = shift;   # AU
   my $r3            = $orbitalRadius ** 3;

   return int( 365.25 * sqrt($r3/$primaryMass) );

   #
   #  TODO Re-figure Zone...
   #
}

###############################################################################
#
#  Generates new stellar data for a given hex.
#
###############################################################################
sub buildStars
{
   my $sectorUID = shift; # a sector's unique name, or its unique ID.
   my $hex       = shift; # hex of system

   my %data;

   my $UID = "$sectorUID/$hex-stars";
   t5srand( $UID );

  #############################################################
  #
  # Page 436
  #
  #############################################################

    my $pfspec = flux() + 6; # flux table based on -6
    my $pfclass = flux() + 6; # flux table based on -6
    my $ps = $spectral[ $pfspec ];

    my $pri_tmp = {};

	$pri_tmp->{  'spectral' } = $ps;
    $pri_tmp->{  'class'    } = $spectral{ $ps }->[ $pfclass ];
    $pri_tmp->{  'decimal'  } = '';
    $pri_tmp->{  'decimal'  } = rand1d10()-1 if $ps ne 'D';
    my $usp = encodeStar( $pri_tmp );
	
	#################################################
	#
	#          Now get some hard data.
	#
	my $pri = parsePrimary( $usp );
	#
	#
	#################################################
    $pri->{ 'position' }      = 'primary';
	$pri->{ 'spectral flux' } = $pfspec;
	$pri->{ 'class flux' }    = $pfclass;
    $pri->{ 'spectral' }      = $ps;
	$pri->{ 'class'    }      = $pri_tmp->{ 'class' };
	$pri->{ 'decimal'   }     = $pri_tmp->{ 'decimal' };

    $data{ 'primary' } = $pri;

    $data{ 'hz' } = getHabitableZone( $data{ 'primary' } );

    $data{ 'primary companion' } = otherStar( \%data, $pfspec, $pfclass ) if flux() >= 3;

    $data{ 'close star' } = otherStar( \%data, $pfspec, $pfclass, -1 ) if flux() >= 3;
    $data{ 'close companion' } = otherStar( \%data, $pfspec, $pfclass )
                                         if  $data{ 'close star' }
                                         && ($data{ 'close star' }->{ 'spectral' } ne 'BD' )
                                         && (flux() >= 3);

    $data{ 'near star' } = otherStar(  \%data, $pfspec, $pfclass, 5 ) if flux() >= 3;
    $data{ 'near companion' } = otherStar( \%data, $pfspec, $pfclass )
                                         if  $data{ 'near star' }
                                         && ($data{ 'near star' }->{ 'spectral' } ne 'BD' )
                                         && (flux() >= 3);

    $data{ 'far star' } = otherStar( \%data, $pfspec, $pfclass, 11 ) if flux() >= 3;
    $data{ 'far companion' } = otherStar( \%data, $pfspec, $pfclass )
                                         if  $data{ 'far star' }
                                         && ($data{ 'far star' }->{ 'spectral' } ne 'BD' )
                                         && (flux() >= 3);


#	print STDERR "[$ps]", '[', $pri->{ 'decimal' }, '][', $pri->{ 'class' }, "]\n";
	
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

  $data{ 'stellar' } = join ' ', @summary;

  return \%data;
}

###############################################################################
#
#  Creates a star profile [orbit:] Spectral Decimal  -  Class
#
###############################################################################
sub encodeStar
{
   my $star = shift;
   my $usp  = '';

   $usp .= $star->{ 'orbit' } . ':'        if $star->{ 'orbit' };
#   $usp .= '  '                            unless $star->{ 'orbit' };
   $usp .= $star->{ 'spectral' };
   $usp .= $star->{ 'decimal' }            if defined $star->{ 'decimal' };
   $usp .= ' ' . $star->{ 'class' }        if $star->{ 'class' };
   $usp .= ' (hz:' . $star->{ 'hz' } . ')' if $star->{ 'hz' } && $star->{ 'hz' } > -1;

   return $usp;
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
   my $classflux = shift;
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
      $star->{ 'class' } = $spectral{ $sp }->[ $classflux + rand1d() + 2 ] || '';
      $star->{ 'decimal' } = rand1d10() - 1 if $star->{ 'class' } ne 'D';
   }

   $star->{ 'usp' } = encodeStar( $star );
   
   if ( $orbitDM == 11 && $sp ne 'BD' ) # far star, generate all data
   {
      my $far = parsePrimary( $star->{ 'usp' } );
	  $far->{ 'spectral' } = $star->{ 'spectral' };
	  $far->{ 'decimal'  } = $star->{ 'decimal'  };
	  $far->{ 'orbit'    } = $star->{ 'orbit'    };
	  $far->{ 'class'    } = $star->{ 'class'    };
	  $far->{ 'usp'      } = $star->{ 'usp'      };
	  
	  $star = $far;
   }

   return $star;
}


###############################################################################
#
#  Builds the following data structure:
#
#  $primary->
#     class (e.g. 'G0 V')
#     luminosity
#     siz
#     mass
#     innerZone
#     habZone
#     midZone
#     outerZone
#     edgeZone
#     idealOrbit
#     midHabOrbit
#
###############################################################################
sub parsePrimary
{
   my $star = shift || 'G0 V'; 

   $star =~ s/^(\w+ \w+).*$/$1/; # remove extra stars for now

   my $primary = 
   {
      usp      => $1,
      siz      => 0,  # diameter
      mass     => 1,  # for now
   };

   $primary->{ siz } = 0.02 if $primary =~ /A|F/
                            || $primary =~ /(G|K)\s*IV/;

   if ( $star =~ /I|II|III/ )
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
      $primary->{ 'luminosity' } = $l;

      my $radius;
      $radius = 0.20 if $flux == -5;
      $radius = 0.10 if $flux == -4;
      $radius = 0.10 if $flux == -3;
      $radius = 0.09 if $flux == -2;
      $radius = 0.24 if $flux == -1;
      $radius = 0.37 if $flux == +0;
      $radius = 0.92 if $flux == +1;
      $radius = 0.06 if $flux == +2;
      $radius = 0.50 if $flux == +3;
      $radius = 0.64 if $flux == +4;
      $radius = 17   if $flux == +5;
      $primary->{ 'siz' } = $radius * 2;

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
      $primary->{ 'mass' } = $m;
   }

   if ( $star =~ /O|B/ )
   {
      my $roll = rand1d();

      $primary->{ 'luminosity' } = sqrt( 10_000_000 ) if $roll == 1;
      $primary->{ 'luminosity' } = sqrt( 100_000 ) if $roll == 2;
      $primary->{ 'luminosity' } = sqrt( 16_000 ) if $roll == 3;
      $primary->{ 'luminosity' } = sqrt( 8_300 ) if $roll == 4;
      $primary->{ 'luminosity' } = sqrt( 750 ) if $roll == 5;
      $primary->{ 'luminosity' } = sqrt( 130 ) if $roll == 6;

      $primary->{ 'siz' } = 0.60 * 2 if $roll == 1;
      $primary->{ 'siz' } = 0.10 * 2 if $roll == 2;
      $primary->{ 'siz' } = 0.03 * 2 if $roll == 3;
      $primary->{ 'siz' } = 0.02 * 2 if $roll == 4;
      $primary->{ 'siz' } = 0.02 * 2 if $roll == 5;
      $primary->{ 'siz' } = 0.01 * 2 if $roll == 6;

      $primary->{ 'mass' } = 60 if $roll == 1;
      $primary->{ 'mass' } = 20 if $roll == 2;
      $primary->{ 'mass' } = 16 if $roll == 3;
      $primary->{ 'mass' } = 10.5 if $roll == 4;
      $primary->{ 'mass' } = 5.4 if $roll == 5;
      $primary->{ 'mass' } = 3.5 if $roll == 6;
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

      # These don't really exist.
      'A6 IV' => [ sqrt(27),    3.7 ],
      'A7 IV' => [ sqrt(27),    3.7 ],
      'A8 IV' => [ sqrt(27),    3.7 ],
      'A9 IV' => [ sqrt(27),    3.7 ],

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

   $primary->{ 'luminosity' } = $map{ $star }->[0] if $map{ $star };
   $primary->{ 'mass'       } = $map{ $star }->[1] if $map{ $star };

   print "Unknown star: [$star]\n" unless $primary->{ 'luminosity' } && $primary->{ 'mass' };

   $primary->{ 'siz' } = sprintf "%.1f", $primary->{ 'siz' };
   $primary->{ 'luminosity' } = sprintf "%.2f", $primary->{ 'luminosity' };

   #
   #  Zones
   #

   my $R  = $primary->{ 'siz' } || 0;
   my $sL = $primary->{ 'luminosity' } || 1;

   $primary->{ 'innerZone' } = sprintf "%.02f", $R + 0.0111 * $sL;            # inner edge
   $primary->{ 'habZone'   } = sprintf "%.02f", $R + 0.95 * $sL;              # inner edge
   $primary->{ 'midZone'   } = sprintf "%.02f", $R + 1.35 * $sL;              # inner edge
   $primary->{ 'outerZone' } = sprintf "%.02f", 2.7 * $sL + (flux()-1)/5.0;   # inner edge = snowline
   $primary->{ 'edgeZone'  } = sprintf "%.02f", 30 * $sL + flux();            # outer edge of OZ
   $primary->{ 'idealOrbit' } = sprintf "%.02f", 0.8 + rand1d()/10 * $sL;
   $primary->{ 'midHabOrbit' } = sprintf "%.1f", $R + (1.0 + rand1d()/20) * $sL; # comfortably inside the hab zone

   return $primary
}

1; # return 1 as all good Perl modules should
