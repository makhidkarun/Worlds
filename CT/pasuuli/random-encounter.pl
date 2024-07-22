use strict;

my @random = <DATA>;

sub dice { my $sum = 0; $sum += int(rand(6)+1) for 1..$_[0]; return $sum; }

my $roll1 = int(rand(6)+1);
my $roll2 = int(rand(6)+1);

print '-' x 50, "\n";
print "Random Encounter $roll2$roll1: ";

if ($roll2 == 6) 
{
   print "none\n\n";
   exit;
}

$roll1--;
$roll2--;

my $index = $roll1 + $roll2 * 6;

my ($count, $type, $remarks) = split ':', $random[ $index ];

$type =~ s/\s*$//;
chomp $remarks;

print dice($count), " $type\n";
print " - TL$1.\n" if $remarks =~ /([+-]\d)/;
print " - Leader present.\n" if $remarks =~ /L/;
print " - Armed.\n" if $remarks =~ /G/;
print " - Wearing armor.\n" if $remarks =~ /A/;
print " - With vehicle/riding beasts." if $remarks =~ /V/;
print "\n\n";
__DATA__
1D:Peasants              :-3                          
2D:Peasants              :-2          
2D:Workers               :-1         
3D:Rowdies               :L         
2D:Thugs                 :L       
4D:Riotous Mob           :-1            
2D:Soldiers              :+1LGA        
2D:Soldiers              :LGAV          
1D:Police Patrol         :+1GA               
2D:Marines               :LGA         
3D:Security Troops       :+1GA                 
2D:Soldiers on Patrol    :LGA                    
1D:Adventurers           :+2GAV             
2D:Noble with Retinue    :LGAV                    
2D:Hunters and Guides    :+1LGV                    
2D:Tourists              :+2          
1D:Researchers           :+3V             
1D:Police Patrol         :VG               
1D:Fugitives             :-2           
2D:Fugitives             :V           
3D:Fuqitives             :G           
2D:Vigilantes            :G            
3D:Bandits               :L         
3D:Ambushing Brigands    :LGA                    
1D:Merchants             :+1LA           
2D:Traders               :GV         
2D:Religious Group       :                 
1D:Beggars               :L         
5D:Pilgrims              :A         
3D:Guards                :A        