#!/usr/local/bin/perl
use CGI;
#use strict;

my $cgi = new CGI;
print $cgi->header;

my %hex2dec = 
(
  '0' => 0, '1' => 1, '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9,
  'A' => 10, 'B' => 11, 'C' => 12, 'D' => 13, 'E' => 14, 'F' => 15, 'G' => 16, 'H' => 17, 'J' => 18, 'K' => 19,
  'L' => 20, 'M' => 21, 'N' => 22, 'P' => 23, 'Q' => 24, 'R' => 25, 'S' => 26, 'T' => 27, 'U' => 28, 'V' => 29,
  'W' => 30, 'X' => 31, 'Y' => 32, 'Z' => 33
);

my $test = "Fubar World  0101  A123456-7";
my $text = $cgi->param( "line" ) || $test;
my @result = ();

foreach my $line (split "\n", $text)
{
   my ($name, $hex, $uwp) = $line =~ /^(.*?)\s+(\d\d\d\d)\s+(\S\S\S\S\S\S\S-\S)/;
   my $result = "";

   unless ($uwp)
   {
      $uwp = shift;
      ($name, $hex, $uwp) = $uwp =~ /^(.+\S)\s+(\d\d\d\d) (.{7}-.)/;
   }

   if ( $uwp )
   {
      srand seed($hex, $uwp);
      $result = doit( $name, $hex, $uwp );
   }

   push @result, $result;
}

my $out = join "", @result;

print<<EOTOP;
<html>
<body>
<a href="../scripts/vilanitools.html">Vilani Tools</a> <br />
<form method="post">
Name Hex UWP: <input type="submit"> <br />
<textarea rows="11" cols="40" name="line">$text</textarea> <br />
Results: <br />
<textarea cols="80" rows="20">$out</textarea>
</form>
</body>
</html>
EOTOP


#foreach (<DATA>)
#{
#   my ($name, $hex, $uwp) = $_ =~ /^(.+\S)\s+(\d\d\d\d) (.{7}-.)/;
#
#   print doit($name, $hex, $uwp);
#}

sub seed
{
   my ($hex, $uwp) = @_;
   
   # make sure $hex has no leading (octal) zeroes.
   $hex =~ s/^0//g;

   # construct a *computed* seed value
   my $seed = $uwp;
      $seed =~ s/-//g;
      $seed =~ s/[G-Z]/0/g;
      $seed = "0x$seed";
      
   return eval "$hex + $seed";
}


sub doit
{
   my $name  = shift;
   my $hex   = shift;
   my $uwp   = shift;

   my ($port, $size, $atm, $hyd, $pop, $gov, $law, $dash, $tl) = split '', $uwp;

   foreach ($size, $atm, $hyd, $pop, $gov, $law, $dash, $tl)
   {
      $_ = $hex2dec{$_};
   }

   my $planet    = planet($size);

   my $desc      = desc($size,$atm,$hyd,$planet);
   my $atmosphere = atmosphere($size, $atm, $hyd);
   my $pressure   = pressure($size, $atm, $hyd);
   my $seas      = seas($atm, $hyd);
   my $diameter  = diameter($size);
   my $circ      = circumference($diameter);
   my $day       = dayLength($diameter);
   my $gravity    = gravity($diameter, $atm);
   my $temp      = temp($size, $atm, $hyd,$planet);
   my $temp_seas = temp_seasonal($size, $atm, $hyd);
   my $temp_alt  = temp_altitude($size, $atm, $hyd);

   my $yearLength = year($planet);
   my $satellites = moons($planet);

   my $pop       = population($pop);
   my $gov       = government( $gov );
   my $laws      = laws( $law );
   my $tech      = tl( $tl );

   $circ       =~ s/(\d)(\d\d\d)$/$1,$2/;
   $diameter   =~ s/(\d)(\d\d\d)$/$1,$2/;
   $pressure   =~ s/(\d)(\d\d\d)$/$1,$2/;
   $yearLength =~ s/(\d)(\d\d\d)$/$1,$2/;

   $day = "in fact 24" if $day == 24;

   my $atSeaLevel = '';
   $atSeaLevel = ' at sea level' if $hyd ne '0';

   if( $pressure == 0 )
   {
      $pressure = '';
   }
   else
   {
      $pressure = " and a pressure of $pressure kPa$atSeaLevel";
   }
   
   if ( $atmosphere =~ /standard gas/ && $atmosphere =~ /standard atmosphere/ )
   {
      $atmosphere = '';
   }
   else
   {
      $atmosphere = "It has $atmosphere$pressure. ";
   }
   
   my $altitude = ", with a temperature change of $temp_alt C per kilometre altitude";
   $altitude = '' if $hyd == 10;
   
   return<<EOTEXT;
$name ($hex) $uwp

$name is a $desc $planet, with a diameter of $diameter km and a circumference of $circ km. ${atmosphere}It has $seas, and its surface gravity is $gravity G. It has a year of $yearLength 24-hour days; its actual day length is $day hours. There $satellites. Average temperature is $temp C$altitude.

$name $pop. It $gov, and its laws $laws. Its tech is equivalent to $tech.


EOTEXT
}

sub gravity
{
   my $diameter  = shift;
   my $atmos = shift;

   my $g = (0.2 + $diameter / 10) / 1000;
         
   return abs ( int( $g * 10 ) / 10 + flux()/20 );
}

sub pressure
{
   my $size  = shift;
   my $atmos = shift;
   my $hyd   = shift;
   
   my @pressureBySize = ( 0, 0.01, 0.2, 0.2, 0.7, 0.7, 1.0, 1.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 );
   my $pressure = $pressureBySize[ $atmos ] * (1+flux()/25);
      
   $pressure += ($size + $hyd - 15) / 400 if $pressure > 0;
   
   return abs( 10 * int(($pressure * 100 + flux())/10) );
}

sub moons
{
   my $desc = shift; # planetary description
   return "are no moons" if $desc =~ /planetoid|satellite/;

   my $sats = abs flux() || 'no';

   if ( $sats == 1 )
   {
      $sats = "is 1 moon";
   }
   else
   {
      $sats = "are $sats moons";
   }

   return $sats;
}
   
sub year
{
   my $desc = shift; # planetary description
   
   my $orbit = rand(3); # or whatever
   $orbit++ if $desc =~ /outward/;
   $orbit-- if $desc =~ /inward/;

   my $au = 0.4 + 0.3 * (2**$orbit);
   
   return int( 365 * sqrt($au * $au * $au) );
}

sub planet
{
   my $size = shift;

   my $desc = 'planet';
   $desc = 'planetoid' if $size == 0;

   my $flux = int(rand(6)) - int(rand(6)); # flux();
   
   if ( $flux < -1 )
   {
      $desc = 'close satellite' if $flux == -2;
      $desc = 'far satellite'   if $flux < -3;

      $flux = flux();
      $desc .= ' of a gas giant' if $desc =~ /satellite/ && $flux < -2;
      
   }
   
   my $hz = flux();
   if ( $hz > 2 )
   {
      $desc .= " one orbit inward from the habitable zone";
   }
   elsif ( $hz < -2 )
   {
      $desc .= " one orbit outward from the habitable zone";
   }
   
   return $desc;
}


sub orbit
{
   my ($size, $atm, $hyd, $tl) = @_;
}

sub population
{
   my $pop = shift;
   
   return "is uninhabited" if $pop == 0;
 
   my $desc = "has a ";
   
   $desc .= 'transient ' if $pop < 6;
   $desc .= 'population';
   
   $desc .= ' in the millions' if $pop == 6;
   $desc .= ' in the tens of millions' if $pop == 7;
   $desc .= ' in the hundreds of millions' if $pop == 8;
   $desc .= ' in the billions' if $pop == 9;
   $desc .= ' in the tens of billions' if $pop == 10;
      
   return $desc;
}

sub government
{
   my $gov = shift;

   my @gov =
   ( 
    "has no government structure",
    "is a corporate state",
    "is a participating democracy",
    "is a self-perpetuating oligarchy",
    "is a representative democracy",
    "is a feudal technocracy",
    "is a captive government",
    "has many regional governments",
    "is a civil service bureaucracy",
    "is an impersonal bureaucracy",
    "is a charismatic dictatorship",
    "has a non-charismatic leader",
    "is a charismatic oligarchy",
    "is a religious dictatorship",
    'is a religious autocracy',
    'is a totalitarian oligarchy',
    "is a military government",
   );
   
   $gov[ $gov ];
}

sub laws
{
   my $ll = shift;

   my @ll =
   (  
      'are unrestrictive',
      'forbid carrying body pistols, explosives, and poison gas',
      'forbid portable energy weapons',
      'forbid military weapons',
      'forbid military and light assault weapons',
      'forbid assault weapons and concealable firearms',
      'forbid most firearms',
      'forbid most firearms, including shotguns',
      'control long bladed weapons, and forbid open possession',
      'prohibit the possession of weapons outside the home',
      'prohibit all weapons',
      'require continental passports',
      'allow unrestricted invasion of privacy',
      'authorize paramilitary law enforcement',
      'amount to a fully-fledged police state',
      'rigidly control daily life',
      'mandate disproportionate punishments',
      'legalize oppressive practices',
      'routinely oppress and restrict'
   );
   
   return $ll[ $ll ];
}

sub tl
{
   my $tl = shift;

   my @tl =
   (
      'the stone age',
      'the bronze or iron age',
      'the rennaissance',
      'the 18th century',
      'the mid 19th century',
      'the early 20th century',
      'the atomic age',
      'the semiconductor age',
      'the space age',
      'that of an early interstellar civilization',
      'that of a low interstellar civilization',
      'that of an average interstellar civilization',
      'that of an average interstellar civilization',
      'that of an above-average interstellar civilization',
      'that of an above-average interstellar civilization',
      'the Third Imperium\'s best technology',               # 15
      'that beyond the Third Imperium\'s best technology',   # 16
      'that of an interstellar civilization with antimatter power',  # 17
      'that of a highly automated interstellar civilization',        # 18
      'that of an interstellar civilization with disruptor weapons', # 19
   );

   return $tl[$tl];
}

sub desc
{
   my $size = shift;
   my $atm  = shift;
   my $hyd  = shift;
   my $planet = shift;
   
   my $desc = "medium-sized";

   $desc = "small" if $size < 5;
   $desc = "large" if $size > 8;

   $desc = "cold, $desc" if $planet =~ /outward/;
   $desc = "hot, $desc"  if $planet =~ /inward/;
   
   $desc .= " water"  if $hyd == 10;
   $desc .= " desert" if $hyd == 0 && $size > 0 && $atm > 0;

   return $desc;  
}

sub atmosphere
{
   my $size  = shift;
   my $atm   = shift;
   my $hyd   = shift;
   
   my $desc = "";
      
   $desc .= "no" if $atm == 0;
   $desc .= "a trace" if $atm == 1;
   $desc .= "a very thin" if $atm >= 2 && $atm <= 3;
   $desc .= "a thin" if $atm >= 4 && $atm <= 5;
   $desc .= "a standard" if $atm >= 6 && $atm <= 7;
   $desc .= "a dense" if $atm > 7;
   
   $desc .= ", corrosive" if $atm > 10;
   
   $desc .= " atmosphere";

   $desc .= " with a standard gas mixture" if ($atm == 3 || $atm == 5 || $atm == 6 || $atm == 8);
   $desc .= " with a tainted gas mixture"  if ($atm == 2 || $atm == 4 || $atm == 7 );
   $desc .= " with a tainted, exotic gas mixture" if $atm == 9;
   $desc .= " with an exotic gas mixture"  if $atm == 10;
   
   if ( $atm > 10 )
   {
      $desc .= ' composed of a' . hostileAtmosphere() . ' mix';
   }
   #$desc .= " that is highly corrosive"    if $atm > 10;
      
   return $desc;
}


sub hostileAtmosphere
{
   #my $zone = shift;

   my $zones = 
   {
      'inner' => [ 'neon', ('co2') x 4, ('n2') x 4, ('nitroxy') x 2 ],
	  'hab'   => [ 'neon', ('co2') x 2, ('n2') x 1, 'ammonia', ('nitroxy') x 1, ('chlorox') x 2, 'carbon', 'so2', 'sulfuric acid' ],
	  'outer' => [ 'neon', ('co2') x 2, ('n2') x 2, 'ammonia', ('carbon') x 2, 'so2', ('o2') x 2 ]
   };
   
   my @atmoList = @{$zones->{ 'hab' }};
   my $atmo = $atmoList[ dice()-2 ];
   
   if ( $atmo eq 'carbon' )
   {
      my @carbons = [ 'methane', 'ethane', 'propane', 'butane', 'pentane' ];
	  $atmo = $carbons[ rand @carbons ];
   }
   
   $atmo =~ s/chlorox/chlorine-oxygen/;
   $atmo =~ s/co2/carbon dioxide/;
   $atmo =~ s/n2/nitrogen/;
   $atmo =~ s/nitroxy/nitric acid/;
   $atmo =~ s/so2/sulfur dioxide/;

   return "n $atmo" if $atmo =~ /ammonia/;
   return ' ' . $atmo;

=pod   
   my $types =
   {
	  'co2' => { 'zones' => 'i', 'temp' => 50 },
	  'carbon'  => { },
	  'chlorox' => { },
	  'n2' => {},
	  'nitroxy' => {},
	  'sulfuric acid' => { 'zones' => 'hm', 'temp' => -30 }
      'ammonia' => { 'zones' => 'm', 'temp' => -55, 'pressure' => 'low' },
	  'so2' => { 'zones' => 'hmo', 'temp' => -40 },
	  'neon' => { 'zones' => 'o' },
	  'oxygen' => { 'zones' => 'o', 'pressure' => 'low' },
   };
=cut

}

sub seas
{
   my $atm = shift;
   my $hyd = shift;
   
   my $desc = "";
   
   $desc = "seas of water covering " . ($hyd * 10) . "% of its surface"
      if $hyd > 0 && $hyd < 10 && $atm < 10;
   
   $desc = "non-water seas covering " . ($hyd * 10) . "% of its surface"
      if $hyd > 0 && $atm > 9;
    
   $desc = "no surface water" if $hyd == 0;

   if ( $hyd == 10 )
   {
      my $depth = int(10+rand(190)) * 100;
      $depth =~ s/(\d)(\d\d\d)$/$1,$2/;
      $desc = "an average depth of $depth metres";
   }
   
   return $desc;
}
    
sub flux
{
   return int(rand(6)) - int(rand(6));
}

sub dice
{
   return int(rand(6)+1) + int(rand(6)+1);
}

sub diameter
{
   my $size = shift;
   
   return int(1 + rand(100)) if $size == 0;

   my $diameter = ($size * 1600 + 100 * flux() + 10 * flux());
   
   return $diameter;
}


sub circumference
{
   my $size = shift;
   
   return int($size * 3.1416 / 10) * 10
}

sub dayLength
{
   my $diameter = shift;
   
   return int($diameter/1600 + 2 * dice());
}

sub temp
{
   my $size = shift;
   my $atm  = shift;
   my $hyd  = shift;
   my $planet = shift;
   
   $size += flux();
   $atm  += flux();
   $hyd  += flux();
   
   $size -= 2 * dice() if $planet =~ /outward/;
   $size += 2 * dice() if $planet =~ /inward/;
   
   return $size + $atm + $hyd;
}

sub temp_seasonal
{
   my $size = shift;
   my $atm  = shift;
   my $hyd  = shift;

   my $temp = temp( $size, $atm, $hyd );
   
   $atm = 1 if $atm == 0;
   $hyd = 1 if $hyd == 0;
   
   return abs( flux() + int(($temp + 2 * $atm) / $hyd ) );
}

sub temp_altitude # per 1000m
{
   my $size = shift;
   my $atm  = shift;
   my $hyd  = shift;

   my $temp = temp( $size, $atm, $hyd );

   $atm = 1 if $atm == 0;
   $hyd = 1 if $hyd == 0;

   my $alt = int(10 * (12 - $size) / ( $atm + $hyd ));
   
   return -$alt;
}


__DATA__
Hollis             0103 A370642-B S De Ni             303 Na
Orond              0107 E921500-8   He Ni Po          500 Na
Tennou             0108 D536732-9 S Ni                701 Na
Solgrethe          0203 C300725-A   Ni Va             410 Na
Gnobit             0304 E535898-8                     111 Ca
Lelia              0310 C9747A4-A   Ag Pi             500 Na
Denestle           0402 C000653-9   Lo Ni As          124 Na
Pomel              0403 B554467-9                     501 Ca
Corlano            0409 C866888-9   Ri                500 Na
Lantiine           0503 B225669-8   Ni                522 Ca
Calida             0504 A667739-B N                   611 Ca
Canlasci           0505 C4518AA-8   Po                520 Na
TOAR               0506 D5409B8-7   Hi Na In Po De    520 Na
Verde              0507 C5877A9-9   Ag                402 Na
Pelloc             0601 E469512-7   Ni                700 Na
Aderni             0607 A779889-A N Ph Pi             511 Na
Pelsansec          0608 E442652-4                     301 Na
Terene             0706 B670621-9   De He Ni          211 Na
Beceru             0709 C431877-8   Ni Po             110 Na
Inesca             0807 E574352-8   Lo Ni             623 Na
Alenzar            0809 C000414-9   As Ni             513 Na
Raschev            0810 C8897C4-6                     123 Na
