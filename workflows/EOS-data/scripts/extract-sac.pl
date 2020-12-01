#!/usr/bin/perl
#
# extract sac files from miniseed
#
use strict;
use warnings;
use File::Basename;

@ARGV == 12 or die "perl $0 ev_dir start end origin evla evlo evdp ref_phase model EOSsta mseed_dir band\n";
my ($ev_dir,$start,$end,$origin,$evla,$evlo,$evdp,$ref_phase,$model,$EOSsta,$mseed_dir,$band) = @ARGV;
# ev_dir   : data directory
# start    : time in second before the reference time
# end      : time in second after the reference time
# origin   : origin time used in CalTravelTime.pl
# evla     : event latitude
# evlo     : event longitude
# evdp     : event depth
# ref_phase:   0 -->> reference is origin time
#            ttp -->> reference is first P
#            tts -->> reference is first S
#             Pn -->> reference is Pn wave
# model    : Earth model used in TauP
# EOSsta   : station location file
# mseed_dir: miniseed directory
# band     : station band code

print STDERR "\na. Extract sac files from miniseed\n";


# check work directory and include time.pm
my $workdir = `pwd`; chomp $workdir;
require "$workdir/time.pm";


# read stations
open(STA, "< $EOSsta") || die "Error in opening $EOSsta.\n";
my @stas = <STA>; close(STA); chomp @stas;
my %sta_coords;
for (my $i = 0; $i < @stas; $i++) {
    my ($net, $sta, $stla, $stlo, $stel) = split " ", $stas[$i];
    $sta_coords{"${net}_${sta}"} = "${stla}_${stlo}_${stel}";
}
my @stations = sort keys %sta_coords;


# miniseed time window
my (@years, @ydays, @hours);


# reference is origin time
if ($ref_phase eq "0") {
    my ($yday_start,$year_start,$mon_start,$day_start,$hour_start)
                                     = split " ", &find_time($origin, $start);
    @years = ($year_start);
    @ydays = ($yday_start);
    @hours = ($hour_start);

    my $temp_time = "${year_start}${mon_start}${day_start}${hour_start}5959999";
    my $end_time  = &time::Get_New_Time($origin, $end);
    my $dt        = &time::CalTimeInt1($temp_time, $end_time);
    #print STDERR "$temp_time $end_time $dt\n";

    while ($dt < 0) {
        $temp_time = &time::Get_New_Time($temp_time, 3600);
        my ($yday,$year,undef,undef,$hour) = split " ", &find_time($temp_time, 0);
        push @years, $year;
        push @ydays, $yday;
        push @hours, $hour;

        $dt = &time::CalTimeInt1($temp_time, $end_time);
        #print STDERR "$temp_time $end_time $dt#\n";
    }

    for (my $i = 0; $i < @hours; $i++) {
        print STDERR "mseeds: Year $years[$i] Day $ydays[$i] Hour $hours[$i]\n";
    }
}


# go to data directory
chdir $ev_dir;


# extract sac files from mseed
for (my $i = 0; $i < @stations; $i++) {
    my ($net, $sta) = split "_", $stations[$i];
    my ($stla, $stlo, $stel) = split "_", $sta_coords{$stations[$i]};

    ## reference is first-arrival instead of origin time
    if ($ref_phase ne "0") {
        my ($gcarc) = split " ", `distaz $stla $stlo $evla $evlo`; chomp $gcarc;
        print STDERR "$sta: $stla $stlo $evla $evlo $evdp $gcarc\n";

        ### calculate first arrival
        my @ttimes = `perl $workdir/CalTravelTime.pl $origin $evdp $gcarc $model $ref_phase`; chomp @ttimes;
        my ($first_arrival, $ph) = split " ", $ttimes[0];
        if ($first_arrival ne "undef") {
            my $start_new = $first_arrival + $start;
            my $end_new   = $first_arrival + $end;
            print STDERR "$start_new $end_new $first_arrival\n";

            # find miniseed time window
            my ($yday_start,$year_start,$mon_start,$day_start,$hour_start) =
                                   split " ", &find_time($origin, $start_new);
            @years = ($year_start);
            @ydays = ($yday_start);
            @hours = ($hour_start);

            my $temp_time = "${year_start}${mon_start}${day_start}${hour_start}5959999";
            my $end_time  = &time::Get_New_Time($origin, $end_new);
            my $dt        = &time::CalTimeInt1($temp_time, $end_time);
            #print STDERR "$temp_time $end_time $dt\n";

            while ($dt < 0) {
                $temp_time = &time::Get_New_Time($temp_time, 3600);
                my ($yday,$year,undef,undef,$hour) = split " ", &find_time($temp_time, 0);
                push @years, $year;
                push @ydays, $yday;
                push @hours, $hour;

                $dt = &time::CalTimeInt1($temp_time, $end_time);
                #print STDERR "$temp_time $end_time $dt#\n";
            }

            for (my $j = 0; $j < @hours; $j++) {
                print STDERR "mseeds: Year $years[$j] Day $ydays[$j] Hour $hours[$j]\n";
            }
        } ### calculate first arrival
    } ## reference is first-arrival instead of origin time


    ## find mseed files
    my @mseeds;
    for (my $j = 0; $j < @hours; $j++) {
        my $data_dir = "$mseed_dir/$years[$j]/$net/$sta";   # data directory

        my @bands = split "_", $band;
        for (my $k = 0; $k < @bands; $k++) {
            my @chn_dirs = glob "$data_dir/$bands[$k]*.D"; chomp @chn_dirs;

            for (my $ii = 0; $ii < @chn_dirs; $ii++) {
                my $data_dir   = "$chn_dirs[$ii]/$ydays[$j]";
                my @mseeds_tmp = glob "$data_dir/${net}.${sta}.*.$years[$j].$ydays[$j].$hours[$j].*.mseed";
                push @mseeds, @mseeds_tmp;
            }
        }
    }


    ## extract sac files from mseed
    if (@mseeds == 0) {
        print STDERR "No data for $origin $net $sta\n";
        next;
    }
    for (my $j = 0; $j < @mseeds; $j++) {
        `mseed2sac $mseeds[$j]`;
    }

}


# go back to the current work directory
chdir $workdir;



####################################################
# find the day of year, year, month, day, hour, hour
# when origin is plus duration
sub find_time {
    my ($origin, $duration) = @_;

    my $new_time = &time::Get_New_Time($origin, $duration);
    my $yday     = &time::CalDOY($new_time);
    my ($year, $mon, $day, $hour) = split " ", &time::Get_Head($new_time);

    return "$yday $year $mon $day $hour";
}

