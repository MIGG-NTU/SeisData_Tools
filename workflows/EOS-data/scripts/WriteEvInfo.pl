#!/usr/bin/perl
#
# write event information into sac files
#
use strict;
use warnings;

@ARGV == 11 || die "Usage: perl $0 dirname origin hypo mag\n";
my ($dir, $year, $yday, $hour, $min, $sec, $msec, $evla, $evlo, $evdp, $evmg) = @ARGV;
# dir  : data directory
# origin time : year yday hour min sec msec
# yday : day of the year
# sec  : second
# msec : millisecond
# evla : event latitude
# evlo : event longitude
# evdp : event depth
# evmg : event magnitude

print STDERR "\nd. Write Event Information\n";


my $workdir = `pwd`; chomp $workdir;
chdir $dir;


my $length   = length($msec);
my $zero_num = 0;
$zero_num    = 3 - $length if ($length < 3);
$msec        = $msec."0"x$zero_num;

open(SAC, "|sac") or die "Error in opening sac\n";
print SAC "wild echo off \n";
print SAC "r *.SAC \n";
print SAC "synchronize \n";
print SAC "ch o gmt $year $yday $hour $min $sec $msec \n";
print SAC "ch allt (0 - &1,o&) iztype IO\n";
print SAC "ch evla $evla evlo $evlo evdp $evdp mag $evmg \n";
print SAC "wh \n";
print SAC "q \n";
close(SAC);

chdir $workdir;

