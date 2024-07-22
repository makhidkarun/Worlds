package Name2;
use Jenkins2rSmallPRNG qw/t5srand randposint/;

my @phone = (
        'ar',  'ar',  'iz',  'at',  'ta',  'da',  'ra', 
        'le',  'ig',  'en',  'ix',  'ag',  'ti',  'id',
        'ro',  'ga',  'ex',  'ox',  'lo',  'ca',  'ni',
        'me',  'li',  'to',  'la',  'wo',  'de',  'ru',

 	'de',  'ag',  'ro',  'po',  'ta',  'se',  'in', 
 	'mo',  'lu',  'de',  'ri',  'pe',  'st',  'er',
	'st',  'ro',  'ta',  'so',  'ar',  'ru',  'wa', 

	'wo', 'ad', 'ak', 'wa', 'en', 'eg', 'de', 'ac', 
	'oc', 'op', 'or', 'pa', 're', 'ri', 'mu', 'ti',
	've', 'wi', 'vi', 'ju', 'mo', 'me', 'ne', 'ut',

	'a', 'i', 'u', 'e', 'o', 'bec', 'tle', 'fle',

	'sho', 'ona', 'ora', 'pho', 'sho', 'for', 'gue', 
        'lan', 'las', 'den', 'tin', 'art', 'ort', 'ert', 
        'ang', 'ing', 'eng', 'ong', 'ant', 'ont', 'int',
        'ind', 'und', 'end',

        'tri',  'ito',  'mer',  'alu',  'bel',  'dec',  'rem',  
        'men',  'duc',  'sco',  'the',  'dre',  'own',  'epi',  
        'cen',  'can',  'sar',  'gen',  'ter',  'agre', 'ate',  
        'bit',  'hen',  'hos',  'gra',  'gno',  'cid',  'can',  
        'ard',  'cor',  'cre',  'ous',  'ath',  'ain',  'whe',  
        'luc',  'lin',  'mat',  'med',  'mis',  'mel',  'mar', 
        'nec',  'nor',  'nes',  'nou',  'ost',  'pel',  'pro',  
        'por',  'pri',  'pla',  'fri',  'reg',  'san',  'sal',  
        'ine',  'sol',  'sem',  'sec',  'sul',  'sca',  'sci',
        'she',  'ran',  'mer',  'mir',  'spi',  'sta',  'tec',
        'aph',  'tel',  'tol',  'tom',  'ten',  'tor',  'ter', 
        'loc',  'val',  'ver',  'erg',
        '',     '',     '',     '',    '',     '',     '',     '',
        '',     '',     '',     '',    '',     '',     '',     '',
        '',     '',     '',     '',    '',     '',     '',     '',
        '',     '',     '',     '',    '',     '',     '',     '',
        '',     '',     '',     '',    '',     '',     '',     '',
        '',     '',     '',     '',    '',     '',     '',     '',
        '',     '',     '',     '',    '',     '',     '',     ''

);

my $phoneArraySize = scalar @phone;

sub name
{
   $name = '';
   until (length($name) > 1)
   {
      $_ = '';
      $_ = $phone[randposint($phoneArraySize)].$phone[randposint($phoneArraySize)].$phone[randposint($phoneArraySize)]
         until ($_ ne '');

      ($head, $tail) = /^(.)(.*)/;
      $head =~ tr/[a-z]/[A-Z]/;
      $name = $head.$tail;
   }
   return $name;
}

1;

