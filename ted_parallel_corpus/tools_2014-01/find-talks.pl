#!/usr/bin/perl -w

# 
# written by Mauro Cettolo (FBK) - 2011
# 

use strict;
use warnings;

use Getopt::Long "GetOptions";

my ($help,$xmlFile)=();

$help=1 unless
&GetOptions(
        'xml-file=s' => \$xmlFile,
        'help' => \$help);

if ($help || !$xmlFile ){
        print "\nfind-talks.pl\n",
        "\t--xml-file <filename>: set of documents in some language (xml format)\n",
        "\t--help                 print this screen\n\n";
        exit(1);
}

my ($l,$tmp,$talkid,@talksL);

open(FH, "<$xmlFile") || die $!;
while ($l=<FH>) {
    if ($l=~/<talkid>/) {
	$tmp=$l;
	while (!($tmp=~/<\/talkid>/)) {
	    $tmp.=" ".$l;
	}
	if ($tmp=~/<talkid>[ \t]*([0-9]+)[ \t]*<\/talkid>/) {
	    $talkid=$1;
	    push @talksL, $talkid;
	} else {
	    die "error format of $xmlFile close to $tmp";
	}
    }
}
close(FH);

foreach my $t (sort{ $a <=> $b } @talksL) {
    printf "%d\n", $t;
}
