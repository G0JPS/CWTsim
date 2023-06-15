text/cgi cwt.cgi ( Perl script, ASCII text executable, with very long lines )
#!/usr/bin/perl
#Interesting mix of Perl and HTML output.

# CWTsim
# G0JPS [2080], Feb 2022

# WHAT IS CWTsim?
# The script does two things. It fetches a CWOPs member list from
# a pre-saved text file and stores it in an array.
#
# Secondly it outputs the text of a running CWT station, either
# to send to students during a zoom session for CWT practice, or
# to paste into CW Player to generate an audio file for them.
#
# SUPPORT
# 1. RTFM
# 2. There is no manual.

use strict;
use warnings;

# CONFIGURATION - IMPORTANT
# How many callsigns to display / work?
my $runs = 10;
my $memfile = "./mems.txt";

# $html will contain the output from the script.
my $html = "";
my $html2 = "";

$html2 .= "Content-type: text/html\n\n";
$html2 .= "<TITLE>G0JPS CWT Simulator</TITLE>\n";
$html2 .= "<CENTER><HEAD></HEAD>\n<BODY><H1>CWT Simulator - G0JPS, Feb 2022</H1>This script does two things. It fetches a CWOPs member list from a pre-saved text file and stores it in an array.<BR>Secondly it outputs the text of a running CWT station, either to send to students during a zoom session for CWT practice,<BR>or to paste into CW Player to generate an audio file for them.<BR>Also, band conditions are not always perfect, so there is a small random chance of repeats being needed!<BR><BR>Hit Refresh for a new set of callsigns.<BR><BR>Below is a morse player (thanks to Fabian, DJ1YFK CWops \# 1566 for creating this!)<BR>You can listen to the generated file in CW, and even download an MP3 of it!</BODY>\n";

my $callsign = "";

my %cwops;
my %cwopsheard;
my @fields;
my $random;
my $mems;
my $ents = 0;
my $running = "|f666 |w30 ";
my $runner;
my $runnercall;
my $cwt = "";
my $qrm;
my $caller;
my $freq;
my $speed;

#Get membership list from the text file
sub getmembers{
	open (my $fh, '<', $memfile) or die "No member list!";
	while (my $line = <$fh>){
	    chomp $line;
	    my ($call, $name, $number) = split /,/, $line;
	    
	    unless ($call =~ /^(R\d|RA|RK|RN|RU|RV|RW|RX|RZ|UA|EU|EW|EV)\S+/){
	        $cwops{$call}=$call . ", " . $name . ", " . $number;
	   }
	}
    $mems = (keys %cwops);
}

sub getacallsign{
	$random = (keys %cwops) [rand keys %cwops];
	$callsign = $cwops {$random};
	delete $cwops{$random};
	$mems = (keys %cwops);
}

sub callin{
    $freq = 366 + int(rand(400));
    $speed = 20 + int(rand(20));
    $caller = "|f$freq |w$speed ";
}



getmembers();
# Check for list too short error
if ($runs >= $mems){
	die "More runs than callsigns!";
}

# Set the running station
getacallsign();
$runner = $callsign;
$html .= "<H2>Running Station is $runner</H2><HR WIDTH = 75%><BR>\n";

@fields = split /,/, $runner;
$runnercall = $fields[0];
$runner = $fields [1] . " " . $fields [2];
$html .= "<SPAN STYLE = 'COLOR:GREEN'>CQ $runnercall CWT</SPAN><BR>\n";
$cwt .= "$running CQ $runnercall CWT   ";

# Display some callsigns

while ($runs >= 0){
	getacallsign();
	callin();
	my ($call,$name,$number) = split /,/, $callsign;
	$html .= "<SPAN STYLE = 'COLOR:RED'> <I>$call</I></SPAN><BR>\n";
	$cwt .= "$caller $call  ";
	$qrm = int(rand(100));
	if ($qrm <= 8){
	    $html .= "<SPAN STYLE = 'COLOR:GREEN'>?</SPAN><BR>\n";
	    $cwt .= "$running ?   ";
	    $html .= "<SPAN STYLE = 'COLOR:RED'> <I>$call</I></SPAN><BR>\n";
	    $cwt .= "$caller $call   ";
	    }
	$html .= "<SPAN STYLE = 'COLOR:GREEN'>$call $runner</SPAN><BR>\n";
	$cwt .= "$running $call $runner   ";
	$qrm = int(rand(100));
	if ($qrm >=47 and $qrm <=53){
	        $html .= "<SPAN STYLE = 'COLOR:RED'><I>AGN?</I></SPAN><BR>\n";
	        $cwt .= "$caller AGN?   ";
	    $html .= "<SPAN STYLE = 'COLOR:GREEN'>$call $runner</SPAN><BR>\n";
	    $cwt .= "$running $call $runner  ";
	    }
	$html .= "<SPAN STYLE = 'COLOR:RED'><I>R $name $number</I></SPAN><BR>\n";
	$cwt .= "$caller R $name $number   ";
	$qrm = int(rand(100));
	if ($qrm >= 94){
	    $html .= "<SPAN STYLE = 'COLOR:GREEN'>AGN?</SPAN><BR>\n";
	    $cwt .= "$running AGN?  ";
	    $html .= "<SPAN STYLE = 'COLOR:RED'><I>$name $number</I></SPAN><BR>\n";
	    $cwt .= "$caller $name $number   ";
	    }
	$html .= "<SPAN STYLE = 'COLOR:GREEN'>TU $runnercall CWT</SPAN><BR>\n";
	$cwt .= "$running TU $runnercall CWT   ";
	$runs --;
}	

$html2 .= "<!DOCTYPE html>\n
    <script src=\"https://fkurz.net/ham/jscwlib/src/jscwlib.js\"></script>\n
    <div id=\"player\"></div>\n
    <script>\n
        var m = new jscw({\"wpm\": 30});\n
        m.setText(\" $cwt \");\n
        m.renderPlayer('player', m);\n
        </script>\n";

$html2 .= "<HR WIDTH = 75%><BR>\n";

print $html2;
print $html;
