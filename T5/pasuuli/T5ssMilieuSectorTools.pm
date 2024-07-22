package T5ssMilieuSectorTools;
=pod

   Utility for dealing with T5SS data per milieu.

=cut
use UWP;

sub getMilieux
{
   my $milieu      = shift;
   my $all_milieux = shift;
   my @milieu      = ();

   return ($milieu) if $milieu;

   # all milieux
   foreach my $dir (<M*>)
   {
      push @milieu, $dir if $dir =~ /M\d\d\d\d/ && $dir ne 'M1105';
   }
   return @milieu;
}

sub readMilieuSector
{
   my ($targetMilieu, $sectorName) = @_;
   my ($filename) = <$targetMilieu/*$sectorName*>;
   my %sector;

   print "sec file [$filename]\n";

   open my $SEC,  '<', $filename;
   my $header = <$SEC>;
   if ( $filename =~ /\.tab$/ )
   {
      my @header = split /\t/, $header;
      chomp @header;

      foreach my $line (<$SEC>)
      {
         chomp $line;
         my $href = read_tabbed( $line, \@header );
         $href = sanitize( $href );
         $sector{ $href->{ 'Hex' } } = $href;
      }
   }
   else
   {
      my @header = split /\s+/, $header;
      chomp @header;

      my $fieldLengths = <$SEC>;
      my @fieldLengths = map { length($_) } split /\s+/, $fieldLengths;
      chomp @fieldLengths;

      foreach my $line (<$SEC>)
      {
         chomp $line;
         my $href = read_substr( $line, \@header, \@fieldLengths );
         $href = sanitize( $href );
         $sector{ $href->{ 'Hex' } } = $href;
      }
   }
   close $SEC;

   print " - loaded ", scalar keys %sector, " UWPs\n";
   print "\n";
   return \%sector;
}

#
#   Fixes the field names in a world reference hash.
#
sub sanitize
{
   my $world = shift;
   # you wouldn't believe the stuff they put in here.

   $world->{ 'Stellar' } = $world->{ 'Stars' } if $world->{ 'Stars' };
   delete $world->{ 'Stars' };

   $world->{ 'Allegiance' } = $world->{ 'A' } if $world->{ 'A' };
   delete $world->{ 'A' };

   # split out the UWP and PBG
   UWP::decodeUWP( $world, $world->{ 'UWP' });
   UWP::parsePBG( $world, $world->{ 'PBG' });

   return $world;
}
#
#   Reads a file of data delimited by tabs.  Very easy.
#
sub read_tabbed
{
    my $line    = shift;
    my $keyref  = shift;
    my @data    = split /\t/, $line;
    my %hash    = map { $_ => shift(@data) } @$keyref;
    return \%hash;
}

#
#   Reads a file of data delimited by headers with dashed lines
#   which indicate field lengths.  Slightly complicated.
#
sub read_substr
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

        $value =~ s/\s*$//;  # trim

        $pos += $width + 1;

        $hashref->{ $key } = $value;
    }
    return $hashref;
}


1; # return a 1 as all good Perl modules should.