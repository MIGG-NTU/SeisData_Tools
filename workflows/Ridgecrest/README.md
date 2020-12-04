# Seismic Data for Three Ridgecrest Earthquakes

## Earthquake Catalog

Earthquake Catalog is downloaded from [Southen California Earthquake Data Center](https://scedc.caltech.edu/research-tools/alt-2011-dd-hauksson-yang-shearer.html) on Nov. 27 2020.

- Waveform Relocated Earthquake Catalog for Southern California: `1981-2019 Catalog file`
- Format and catalog information: `Format and catalog information (2019 dataset)`

```bash
# download catalog
$ wget -c -np -r https://service.scedc.caltech.edu/ftp/catalogs/hauksson/Socal_DD/sc_1981_2019_1d_3d_gc_soda_noqb_v0.gc -O sc-catalog.dat
```

We only keep earthquakes occuring in 2019/07 in `sc-catalog-201907.dat` because the original catalog is a little large.

- columns `1-6`: year, month, day, hour, minute, second
- column `7`: event ID
- column `8-10`: latitude (decimal degrees), longitude (decimal degrees), depth (km)
- column `11`: event magnitude

We then find the main shock, 1 foreshock and 1 aftershock and put them in `events-selected.dat`.

```bash
$ sort -k 11n sc-catalog-201907.dat | tail -n 3 | sort -k1nr -k2nr -k3nr -k4nr -k5nr -k6nr > events-selected.dat
```


```bash
# plot seismicity
$ ./plot-seismicity.sh
```

![Ridgecrest Earthquakes](Ridgecrest-eqs.png)


## Seismic Data

Use SOD to download seismic data for the three selected events.

