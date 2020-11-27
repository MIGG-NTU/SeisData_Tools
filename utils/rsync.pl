#!/usr/bin/env perl
# rsync
#
# Perl scripts used to synchronize data and codes
#
# Revisions:
#   2020/08/23  Jiayuan Yao     initial version
#

use strict;
use warnings;
use File::Basename;


# change those vars according to your owner case
my $me   = "tomoboy";                             # user name
my $HOME = "/home/$me";                           # home directory
my @dir  = glob "$HOME/Desktop/workspace/TMP/*";  # dirs to be synchronized,
                                                  # ignore hidden directories
#my $BACK = "/run/media/$me/My\ Book/BACKUP";     # backup directory
my $BACK = "/run/media/$me/MIG-8T/BACKUP";        # backup directory

mkdir "$BACK" if (!-e $BACK);


##################################
######## begin to backup #########
##################################
my ($start, $end, $now);

open(LOG, ">> $BACK/log.backup") || die "Error in opening log\n";
$start = `date +%F-%H:%M:%S`;
print LOG "## backup begin: $start";

foreach (@dir) {
    my ($dname) = fileparse($_, "");
    next if ($dname eq "PASS1" || $dname eq "PASS2"); # ignore those dirs
    #print STDERR "$dname\n";

    $now = `date +%F-%H:%M:%S`; chomp($now);
    print LOG "backup $_ at $now\n";

    system "rsync -av --delete $_ '$BACK'";
}

$end = `date +%F-%H:%M:%S`;
print LOG "## backup end: $end";
print LOG "\n\n";
close(LOG);

######## backup end ###############


# check backup dirs
print STDERR "\n\n--------------------------------------\n";
print STDERR "Folders and Files in '$BACK':\n";
my @bakdirs = glob "'${BACK}'/*"; chomp @bakdirs;
for (my $i = 0; $i < @bakdirs; $i++) {
    print STDERR "$bakdirs[$i]\n";
}

