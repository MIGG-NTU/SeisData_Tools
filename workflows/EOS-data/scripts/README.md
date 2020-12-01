
## Perl scripts to extract seismic waveforms at EOS

- ExtractWaveform.pl   : main script

    - extract-sac.pl   : extract sac files from miniseed
    - CalTravelTime.pl : calculate traveltime used by extract-sac.pl
    - merge.pl         : merge data. You may change the arguments for merge.
    - rename.pl        : rename seismic waveforms
    - WriteEvInfo.pl   : write event information
    - WriteStaInfo.pl  : write station information
    - CutWF.pl         : cut seismic waveforms
    - CalTravelTime.pl : calculate traveltime called by extract-sac.pl
    - time.pm          : date and time package called by ExtractWaveform.pl and extract-sac.pl


To see the command options, please run
```bash
$ ./ExtractWaveform.pl
```

See an bash example: `extract-EOSdata.sh`.

