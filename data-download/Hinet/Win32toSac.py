# -* - coding: UTF-8 -* -
#****************************
#*     By Jing Chen			*
#****************************

import numpy as np
import os
import math
import glob
from HinetPy import Client
from HinetPy import win32
import obspy
from obspy import read
import sys

def data_process(data,ctable,data_path,ctable_path):
    try:
        if (os.path.exists(data)):
            win32.extract_sac(data, ctable,outdir=data_path)
            win32.extract_pz(ctable,outdir=ctable_path)
        else:
            print('no file: %s'%(path))
    except:
        print('error %s'%(path))



#----------------------main--------------
if(not len(sys.argv)==4):
	print('Input Error: python Win32toSac.py input_dir output_dir netid \n')
	print('e.g. python Win32toSac.py ./Waveform ./SAC 0101,0103')
	sys.exit('\n')

# Read input
waveform_path = str(sys.argv[1])   # input .cnt waveform path
output_dir = str(sys.argv[2])      # output folder
netid = str(sys.argv[3])           # Network No. separated by comma (e.g., 0101,0103 (Hi-net and F-net))


os.system('mkdir -p %s'%(output_dir))

# Loop events to transform the format from ".cnt" to ".sac"
for path in sorted(glob.glob('%s/*'%(waveform_path))):

    # Read evid
    print(path)
    evid=path.split('/')
    evid=evid[-1]

    os.system('mkdir -p %s/%s'%(output_dir,evid))

    # Begin to transform the format
    all_net=netid.split(',')
    for iid in all_net:
        data='%s/%s_%s.cnt'%(path,evid,iid)
        ctable='%s/%s.ch'%(path,iid)
        data_path='%s/%s/SAC'%(output_dir,evid)
        ctable_path='%s/%s/instrument'%(output_dir,evid)

        data_process(data,ctable,data_path,ctable_path)


    # Write STATION information as well
    doc=open('%s/%s/STATIONS'%(output_dir,evid),'w')
    all_stid=[]

    for ifile in sorted(glob.glob('%s/%s/SAC/*.SAC'%(output_dir,evid))):
        print(ifile)
        signal=read(ifile)
        tr1=signal[0]
        stla=tr1.stats.sac.stla
        stlo=tr1.stats.sac.stlo
        stel=tr1.stats.sac.stel
        net=tr1.stats.sac.kevnm
        stid=tr1.stats.sac.kstnm

        if(stid in all_stid):
            continue

        all_stid.append(stid)
        if(net==''):
            net='Unknown'

        doc.write('%-8s  %-8s  %8.4f  %8.4f  %7.1f  0.0\n'%(net,stid,float(stla),float(stlo),float(stel)))

    doc.close()

    # Copy the CMT file
    os.system('cp %s/CMTSOLUTION %s/%s'%(path,output_dir,evid))

