use strict;

my @rumorMatrix
	= qw/
			0  1  2  3  4  5
			6 20 20 22 22  7
			8 20 24 24 22  9
		   10 23 25 25 21 11
		   12 23 23 21 21 13
		   14 15 16 17 18 19
		/;

my @rumors = <DATA>;

my $index = $rumorMatrix[ rand @rumorMatrix ];

print "Rumor No. $index: $rumors[ $index ]";

__DATA__
Background information
Minor fact
Major fact
Partial (potentially misleading) fact
Veiled clue
Information leading to trap
Location data
Important fact
Obvious clue
Completely false information
Terminology
Library data reference
Helpful data
Location data
Reliable recommendation to action
Major fact
Background information
Minor fact
Veiled clue
Misleading clue
Broad background information
Misleading background information
Reference to library data
General location data
Specific background data
Misleading background data