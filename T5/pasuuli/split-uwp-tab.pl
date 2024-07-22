=pod

 @@@@@@   @@@@@@@   @@@       @@@  @@@@@@@             @@@  @@@  @@@  @@@  @@@  @@@@@@@   
@@@@@@@   @@@@@@@@  @@@       @@@  @@@@@@@             @@@  @@@  @@@  @@@  @@@  @@@@@@@@  
!@@       @@!  @@@  @@!       @@!    @@!               @@!  @@@  @@!  @@!  @@!  @@!  @@@  
!@!       !@!  @!@  !@!       !@!    !@!               !@!  @!@  !@!  !@!  !@!  !@!  @!@  
!!@@!!    @!@@!@!   @!!       !!@    @!!    @!@!@!@!@  @!@  !@!  @!!  !!@  @!@  @!@@!@!   
 !!@!!!   !!@!!!    !!!       !!!    !!!    !!!@!@!!!  !@!  !!!  !@!  !!!  !@!  !!@!!!    
     !:!  !!:       !!:       !!:    !!:               !!:  !!!  !!:  !!:  !!:  !!:       
    !:!   :!:        :!:      :!:    :!:               :!:  !:!  :!:  :!:  :!:  :!:       
:::: ::    ::        :: ::::   ::     ::               ::::: ::   :::: :: :::    ::       
:: : :     :        : :: : :  :       :                 : :  :     :: :  : :     :        


   This beast is a result of many hours of pain.

   Its job is simple: to divide sector data into two master source YAML files:
   * system data
   * mainworld data

   The distinction is carefully made.  The following data is stored in the systems file:
   - belts
   - gas giants
   - world count
   - stellar data

   Everything else goes into the mainworlds file.

=cut
use strict;

#
#   This works with M1201 and M1105 data.
#
my $milieu = "M1201";
my $src = "/Users/rje/git/travellermap/res/Sectors/$milieu";
my $DASH = "'-'";

print "*** Using $milieu Data ***\n";
print "Don't forget M1105 data!\n" if $milieu =~ /1201/;
print "Don't forget M1201 data!\n" if $milieu =~ /1105/;

foreach my $tabfile (<$src/*.tab>)
{
   my ($abbr) = $tabfile =~ m#$milieu/(....)#;
   $abbr = ucfirst $abbr;
   my $systemFile    = "$milieu-$abbr-system.yaml";
   my $mainworldFile = "$milieu-$abbr-mainworld.yaml";

   open my $SEC,  '<', $tabfile;
   open my $SYS,  '>', $systemFile;
   open my $MAIN, '>', $mainworldFile;

   print $SYS <<SYSHDR;
---
$milieu:
  $abbr: 
SYSHDR

   print $MAIN <<MAINHDR;
---
$milieu:
  $abbr:
MAINHDR

   my $header = <$SEC>;
   my @header = split /\t/, $header;
   chomp @header;

   foreach my $line (<$SEC>)
   {
       my @data = split /\t/, $line;
       my $href = foo( \@data, \@header );
       my ($popMult, $belts, $ggs) = $href->{ 'PBG' } =~ /(.)(.)(.)/;

       my $bases = $href->{ 'Bases' } || $DASH;
       my $remarks = $href->{ 'Remarks' } || $DASH;
       my $zone  = $href->{ 'Zone'  };
       my $nobles = $href->{ 'Nobility' };
       my $RU     = $href->{ 'RU' };
       my $alleg  = $href->{ 'Allegiance' };

       my $worlds = $href->{ 'W' } || $DASH;

       $zone = $DASH unless $zone =~ /\S/;
       $nobles = $DASH unless $nobles =~ /\S/;
       $RU = $DASH unless $RU =~ /\S/;
       $alleg = $DASH unless $alleg =~ /\S/;

       foreach my $extension ('{Ix}', '(Ex)', '[Cx]')
       {
          $href->{ $extension } =~ s/[\(\)\[\]\{\}]//g; # remove all those braces
       }

       print $SYS  <<EOSYSREC;     
    $href->{'Hex'}:
      hex:     $href->{ 'Hex' }
      belts:   $belts
      ggs:     $ggs
      worlds:  $worlds
      stellar: $href->{'Stars'}

EOSYSREC

       print $MAIN <<EOMAINREC;
    $href->{'Hex'}:
      hex:        $href->{ 'Hex' }
      name:       $href->{ 'Name' }    
      uwp:        $href->{ 'UWP' }
      bases:      $bases
      remarks:    $remarks
      zone:       $zone
      pop mult:   $popMult
      allegiance: $alleg
      Ix:         $href->{ '{Ix}' }
      Ex:         $href->{ '(Ex)' }
      Cx:         $href->{ '[Cx]' }
      nobility:   $nobles
      RU:         $RU

EOMAINREC
   }
}

sub foo
{
    my $dataref = shift;
    my $keyref  = shift;
    my %hash    = map { $_ => shift(@$dataref) } @$keyref;
    return \%hash;
}

