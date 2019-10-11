#!/usr/bin/perl

# CWTsim
# G0JPS [2080], Feb 2019

# WHAT IS CWTsim?
# The script does two things. It fetches a CWOPs member list from
# the web and stores it in an array.
#
# Secondly it outputs the text of a running CWT station, either
# to send to students during a zoom session for CWT practice, or
# to paste into CW Player to generate an audio file for them.
#
# *If* I can get sound working, I hope to make it simulate a running station!


# SUPPORT
# 1. RTFM
# 2. There is no manual.

# CONFIGURATION - IMPORTANT

# How many callsigns to display / work?
my $runs = 20;

use strict;
use warnings;

my $callsign = "";

my %cwops;
my %cwopsheard;
my @fields;
my $random;
my $mems;
my $ents = 0;
my $runner;
my $runnercall;
my $cwt = "";

print "\033[2J";
print "\033[0;0H";
print "CWOpCallsigns : started\n";

#Get membership list from the web
sub getmembers{
	print "Getting member list...";
	my $content = qx{curl https://docs.google.com/spreadsheets/d/1Ew8b1WAorFRCixGRsr031atxmS0SsycvmOczS_fDqzc/export?format=csv};
	die "CWOPS: No Web Data\n" unless defined $content;

	while ($content =~ /([^\n]+)\n?/g){
		my $line = $1;
		chomp $line;
		my ($null,$exp, $call, $number, $name, $d1) = split /,/, $line;
		$cwops{$call}=$call . "," . $name . "," . $number;
	}
$mems = (keys %cwops);
print "Done - $mems members downloaded.\n\n";
}

sub getacallsign{
	$random = (keys %cwops) [rand keys %cwops];
	$callsign = $cwops {$random};
	delete $cwops{$random};
	$mems = (keys %cwops);
}

getmembers();
# Check for list too short error
if ($runs >= $mems){
	die "More runs than callsigns!";
}

# Set the running station
getacallsign();
$runner = $callsign;
print "Running Station is $runner\n\n";
sleep 1;

@fields = split /,/, $runner;
$runnercall = @fields[0];
$runner = @fields [1] . " " . @fields [2];
$cwt .= "CQ $runnercall CWT\n";

# Display some callsigns

while ($runs >= 0){
	getacallsign();
	my ($call,$name,$number) = split /,/, $callsign;
	$cwt .= "  $call\n";
	$cwt .= "$call $runner\n";
	$cwt .= "  R $name $number\n";
	$cwt .= "TU $runnercall CWT\n";
	$runs --;
}	

print "$cwt \n\n73!\n";

