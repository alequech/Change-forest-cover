#!/usr/bin/env bash
#author: alequech@gmail.com 
#Date: 08/08/18
#This script is in charge of applying the FMASK algorithm , for more references see http://pythonfmask.org/en/latest/
#Previous steps:
#1.Unzip the file that contains the images in a directory that keeps the same name 
#2. source activate myenv
#3.
import sys
import argparse
##import fmask
import os
import subprocess
import glob

folder = r"/home/yangao/Documents/L_8_7_5_PR2847"

#Creates the function that deletes files that are not needed 
def purge(pattern):
    filelist=glob.glob(pattern)
    for file in filelist:
        os.remove(file)
        print("deleted files....")

listdir = next(os.walk(folder))[1]

for i in range(len(listdir)):
    print(listdir[i])
    typ_L = listdir[i][0:4]
    os.chdir(folder +"/"+ listdir[i])
    if typ_L == 'LT05':
        os.system("gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img L*_B[1,2,3,4,5,7].TIF")
        os.system("gdal_merge.py  -separate -of HFA -co COMPRESSED=YES -o thermal.img L*_B6.TIF")
        os.system("fmask_usgsLandsatMakeAnglesImage.py -m *_MTL.txt -t ref.img -o angles.img") 
        os.system("fmask_usgsLandsatSaturationMask.py -i ref.img -m *_MTL.txt -o saturationmask.img")
        os.system("fmask_usgsLandsatTOA.py -i ref.img -m *_MTL.txt -z angles.img -o toa.img")
        os.system("fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m *_MTL.txt -z angles.img -s saturationmask.img -o" + " "+listdir[i]+"_Fmask.TIF")
        purge("*.img")
    elif typ_L == 'LE07':
        os.system("gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img L*_B[1,2,3,4,5,7].TIF") 
        os.system("gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img L*_B6_VCID_?.TIF")
        os.system("fmask_usgsLandsatMakeAnglesImage.py -m *_MTL.txt -t ref.img -o angles.img") 
        os.system("fmask_usgsLandsatSaturationMask.py -i ref.img -m *_MTL.txt -o saturationmask.img")
        os.system("fmask_usgsLandsatTOA.py -i ref.img -m *_MTL.txt -z angles.img -o toa.img")
        os.system("fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m *_MTL.txt -z angles.img -s saturationmask.img -o" + " "+listdir[i]+"_Fmask.TIF")
        purge("*.img")       
    elif typ_L == 'LC08':
        os.system("gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o ref.img LC08*_B[1-7,9].TIF")
        os.system("gdal_merge.py -separate -of HFA -co COMPRESSED=YES -o thermal.img LC08*_B1[0,1].TIF")
        os.system("fmask_usgsLandsatMakeAnglesImage.py -m *_MTL.txt -t ref.img -o angles.img") 
        os.system("fmask_usgsLandsatSaturationMask.py -i ref.img -m *_MTL.txt -o saturationmask.img")
        os.system("fmask_usgsLandsatTOA.py -i ref.img -m *_MTL.txt -z angles.img -o toa.img")
        os.system("fmask_usgsLandsatStacked.py -t thermal.img -a toa.img -m *_MTL.txt -z angles.img -s saturationmask.img -o" + " "+listdir[i]+"_Fmask.TIF")
        purge('*.img')
        
       



