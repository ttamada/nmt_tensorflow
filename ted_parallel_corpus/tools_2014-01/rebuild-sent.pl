#!/usr/bin/perl -w

#
# written by Mauro Cettolo (FBK) - 2011
#

use strict;
use warnings;

use Getopt::Long "GetOptions";

my ($help,$srcf,$tgtf,$printempty)=();

$printempty=0;
$help=1 unless
&GetOptions(
        'file-l1=s' => \$srcf,
        'file-l2=s' => \$tgtf,
        'print-empty' => \$printempty,
        'help' => \$help);

if ($help || !$srcf || !$tgtf){
        print "\nrebuild-sent.pl\n",
        "\t--file-l1 <filename> sentence fragments in language 1\n",
        "\t--file-l2 <filename> sentence fragments in language 2\n",
        "\t--print-empty        pairs with empty sides are also printed (optional; default: no print)\n",
        "\t--help               print this screen\n\n";
        exit(1);
}

open(IS, "<$srcf") || die $!;
open(IT, "<$tgtf") || die $!;

my($srcof,$tgtof,$src,$tgt,$dot,$tmps,$tmpt);

$srcof=$srcf.".sent";
$tgtof=$tgtf.".sent";

open(OS, ">$srcof") || die $!;
open(OT, ">$tgtof") || die $!;

while ($src=<IS>, $tgt=<IT>) {
    chop($src); chop($tgt);
    $tmps.=$src." ";
    $tmpt.=$tgt." ";
    if ($tgt=~/[<>\.\!\?][ \t]*$/ || $tgt=~/[<>\.\!\?]\"[ \t]*$/) {
	if ($printempty || !($tmps=~/^[ \t]*$/) && !($tmpt=~/^[ \t]*$/)) {
	    printf OS "%s\n", $tmps;
	    printf OT "%s\n", $tmpt;
	}
        $dot="yes";
	$tmps=$tmpt="";
    } else {
        $dot="no";
    }
}

if ($dot eq "no") {
    if ($printempty || !($tmps=~/^[ \t]*$/) && !($tmpt=~/^[ \t]*$/)) {
	printf OS "%s\n", $tmps;
	printf OT "%s\n", $tmpt;
    }
}

close(OS);
close(OT);
close(IS);
close(IT);
