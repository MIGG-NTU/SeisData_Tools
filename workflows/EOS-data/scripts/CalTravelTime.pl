#!/usr/bin/perl
#
# calculate theoretical travel time
#
use strict;
use warnings;

@ARGV == 5 or die "perl $0 evdp dist model phase\n";
my ($origin, $evdp, $gcarc, $model, $phase) = @ARGV;

my $time_table = "time-table-${origin}";
`taup_time -mod $model -h $evdp -ph $phase -deg $gcarc > $time_table`;

open(TIME, "< $time_table") or die "Error in opening $time_table.\n";
my @times = <TIME>; close(TIME); chomp @times;

unlink $time_table;

## no such a phase
if ($times[5] eq "") {
    print STDOUT "undef $phase\n";
    exit(0);
}

## first arrival
## ttp+ has surface reflected phases, as compared to ttp
if (grep {$phase eq $_} ("ttp", "tts", "ttp+", "tts+", "ttbasic", "ttall")) {
    my ($gc, $dep, $ph, $tt, $p, $takeoff, $incident, $pd, undef) = split " ", $times[5];
        #print STDERR "#$gc#$dep#$ph, $tt, $p, $takeoff, $incident#$pd#\n";
    print STDOUT "$tt $ph\n";
    exit(0);
}

## travel times of phase
for (my $i = 5; $i < @times-1; $i++) {
    my ($gc, $dep, $ph, $tt, $p, $takeoff, $incident, $pd, undef) = split " ", $times[$i];
        #print STDERR "#$gc#$dep#$ph, $tt, $p, $takeoff, $incident#$pd#\n";
    if ($ph eq $phase) {
        print STDOUT "$tt $ph\n";
    }
}

