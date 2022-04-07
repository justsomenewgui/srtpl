#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

my $milliseconds = 0;
my $seconds = 0;
my $minutes = 0;
my $file = '';
my $line = '';
my $help = 0;
GetOptions ('file=s' => \$file, 'f=s' => \$file,
            'seconds=i' => \$seconds, 's=i' => \$seconds,
	    'milliseconds=i' => \$milliseconds, 'ml=i' => \$milliseconds,
	    'minutes=i' => \$minutes, 'min=i' => \$minutes,
            'help|?' => \$help) or pod2usage(1);
pod2usage(1) if $help;

sub timecodes {
    my $x = $_[0];
    my ($opt_name, $opt_value) = @_;
    my $msLine = substr $line, $x, 3;
    my $secLine = substr $line, $x - 3, 2;
    my $minLine = substr $line, $x - 6, 2;
    my $hourLine = substr $line, $x - 9, 2;
    # milliseconds bloc:
    $msLine = sprintf("%03d", $msLine + $milliseconds);
    if ($msLine > 999) {
	while ($msLine > 999) {
	    $secLine = $secLine + 1;
	    $msLine = sprintf("%03d", $msLine - 1000);
	}
    }
    elsif ($msLine < 0) {
	while ($msLine < 0) {
	    $secLine = $secLine - 1;
	    $msLine = sprintf("%03d", 1000 + $msLine);
	}
    }
    # seconds bloc:
    $secLine = sprintf("%02d", $secLine + $seconds);
    if ($secLine > 59) {
	while ($secLine > 59) {
	    $minLine = $minLine + 1;
	    $secLine = sprintf("%02d", $secLine - 60);
	}
    }
    elsif ($secLine < 0) {
	while ($secLine < 0) {
	    $minLine = $minLine - 1;
	    $secLine = sprintf("%02d", 60 + $secLine);
	}
    }
    # minutes bloc:
    $minLine =  sprintf("%02d", $minLine + $minutes);
    if ($minLine > 59) {
	while ($minLine > 59) {
	    $hourLine = sprintf("%02d", $hourLine + 1);
	    $minLine =  sprintf("%02d", $minLine - 60);
	}
    }
    elsif ($minLine < 0) {
	while ($minLine < 0) {
	    $hourLine = sprintf("%02d", $hourLine - 1);
	    $minLine = sprintf("%02d", 60 + $minLine);
	}
    }
    my $newLine = "$hourLine:$minLine:$secLine,$msLine"; 
    return $newLine;
}

my @lines = ();
open(FILE, "$file");
while ($line = <FILE>) {
    if ($line =~ /-?\d*\d:\d\d:\d\d,\d\d\d\s-->\s-?\d*\d:\d\d:/) {
        my $first = timecodes(9, $file,  $seconds, $milliseconds,
			      $minutes);
        my $second = timecodes(26, $file, $seconds, $milliseconds,
			       $minutes);
        $line = "$first --> $second\n";
	push(@lines, $line);
    }
    else {
	push(@lines, $line);
    }
}
close(FILE);
open(FILE2, "> $file");
print FILE2 @lines;
close(FILE2);

__END__
=head1 NAME

sample - Using Getopt::Long and Pod::Usage

=head1 SYNOPSIS

./timecodes.pl [file] [options]

 Options:
   -f --file           Path to subtitles file, that need to be changed.
   -help               help message
   -s --seconds        The seconds for which the timecode needs to be
                       corrected.
   -ml --milliseconds  The milliseconds for which the timecode needs to be
                       corrected.
   -min --minutes      The minutes for which the timecode needs to be
                       corrected.
