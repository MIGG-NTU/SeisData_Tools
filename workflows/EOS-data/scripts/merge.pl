#!/usr/bin/perl
#
# Merge Data at the Same Station
#
use strict;
use warnings;

@ARGV == 1 || die "Usage: perl $0 dirname\n";
my ($dir) = @ARGV;
# dir : data directory

print STDERR "\nb. Merge Sac Files\n";


my $workdir = `pwd`; chomp $workdir;
chdir $dir;

my %sets;
foreach (glob "*.SAC") {
    my ($net, $sta, $loc, $chn) = (split /\./)[0..3];
    $sets{"$net.$sta.$loc.$chn"}++;
}

open(SAC, "|sac") or die "Error in opening sac\n";
print SAC "wild echo off \n";
my @to_del;
while (my ($key, $value) = each %sets) {
    next if $value == 1;

    #print STDERR "merge $key: $value traces\n";
    my @traces = sort glob "$key.*.SAC";

    print SAC "r $key.*.SAC \n";
    print SAC "merge GAP ZERO OVERLAP AVERAGE\n";
    print SAC "w $traces[0] \n";

    push @to_del, splice(@traces, 1);
}

print SAC "q \n";
close(SAC);
unlink (@to_del);


chdir $workdir;

