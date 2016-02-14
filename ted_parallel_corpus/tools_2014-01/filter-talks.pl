#!/usr/bin/perl


#
# written by Marcello Federico (FBK) - 2010
#

use strict;
use warnings;


use Getopt::Long "GetOptions";


my ($help,$talk_ids,$xml_file,$uniq)=();

$uniq=0;
$help=1 unless
&GetOptions(
	'talkids=s' => \$talk_ids,
	'xml-file=s' => \$xml_file,
	'uniq' => \$uniq,
	'help' => \$help);

if ($help || !$talk_ids || !$xml_file){
	print "\nfilter-talks.pl\n",
	"\t--talkids  <filename> file with talk ids to be extracted\n",
	"\t--xml-file <filename> xml corpus\n",
	"\t--uniq     print once each talk even if occurs more times (optional; default: print all of them)\n",
	"\t--help     print this screen\n\n";

	exit(1);
}

printf "<xml>\n";

open (FILTER,$talk_ids)|| die $!;

my (%talk2extract, %alreadyprinted);
while(<FILTER>){
    chop; $_=~s/[ \t]+/ /g; $_=~s/^ | $//g;
    $talk2extract{$_}=1 if ($_);
}

close(FILTER);

open (CORPUS,$xml_file)|| die $!;
my $i=0;
my (@buffer, $talkid);
$talkid=-1;
while(my $line=<CORPUS>){
    if ($line=~/<\/file>/){
	push @buffer,$line;

	if ($talkid==-1 ||
	    (defined $talk2extract{"$talkid"} && 
	     (!($uniq && defined $alreadyprinted{"$talkid"})))) {
	    $alreadyprinted{"$talkid"}=1;
	    foreach my $i (0..$#buffer){
		print $buffer[$i];
	    }
	} 
	@buffer=();
    } else{
	if ($line=~/<talkid>(.+)<\/talkid>/) {
	    $talkid=$1;
	}
	push @buffer,$line if (!($line=~/<xml/) && !($line=~/<\?xml version/));
    }
}

printf "</xml>\n";

close(CORPUS);
