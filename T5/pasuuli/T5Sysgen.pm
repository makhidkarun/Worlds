package T5Sysgen;
use Jenkins2rSmallPRNG qw/t5srand rand1d rand2d rand3d rand1d9 rand1d10 flux/;
use UWP;
use strict;

=pod

 @@@@@@   @@@ @@@   @@@@@@    @@@@@@@@  @@@@@@@@  @@@  @@@  
@@@@@@@   @@@ @@@  @@@@@@@   @@@@@@@@@  @@@@@@@@  @@@@ @@@  
!@@       @@! !@@  !@@       !@@        @@!       @@!@!@@@  
!@!       !@! @!!  !@!       !@!        !@!       !@!!@!@!  
!!@@!!     !@!@!   !!@@!!    !@! @!@!@  @!!!:!    @!@ !!@!  
 !!@!!!     @!!!    !!@!!!   !!! !!@!!  !!!!!:    !@!  !!!  
     !:!    !!:         !:!  :!!   !!:  !!:       !!:  !!!  
    !:!     :!:        !:!   :!:   !::  :!:       :!:  !:!  
:::: ::      ::    :::: ::    ::: ::::   :: ::::   ::   ::  
:: : :       :     :: : :     :: :: :   : :: ::   ::    :   

=cut

sub new { bless{}, shift }

sub init
{
   my $self   = shift;
   my $seed   = shift;
   t5srand( $seed );
}

###############################################################################
#
#  Useful data
#
###############################################################################

        my @ehex = (0..9, 'A'..'H', 'J'..'N', 'P'..'Z');
        my @moonOrbit1  = qw/a b c d e f g h i j k l m/;
        my @moonOrbit2  = qw/n o p q r s t u v w x y z/;

###############################################################################
#
#  Figures out the TL of any world, moon, or whatever.
#
###############################################################################
sub techLevel
{
   my $self = shift;
   my $world = shift;
 
   return UWP::techLevel( $world, rand1d() );
}

###############################################################################
#
#  Fixes a number in between two bounds.
#
###############################################################################
sub bounded
{
   my $num = shift;
   my $low = shift;
   my $high = shift;
   
   return $low  if $num < $low;
   return $high if $num > $high;
   return $num;
}
		
###############################################################################
#
#  Adds satellites to a world.
#
###############################################################################
sub satellites
{
   my $self  = shift;
   my $world = shift;
   
   my $satellites = rand1d() - 4;
   if ( $satellites == 0 )
   {
      $world->{ 'ringed' } = 'ringed';
      $satellites = rand1d() - 4;
   }

   for my $num (0..$satellites-1) # satellites
   {
      $world->{ satellites }->[ $num ] = $self->hospitableSatellite( $world );
   }
}

###############################################################################
#
#  Generate a moon for a world in the habitable zone.
#
###############################################################################
sub hospitableSatellite
{
   my $self      = shift;
   my $mainworld = shift;
   my $d6        = rand1d();

#  
#  Determine orbit number, please
#
   my $orbit = rand1d();
   if ( $orbit <= 3 )
   {
      $orbit = $moonOrbit1[1 + rand2d() ];
   }
   else
   {
      $orbit = $moonOrbit2[1 + rand2d() ];
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

   my $starport = $self->spaceport( $pop );
    
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

   $sat->{ 'tl' } = $self->techLevel( $sat );

   my $s = $ehex[ $size ];

   my $uwp = UWP::encodeUWP( $sat ); # $self->uwpToString( $sat );

   $uwp = "$uwp    As"         if $size == 0;
   $uwp = "$uwp    Worldlet"   if $d6 <= 2;
   $uwp = "$uwp    Inferno moon"    if $d6 == 3;
   $uwp = "$uwp    'Hospitable'" if $d6 == 4;
   $uwp = "$uwp    Stormworld" if $d6 == 5;
   $uwp = "$uwp    Radworld"   if $d6 == 6;

   $sat->{ '_uwp' } = $uwp;

   return $sat;
}

###############################################################################
#
###############################################################################
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

1; # returns 1 as every good Perl module should
