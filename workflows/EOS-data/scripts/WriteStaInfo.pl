#!/usr/bin/perl
#
# write station information into sac files
#
use strict;
use warnings;

@ARGV == 2 || die "Usage: perl $0 dirname EOSsta\n";
my ($dir, $EOSsta) = @ARGV;
# dir    : data directory
# EOSsta : station location file

print STDERR "\ne. Write Station Information\n";


# read stations
open(STA, "< $EOSsta") || die "Error in opening $EOSsta.\n";
my @stas = <STA>; close(STA); chomp @stas;
my %sta_coords;
for (my $i = 0; $i < @stas; $i++) {
    my ($net, $sta, $stla, $stlo, $stel) = split " ", $stas[$i];
    $sta_coords{"${net}_${sta}"} = "${stla}_${stlo}_${stel}";
}


my $workdir = `pwd`; chomp $workdir;
chdir $dir;


my @sacs = glob "*.SAC"; chomp @sacs;
for (my $i = 0; $i < @sacs; $i++) {
    my ($net, $sta, $loc, $chn) = (split /\./, $sacs[$i])[0..3];
    next if (! (exists $sta_coords{"${net}_${sta}"}) );
    my ($stla, $stlo, $stel) = split "_", $sta_coords{"${net}_${sta}"};
        #print STDERR "$net $sta $chn: $stla $stlo $stel\n";

    my $chn_ori = substr($chn, -1);
    my ($cmpaz, $cmpinc);
    if ($chn_ori eq "N") {
        $cmpaz =  0;
        $cmpinc= 90; }
    elsif ($chn_ori eq "E") {
        $cmpaz = 90;
        $cmpinc= 90; }
    elsif ($chn_ori eq "Z") {
        $cmpaz = 0;
        $cmpinc= 0; }
    else {
        $cmpaz = "undef";
        $cmpinc= "undef";
    }

    open(SAC, "| sac") or die "Error in opening sac.\n";
    print SAC "wild echo off \n";
    print SAC "r $sacs[$i] \n";
    print SAC "ch cmpinc $cmpinc cmpaz $cmpaz \n";
    print SAC "ch stla $stla stlo $stlo stel $stel\n ";
    print SAC "wh \n";
    print SAC "q \n";
    close(SAC);
}

chdir $workdir;


