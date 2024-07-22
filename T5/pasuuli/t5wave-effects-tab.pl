my $VERSION = "2023.03.18";

print<<EOTITLE;

                     Version $VERSION
                                                                     
@@@@@@@  @@@@@@@     @@@  @@@  @@@   @@@@@@   @@@  @@@  @@@@@@@@     
@@@@@@@  @@@@@@@     @@@  @@@  @@@  @@@@@@@@  @@@  @@@  @@@@@@@@     
  @@!    !@@         @@!  @@!  @@!  @@!  @@@  @@!  @@@  @@!          
  !@!    !@!         !@!  !@!  !@!  !@!  @!@  !@!  @!@  !@!          
  @!!    !!@@!!      @!!  !!@  @!@  @!@!@!@!  @!@  !@!  @!!!:!       
  !!!    @!!@!!!     !@!  !!!  !@!  !!!@!!!!  !@!  !!!  !!!!!:       
  !!:        !:!     !!:  !!:  !!:  !!:  !!!  :!:  !!:  !!:          
  :!:        !:!     :!:  :!:  :!:  :!:  !:!   ::!!:!   :!:          
   ::    :::: ::      :::: :: :::   ::   :::    ::::     :: ::::     
   :     :: : :        :: :  : :     :   : :     :      : :: ::      
                                                                     
                                                                     
@@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@@   @@@@@@@  @@@@@@@   @@@@@@   
@@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@  @@@@@@@   
@@!       @@!       @@!       @@!       !@@         @@!    !@@       
!@!       !@!       !@!       !@!       !@!         !@!    !@!       
@!!!:!    @!!!:!    @!!!:!    @!!!:!    !@!         @!!    !!@@!!    
!!!!!:    !!!!!:    !!!!!:    !!!!!:    !!!         !!!     !!@!!!   
!!:       !!:       !!:       !!:       :!!         !!:         !:!  
:!:       :!:       :!:       :!:       :!:         :!:        !:!   
 :: ::::   ::        ::        :: ::::   ::: :::     ::    :::: ::   
: :: ::    :         :        : :: ::    :: :: :     :     :: : :    
                                                                     
   This script models the destruction caused by the Wave.

EOTITLE
use lib '.';
use UWP;
use Data::Dumper;
$Data::Dumper::Pair = ": ";
$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Useqq = 1;

#
#  Build our e-hex converters
#
my @hex = split '', '0123456789ABCDEFGHJKLMNPQRSTUVWXYZ';
my %hex2dec = map { $hex[$_] => $_ } 0..33;

my $sectorfile = shift;
synopsis("ERROR  .tab file required.") unless $sectorfile =~ /\.tab$/;

#
#  read file
#
#  The header always contains these fields in order:
#
#  Sector, SS, Hex, Name, UWP, Bases, Remarks, Zone, PBG, Allegiance, Stars, {Ix}, (Ex), [Cx], Nobility, W, RU
#
open my $in, '<', $sectorfile || synopsis();
my $hdr = <$in>; # read header line
my @hdr = split /\t/, $hdr;
my @lines = <$in>;
close $in;

#
#  open output files for Y+10, Y+100, Y+300, and Y+600 years
#
#open my $o10,  '>', "$sectorfile.10";
#open my $o100, '>', "$sectorfile.100";
#open my $o300, '>', "$sectorfile.300";
#open my $o600, '>', "$sectorfile.600";
#
#  maybe later.


chomp @lines;
s/\s*\r// for @lines;

print $hdr;

=pod
                                                                             
@@@@@@@  @@@  @@@  @@@@@@@@     @@@  @@@  @@@   @@@@@@   @@@  @@@  @@@@@@@@  
@@@@@@@  @@@  @@@  @@@@@@@@     @@@  @@@  @@@  @@@@@@@@  @@@  @@@  @@@@@@@@  
  @@!    @@!  @@@  @@!          @@!  @@!  @@!  @@!  @@@  @@!  @@@  @@!       
  !@!    !@!  @!@  !@!          !@!  !@!  !@!  !@!  @!@  !@!  @!@  !@!       
  @!!    @!@!@!@!  @!!!:!       @!!  !!@  @!@  @!@!@!@!  @!@  !@!  @!!!:!    
  !!!    !!!@!!!!  !!!!!:       !@!  !!!  !@!  !!!@!!!!  !@!  !!!  !!!!!:    
  !!:    !!:  !!!  !!:          !!:  !!:  !!:  !!:  !!!  :!:  !!:  !!:       
  :!:    :!:  !:!  :!:          :!:  :!:  :!:  :!:  !:!   ::!!:!   :!:       
   ::    ::   :::   :: ::::      :::: :: :::   ::   :::    ::::     :: ::::  
   :      :   : :  : :: ::        :: :  : :     :   : :     :      : :: ::   
                                                                             

                Here's where we apply the initial wave effects.
=cut
foreach my $line (@lines)
{
   my $world = decodeUWPline($line);
   next unless $world->{ 'starport' };

   checkForNIL($world, $line);
   UWP::isHospitableOrNot( $world );
   $world->{ 'zone' } = 'A'; # everything is Amber Zone.

   #
   #  Do the Wave
   #
   #  Step 1: calculate for Wave + 10 years.
   #
   printWorld( $world, "Input" );
   $world->{ 'zone' } = '-';
   if ($world->{ 'NIL' }) # NIL = shirtsleeves
   {
      shirtsleeveWorld($world);
   }
   elsif ($world->{'trade_codes'} =~ /Ni|He|Lo/)
   {
      niWorld($world) if $world->{ 'trade_codes' } =~ /Ni/;
      heWorld($world) if $world->{ 'trade_codes' } =~ /He/;
      loWorld($world) if $world->{ 'trade_codes' } =~ /Lo/;
   }
   else 
   {
      shirtsleeveWorld($world);
   }

   if ($world->{ 'is_hospitable' } eq 'no')
   {
      dieback($world) if $world->{ 'tl' } < 4;
   }
   
   reduceBases($world);
   UWP::rerollGovAndLaw($world);

   # apply to preserved TL die roll minus two
   $world->{ 'tl' } = UWP::techLevel($world, $world->{ '_tl_die_roll' } - 2);

   recodeWorld( $world );
   printWorld( $world, "Wave+10" );

   after100years($world);
   printWorld( $world, "Wave+100" );

   after300years($world);
   printWorld( $world, "Wave+300" );

   after300years($world);
   printWorld( $world, "Wave+600" );

   print "\n\n";   
}

sub decodeUWPline
{
   my $line = shift;
   my $world = {};
   my ($sector, $ss, $hex, $name, $uwp, $bases, $remarks, $zone, $pbg, $allegiance, $stars, $ix, $ex, $cx, $nobility, $w, $ru) = split /\t/, $line;
   my ($sp, $siz, $atm, $hyd, $pop, $gov, $law, $tl) = $uwp =~ /(.)(.)(.)(.)(.)(.)(.)-(.)/;
   my ($popmult, $belts, $ggs) = split '', $pbg;

   $world->{ 'sector' }   = $sector;
   $world->{ 'ss' }       = $ss;
   $world->{ 'hex' }      = $hex;
   $world->{ 'name' }     = $name;

   $world->{ 'uwp' }      = $uwp;
   $world->{ 'starport' } = $sp;
   $world->{ 'siz' }      = $hex2dec{$siz};
   $world->{ 'atm' }      = $hex2dec{$atm};
   $world->{ 'hyd' }      = $hex2dec{$hyd};
   $world->{ 'pop' }      = $hex2dec{$pop};
   $world->{ 'gov' }      = $hex2dec{$law};
   $world->{ 'law' }      = $hex2dec{$gov};
   $world->{ 'tl'  }      = $hex2dec{$tl};
   $world->{ '_tl_die_mods' } = UWP::techLevel( $world, 0 );
   $world->{ '_tl_die_roll' } = $world->{ 'tl' } - $world->{ '_tl_die_mods' };

   $world->{ 'pbg' }      = $pbg;
   $world->{ 'pop_mult' } = $popmult;
   $world->{ 'belts' }    = $belts;
   $world->{ 'ggs' }      = $ggs;

   $world->{ 'bases' }    = $bases;
   $world->{ 'remarks' }  = $remarks;
   $world->{ 'zone' }     = $zone;
   $world->{ 'allegiance' } = $allegiance;
   $world->{ 'stars' }    = $stars;
   $world->{ 'Ix' }       = $ix;
   $world->{ 'Ex' }       = $ex;
   $world->{ 'Cx' }       = $cx;
   $world->{ 'nobility' } = $nobility;
   $world->{ 'w' }        = $w;
   $world->{ 'ru' }       = $ru;

   return $world;
}

#
#  After everything's done, you'll have to recalculate some codes.
#
sub recodeWorld
{
   my $world = shift;
   UWP::encodeUWP( $world );
   UWP::encodePBG( $world );

   my $remarks = UWP::findNonComputableRemarks( $world->{ 'remarks' } );
   my $tradeCodes = UWP::tradeCodes( $world->{ 'uwp' }, 'A' );
   $world->{ 'remarks' } = $tradeCodes . ' ' . $remarks;
   $world->{ 'trade_codes' } = $tradeCodes;
   UWP::importance( $world );
   UWP::economicExtension( $world );
   UWP::aryu( $world );
}

sub checkForNIL
{
   my $world = shift;
   my $line  = shift;

   $world->{ 'NIL' } = undef;
   $world->{ 'NIL' } = $1 if $line =~ /\w\s+\((\w+)\)/;
}

sub niWorld
{
   my $world = shift;
   reducePop($world);
   dieback($world) if $world->{ 'pop' } <= 3;
   print "Check Ni\n";
}

sub heWorld
{
   my $world = shift;
   reducePop($world);
   dieback($world) if $world->{ 'pop' } <= 6;
   print "Check He\n";
}

sub loWorld
{
   my $world = shift;
   dieback($world);
   print "Check Lo\n";
}


sub shirtsleeveWorld
{
   my $world = shift;

   $world->{ 'pop_mult' } = int($world->{'pop_mult'}/2);
   if ($world->{ 'pop_mult' } < 1)
   {
      $world->{ 'pop_mult' } = 5;
      $world->{ 'pop' }--;
   }
   dieback($world)        if $world->{ 'pop' } <= 0;
}

sub printWorld
{
   my $world = shift;
   my $msg   = shift || "";

   $world->{ 'uwp' } = UWP::encodeUWP( $world );
   $world->{ 'pbg' } = UWP::encodePBG( $world );
   $world->{ 'trade_codes' } = UWP::tradeCodes($world->{ 'uwp' });

   my $remarks = $world->{ 'trade_codes' }
               . ' '
               . $world->{ 'remarks' }
               . ' ';

   $remarks .= "(" . $world->{ 'NIL' } . ")" if $world->{ 'NIL' };

   $world->{ 'remarks ' } = $remarks;

   # printf(" %-16s  %s  %-15s  %s %s%s  %-18s  %s  %s%s%s  %s %s\n", 
   #    $msg,
   #    $world->{ 'hex' },
   #    $world->{ 'name' },
   #    $world->{ 'uwp' },
   #    $world->{ 'naval base' },
   #    $world->{ 'scout base' },
   #    $remarks,
   #    $world->{ 'zone' },
   #    $world->{ 'pop_mult' },
   #    $world->{ 'belts' },
   #    $world->{ 'ggs' },
   #    $world->{ 'stellar' },
   # );

    printf "%-10s", $msg;
    print join "\t", 
      #$world->{ 'sector' }, 
      #$world->{ 'ss' }, 
      $world->{ 'hex' }, 
      $world->{ 'name' }, 
      $world->{ 'uwp' }, 
      $world->{ 'bases' }, 
      $world->{ 'remarks' }, 
      $world->{ 'zone' }, 
      $world->{ 'pbg' }, 
      $world->{ 'allegiance' }, 
      $world->{ 'stars' }, 
      $world->{ 'Ix' }, 
      $world->{ 'Ex' }, 
      $world->{ 'Cx' }, 
      $world->{ 'nobility' }, 
      $world->{ 'w' }, 
      $world->{ 'ru' };
   print "\n";
}

sub reducePop
{
   my $world = shift;
   my $hardFlux = int(rand(6)) - int(rand(6));

   $world->{ 'pop' } -= abs($hardFlux);

   if ($world->{ 'pop' } <= 0)
   {
      dieback( $world );
   }
   else
   {
      print "REDUCED:\n";
   }
}

sub dieback
{
   my $world = shift;

   print "DIEBACK:\n" if $world->{ 'pop' } > 0;

   $world->{ 'pop' } = 0; 
   $world->{ 'gov' } = 0; 
   $world->{ 'law' } = 0; 
   $world->{ 'pop_mult' } = 0;
   $world->{ 'starport' } = 'D' if $world->{ 'starport' } =~ /[ABC]/;

   recodeWorld( $world );
}

sub reduceBases
{
   my $world = shift;

   return if $world->{ 'starport' } eq 'A';
   $world->{ 'bases' } =~ s/[DW]/ /g;
   
   return if $world->{ 'starport' } eq 'B';
   $world->{ 'bases' } =~ s/N/ /;

   return if $world->{ 'starport' } =~ /[CD]/;
   $world->{ 'bases' } = '  ';   
}

sub twoD
{
   return int(rand(6))+int(rand(6))+2;
}

sub applyRecovery
{
   my $world = shift;
 
   return if $world->{ 'pop' } == 0;

   $world->{ 'tl' }++; # if twoD() < $world->{ 'pop '};
   $world->{ 'pop_mult' }++;
   if ( $world->{ 'pop_mult' } > 9 )
   {
      $world->{ 'pop' }++;
      $world->{ 'pop_mult' } = 1;
   }
   recodeWorld( $world );
   UWP::rerollGovAndLaw($world);
}


=pod
                100 years later
=cut
sub after100years
{
   my $world = shift;
   applyRecovery($world);
}

=pod
                300 years later
=cut
sub after300years
{
   my $world = shift;
   applyRecovery($world);
}


sub synopsis
{
   my $msg = shift || "";
   print "$msg\n";

   print<<SYNOPSIS;

T5-wave-effects: models the destruction caused by the Wave.

SYNOPSIS

   die "script aborted.\n";
}
