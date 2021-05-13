#!/usr/bin/env python
import os
from obspy import UTCDateTime
from obspy.clients.fdsn.mass_downloader import RectangularDomain, Restrictions, MassDownloader
import csv

def get_mseed_storage(network, station, location, channel, starttime, endtime):
    """Use custom function to store miniseed waveforms

    is_in_db function needs to be coded yourself
    """
    # Returning True means that neither the data nor the StationXML file
    # will be downloaded.
    #if is_in_db(network, station, location, channel, starttime, endtime):
    #    return True
    # If a string is returned the file will be saved in that location.
    return os.path.join("miniseed/{}".format(event_fname), "{}.{}.{}.{}.mseed".format(network, station,location, channel))


# read catalog
catalog = "events.csv"
with open(catalog, "r", newline='') as csvfile:
    line = csv.reader(csvfile, delimiter=',')
    next(line, None)  # skip the headers

    # loop over each event
    for row in line:
        origin_time = UTCDateTime(row[0])
        event_fname = "".join(row[0].split("T")[0].split("-")) + "".join("".join("".join(row[0].split("T")[1].split("Z")).split(".")).split(":"))

        # Step 1: Data Selection

        # Rectangular Domain
        domain = RectangularDomain(minlatitude=35.5, maxlatitude=36,
                                   minlongitude=-118, maxlongitude=-117.3)

        # Restrictions
        # I put all the options here. You may delete some defaults to clear the code.
        restrictions = Restrictions(
            # time range
            starttime=origin_time - 1*60,
            endtime=origin_time + 2*60,

            # station start and end time (default values used)
            station_starttime=None,
            station_endtime=None,

            # The length of one chunk in seconds (default value used)
            chunklength_in_sec=None,

            # network and station (default values used)
            network=None,
            station=None,
            location=None,
            channel=None,
            exclude_networks=(),
            exclude_stations=(),
            limit_stations_to_inventory=None,

            # If True, miniSEED files with gaps and/or overlaps will be rejected (default is True)
            reject_channels_with_gaps=False,

            # The minimum length of the data as a fraction of the requested time frame (0.0~1.0, default is 0.9)
            minimum_length=0.0,

            # Each MiniSEED file also has an associated StationXML file,
            # otherwise the MiniSEED files will be deleted afterwards (default is True)
            sanitize=False,

            # The minimum inter-station distance (default is 1000)
            minimum_interstation_distance_in_m=0,

            # Priority list for the channels.
            # Will not be used if the channel argument is used.
            channel_priorities=('BH[ZNE12]', 'BL[ZNE12]',
                                'HH[ZNE12]', 'HL[ZNE12]',
                                'SH[ZNE12]', 'SL[ZNE12]',
                                'EH[ZNE12]', 'EL[ZNE12]',
                                'SP[ZNE12]', 'EP[ZNE12]',
                                'DP[ZNE12]'),

            # Priority list for the locations.
            # Will not be used if the location argument is used. (defaults are used)
            location_priorities=('', '00', '10', '01', '20', '02', '30', '03', '40', '04',
                               '50', '05', '60', '06', '70', '07', '80', '08', '90', '09'))


        # Step 2: Storage Options

        # Use custom function to store miniSEED waveforms
        mseed_storage = get_mseed_storage
        # Directly use folder name to store StationXML files
        stationxml_storage = "stations"

        # Step 3: Start the Download

        # List of FDSN client names or service URLS
        #mdl = MassDownloader(providers=["IRIS", "GFZ", "SCEDC"])
        mdl = MassDownloader()

        tt = mdl.download(domain, restrictions, threads_per_client=3,
                          mseed_storage=mseed_storage, stationxml_storage=stationxml_storage)

