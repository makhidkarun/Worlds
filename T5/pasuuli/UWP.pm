package UWP;
use Jenkins2rSmallPRNG qw/t5srand flux rand1d rand2d rand1d9 rand1d10/;
use Name2;
use strict;
use Data::Dumper;
$Data::Dumper::Pair   = ": ";
$Data::Dumper::Terse  = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Useqq  = 1;

=pod

@@@  @@@  @@@  @@@  @@@  @@@@@@@              @@@@@@@   @@@@@@    @@@@@@   @@@        @@@@@@   
@@@  @@@  @@@  @@@  @@@  @@@@@@@@             @@@@@@@  @@@@@@@@  @@@@@@@@  @@@       @@@@@@@   
@@!  @@@  @@!  @@!  @@!  @@!  @@@               @@!    @@!  @@@  @@!  @@@  @@!       !@@       
!@!  @!@  !@!  !@!  !@!  !@!  @!@               !@!    !@!  @!@  !@!  @!@  !@!       !@!       
@!@  !@!  @!!  !!@  @!@  @!@@!@!   @!@!@!@!@    @!!    @!@  !@!  @!@  !@!  @!!       !!@@!!    
!@!  !!!  !@!  !!!  !@!  !!@!!!    !!!@!@!!!    !!!    !@!  !!!  !@!  !!!  !!!        !!@!!!   
!!:  !!!  !!:  !!:  !!:  !!:                    !!:    !!:  !!!  !!:  !!!  !!:            !:!  
:!:  !:!  :!:  :!:  :!:  :!:                    :!:    :!:  !:!  :!:  !:!   :!:          !:!   
::::: ::   :::: :: :::    ::                     ::    ::::: ::  ::::: ::   :: ::::  :::: ::   
 : :  :     :: :  : :     :                      :      : :  :    : :  :   : :: : :  :: : :    

=cut

my @ehex = (0..9, 'A'..'H', 'J'..'N', 'P'..'Z');
my %hex2dec = qw/ 0  0  1  1  2  2  3  3  4  4  5  5  6  6  7  7  8  8  9  9  A  10 10 10
                  B  11 11 11 C  12 12 12 D  13 13 13 E  14 14 14 F  15 15 15 G  16 16 16
                  H  17 17 17 J  18 18 18 K  19 19 19 L  20 20 20 M  21 21 21 N  22 22 22
                  P  23 23 23 Q  24 24 24 R  25 25 25 S  26 26 26 T  27 27 27 U  28 28 28 
                  V  29 29 29 W  30 30 30 X  31 31 31 Y  32 32 32 Z  33 33 33
                /;

my @starport = qw/. . A A A B B C C D E E X/;
my %navytn   = qw/A 6 B 5 C 0 D 0 E 0 X 0/;
my %scouttn  = qw/A 4 B 5 C 6 D 7 E 0 X 0/;

###############################################################################
sub T5ssHeader
{
   return<<EOHDR;
Hex  Name                 UWP       Remarks                             {Ix}   (Ex)    [Cx]   N    B   Z PBG W  A    Stellar       
---- -------------------- --------- ----------------------------------- ------ ------- ------ ---- --- - --- -- ---- --------------
EOHDR
}
###############################################################################
sub flux
{
   return int(rand(6))-int(rand(6));
}

sub toT5ss
{
   my $world = shift;
   my $remarks = $world->{ 'trade_codes' } . ' ';
   $remarks .= $world->{ 'remarks' };

   return sprintf "%-4s %-20s %s %-35s {%-4s} (%-5s) [%-4s] %-4s %-3s %1s %-3s %-2s %-4s %-15s\n",
	$world->{ 'hex' },
	$world->{ 'name' },
	$world->{ 'uwp' },
	$remarks,
	$world->{ 'Ix' },
   $world->{ 'Ex' },
	$world->{ 'Cx' },
	$world->{ 'nobility' },
	$world->{ 'bases' } || '-',
	$world->{ 'zone' },
	$world->{ 'pop_mult' } . $world->{ 'belts' } . $world->{ 'ggs' },
	$world->{ 'worlds' },
	$world->{ 'allegiance' },
	$world->{ 'stellar' };
}

sub MWOnly 
{
   my $world   = shift;
   my $hex     = $world->{ 'hex' };
   my $name    = $world->{ 'name' };
   my $uwp     = $world->{ 'uwp' };
	my $remarks = $world->{ 'trade_codes' } . ' ' . $world->{ 'remarks' };
   my $ix      = $world->{ 'Ix' };
   my $ex      = $world->{ 'Ex' };
	my $cx      = $world->{ 'Cx' };
	my $n       = $world->{ 'nobility' };
	my $bases   = $world->{ 'bases' };
	my $zone     = $world->{ 'zone' };
	my $pm      = $world->{ 'pop_mult' };
	my $alleg   = $world->{ 'allegiance' };

   return<<EOMW;
   $hex:
      name:       $name
      uwp:        $uwp
      remarks:    $remarks
      Ix:         $ix
      Ex:         $ex
      Cx:         $cx
      nobility:   $n
      bases:      $bases
      zone:       $zone
      pop_mult:   $pm
      allegiance: $alleg

EOMW
}

sub SysOnly
{
   my $world = shift;
   my $hex   = $world->{ 'hex' };
   my $belts = $world->{ 'belts' };
   my $ggs   = $world->{ 'ggs' };
   my $wc    = $world->{ 'worlds' };
   my $star  = $world->{ 'stellar' };

   return <<EOSYS;
   $hex:
      belts:  $belts
      ggs:    $ggs
      worlds: $wc
      stars:  $star

EOSYS
}

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
#  Generates a fresh UWP.
#
###############################################################################
sub create
{
   my $sectorUID = shift || ''; # a sector's unique name, or its unique ID.
   my $hex       = shift || '0000'; # hex of system
   my $tag       = shift || 'main';
   my $tlCap     = shift || 21;
   
   my $UID = "$sectorUID/$hex-$tag";
   t5srand( $UID );

   my $name = Name2::name();
      $name = substr( $name, 0, 15 ) if length $name > 15;

   my $world = 
   {
          worldname => $name,
	  name => $name,
	  hex  => $hex,
   };

   # Page 432

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
   
   $world->{ 'siz' } = $siz;
   $world->{ 'atm' } = $atm;
   $world->{ 'hyd' } = $hyd;
   $world->{ 'pop' } = $pop;
   $world->{ 'gov' } = $gov;
   $world->{ 'law' } = bounded( flux() + $gov, 0, 18 );
   $world->{ 'tl'  } = bounded( techLevel( $world, rand1d() ), 0, $tlCap );
   
   $world->{ 'naval base' } = 1 if rand2d() < $navytn{ $world->{ 'starport' } };
   $world->{ 'scout base' } = 1 if rand2d() < $scouttn{ $world->{ 'starport' } };
   $world->{ 'zone' } = '';

   $world->{ 'pop_mult' } = 0;
   $world->{ 'pop_mult' } = rand1d9() if $pop > 0;
   $world->{ 'belts' } = bounded( rand1d()-3, 0, 6 );
   $world->{ 'ggs'   } = bounded( int(rand2d()/2-2), 0, 6 );
   $world->{ 'pbg'   } = $world->{ 'pop_mult' } . $world->{ 'belts' } . $world->{ 'ggs' };

   $world->{ 'uwp'   } = encodeUWP( $world );
   $world->{ 'bases' } = ' ';
   $world->{ 'bases' } = 'N' if $world->{ 'naval base' };
   $world->{ 'bases' } .= 'S' if $world->{ 'scout base' };
   
   $world->{ 'trade_codes' } = tradeCodes( $world->{ 'uwp' } );
   isHospitableOrNot($world);
   
   importance( $world );
   
   $world->{ 'descriptions' }->{ 'starport' } = describeStarport( $world->{ 'starport' } );
   $world->{ 'descriptions' }->{ 'siz' } = describeSiz( $siz );
   $world->{ 'descriptions' }->{ 'atm' } = describeAtm( $atm );
   $world->{ 'descriptions' }->{ 'hyd' } = describeHyd( $hyd );
   $world->{ 'descriptions' }->{ 'pop' } = describePop( $pop );
   $world->{ 'descriptions' }->{ 'gov' } = describeGov( $gov );
   $world->{ 'descriptions' }->{ 'law' } = describeLaw( $world->{ 'law' } );
   $world->{ 'descriptions' }->{ 'tl' } = describeTL( $world->{ 'tl' } );
#   $world->{ 'descriptions' }->{ 'world' } = World::describeWorld( $world );
   
   return $world;
}

sub rerollGovAndLaw
{
   my $world = shift;

   $world->{ 'gov' } = 0;
   $world->{ 'law' } = 0;

   return if $world->{ 'pop' } == 0;
   $world->{ 'gov' } = bounded( flux() + $world->{ 'pop' }, 0, 15 );
   $world->{ 'law' } = bounded( flux() + $world->{ 'gov' }, 0, 18 );
}
	  
###############################################################################
#
#  Parsing UWP data (SSAHPGL-T)
#
#  $world is a target hashref for holding world data.
#  $uwp contains ONLY the UWP string. 
#
###############################################################################
sub decodeUWP
{
   my $world = shift;
   my $uwp   = shift;

   $uwp =~ /\b([ABCDEFGHXY])(\w)(\w)(\w)(\w)(\w)(\w)-(\w)\b/;

   $world->{ 'uwp' }      = $uwp;
   $world->{ 'starport' } = $1;
   $world->{ 'siz' }      = $hex2dec{$2};
   $world->{ 'atm' }      = $hex2dec{$3};
   $world->{ 'hyd' }      = $hex2dec{$4};
   $world->{ 'pop' }      = $hex2dec{$5};
   $world->{ 'gov' }      = $hex2dec{$6};
   $world->{ 'law' }      = $hex2dec{$7};
   $world->{ 'tl'  }      = $hex2dec{$8};

   t5srand($world->{ 'uwp' });
}

sub encodeUWP
{
   my $world = shift;
   my $uwp = $world->{ 'starport' }
           . $ehex[ $world->{ 'siz' } ]
                   . $ehex[ $world->{ 'atm' } ]
                   . $ehex[ $world->{ 'hyd' } ]
                   . $ehex[ $world->{ 'pop' } ]
                   . $ehex[ $world->{ 'gov' } ]
                   . $ehex[ $world->{ 'law' } ]
                   . '-'
                   . $ehex[ $world->{ 'tl' } ];

   return $uwp;
}
###############################################################################
#
#  Parsing PBG 
#
#  $world is a target hashref for holding data.
#
###############################################################################
sub parsePBG
{
   my $world = shift;
   my $pbg   = shift;

   ($world->{ 'pop_mult'}, 
    $world->{ 'belts'   },
    $world->{ 'ggs'     }) = split '', $pbg;
}

sub encodePBG
{
   my $world = shift;
   return $world->{ 'pop_mult'} . $world->{ 'belts' } . $world->{ 'ggs' };
}

#################################################################################
#
#  This requires the input line to be in CANONICAL T5SS FORMAT:
#
#   hex (4 digits)
#   name (at least 15 chars) - includes spaces
#   UWP  
#   remarks (at least 15 chars) - includes spaces
#   Ix.  If empty, then just bare braces: {}
#   Ex.  If empty, then just bare parens: ()
#   Cx.  If empty, then just bare brackets: []
#   N    If empty, then just a dash
#   B    If empty, then just a dash
#   Z    If empty, then just a dash
#   PBG  3 digits
#   W    1 or 2 digits
#   A    2 or 4 characters.  If empty, then just a dash
#   Stellar: characters to end of line
#
#  Each field is space-delimited.
#
#################################################################################
sub decodeUWPline
{
   my $line  = shift;
   my $world = {};

   $line =~ m/^(\d\d\d\d) (\w.*?) ([ABCDEFGHXY]\S\S\S\S\S\S-\S) (.*?)\{/; # everything up to Ix

   $world->{ 'hex'  } = $1;
   $world->{ 'name' } = $2;
   $world->{ 'uwp'  } = $3;

   my $comments = $4;
   $world->{ 'remarks' } = findNonComputableRemarks( $comments );

   decodeUWP( $world, $world->{ 'uwp' });
   
   t5srand( $world->{ 'hex' } . $world->{ 'name' } . $world->{ 'uwp' } ); # why not

   ($world->{ 'ix' }->{ 'importance'} ) = $line =~ m/\{(.*?)\}/; # importance
   ($world->{ 'Ex' }) = $line =~ m/\}\s*\((.*?)\)/; # Economic Ext comes after Importance
   ($world->{ 'Cx' }) = $line =~ m/\[(.*?)\]/; # Cultural Ext

   $world->{ 'Ix' } = '{' . $world->{ 'ix' }->{ 'importance' } . '}';
   $world->{ 'naval base' } = 0;
   $world->{ 'scout base' } = 0;

   if ( $line =~ /(\].*)$/ ) # starting from the end of the Cx.
   {
      my @chunks = split /\s+/, $1;

      #print join ", ", @chunks;

      $world->{ 'nobility' }        = $chunks[1];
      $world->{ 'bases' }         = $chunks[2];
      $world->{ 'naval base'}     = 1 if $chunks[2] =~ /ND/;
      $world->{ 'scout base'}     = 1 if $chunks[2] =~ /S/;
      $world->{ 'way station'}    = 1 if $chunks[2] =~ /W/;
      $world->{ 'zone' }          = $chunks[3];
      $world->{ 'pop_mult'   }    = $1 if $chunks[4] =~ /^(.)../;
      $world->{ 'belts' }         = $1 if $chunks[4] =~ /^.(.)./;
      $world->{ 'ggs'   }         = $1 if $chunks[4] =~ /^..(.)/;
      $world->{ 'worlds' }        = $chunks[5];
      $world->{ 'allegiance' }    = $chunks[6];
      $world->{ 'stellar' }       = join ' ', @chunks[7..12]; # if there are that many...

      #foreach (qw/nobility zone belts ggs worlds/)
      #{
      #   print "   $_: ", $world->{$_}, "\n";
      #}
   }

   # calculate the TL mods
   $world->{ '_tl_mods' } = techLevel($world);

   # and now calculate the TL die roll from that
   $world->{ '_tl_die_roll' } = $world->{ 'tl' } - $world->{ '_tl_mods' };

   # redo the trade codes.  Just do it.
   $world->{ 'trade_codes' } = tradeCodes( $world->{ 'uwp' } );

   # is this world "hospitable"?
   isHospitableOrNot($world);

   return $world;
}

sub findNonComputableRemarks
{
   my $remarks = shift;
   for (qw/Ag As Ba Cy Da De Di Fl Fo Ga He Hi Ic In Lo Na Ni Oc Pa Ph Pi Po Pr Px Pz Re Ri Va Wa/)
   {
      $remarks =~ s/$_\s?\b//;
   }
   #$remarks =~ s/O:\d+\s*//g;          # old data
   $remarks =~ s/^\s*//g;
   $remarks =~ s/\s*$//g;
   return $remarks;
}

###############################################################################
#
#  Various encoders.
#
###############################################################################
sub encodeGG
{
   my $gg = shift;
   my $uwp = $gg->{ 'starport' }
           . $gg->{ 'code' }
           . $ehex[ $gg->{ 'size' } ]
           . ':'
           . $ehex[ $gg->{ 'satellites' } ]
           ;

   $uwp .= 'R' if $gg->{ 'ringed' } =~ /r/i;

   return $uwp;
}

###############################################################################
#
#   Rebuild Trade Codes.
#
###############################################################################
sub tradeCodes
{
   my $uwp   = shift;
   my $zone  = shift;
   my $mainworldType = shift;
   my $hz    = shift || 0; # i.e. in the HZ
   my $orbit = shift || 3; # safe guess

   print STDERR "** ERROR ** tradeCodes() requires a UWP, not a worldref!\n" unless $uwp =~ /\w{6}-\w/;

   my @codes;
   push @codes, 'Ag' if $uwp =~ /..[4-9][4-8][5-7]..-./;
   push @codes, 'As' if $uwp =~ /.000...-./;
   push @codes, 'Ba' if $uwp =~ /....000-0/;
   push @codes, 'Cy' if $uwp =~ /....[5-9A]6[0-3]-./;
   push @codes, 'De' if $uwp =~ /..[2-9]0...-./;
   push @codes, 'Di' if $uwp =~ /....000-[^0]/;
   push @codes, 'Fl' if $uwp =~ /..[ABC][1-9A]...-./;
   push @codes, 'Ga' if $uwp =~ /.[678][568][567]...-./;
   push @codes, 'He' if $uwp =~ /.[3-9ABC][2479ABC][012]...-./;
   push @codes, 'Hi' if $uwp =~ /....[9ABCDEF]..-./;
   push @codes, 'Ic' if $uwp =~ /..[01][1-9A]...-./;
   push @codes, 'In' if $uwp =~ /..[012479ABC].[9ABCDEF]..-./;
   push @codes, 'Lo' if $uwp =~ /....[123]..-./;
   push @codes, 'Na' if $uwp =~ /..[0-3][0-3][6-9ABCDEF]..-./;
   push @codes, 'Ni' if $uwp =~ /....[456]..-./;
   push @codes, 'Oc' if $uwp =~ /.[ABCDEF][^012]A...-./;
   push @codes, 'Pa' if $uwp =~ /..[4-9][4-8][48]..-./;
   push @codes, 'Ph' if $uwp =~ /....8..-./;
   push @codes, 'Pi' if $uwp =~ /..[012479].[78]..-./;
   push @codes, 'Po' if $uwp =~ /..[2-5][0-3]...-./;
   push @codes, 'Pr' if $uwp =~ /..[68].[59]..-./;
   push @codes, 'Px' if $uwp =~ /..[23AB][1-5][3-6].[6-9]-./;
   push @codes, 'Re' if $uwp =~ /....[0-4]6[045]-./;
   push @codes, 'Ri' if $uwp =~ /..[68].[6-8]..-./;
   push @codes, 'Va' if $uwp =~ /..0....-./;
   push @codes, 'Wa' if $uwp =~ /.[3-9][3-9DEF]A...-./;
  
   #push @codes, 'Mr' if $uwp =~ /.....6.-./ && ! grep( /Px|Re|Pe/, @codes );

   push @codes, 'Fr' if $uwp =~ /.[2-9].[1-9A]...-./ && $hz >= 2;
   push @codes, 'Ho' if $hz < 0;
   push @codes, 'Co' if $hz > 0;
   push @codes, 'Lk' if $mainworldType eq 'Close Satellite';
   push @codes, 'Tr' if $uwp =~ /.[6-9][4-9][3-7]...-./ && $hz == -1;
   push @codes, 'Tu' if $uwp =~ /.[6-9][4-9][3-7]...-./ && $hz == 1;
   push @codes, 'Tz' if $orbit == 0 || $orbit == 1;

   push @codes, 'Sa' if $mainworldType =~ /Satellite/
                     && $mainworldType ne 'Close Satellite';

   push @codes, 'Fo' if $zone eq 'R';
   push @codes, 'Pz' if $uwp =~ /....[789ABCDEF]..-./ && $zone eq 'A';
   push @codes, 'Da' if $uwp =~ /....[0-6]..-./    && $zone eq 'A';

   return join ' ', @codes;
}

###############################################################################
#
#  Mark the world as hospitable or not hospitable.
#
###############################################################################
sub isHospitableOrNot
{
   my $world = shift;
   $world->{ 'is_hospitable' } = 'no';
   $world->{ 'is_hospitable' } = 'yes' if $world->{ 'trade_codes' } =~ /Ri|Ga|Ag/;
}

###############################################################################
#
#  Calculate Tech Level of anything which has a UWP.
#  Requires worldref with 'starport', 'siz', 'atm', 'hyd', 'pop', and 'gov'.
#  The initial 1D is NOT ROLLED.
#
#  OPTIONAL "DM" allowed 
#   -- this would be a good place to put the initial 1D6.
#
###############################################################################
sub techLevel
{
   my $world = shift;
   my $tl    = shift || 0;
   
   return 0 if $world->{ 'pop' } == 0;

   my %porttech = ('A' => 6, 'B' => 4, 'C' => 2, 'F' => 1, 'X' => -4);
   my @sizetech = qw/2 2 1 1 1 0 0 0 0 0 0 0 0 0 0 0/;
   my @atmotech = qw/1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 1/;
   my @hydtech  = qw/0 0 0 0 0 0 0 0 0 1 2/;
   my @poptech  = qw/0 1 1 1 1 1 0 0 0 2 4 4 4 4 4 4/;
   my @govtech  = qw/1 0 0 0 0 1 0 0 0 0 0 0 0 -2/;

   my $newtl = $tl + $porttech{ $world->{ 'starport' } }
              + $sizetech[ $world->{ 'siz' } ]
              + $atmotech[ $world->{ 'atm' }]
              + $hydtech[ $world->{ 'hyd' }]
              + $poptech[ $world->{ 'pop' }]
              + $govtech[ $world->{ 'gov' }];

   return 0 if $newtl < 0;
   return $newtl;
}

###############################################################################
#
#  Calculate World Importance.  REQUIRES TRADE CODES.
#
###############################################################################
sub importance
{
   my $world   = shift;
   my $i       = 0;
  
   $i++ if $world->{ 'starport' } =~ /[AB]/;
   $i-- if $world->{ 'starport' } =~ /[^ABC]/;

   $i++ if $world->{ 'trade_codes' } =~ /\bAg\b/;
   $i++ if $world->{ 'trade_codes' } =~ /\bRi\b/;
   $i++ if $world->{ 'trade_codes' } =~ /\bIn\b/;
   $i++ if $world->{ 'trade_codes' } =~ /\bHi\b/;
 
   $i-- if $world->{ 'pop' } <= 6;
   $i-- if $world->{ 'tl'  } <= 8;
   $i++ if $world->{ 'tl'  } >= 10;
   $i++ if $world->{ 'tl'  } >= 16;

   $i++ if $world->{ 'naval base' } + $world->{ 'scout base' } == 2;
   $i++ if $world->{ 'way station' };

   $world->{ 'ix' }->{ 'importance' } = $i;
   $world->{ 'Ix' } = '{ ' . $i . ' }';

   return $i;
}

###############################################################################
#
#  Calculate Economic Extension.  
#  Requires a lot of things...
#
###############################################################################
sub economicExtension
{
   my $world = shift;
   resources($world);
   $world->{ 'ex' }->{ 'labor' } = $world->{ 'pop' } - 1;
   $world->{ 'ex' }->{ 'labor' } = 0 if $world->{ 'pop' } == 0;
   infrastructure($world);

   my $efficiency = flux();

   $world->{ 'ex' }->{ 'efficiency' } = $efficiency;

   $efficiency = '1' if $efficiency == 0;
   $efficiency = '+' . $efficiency if $efficiency > -1;

   $world->{ 'Ex' } = sprintf( "(%1s%1s%1s%2s)", 
         $ehex[$world->{ 'ex' }->{ 'resources' }],
         $ehex[$world->{ 'ex' }->{ 'labor' }],
         $ehex[$world->{ 'ex' }->{ 'infrastructure' }],
         $efficiency,
   );
}

###############################################################################
#
#  Calculate Resources (from the Economic Extension).  
#  REQUIRES TL, Belts, and GGs.
#
###############################################################################
sub resources
{
   my $world = shift;
   my $r = rand2d();
   $r += $world->{ 'ggs' } + $world->{ 'belts' } if $world->{ 'tl' } >= 8;
   $r = 0 if $r < 0;
   $world->{ 'ex' }->{ 'resources' } = $r;
}

###############################################################################
#
#  Calculate Infrastructure (from the Economic Extension).  
#  REQUIRES IMPORTANCE and TRADE CODES.
#
###############################################################################
sub infrastructure
{
   my $world = shift;
   my $infra = 0;
   my $pop   = $world->{ 'pop' };
   
   $world->{ 'ex' }->{ 'infrastructure' } = 0;
   return if $pop == 0;                           # pop = 0

   $infra = $world->{ 'ix' }->{ 'importance' };   # pop = 123
   $infra += rand1d() if $pop >= 4 && $pop <= 6;  # pop = 456
   $infra += rand2d() if $pop >= 7;               # pop = 7+
   $infra = 0 if $infra < 0;
   $world->{ 'ex' }->{ 'infrastructure' } = $infra;
}

###############################################################################
#
#  Calculate RU.  REQUIRES ECONOMIC EXTENSION.
#
###############################################################################
sub aryu 
{
   my $world = shift;
   my $resources      = $world->{ 'ex' }->{ 'resources' };
   my $labor          = $world->{ 'ex' }->{ 'labor' };
   my $infrastructure = $world->{ 'ex' }->{ 'infrastructure' };
   my $efficiency     = $world->{ 'ex' }->{ 'efficiency' };
   
   $labor = 1          if $labor          == 0;
   $infrastructure = 1 if $infrastructure == 0;
   $efficiency = 1     if $efficiency     == 0;

   $world->{ 'ru' } = $resources * $labor * $infrastructure * $efficiency;

   return $world->{ 'ru' };
}

###############################################################################
#
#  Calculate Cultural Extension.  REQUIRES IMPORTANCE, WORLD POP and TL.
#
###############################################################################
sub culturalExtension
{
   my $world = shift;
   my $homogeneity = $world->{ 'pop' } + flux();
   my $acceptance  = $world->{ 'pop' } + $world->{ 'ix' }->{ 'importance' };
   my $strangeness = 5 + flux();
   my $symbols     = $world->{ 'tl' } + flux();
  
   $homogeneity = 1 if $homogeneity < 1;
   $acceptance  = 1 if $acceptance < 1;
   $strangeness = 1 if $strangeness < 1;
   $symbols     = 1 if $symbols < 1;

   if ($world->{ 'pop' } == 0)
   {
      $homogeneity = 0;
      $acceptance = 0;
      $strangeness = 0;
      $symbols = 0;
   }

   $world->{ 'cx' } = 
   {
      'homogeneity' => $homogeneity,
      'acceptance'  => $acceptance,
      'strangeness' => $strangeness,
      'symbols'     => $symbols
   };

   $world->{ 'Cx' } = sprintf "[%1s%1s%1s%1s]",
      $ehex[$homogeneity],
      $ehex[$acceptance],
      $ehex[$strangeness],
      $ehex[$symbols],
      ;
}

###############################################################################
#
#  Dieback World
#
###############################################################################
sub dieback
{
   my $world = shift;
   $world->{ 'pop' } = 0;
   $world->{ 'gov' } = 0;
   $world->{ 'law' } = 0;
   $world->{ 'pop_mult' } = 0;
   $world->{ 'remarks' } =~ s/\b\w\w\w\w\w\b//g;
}

###############################################################################
#
#  Descriptions of UWP data.
#
###############################################################################
my %starport =
(
   'A' =>  'Excellent quality',
   'B' =>  'Good quality',
   'C' =>  'Fair quality',
   'D' =>  'Poor quality',
   'E' =>  'No starport present',
   'F' =>  'Frontier quality',
   'G' =>  'Poor frontier quality',
   'H' =>  'No spaceport present',
   'X' =>  'Unknown',
   'Y' =>  'Unknown',
);
sub describeStarport { $starport{$_[0]} }

sub circumference { 10 * int( describeSiz($_[0]) * 0.31416 ) }

sub describeSiz { $hex2dec{ $_[0] } * 1600 }

my %atmosphere =
(
   '0' => 'Vacuum world',
   '1' => 'Trace',
   '2' => 'Very thin, tainted',
   '3' => 'Very thin',
   '4' => 'Thin, tainted',
   '5' => 'Thin',
   '6' => 'Standard',
   '7' => 'Standard, tainted',
   '8' => 'Dense',
   '9' => 'Dense, tainted',
   'A' => 'Exotic',
   '10' => 'Exotic',
   'B' => 'Corrosive',
   '11' => 'Corrosive',
   'C' => 'Insidious',
   '12' => 'Insidious',
   'D' => 'Dense high',
   '13' => 'Dense high',
   'E' => 'Ellipsoid',
   '14' => 'Ellipsoid',
   'F' => 'Thin Low',
   '15' => 'Thin Low',
);
sub describeAtm { $atmosphere{$_[0]} }

sub describeHyd
{
   return 'No free standing water' if $_[0] =~ /0/;
   return 'Water world'            if $_[0] eq 'A' || $_ eq '10';
   return "$_[0]0% water";
}

my %population =
(
   '0' => 'unpopulated',
   '1' => 'tens',
   '2' => 'hundreds',
   '3' => 'thousands',
   '4' => 'ten thousands',
   '5' => 'hundred thousands',
   '6' => 'millions',
   '7' => 'ten millions',
   '8' => 'hundred millions',
   '9' => 'billions',
   'A' => 'ten billions',
   '10' => 'ten billions',
   'B' => 'hundred billions',
   '11' => 'hundred billions',
   'C' => 'trillions',
   '12' => 'trillions',
   'D' => 'ten trillions',
   '13' => 'ten trillions',
   'E' => 'hundred trillions',
   '14' => 'hundred trillions',
   'F' => 'quadrillions',
   '15' => 'quadrillions',
);
sub describePop { $population{$_[0]} }

my %government =
(
   '0' => "No government structure",
   '1' => "Company/Corporation",
   '2' => "Participating Democracy",
   '3' => "Self-Perpetuating Oligarchy",
   '4' => "Representative Democracy",
   '5' => "Feudal Technocracy",
   '6' => "Captive Government",
   '7' => "Balkanization",
   '8' => "Civil Service Bureaucracy",
   '9' => "Impersonal Bureaucracy",
   'A' => "Charismatic Dictator",
   '10' => "Charismatic Dictator",
   'B' => "Non-Charismatic Leader",
   '11' => "Non-Charismatic Leader",
   'C' => "Charismatic Oligarchy",
   '12' => "Charismatic Oligarchy",
   'D' => "Religious Dictatorship",
   '13' => "Religious Dictatorship",
   'E' => 'Religious Autocracy',
   '14' => 'Religious Autocracy',
   'F' => 'Totalitarian Oligarchy',
   '15' => 'Totalitarian Oligarchy',
);
sub describeGov { $government{$_[0]} }

my %law =
(
   '0' => 'are unrestrictive',
   '1' => 'prohibit carrying WMD and Psi weapons',
   '2' => 'prohibit Man-Portable Weapons',
   '3' => 'prohibit of Acid, Fire, Gas weapons',
   '4' => 'prohibit Laser, Beam weapons',
   '5' => 'prohibit Shock, EMP, Rad, Mag, and Grav weapons',
   '6' => 'prohibit MachineGuns',
   '7' => 'prohibit Pistols',
   '8' => 'prohibit open display of weapons',
   '9' => 'prohibit possession of weapons outside the home',
   'A' => 'prohibit weapon possession',
   '10' => 'prohibit weapon possession',
   'B' => 'require continental passports',
   '11' => 'require continental passports',
   'C' => 'allow unrestricted invasion of privacy',
   '12' => 'allow unrestricted invasion of privacy',
   'D' => 'authorizes paramilitary law enforcement',
   '13' => 'authorizes paramilitary law enforcement',
   'E' => 'amount to a fully-fledged police state',
   '14' => 'amount to a fully-fledged police state',
   'F' => 'rigidly control daily life',
   '15' => 'rigidly control daily life',
   'G' => 'mandate disproportionate punishments',
   '16' => 'mandate disproportionate punishments',
   'H' => 'legalize oppressive practices',
   '17' => 'legalize oppressive practices',
   'J' => 'routinely oppress and restrict',
   '18' => 'routinely oppress and restrict',
);
sub describeLaw { $law{$_[0]} }

my %techLevels =
(
   '0'  => 'the stone age',
   '1'  => 'the bronze or iron age',
   '2'  => 'the age of sail',
   '3'  => 'the industrial revolution',
   '4'  => 'the mid 19th century',
   '5'  => 'the early 20th century',
   '6'  => 'the atomic age',
   '7'  => 'the information age',
   '8'  => 'the space age',
   '9'  => 'that of an early interstellar civilization',
   'A'  => 'the gravitics age', # '(10) Lifters',
   '10' => 'the gravitics age', # '(10) Lifters',
   'B'  => 'the fusion+ age',
   '11' => 'the fusion+ age',
   'C'  => 'the jump-3 age',
   '12' => 'the jump-3 age',
   'D'  => 'the age of biologics and robots',
   '13' => 'the age of biologics and robots',
   'E'  => 'the age of geneering',
   '14' => 'the age of geneering',
   'F'  => 'the age of anagathics',
   '15' => 'the age of anagathics',
   'G'  => 'the age of synthetics',
   '16' => 'the age of synthetics',
   'H'  => 'a hop and antimatter culture',
   '17' => 'a hop and antimatter culture',
   'J'  => 'the age of collectors',
   '18' => 'the age of collectors',
   'K'  => 'the matter transport age',
   '19' => 'the matter transport age',
   'L'  => 'the white globe age',
   '20' => 'the white globe age',
   'M'  => 'the stasis age',
   '21' => 'the stasis age',
   'N'  => 'the age of individual transformations',
   '22' => 'the age of individual transformations',
   'P'  => 'the rosette age',
   '23' => 'the rosette age',
   'Q'  => 'the portal age',
   '24' => 'the portal age',
   'R'  => 'the age of psionic engineering',
   '25' => 'the age of psionic engineering',
   'S'  => 'the age of world engineering',
   '26' => 'the age of world engineering',
   'T'  => 'the age of ringworlds',
   '27' => 'the age of ringworlds',
   'U'  => 'the age of stellar manipulation',
   '28' => 'the age of stellar manipulation',
   'V'  => 'the age of dyson spheres',
   '29' => 'the age of dyson spheres',
   'W'  => 'the age of stellar engineering',
   '30' => 'the age of stellar engineering',
   'X'  => 'the age of pocket universes',
   '31' => 'the age of pocket universes',
   'Y'  => 'the age before Singularity',
   '32' => 'the age before Singularity',
   'Z'  => 'the age of the Singularity',
   '33' => 'the age of the Singularity',
);
sub describeTL { $techLevels{$_[0]} }

1; # return true as all good Perl modules should.

