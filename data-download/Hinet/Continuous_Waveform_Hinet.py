# -* - coding: UTF-8 -* -
#********************************
#*      By Jing Chen			*
#********************************

import numpy as np
import os
import math
import glob
import time
from HinetPy import Client
from datetime import datetime,timedelta
import sys



def download_waveform(netid,evid,starttime,duration,out_dir):
	data_downloaded=False
	try:
		print('ev:%s, net:%s is downloading ...'%(evid,netid))
		data,ctable=client.get_continuous_waveform(netid, starttime, duration, data='%s_%s.cnt'%(evid,netid),ctable='%s.ch'%(netid),outdir='%s/%s'%(out_dir,evid))
		data_downloaded=True
	except:
		print ('ev:%s, net:%s error'%(evid,netid))
		time.sleep(5)
	return data_downloaded



#--------------main-----------------
if(not len(sys.argv)==4):
	print('Input Error: python Continue_Waveform_Hinet.py cmt_file out_dir netid \n')
	print('e.g. python Continue_Waveform_Hinet.py ./CMTlist ./Waveform 0101,0103')
	sys.exit('\n')

# Read input
cmt_file = str(sys.argv[1])	# CMT catalog
out_dir = str(sys.argv[2])	# output folder
netid= str(sys.argv[3])		# Network No. separated by comma (e.g., 0101,0103 (Hi-net and F-net))

os.system('mkdir -p %s'%(out_dir))

# Please input Hinet username and passwd
username=""
password=""
client= Client(username,password)

# Read catalog
doc=open('%s'%(cmt_file),'r')
cmtlist=doc.readlines();
doc.close();

# Downloading parameters
TWL=2.5		 # time before the event, e.g., 2.5 minutes
duration=8	 # data duration, e.g., 8 minutes
startline=0; # starting line in the catalog
minmag=0;
maxmag=10;

# Loop events to download data
for i,cmt in enumerate(cmtlist):
	if (i<startline):
		continue

	if (cmt.__contains__('PDE')):
        # Read earthquake parameters
		if (cmt.__contains__('PDE ')):
			test=cmt.split(None)
			(year,month,day,hour,minute,second)=test[1:7]
			second=second.split('.')
			second=second[0]
			mag=max(float(test[10]),float(test[11]))
		elif (cmt.__contains__('PDEW')):
			test=cmt.split(None)
			(month,day,hour,minute,second)=test[1:6]
			second=second.split('.')
			second=second[0]
			year=cmt[5:9]
			mag=max(float(test[9]),float(test[10]))

        # Magnitude
		if (mag>minmag and mag<maxmag):
			origin=year+'-'+month+'-'+day+' '+hour+':'+minute+':'+second
			#print(origin)
			origintime_UTC=datetime.strptime(origin,'%Y-%m-%d %H:%M:%S')
			origintime_JST=origintime_UTC+timedelta(hours=9)
			starttime=origintime_JST-timedelta(minutes=TWL)

		print(test)

		# Event No.
		evid='%s%s%s%s%s%s'%(year.zfill(4),month.zfill(2),day.zfill(2),hour.zfill(2),minute.zfill(2),second.zfill(2))

		# Begin to download data
		print('downloading ... time: '+origin+' mag: '+str(mag)+'\n')
		data_downloaded=False
		all_net=netid.split(',')
		for iid in all_net:
			temp=download_waveform(iid,evid,starttime,duration,out_dir)
			data_downloaded=data_downloaded or temp

        # If data are downloaded, write CMT information as well
		if(data_downloaded):
			try:
				doc=open('Waveform/%s/CMTSOLUTION'%(evid),'w')
				doc.write(cmtlist[i][1:5]+' '+cmtlist[i][5:len(cmtlist[i])])
				for j in range(1,13):
					doc.write(cmtlist[i+j])
					doc.close()
			except:
				print('error %s'%(evid))

