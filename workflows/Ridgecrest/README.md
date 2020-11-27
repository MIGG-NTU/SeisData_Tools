# Seismic Data for Three Ridgecrest Earthquakes


## Earthquake Catalog

Earthquake Catalog is downloaded from [Waveform Relocated Earthquake Catalog for Southern California (1981 to 2019)](https://scedc.caltech.edu/research-tools/alt-2011-dd-hauksson-yang-shearer.html) on Nov. 27 2020.

```bash
# download catalog
$ wget -c -np -r https://service.scedc.caltech.edu/ftp/catalogs/hauksson/Socal_DD/sc_1981_2019_1d_3d_gc_soda_noqb_v0.gc -O sc-catalog.dat
```

Find earthquakes occuring in 2019/07 (**sc-catalog-201907.dat**).

Find the main shock, 1 foreshock and 1 aftershock (**events-selected.dat**).

Remove origin catalog because it is a little large.

```bash
# plot seismicity
$ ./plot-seismicity.sh
```

![Ridgecrest Earthquakes](Ridgecrest-eqs.png)


## Seismic Data

Use SOD to download seismic data for the three selected events.

