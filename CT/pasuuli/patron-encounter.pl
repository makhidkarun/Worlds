use strict;

my $list   = shift || synopsis();
my $career = shift || synopsis();
my $SOC    = shift || 0;
my $admin  = shift || 0;
my $street = shift || 0;

my $roll1 = int(rand(6)+1);
my $roll2 = int(rand(6)+1);

my @list;

if ($list == 1)
{
  $roll1-- if $career =~ /nav/i;
  $roll1++ if $career =~ /merch/i;
  $roll2-- if $street;
  $roll2++ if $admin;

  @list = getListOne();
}
else # list 2
{
  $roll1++ if $SOC > 10;
  $roll1-- if $career =~ /merch/i;
  $roll2++ if $career =~ /army|marine|soldier/i;
  $roll2-- if $career =~ /other|rogue/i;

  @list = getListTwo();
}

$roll1 = 6 if $roll1 > 6;
$roll2 = 6 if $roll2 > 6;
$roll1 = 1 if $roll1 < 1;
$roll2 = 1 if $roll2 < 1;

my $index = ($roll1-1) + ($roll2-1) * 6;

print "List $list, entry ($roll2$roll1): $list[ $index ]\n";

sub synopsis
{
	die "SYNOPSIS: $0 <list_num> <career> [<SOC> [<admin> [<streetwise>]]]\n";
}

sub getListOne
{
   return split "\n", <<__END_OF_PATRON_LIST_TWO__;
Naval Officer
Scout Administrator
Marine Officer
Hunter
Starport Warden
Naval Officer
Reporter
Technician
Doctor
Rogue
Noble
Government Official
Barbarian
Scout Pilot
Pirate
Researcher
Writer
Professor
Underworld Leader
Scientist
Belter
Naval Architect
Steward
Financier
Astrogator
Swindler
Broker
Arms Merchant 
Doctor
Pilot
Merchant 
Rogue 
Embezzler 
Belter
Bureaucrat
Diplomat
__END_OF_PATRON_LIST_TWO__
}

sub getListTwo
{
   return split "\n", <<__END_OF_PATRON_LIST_ONE__;
Arsonist
Cutthroat
Assassin
Hijacker
Smuggler
Terrorist
Crewmember
Peasant
Rumor
Clerk
Soldier
Shopkeeper
Shipowner
Tourist
Merchant
Police
Scout
Rumor
Diplomat
Courier
Spy
Scholar
Governor
Administrator
Mercenary
Naval Officer
Marine Officer
Scout
Army Officer
Mercenary
Noble
Playboy
Avenger
Emigre
Speculator
Rumor
__END_OF_PATRON_LIST_ONE__
}
