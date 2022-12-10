# -*- coding: utf-8 -*-
import numpy as np
import math as m
"""
Created on Sun Mar 13 14:22:59 2022

@author: Sagar Singhal
"""

n_steps = 5;
n_beacons = 5;

PDR_dat = np.ones((n_steps-1,2))
t = np.linspace(1, 10, num=n_steps-1)
PDR_dat[:,1] = np.sin(t)

d = np.linspace(0.1, 20, num=100)

RSSI_base = -(10*2.5*np.log10(d) + 30) #30 to be replaced with RSSI at 1m
RSSI_map = RSSI_base
i = 1
while i < n_beacons:
    RSSI_map = np.vstack((RSSI_map,RSSI_base))
    i += 1
    
RSSI_map = RSSI_map.T

t = np.linspace(1, 10, num=(n_steps)*n_beacons)
RSSI_dat = -50*np.absolute(np.sin(t))
RSSI_dat = RSSI_dat.reshape((n_steps,n_beacons)) #

q_var = np.zeros((n_steps,3))
p_var = np.zeros((n_beacons,2))


def err_pdr(q,IMU):
    x = q[0:-1,0] - q[1:,0]
    x = np.square(x)
    y = q[0:-1,1] - q[1:,1]
    y = np.square(y)
    err1 = np.sqrt(x+y) - IMU[:,0]
    err2 = q[0:-1,2] - q[1:,2] - IMU[:,1]
    err = np.vstack((err1, err2)).T
    return err

def err_RSSI(RSSI,map,q,p):
    d = -(RSSI + 30)/(10*2.5)
    d = np.power(10,d)
    i = 0
    dist = np.zeros((len(q),1)).T
    while i < len(p):
        x = q[:,0] - p[i,0]
        x = np.square(x)
        y = q[:,1] - p[i,1]
        y = np.square(y)
        dist1 = np.sqrt(x+y) - d[:,i]
        dist = np.vstack((dist,dist1))
        #print(dist)
        i += 1
    err = dist[1:,:].T - d
    return err

def err_RFM(RSSI,q):
    i = 0
    dmin = 5
    dmax = 20
    emax = 1
    dr_thresh = 8#dBm
    err = np.zeros((len(RSSI),len(RSSI)))
    while i < len(RSSI):
        j = i
        while j < len(RSSI):
            d = np.linalg.norm(RSSI[i,:] - RSSI[j,:])/np.sqrt(np.shape(RSSI)[1])
            dis = np.linalg.norm(q[i,0:-1] - q[j,0:-1])
            #print(dis)
            if d < dr_thresh:
                if dis < dmin:
                    err[j,i] = 0
                elif dis > dmax:
                    err[j,i] = emax
                else:
                    err[j,i] = emax*(dis - dmin)/(dmax - dmin)
            j += 1
        i+= 1
    
    return err
  
err_q = err_pdr(q_var,PDR_dat)
err_p = err_RSSI(RSSI_dat,RSSI_map,q_var,p_var)
err_r = err_RFM(RSSI_dat,q_var)

