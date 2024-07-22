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


   Its job is simple: to divide sector data into two master source YAML files:
   * system data
   * mainworld data

   The distinction is carefully made.  The following data is stored in the systems file:
   - belts
   - gas giants
   - world count
   - stellar data

   Everything else goes into the mainworlds file.

    1. Read the header keys line.
    2. Read the field format length key line and determine the lengths of each field.
    3. Split the data based on field lengths into hashes.
    4. Write out to the respective output sector files.
 
=cut
use strict;
use Data::Dumper;
$Data::Dumper::Pair = ": ";
$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;
$Data::Dumper::Useqq = 1;

my $milieu = "M1120";
my $src = "/Users/rje/git/travellermap/res/Sectors/$milieu";
my $DASH = "'-'";

foreach my $tabfile (<$src/1120_*.sec>)
{
   my ($abbr) = $tabfile =~ m#$milieu/1120_(....)#;
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
   my @header = split /\s+/, $header;
   chomp @header;

   my $fieldLengths = <$SEC>;
   my @fieldLengths = map { length($_) } split /\s+/, $fieldLengths;
   chomp @fieldLengths;

   foreach my $line (<$SEC>)
   {
       my $href = foo( $line, \@header, \@fieldLengths );
       my ($popMult, $belts, $ggs) = $href->{ 'PBG' } =~ /(.)(.)(.)/;

       my $bases = $href->{ 'Bases' } || $DASH;
       my $remarks = $href->{ 'Remarks' } || $DASH;
       my $zone  = $href->{ 'Zone'  } || $DASH;
       my $nobles = $href->{ 'N' } || $DASH;
       $nobles = $DASH if $nobles =~ /-/;

       foreach my $extension ('{Ix}', '(Ex)', '[Cx]')
       {
          $href->{ $extension } =~ s/[\(\)\[\]\{\}]//g; # remove all those braces
       }

       print $SYS  <<EOSYSREC;     
    $href->{'Hex'}:
      hex:     $href->{ 'Hex' }
      belts:   $belts
      ggs:     $ggs
      worlds:  $href->{'W'}
      stellar: $href->{'Stellar'}

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
      allegiance: $href->{ 'A' }
      Ix:         $href->{ '{Ix}' }
      Ex:         $href->{ '(Ex)' }
      Cx:         $href->{ '[Cx]' }
      nobility:   $nobles

EOMAINREC
   }

   close $SEC;
}

sub foo
{
    my $line = shift;
    my $hdrref = shift;
    my $fieldLengthsref = shift;

    my @header = @$hdrref;
    my @fieldLengths = @$fieldLengthsref;

    my $hashref = {};

    my $pos = 0;
    for(my $i=0; $i<@header; ++$i)
    {
        my $key   = $header[$i];
        my $width = $fieldLengths[$i];
        my $value = substr( $line, $pos, $width );
        $pos += $width + 1;

        $hashref->{ $key } = $value;
    }
    return $hashref;
}