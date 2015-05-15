#!/usr/bin/env perl -w

use warnings;
use strict;
use XML::Twig;


if( ( @ARGV == 2 ) )
{
	print "Input arguments are $ARGV[0] and $ARGV[1]\n";

}else
{
 print "Usage: Enter input full path and output full path\n";
 print "For example: input full path /usr/apps/pisc_as/pisc/AGE/input/XMLFILE.txt \n";
 print "For example: output full path /usr/apps/pisc_as/pisc/AGE/input/DIFF_XMLFILE.txt \n";
 exit;
}


print "Start Program \n";

my $file=$ARGV[0];

my $output=$ARGV[1];
my $tempoutput=$output.".temp";

print "Input file is $file \n";
open(my $fh,'>',$tempoutput);
my $count=0;
my $linenumber=0;

&printtag("<AgencySynchronizationFile>",$fh);
my $twig = XML::Twig ->new(
		twig_roots =>
			{ 
			  'AgencySynchronizationFile/RecordCount' => \&copynode,	
			  'AgencySynchronizationFile/AgencySynchronization' => \&module,
			},
				);

$twig->parsefile($file);
&printtag("</AgencySynchronizationFile>",$fh);

close $fh;

open(my $f,'>',$output);
&printtag("<AgencySynchronizationFile>",$f);
my $twig_output = XML::Twig ->new(
		twig_roots =>{ 
		'AgencySynchronizationFile/RecordCount' => \&updaterecordcount,
		'AgencySynchronizationFile/AgencySynchronization' => \&copyrecords,
		},
			);
$twig_output->parsefile($tempoutput);
&printtag("</AgencySynchronizationFile>",$f);
close $f;
	
##Delete Temp file
unlink $tempoutput or warn "Could not unlink $tempoutput: $!";
	
print "\nEnd program \n";


sub printtag
{
	my $tag=$_[0];
	my $printfile=$_[1];
	print $printfile "$tag\n";
}

sub copynode
{
	my( $twig, $elt) =@_;
	$elt->print($fh);
	print $fh "\n";
	$elt->purge;
}

sub module
{
# print "\nStart module\n";
 	my( $twig, $elt) =@_;
	my $producer=$elt->first_child('Producer');
	my $generalpartyinfo=$producer->first_child('GeneralPartyInfo');
	my $producerinfo=$generalpartyinfo->first_child('ProducerInfo');
	my $changeactivityind =$producerinfo->first_child('ChangeActivityInd');
	my $changeactivityindvalue=$changeactivityind->text;
	$linenumber++;
	 if ( $linenumber %100 == 0)
	{
		print "The total number of records that has been parsed is $linenumber";
	}
	if( $changeactivityind->text eq "Y")
	{
	 $count++;
	 $elt->print($fh);
	 print $fh "\n";

	}else
	{
	 #print " not finding change activity ind\n";
	}
 $elt ->purge;
#print "\nEnd module\n";
}

sub updaterecordcount
{
	my( $twig_output, $elt) =@_;
	my $recordcount=$elt->text();
	$elt->subs_text(qr/$recordcount/,$count);
	$elt->print($f);
	print $f "\n";
	$elt->purge;
}

sub copyrecords
{
	my( $twig_output, $elt) =@_;
	$elt->print($f);
	print $f "\n";
	$elt->purge;
}



