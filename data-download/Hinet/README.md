# An example of HinetPy

The script is used to download waveforms from [Hi-net](https://www.hinet.bosai.go.jp/?LANG=en) using the python package [HinetPy](https://github.com/seisman/HinetPy).

You need to first apply for a Hinet [account](https://hinetwww11.bosai.go.jp/auth/?LANG=en). Then, you can apply for the continuous waveform around the origin time of events in `CMTlist` using python script `Continue_Waveform_Hinet.py`.

```bash
$ python Continuous_Waveform_Hinet.py ./CMTlist ./Waveform 0101,0103
```


After downloading, you can convert waveform data (".cnt" file) and instrument responses (".ch" file) into SAC and SAC polezero formats.

```bash
$ python Win32toSac.py ./Waveform ./SAC 0101
```


## Notes

CMTlist can be accessed in [GCMT](https://www.globalcmt.org/).

For the transformation about the instrument response, this script only works for Hi-net network (id:`0101`).

F-net data users are highly recommended to use [FnetPy](https://github.com/seisman/FnetPy) to request waveform data in SEED format and extract instrumental responses in RESP or PZ format from SEED files.

