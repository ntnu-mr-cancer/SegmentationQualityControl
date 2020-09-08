# -*- coding: utf-8 -*-
"""
Created on Wed Sep 12 15:45:35 2018

@author: mohammed r. s. sunoqrot
"""

import SimpleITK as sitk
import os
import glob

inputdir = 'Path to nnUNet_3D predictions'
outputdir = os.path.join('basePath','Data','Segmentations','nnUNet_3D') # change basePath with the full path to it

reader = sitk.ImageFileReader()
writer = sitk.ImageFileWriter()

files = []
os.chdir(inputdir)
for file in glob.glob("*.gz"):
    files.append(file)

for ii in  files:
    input_name = str(ii) 
    print(input_name)
    
    imagein = os.path.join(inputdir,input_name)
    imageout = os.path.join(outputdir,str(ii[:-7]+'_segmentation.mhd')) # [:-7] might need to be changed to fit your data naming system
    
    reader.SetFileName(imagein)
    image = reader.Execute()
    writer.SetFileName(imageout)
    writer.Execute(image)