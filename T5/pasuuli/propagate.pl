use strict;
use T5ssMilieuSectorTools;
sub title
{
   print<<EOTITLE;

    ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄ 
  ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
  ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌ ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ 
  ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌       ▐░▌     ▐░▌     ▐░▌          
  ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌ ▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌     ▐░▌     ▐░█▄▄▄▄▄▄▄▄▄ 
  ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌▐░░░░░░░░▌▐░░░░░░░░░░░▌     ▐░▌     ▐░░░░░░░░░░░▌
  ▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀█░█▀▀ ▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░▌ ▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌     ▐░▌     ▐░█▀▀▀▀▀▀▀▀▀ 
  ▐░▌          ▐░▌     ▐░▌  ▐░▌       ▐░▌▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌     ▐░▌     ▐░▌          
  ▐░▌          ▐░▌      ▐░▌ ▐░█▄▄▄▄▄▄▄█░▌▐░▌          ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌     ▐░▌     ▐░█▄▄▄▄▄▄▄▄▄ 
  ▐░▌          ▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌          ▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌     ▐░▌     ▐░░░░░░░░░░░▌
   ▀            ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀            ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀       ▀       ▀▀▀▀▀▀▀▀▀▀▀  

EOTITLE
}
use Getopt::Long;
use Data::Dumper;
$Data::Dumper::Pair = ": ";
$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Useqq = 1;

my ($sah, $sys, $star, $remarks, $tl, $wholeSector, $sectorName, $help, $milieu, $allMilieux, $anRemark);

GetOptions ("sah"           => \$sah,
            "sys"           => \$sys,
            "star"          => \$star,
            "tl"            => \$tl,
            "an"            => \$anRemark,
            "remarks"       => \$remarks,
            "whole_sector"  => \$wholeSector,
            "sector=s"      => \$sectorName,
	         "milieu=s"      => \$milieu,
            "all_milieux"   => \$allMilieux,
            "help"          => \$help);

synopsis() if $help;

my @hex = @ARGV;

unless ($sah || $sys || $star || $tl || $remarks || $anRemark)
{
   die "ERROR: nothing to copy! (try '$0 --help')\n";
}

unless ($sectorName)
{
   die "ERROR: no source sector! (try '$0 --help')\n";
}

$sectorName =~ s/^(....).*$/\u\L$1/;

unless (@hex || $wholeSector)
{
   die "ERROR: no hexes specified! (try '$0 --help')\n";
}

$wholeSector = undef if @hex;

unless ($milieu || $allMilieux)
{
   die "ERROR: no target milieu(x)! (try '$0 --help')\n";
}

$allMilieux = undef if $milieu;

title();

print "Propagating:\n";
print " - SAH\n"                     if $sah;
print " - Belts, GGs, World Count\n" if $sys;
print " - Stellar data\n"            if $star;
print " - Updating TL\n"             if $tl;
print " - Propagating An remark\n"   if $anRemark;
print " - Refreshing remarks\n"      if $remarks;
print "\n";

print "Source:\n";
print " - sector: $sectorName\n";
print " - hexes: @hex\n"             if @hex;
print " - whole sector\n"            if $wholeSector;
print "\n";

my @milieu = T5ssMilieuSectorTools::getMilieux($milieu, $allMilieux);

print "Target:\n";
print " - milieu(x): ", join(' ', @milieu), "\n";
print "\n";

my $m1105ref  = T5ssMilieuSectorTools::readMilieuSector( "M1105", $sectorName );
print "World Example: ", Dumper $m1105ref->{ '1910' };

print<<EORUN;

 ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄        ▄ 
▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░▌      ▐░▌
▐░█▀▀▀▀▀▀▀█░▌▐░▌       ▐░▌▐░▌░▌     ▐░▌
▐░▌       ▐░▌▐░▌       ▐░▌▐░▌▐░▌    ▐░▌
▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌▐░▌ ▐░▌   ▐░▌
▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░▌  ▐░▌  ▐░▌
▐░█▀▀▀▀█░█▀▀ ▐░▌       ▐░▌▐░▌   ▐░▌ ▐░▌
▐░▌     ▐░▌  ▐░▌       ▐░▌▐░▌    ▐░▌▐░▌
▐░▌      ▐░▌ ▐░█▄▄▄▄▄▄▄█░▌▐░▌     ▐░▐░▌
▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌      ▐░░▌
 ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀        ▀▀ 

EORUN

my @worldrefs = getWorlds($m1105ref, $wholeSector, @hex);

my $updates = 0;
foreach my $targetMilieu (@milieu)
{
   my $milref = T5ssMilieuSectorTools::readMilieuSector( $targetMilieu, $sectorName );
   foreach my $worldref (@worldrefs)
   {
      my $targetWorld = $milref->{ $worldref->{ 'Hex' } };
      $updates += updateSAH( $worldref, $targetWorld ) if $sah;
      $updates += updateSYS( $worldref, $targetWorld ) if $sys;
      $updates += updateStellar( $worldref, $targetWorld ) if $star;
      $updates += updateTL( $worldref, $targetWorld ) if $tl;
      $updates += propagateRemark( $worldref, $targetWorld, 'An' ) if $anRemark;
      $updates += updateRemarks( $targetWorld ) if $remarks;
   }
   saveMilieuSector( $targetMilieu, $sectorName, $milref );
}

summary();

print "*********************************************************************************************\n";
print "*                                                                                           *\n";
print "*                                                                                           *\n";
print "*                    Options processed successfully.                                        *\n";
print "*                    However, functions not yet implemented.     :(                         *\n";
print "*                                                                                           *\n";
print "*                                                                                           *\n";
print "*********************************************************************************************\n";


print "\n";
print "PROGRAM DONE \n";
print "\n";
print "Have a nice day.\n";
print "\n";

sub getWorlds
{
   my ($m1105ref, $wholeSector, @hex) = @_;
   my %m1105 = %$m1105ref;

   return values %m1105 if $wholeSector;
   return @m1105{ @hex };
}

#
#  Update size, atmosphere, hydrographics
#
sub updateSAH
{
   my ( $m1105ref, $targetWorldref ) = @_;
   my $changed = 0;
   my $label = sprintf "%-25s", "$targetWorldref->{'Hex'}/$targetWorldref->{ 'Name' }";
   
   for (qq/siz atm hyd/)
   {
      if ( $targetWorldref->{ $_ } ne $m1105ref->{ $_ } )
      {
         print " - updating SAH/$_ on $label from $targetWorldref->{$_} to $m1105ref->{$_}\n";
         $targetWorldref->{$_} = $m1105ref->{$_};
         ++$changed;
      }
   }
   #print " - SAH Unchanged: $label\n" unless $changed;
   return $changed;
}

#
#  Update belts, GGs, world count
#
sub updateSYS
{
   my ( $m1105ref, $targetWorldref ) = @_;
   my $changed = 0;
   my $label = sprintf "%-25s", "$targetWorldref->{'Hex'}/$targetWorldref->{ 'Name' }";

   for (qq/belts ggs W/)
   {
      if ( $targetWorldref->{ $_ } ne $m1105ref->{ $_ } )
      {
         print " - updating Sys/$_   on $label from $targetWorldref->{$_} to $m1105ref->{$_}\n";
         $targetWorldref->{$_} = $m1105ref->{$_};
         ++$changed;
      }
   }
   #print " - Sys Unchanged: $label\n" unless $changed;
   return $changed;
}

sub updateStellar
{
   my ( $m1105ref, $targetWorldref ) = @_;
   my $changed = 0;
   my $label = sprintf "%-25s", "$targetWorldref->{'Hex'}/$targetWorldref->{ 'Name' }";

   for (qq/Stars/)
   {
      if ( $targetWorldref->{ $_ } ne $m1105ref->{ $_ } )
      {
         print " - updating Sys/$_   on $label from $targetWorldref->{$_} to $m1105ref->{$_}\n";
         $targetWorldref->{$_} = $m1105ref->{$_};
         ++$changed;
      }
   }
   #print " - Stars Unchanged: $label\n" unless $changed;
   return $changed;
}

#
#  Determines the original 1D roll from 1105 data.
#  Calculates the TL for the target data.
#  BUT: keeps the target TL if it's higher.
#
sub updateTL
{
   my ( $m1105ref, $targetWorldref ) = @_;
   my $changed = 0;
   my $label = sprintf "%-25s", "$targetWorldref->{'Hex'}/$targetWorldref->{ 'Name' }";

   my $TLdieroll = $m1105ref->{ 'tl' } - UWP::techLevel( $m1105ref ); # ideally should be 1 to 6
   my $TL = UWP::techLevel( $targetWorldref, $TLdieroll );

   if ( $TL > $targetWorldref->{ 'tl' } )
   {
      print " - updating TL   on $label from $targetWorldref->{'tl'} to $TL\n";
      $targetWorldref->{'tl'} = $TL;
      ++$changed;
   }
   elsif ( $TL < $targetWorldref->{ 'tl' } && $targetWorldref->{ 'Remarks'} !~ /Di\b/)
   {
      print " - NOTE:    TL   on $label is above calculation ($targetWorldref->{'tl'} > $TL)\n";
   }
   #print " - TL Unchanged: $label ($targetWorldref->{ 'tl' })\n" unless $changed;
   return $changed;
}

#
#  Makes sure a particular remark is present.
#  Does NOT recompute or refresh remarks.
#
sub propagateRemark
{
   my ( $worldref, $targetWorld, $theRemark ) = @_;
   my $changed = 0;
   my $label = sprintf "%-15s", "$targetWorldref->{ 'Name' }";

   my $remarks = $targetWorldref->{ 'Remarks' };
   return 0 if $remarks =~ /$theRemark\b/;
   $remarks =~ s/\s+$//;
   $remarks .= " $theRemark "; # tack on new remark
   $targetWorldref->{ 'Remarks' } = $remarks;
}

sub updateRemarks
{
   my ( $targetWorldref ) = @_;
   my $changed = 0;
   my $label = sprintf "%-15s", "$targetWorldref->{ 'Name' }";

   my $oldRemarks = $targetWorldref->{ 'Remarks' };
   my $nonComputables = UWP::findNonComputableRemarks( $oldRemarks );
   my $computables = UWP::tradeCodes( $targetWorldref->{ 'UWP'}, $targetWorldref->{ 'Zone' } );
   my $newRemarks = "$computables $nonComputables";

   $oldRemarks =~ s/\s+$//;
   $newRemarks =~ s/\s+$//;
 
   if ( $newRemarks ne $oldRemarks )
   {
      $targetWorldref->{ 'Remarks' } = $remarks;
      printf " - updating   [$label]  from  [%-25s]  to  [%-25s]\n", $oldRemarks, $newRemarks;
      ++$changed;
   }

   return $changed;
}

sub saveMilieuSector
{
   my ( $targetMilieu, $sectorName, $milref ) = @_;
   print "==> SAVING updated sector: $targetMilieu/$sectorName\n";
}

sub summary
{
   print<<EOSUMMARY;

   ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄       ▄▄  ▄▄       ▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄ 
  ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░▌     ▐░░▌▐░░▌     ▐░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌
  ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌▐░▌░▌   ▐░▐░▌▐░▌░▌   ▐░▐░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌       ▐░▌
  ▐░▌          ▐░▌       ▐░▌▐░▌▐░▌ ▐░▌▐░▌▐░▌▐░▌ ▐░▌▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌
  ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌▐░▌ ▐░▐░▌ ▐░▌▐░▌ ▐░▐░▌ ▐░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌
  ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░▌  ▐░▌  ▐░▌▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
   ▀▀▀▀▀▀▀▀▀█░▌▐░▌       ▐░▌▐░▌   ▀   ▐░▌▐░▌   ▀   ▐░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀█░█▀▀  ▀▀▀▀█░█▀▀▀▀ 
            ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌     ▐░▌       ▐░▌     
   ▄▄▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌      ▐░▌      ▐░▌     
  ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌     ▐░▌     
   ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀         ▀  ▀         ▀  ▀         ▀       ▀      

EOSUMMARY
}


sub synopsis
{
   title();

   print<<EOSYNOPSIS;

SYNOPSIS: $0 [-sah] [-sys] [-star] [-tl] [-all_milieux] [-milieu <Mdddd>]  [-whole_sector] -sector <NNNN> [hex...]

   Propagates M1105 data to other milieux.

PROPAGATIONS

   -sah             propagates Size, Atm, and Hyd.  Updates trade remarks.
   -sys             propagates belts, GGs, and world count.
   -star            propagates stellar data.
   -tl              regenerate TL.

TARGET

   -all_milieux     targets all milieux.
   -milieu <Mnnnn>  the target milieu.

   -sector <NNNN>   the sector to update.

   -whole_sector    propagates data from every world in the sector.
   hex...           the list of hexes to propagate.

NOTES

   If the hex list is present, -whole_sector is ignored.
   If -milieu is specified, -all_milieux is ignored. 

EOSYNOPSIS

   exit(0);
}


