#/bin/bash
#
# extract seismic data at EOS, using EOS.data-scripts in
# https://github.com/core-man/EOS.data-scripts
#

# you may change the following parameters according to your purpose
catalog=../catalog/catalog.dat                      # catalog
station=../station/MMEOS-coord.dat                  # station locations
#mseedir=/run/media/core-man/4T/EOS-Myanmar/mseed    # miniseed directory
mseedir=/run/media/tomoboy/4T-YAO1/EOS-Myanmar/mseed    # miniseed directory
sacdir=../sac                                       # output sac directory

# extract broadband data within 50 sec before and 150 sec after
# first P-wave arrival based on AK135 model
./ExtractWaveform.pl -C$catalog -S$station -M$mseedir -O$sacdir -Rttp -Eak135 -T-50,150 -BH

