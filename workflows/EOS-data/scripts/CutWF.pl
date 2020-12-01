#!/usr/bin/perl
#
# cut seismic waveforms to the right time window,
# because EOS store 1-h data in single mseed file
#
use strict;
use warnings;

@ARGV == 6 || die "Usage: perl $0 dirname start end origin ref_phase model\n";
my ($dir,$start,$end,$origin,$ref_phase,$model) = @ARGV;
# dir   : data directory
# start : time in second before the reference time
# end   : time in second after the reference time
# origin: origin time used in CalTravelTime.pl
# ref_phase:   0 -->> reference is origin time
#            ttp -->> reference is first P
#            tts -->> reference is first S
#             Pn -->> reference is Pn wave
# model    : Earth model used in TauP

print STDERR "\nf. Cut Seismic Waveforms\n";


my $workdir = `pwd`; chomp $workdir;
chdir $dir;


# default reference time is origin
my ($start_new, $end_new) = ($start, $end);

# first arrival and phase name
my ($first_arrival,$ph) = ("undef", "undef");

open(SAC, "| sac");
print SAC "cuterr u \n";

foreach (glob "*.SAC") {
    chomp;

    # reference is first-arrival instead of origin time
    if ($ref_phase ne "0") {
        my (undef,$stla,$stlo,$evla,$evlo,$evdp) = split " ",
                             `saclst stla stlo evla evlo evdp f $_`;
        my ($gcarc) = split " ", `distaz $stla $stlo $evla $evlo`; chomp $gcarc;
        print STDERR "$_: $stla $stlo $evla $evlo $evdp $gcarc\n";

        # calculate first arrival
        my @ttimes = `perl $workdir/CalTravelTime.pl $origin $evdp $gcarc $model $ref_phase`; chomp @ttimes;
        ($first_arrival, $ph) = split " ", $ttimes[0];
        print STDERR "$first_arrival $ph\n";
        next if ($first_arrival eq "undef");

        $start_new = $first_arrival + $start;
        $end_new   = $first_arrival + $end;
        print STDERR "$start_new $end_new $first_arrival\n";
    }

    my (undef, $b, $e) = split " ", `saclst b e f $_`;
    if ($b > $end_new || $e < $start_new) {
        unlink $_;
    }
    else {
        print SAC "cut $start_new $end_new \n";
        print SAC "r $_ \n";
        print SAC "ch t1 $first_arrival kt1 $ph \n";
        print SAC "w over \n";
    }
}

print SAC "quit \n";
close(SAC);


chdir $workdir;

