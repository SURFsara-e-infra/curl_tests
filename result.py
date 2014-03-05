#!/usr/bin/env python

import glob
import os
import re
import time

thistime=time.time()

m=re.compile("time:([0-9]+\.[0-9]+);([0-9]+\.[0-9]+)\s+MB.*Throughput:\s+([0-9]+\.[0-9]+)\s+.*")

def get_info_from_file (file):
    f=open(file,"r")
    l=f.readlines()
    f.close()

    average=0.0  
    size=None
    mintime=thistime
    maxtime=0.0
    for i in l:
        p=m.match(i)
        if p != None:
           average=average+float(p.group(3))
           if size == None: size=float(p.group(2))
           time=float(p.group(1))
           if time>maxtime: maxtime=time
           if time<mintime: mintime=time
        
    num=len(l)
    if num>0:
        average=average/num

    return num,average,mintime,maxtime,size

def get_info(fileslist):
    avg=0.0
    sz=None
    mntime=thistime
    mxtime=0.0
    ntransfers=0
    for f in fileslist:
        n,a,mn,mx,s=get_info_from_file(f)
        avg=avg+a
        ntransfers=ntransfers+n
        if sz==None: sz=s
        if mx>mxtime: mxtime=mx
        if mn<mntime: mntime=mn

    num=len(fileslist)
    if num>0:
        avg=avg/num

    return ntransfers,avg,mntime,mxtime,sz

def results(transfer):

    files=[]
    string='test_results_'+transfer+'*'
    for file in glob.glob(string):
        files.append(file)

    ntransfers,avg,mntime,mxtime,sz=get_info(files)

    elapsedtime=int(mxtime-mntime)
    if elapsedtime<=0:
        print "There were no "+transfer+"s"
    else:
        print "Average "+transfer+" speed:"+str(avg)+" MB/s"
        print "Total number of "+transfer+"s: "+str(ntransfers)+" of "+str(sz)+" MB files in "+str(elapsedtime)+" seconds"
        print "Overall throughput: "+str((ntransfers*sz)/elapsedtime)+" MB/s"

if __name__=='__main__':

    results('write')
    results('read')
