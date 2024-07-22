#!/usr/local/bin/perl
use CGI;
use Data::Dumper;
$Data::Dumper::Terse = 1;
$Data::Dumper::Pair = ': '; # JSON output
use UWP;
$| = 1;

my $help = <<EOHELP;

*****************************************************
UWP-HELPER

DESKTOP USAGE EXAMPLE: 
perl uwp-helper.cgi uwp=A788899-C bases=DS tldm=-2

WEB USAGE EXAMPLE:
http://.../uwp-helper.cgi?uwp=A788899-C&bases=DS&tldm=-2

INPUTS:
- uwp
- bases
- TL die modifier

If you don't supply a UWP, an example one will be used,
and this help message will be included in the output.

OUTPUTS:
- recalculated TL
- UWP with new TL
- recalculated Trade Codes
- reclaculated Importance
- recalculated Infrastructure
- recalculated Cultural Extension

The output is in JSON with the following example for the format:

{ 
   'uwp': 'A788899-9', 
   'starport': 'A', 
   'siz': 7, 
   'atm': 8, 
   'hyd': 8, 
   'pop': 8, 
   'gov': 9, 
   'law': 9, 
   'tl': 9, 
   'trade_codes': 'Ph Pa Ri', 
   'ix': { 'importance': 1 } 
   'ex': { 'infrastructure': 3 }, 
   'cx': { 'acceptance': 9, 'symbols': 4, 'strangeness': 1, 'homogeneity': 3 }, 
} 

*****************************************************
EOHELP

my $cgi = CGI->new;

print "Content-type: text/html\n\n";
sleep 1;

my $uwp    = $cgi->param( 'uwp' )    || 'D867973-8';
my $bases  = $cgi->param( 'bases' )  || '';
my $tldm   = $cgi->param( 'tldm' )   || 0;

my ($sp,$s,$a,$h,$p,$g,$l,$tl) = $uwp =~ /([ABCDEX])(\w)(\w)(\w)(\w)(\w)(\w)-(\w)/;

#
# Build the world structure
#
my $world = 
{
   'starport' => $sp,
   'siz' => $s,
   'atm' => $a,
   'hyd' => $h,
   'pop' => $p,
   'gov' => $g,
   'law' => $l,
   'tl'  => $tl,
   'bases' => $bases,
   'timestamp' => time,
   'date' => scalar localtime,
};

$world->{ 'naval_base'  } = 1 if $bases =~ /[ND]/;
$world->{ 'scout_base'  } = 1 if $bases =~ /S/;
$world->{ 'way_station' } = 1 if $bases =~ /W/;

$world->{ 'help' } = $help if $uwp eq 'D867973-8';

#
# Recalculate TL
#
my $newtl = UWP::techLevel( $world, int(rand(6)+1) + $tldm );

#
# Update UWP with new TL
#
$world->{ 'tl' } = $newtl;
my $newuwp = UWP::encodeUWP( $world );
$world->{ 'uwp' } = $newuwp;
   
#
# Regenerate trade codes
#
my $codes = UWP::tradeCodes( $newuwp );
$world->{ 'trade_codes' } = $codes;

#
# Regenerate world Importance
#
my $ix = UWP::importance( $world );

#
# Reroll Infrastructure
#
UWP::infrastructure( $world );

#
# Reroll cultural extension
#
UWP::culturalExtension( $world );

#
# Now dump it to STDOUT
#
print Dumper( $world );

