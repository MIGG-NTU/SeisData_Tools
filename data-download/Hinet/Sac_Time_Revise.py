# -* - coding: UTF-8 -* -

#****************************************
#*      By Jing Chen			*
#*                                      *
#****************************************


import numpy as np
import os
import math
import glob
import obspy
import time
from obspy import read
from datetime import datetime,timedelta
import datetime
import sys
import subprocess
import multiprocessing



# (year, day) -> (year, month, day)
def Day2date(year,day):
	first_day=datetime.datetime(year,1,1)
	add_day=datetime.timedelta(days=day-1)
	return datetime.datetime.strftime(first_day+add_day,"%Y-%m-%d")

#  (year, month, day) -> (year, day) 
def Date2day(year,month,day):
	months=[0,31,59,90,120,151,181,212,243,273,304,334]
	if 0<month<=12:
		sum=months[month-1]
	else:
        	print("month error")
	sum+=day
	leap=0

	if(year%400==0) or ((year%4)==0) and (year%100!=0):
		leap=1

	if(leap==1) and (month>2):
		sum+=1
	return sum

def Day2day(year,day):
	if(year%400==0) or ((year%4)==0) and (year%100!=0):
		if(day>366):
			return [year+1,day-366]	
	else:
		if(day>365):
			return [year+1,day-366]

	if (day<=0):
		if((year-1)%400==0) or (((year-1)%4)==0) and ((year-1)%100!=0):
			return [year-1,day+366]
		else:
			return [year-1,day+365]
	return [year,day]

# usage of functions:
#print(Day2date(2008,123))    			#output:2008-05-02
#print(Date2day(2008,5,2))			#output:123
#tp=Day2day(2009,0);year=tp[0];day=tp[1]	
#print(year,day)				#output:2008 366



#--------------main-----------------
if(not len(sys.argv)==4):
	print('Input Error: python Sac_Time_Revise.py input_dir sub_input_dir sub_output_data_dir \n')
	print('e.g. python Continue_Waveform_Hinet.py ./SAC SAC rSAC')
	sys.exit('\n')


# Read input
input_dir = str(sys.argv[1])		# input folder
sub_input_dir = str(sys.argv[2])	# sub-input folder
sub_output_dir = str(sys.argv[3])	# sub-output folder


# Loop events
for path in sorted( glob.glob('%s/*'%(input_dir)) ):

	doc=open('%s/CMTSOLUTION'%(path),'r')
	cmtfile=doc.readlines()
	doc.close()

	timtshift=cmtfile[2].split(None)
	timtshift=timtshift[2]

	cmt=cmtfile[0].split(None)
	cyear=int(cmt[1]);cmonth=int(cmt[2]);cday=int(cmt[3]);cjday=Date2day(cyear,cmonth,cday)
	chour=int(cmt[4]);cminute=int(cmt[5]);csecond=float(cmt[6])+float(timtshift)
		
	#print(cyear,cjday,csecond)
	
	os.system('mkdir -p %s/%s'%(path,sub_output_dir))

	# For event "path", loop waveform data ".sac"
	for sac_data in sorted( glob.glob('%s/%s/*'%(path,sub_input_dir)) ):

		print(sac_data)
		
		tr=read(sac_data)
		data=tr[0]

		# JST:	time in SAC
		nzyear=int(data.stats.sac.nzyear)
		nzjday=int(data.stats.sac.nzjday)
		nzhour=int(data.stats.sac.nzhour)
		nzmin=int(data.stats.sac.nzmin)
		nzsec=int(data.stats.sac.nzsec)
		nzmsec=float(data.stats.sac.nzmsec)

		# JST to UST
		nzhour=nzhour-9
		if(nzhour<0):
			nzhour+=24
			nzjday-=1
		tp=Day2day(nzyear,nzjday);nzyear=tp[0];nzjday=tp[1]
		
		#print(nzyear,nzjday,nzsec)
		#origin time

		
		sac_o=[(cyear-nzyear),(cjday-nzjday),(chour-nzhour),(cminute-nzmin),(csecond-nzsec-nzmsec/1000)]
		print(sac_o)
		if (sac_o[0]>0):
			if((nzyear-1)%400==0) or (((nzyear-1)%4)==0) and ((nzyear-1)%100!=0):
				sac_o=(( ( sac_o[0]*366+sac_o[1] )*24+sac_o[2] )*60+sac_o[3] )*60+sac_o[4]
			else:
				sac_o=(( ( sac_o[0]*365+sac_o[1] )*24+sac_o[2] )*60+sac_o[3] )*60+sac_o[4]
		elif (sac_o[0]<0):
			if((cyear-1)%400==0) or (((cyear-1)%4)==0) and ((cyear-1)%100!=0):
				sac_o=(( ( sac_o[0]*366+sac_o[1] )*24+sac_o[2] )*60+sac_o[3] )*60+sac_o[4]
			else:
				sac_o=(( ( sac_o[0]*365+sac_o[1] )*24+sac_o[2] )*60+sac_o[3] )*60+sac_o[4]
		else: # sac_o[0]=0
			sac_o=(( ( sac_o[0]*365+sac_o[1] )*24+sac_o[2] )*60+sac_o[3] )*60+sac_o[4]

		print(sac_o)	


		# Add origin time to SAC, transform reference time in SAC from JST to UST
		infile=sac_data
		tp=infile.split('/')
		oufile='%s/%s/%s'%(path,sub_output_dir,tp[-1])

		sactxt='r '+infile+'\n'    #读取对应sac文件
		sactxt+='ch o %s \n'%(sac_o)
		sactxt+='ch nzyear %s \n'%(nzyear)
		sactxt+='ch nzjday %s \n'%(nzjday)
		sactxt+='ch nzhour %s \n'%(nzhour)
		sactxt+='w '+oufile+'\n'
		sactxt+='q \n'
		subprocess.Popen(['sac'], stdin=subprocess.PIPE).communicate(sactxt.encode())
































