#!/usr/bin/perl -w

# 
# written by Mauro Cettolo (FBK) - 2011
# 

use strict;
use warnings;

use Getopt::Long "GetOptions";

my ($help,$xmlFile1,$xmlFile2)=();

$help=1 unless
&GetOptions(
        'xml-file-l1=s' => \$xmlFile1,
        'xml-file-l2=s' => \$xmlFile2,
        'help' => \$help);

if ($help || !$xmlFile1 || !$xmlFile2){
        print "\nfind-common-talks.pl\n",
        "\t--xml-file-l1 <filename>: set of documents in language 1 (xml format)\n",
        "\t--xml-file-l2 <filename>: set of documents in language 2 (xml format)\n",
        "\t--help                    print this screen\n\n";
        exit(1);
}

my ($l,$tmp,$talkid,%talksL1,%talksL2,@common);

open(FH, "<$xmlFile1") || die $!;
while ($l=<FH>) {
    if ($l=~/<talkid>/) {
	$tmp=$l;
	while (!($tmp=~/<\/talkid>/)) {
	    $tmp.=" ".$l;
	}
	if ($tmp=~/<talkid>[ \t]*([0-9]+)[ \t]*<\/talkid>/) {
	    $talkid=$1;
	    if (! defined $talksL1{"$talkid"}) {
		$talksL1{"$talkid"}=1;
#	    } else {
#		die "talkid $talkid occurs more than once in $xmlFile1";
	    }
	} else {
	    die "error format of $xmlFile1 close to $tmp";
	}
    }
}
close(FH);

open(FH, "<$xmlFile2") || die $!;
while ($l=<FH>) {
    if ($l=~/<talkid>/) {
	$tmp=$l;
	while (!($tmp=~/<\/talkid>/)) {
	    $tmp.=" ".$l;
	}
	if ($tmp=~/<talkid>[ \t]*([0-9]+)[ \t]*<\/talkid>/) {
	    $talkid=$1;
	    if (! defined $talksL2{"$talkid"}) {
		$talksL2{"$talkid"}=1;
#	    } else {
#		die "talkid $talkid occurs more than once in $xmlFile2";
	    }
	} else {
	    die "error format of $xmlFile2 close to $tmp";
	}
	if (defined $talksL1{"$talkid"}) {
	    push @common, $talkid;
	}
    }
}
close(FH);

foreach my $t (sort{ $a <=> $b } @common) {
    printf "%d\n", $t;
}
