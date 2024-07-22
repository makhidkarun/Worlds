package Jenkins2rSmallPRNG;
use Digest::MD5 qw/md5_hex/;
=pod

 JJJJJJJJ EEEEEEE NN      NN KK   KK IIIIIIII NN      NN  SSSSSS 
     JJ   EE      NNN     NN KK   KK    II    NNN     NN SS     S
     JJ   EE      NN N    NN KK  KK     II    NN N    NN SS      
     JJ   EEEEEE  NN  N   NN KK KK      II    NN  N   NN   SS    
     JJ   EE      NN   N  NN KKKKK      II    NN   N  NN     SS  
 JJ  JJ   EE      NN    N NN KK  KK     II    NN    N NN       SS
 JJ  JJ   EE      NN     NNN KK   KK    II    NN     NNN S     SS
  JJJJ    EEEEEEE NN      NN KK   KK IIIIIIII NN      NN  SSSSSS 

  SSSSSS  MM      MM    AA    LL      LL     
 SS     S MMM    MMM   AAAA   LL      LL     
 SS       MM M  M MM  AA  AA  LL      LL     
   SS     MM  MM  MM AA    AA LL      LL     
     SS   MM      MM AAAAAAAA LL      LL     
       SS MM      MM AA    AA LL      LL     
 S     SS MM      MM AA    AA LL      LL     
  SSSSSS  MM      MM AA    AA LLLLLLL LLLLLLL

 PPPPPPP  RRRRRRR  NN      NN  GGGGGG 
  PP   PP  RR   RR NNN     NN GG    GG
  PP   PP  RR   RR NN N    NN GG      
  PPPPPP   RRRRR   NN  N   NN GG      
  PP       RR  RR  NN   N  NN GG  GGGG
  PP       RR   RR NN    N NN GG    GG
  PP       RR   RR NN     NNN GG    GG
 PPPP     RRR   RR NN      NN  GGGGGG 

=cut

require Exporter;
@ISA = qw(Exporter);
@EXPORT_OK = qw(t5srand 
                randint 
		randposint 
                randd3
		rand1d 
		rand2d 
		rand3d 
		flux 
		rand1d10 
		rand1d9);

sub new { bless{}, shift }
#######################################################################
#
#  As seen on http://www.burtleburtle.net/bob/rand/smallprng.html
#
#  The average cycle length is expected to be 
#  85,070,591,730,234,615,865,843,651,857,942,052,864 results.
#
#######################################################################
use integer;
my ($a, $b, $c, $d);

sub rot { ($_[0] << $_[1]) | ($_[0] >> (32-$_[1])) }

sub randint
{
   my $e = ( $a - rot( $b, 27 ) );
      $a = $b ^ rot( $c, 17 );
      $b = ( $c + $d );
      $c = ( $d + $e );
      $d = ( $e + $a );

   return $d;
}

sub randposint
{
   my $mod = shift;  
   my $val = abs randint();
   $val %= $mod if $mod;
   return $val;
}

#######################################################################
#
#  t5srand(): Seeds the random number generator with a string.
#
#  For world-building, I suggest the following format:
#
#  <galaxy>/<arm>/<sector>/<hex>-<orbit>
#
#  Examples:
#
#  t5srand( "Faraway/1010" );        # hex 1010 in the Faraway sector
#  t5srand( "Faraway/1010-1" );      # hex 1010 in the Faraway sector, Orbit 1
#  t5srand( "Orion/X411/1910" );     # hex 1910 in sector X411 of the Orion arm
#  t5srand( "MW1/012F/B9900/3201" ); # hex 3210, sector B9900, arm 012F, galaxy MW1
#
#######################################################################
sub t5srand 
{
   my $UID  = shift;
   my $hash = '0x' . substr( md5_hex( $UID ), 0, 16 ); # 64 bits

   $a = 0xf1ea5eed;
   $b = $c = $d = eval $hash;
   randint() for 0..19;
}

#######################################################################
#
#  Dice-rolling-specific methods.
#  Each of these methods use only *one* call to the RN Generator.
#
#######################################################################
sub randd3   { randposint(3) }
sub rand1d   { 1  + randposint(6) }
sub rand2d   { 2  + randposint(6) + randposint(6) }
sub flux     { -5 + randposint(6) + randposint(6) }
sub rand1d10 { 1 + randposint(10)    } # 1 thru 10
sub rand1d9  { 1 + randposint(9) } # 1 thru 9
sub rand3d   { 3 + randposint(6) + randposint(6) + randposint(6) }

1; # return a true value as all packages should
