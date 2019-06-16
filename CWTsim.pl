#!/usr/bin/perl

# CWTsim
# G0JPS [2080], Jun 2019

# WHAT IS CWTsim?
# The script does two things. It fetches a CWOPs member list from
# the web and stores it in memory.
#
# Then it displays a selction of random entries for an advisor
# to send to students during a zoom session for CWT practice.
#

# SUPPORT
# 1. RTFM
# 2. Ah. There is no manual.
# 3. Read XKCD instead. It won't help with this program, but it's funny.

# CONFIGURATION - IMPORTANT
# How many callsign/name/number to show?
my $runs = 20;

use strict;
use warnings;
my $callsign = "";

my %cwops;
my $random;
my $mems;

print "\033[2J";
print "\033[0;0H";
print "CWTsim : started\n";

#Get membership list from the web
sub getmembers{
	print "Getting member list...";
	my $content = qx{curl http://hamclubs.info/lists/CWOPS_members.txt};
	die "CWOPS: No Web Data\n" unless defined $content;

	while ($content =~ /([^\n]+)\n?/g){
		my $line = uc($1);
		chomp $line;
		my ($exp, $call, $number, $name, $d1) = split / /, $line;
		$cwops{$call}=$call . " " . $name . " " . $number;
	}
$mems = (keys %cwops);
print "\033[2J";
print "\033[0;0H";
print "$mems callsigns downloaded. ";
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


# Display some callsigns
print "Displaying $runs callsigns...\n\n";

while ($runs >= 0){
	getacallsign();
	print "$callsign\n";
	$runs --;
	sleep 1;
}	

print "\n73!\n";

