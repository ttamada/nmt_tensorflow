#! /usr/bin/perl

#*****************************************************************************
# Copyright (C) 2010 Marcello Federico, FBK Trento, Italy
#******************************************************************************

use strict;
use Getopt::Long "GetOptions";


my ($help,$tag,$xsrc,$xtgt,$outsrc,$outtgt,$outdel,$verbose)=();
my ($filter,$Nout)=0;

$tag=0;
$help=1 unless
&GetOptions('xmlsource=s' => \$xsrc,
	    'xmltarget=s' => \$xtgt, 
            'outsource=s' => \$outsrc,
            'outtarget=s' => \$outtgt,
            'outdiscarded=s' => \$outdel,
            'tag'         => \$tag,
	    'filter=s'    => \$filter,
            'help'        => \$help,
            'verbose'     => \$verbose);

if ($help || !$xsrc|| !$xtgt|| !$outsrc || !$outtgt){
    print "\nted-extract-par.pl\n",
    "\t--xmlsource    <filename>  specify xml file with source language talks\n",
    "\t--xmltarget    <filename>  specify xml file with target language talks\n",
    "\t--outsource    <filename>  specify file where storing parallel source side\n",
    "\t--outtarget    <filename>  specify file where storing parallel target side\n",
    "\t--outdiscarded <filename>  specify file where storing discarded pairs\n",
    "\t--filter       <num>       discard outliers based on normal-mean test (e.g. num >= 1.96) \n",
    "\t--tag                      print also talks metadata (optional; default: no print)\n",    
    "\t--help                     print these instructions (optional)\n\n\n";    

    exit(1);
}


#load source data
my (@stext,%sindex)=();
&load($xsrc,\@stext,\%sindex);

#load target data
my (@ttext,%tindex)=();
&load($xtgt,\@ttext,\%tindex);


my $title;

warn "Check misaligned documents\n";
for $title (keys %sindex){
    if (defined($tindex{$title})){
	#consistency check
	if (($sindex{$title}[1]-$sindex{$title}[0]) != 
	    ($tindex{$title}[1]-$tindex{$title}[0])){
	    print "Discard $title: ";
	    print "srclen: ",($sindex{$title}[1]-$sindex{$title}[0]);
	    print " != tgtlen: ",($tindex{$title}[1]-$tindex{$title}[0]),"\n";
	    undef($sindex{$title}[0]);
	}else{
	    my $n=$sindex{$title}[1]-$sindex{$title}[0]; 
	    for (my $i=0;$i<=$n;$i++){
		my $s=$stext[$sindex{$title}[0]+$i];
		my $t=$ttext[$tindex{$title}[0]+$i];
		my ($sseeknum)=$s=~/seekvideo id=\"(\d+)\"/;
		my ($tseeknum)=$t=~/seekvideo id=\"(\d+)\"/;
		if ($sseeknum ne $tseeknum){
		    print "misaligned segment in ($title)\n";
		    print "Discard full document!\n";
		    undef($sindex{$title}[0]);	
		    last;
		}
	    }
	}
    }			
}	


warn "Compute document-level and global level statistics\n";
my ($N,$s1,$s2)=(0,0,0);
for $title (keys %sindex){
    if (defined($sindex{$title}[0]) && defined($tindex{$title})){
        my $n=$sindex{$title}[1]-$sindex{$title}[0]; 
        for (my $i=0;$i<=$n;$i++){
	    my $s=$stext[$sindex{$title}[0]+$i];
	    my $t=$ttext[$tindex{$title}[0]+$i];

	    if ($s=~/seekvideo/){
		my $r=wlength($s)/wlength($t);
				#printf("aaa %2.1f\n",$r);
				#global level statistics 
		$N++;$s1+=$r;$s2+=$r*$r;
				#document level statistics (not used yet)
		$sindex{$title}[2]+=1;
		$sindex{$title}[3]+=$r;
		$sindex{$title}[4]+=$r*$r;
	    }		
	}	
    }
}

#global sample standard deviation
my $SD=sqrt(($N * $s2 - $1*$s1)/($N*($N-1)));
printf(STDERR "Average length ratio: %2.2f  STDDEV: %2.2f\n",$s1/$N,$SD);


#Print output documents and filter out outliners

printf STDERR "opening for writing $outsrc\n";
open(SRC,"> $outsrc");
printf STDERR "opening for writing $outtgt\n";
open(TGT,"> $outtgt");
printf STDERR "opening for writing $outdel\n";
open(OUT,"> $outdel") if $filter;

for $title (keys %sindex){
    if (defined($sindex{$title}[0]) && defined($tindex{$title})){
	my $n=$sindex{$title}[1]-$sindex{$title}[0]; 
	for (my $i=0;$i<=$n;$i++){
	    my $s=$stext[$sindex{$title}[0]+$i];
	    my $t=$ttext[$tindex{$title}[0]+$i];

	    my ($dN,$ds1,$ds2)=($sindex{$title}[2],$sindex{$title}[3],$sindex{$title}[4]);
	    die "$title: $dN $ds1 $ds2\n" if !($dN && $ds1 && $ds2);
	    my $dSD=sqrt(($dN * $ds2 - $ds1 * $ds1)/($dN*($dN-1)));

	    if ($filter && $s=~/seekvideo/){ #Remove outliers
		my $r=wlength($s)/wlength($t);
		if (adist(wlength($s),wlength($t))>2  &&
		    adist($r,$s1/$N)/$SD > $filter)
		{
		    print OUT "${s}${t}";	
		    print OUT "$r vs m=",$s1/$N,"  SD=",$SD,"\n";    
		    $Nout++;
		    next;
		}
	    }
	    if ($tag || ($s=~/^[ \t]*<seekvideo /)) {
		print(SRC clean($s),"\n");
		print(TGT clean($t),"\n");
	    }
	}
    }
}

close(SRC);
close(TGT);
close(OUT) if $filter;

printf("Collected %d (non tags) sentence pairs \n",$N);
printf("Filtered out %d sentence pairs (%4.2f\%)\n",$Nout, 100 * $Nout/($N+$Nout));
##########################

sub load{
    my ($filename,$text,$idx)=@_;

    printf STDERR "opening for reading $filename\n";
    open(DATA,"cat $filename |") ||	die "cannot open $filename";
    my $title="";

    while(<DATA>){
	chop; 	
	if (/<url>.*\/(.*).html<\/url>/){
	    $title=$1;
	    push (@$text,$_) if ($tag);
	    %$idx->{$title}[0]=$#{$text}; #start position inside text array
	    next;
	}
	push (@$text,  $_),next  if (/<keywords>/);	  
	push (@$text,  $_),next  if (/<description>/);
	push (@$text,  $_),next,  if (/<title>/);
	push (@$text,  $_),next,  if (/<talkid>/);

	if (/<transcription>/){
            $_=<DATA>;
            chop;       
            while(!($_=~/<\/transcription>/)) {
#                ~s/\<seekvideo[^>]+\>//;
                ~s/\<\/seekvideo\>//;
                push (@$text, $_);
                $_=<DATA>;
                chop;   
	    }
	}

	if (/<\/file>/) {
            %$idx->{$title}[1]=$#{$text}; #last position inside text array      
        }

    }

    close(DATA);

}

#######################
sub wlength{
    my($txt)=@_;

    chop($txt);
    $txt=~s/ *\<seekvideo id=\"\d+\"\>//; #rm seekvideo
    $txt=~s/[\",;.!:\'?\-]/ /g;$txt=~s/ +/ /g;$txt=~s/^ +//;$txt=~s/ +$//;
    my $n=split(/ /,$txt);
    $n=1 if $n eq 0;
    return $n;
}


#######################
sub clean{
    my ($txt)=@_;
    $txt=~s/\<seekvideo id=\"\d+\">//;
    $txt=~s/^ +//;
    $txt=~s/$ +//;
    $txt=~s/ +/ /g;	
    return $txt;
}

#######################
sub adist{
    my ($a,$b)=@_;
    my $d=$a-$b;
    return ($d>0?$d:-$d);
}
