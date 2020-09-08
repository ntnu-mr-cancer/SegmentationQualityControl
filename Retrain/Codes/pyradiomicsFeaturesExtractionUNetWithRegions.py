# -*- coding: utf-8 -*-
"""
Created on Mon Mar 12 15:55:07 2018

@author: mattjise
Modified by Mohammed Sunoqrot March 2020
"""

import radiomics
import SimpleITK as sitk
import numpy as np
import math
import json
import os
import glob

def getSettings(image_array_in,mask_array_in,nr_bins):
    intensity_range = np.max(image_array_in[mask_array_in == 1])-np.min(image_array_in[mask_array_in == 1])
    settings = {} 
    settings['binWidth'] = intensity_range/64
    settings['correctMask'] = True
    return settings

def getSliceFromMask(mask_in,slice_nr_in):
    mask_array = sitk.GetArrayFromImage(mask_in)
    new_mask_array = np.zeros_like(mask_array)
    new_mask_array[:,:,:] = 0
    new_mask_array[slice_nr_in,:,:] = mask_array[slice_nr_in,:,:]
    new_mask = sitk.GetImageFromArray(new_mask_array)
    new_mask.CopyInformation(mask)
    return new_mask

# loop over all patients
image_dir = 'Path to the Original scans folder'
mask_dir = 'Path to the Manual segmentations folder'
results_dir = 'Path to the output folder'

files = []
os.chdir(mask_dir)
for file in glob.glob("*.mhd"):
    files.append(file)

for patient_nr in files:
        numbertocheck = int(str(patient_nr[4:7])) # [4:7] might need to be changed to fit your data naming system
        image_name = str(patient_nr[0:7])+'_normalized.mhd' # [:-7] might need to be changed to fit your data naming system
        mask_name = str(patient_nr)
        print(image_name, mask_name)
    
        # read in data
        image = sitk.ReadImage(os.path.join(image_dir,image_name))
        mask = sitk.ReadImage(os.path.join(mask_dir,mask_name))
        mask = sitk.Cast( mask, sitk.sitkUInt8)

        mask.SetDirection(image.GetDirection())
        mask.SetOrigin(image.GetOrigin())
        mask_array = sitk.GetArrayFromImage(mask)
        image_array = sitk.GetArrayFromImage(image)
        
        # get slices
        slice = mask_array.sum(axis = (1,2)) > 0
        index = np.where(slice==1)
        
       #---Whole prostate---# 

       # whole prostate - firstorder
        region_class = 'wholeprostate'
        feature_class = 'firstorder'
        settings = getSettings(image_array,mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json' # [:-17] might need to be changed everywhere here and follow to fit your data naming system
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))

        # whole prostate - shape 3d
        region_class = 'wholeprostate'
        feature_class = 'shape'
        settings = getSettings(image_array,mask_array,64)       
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
       # whole prostate - glcm
        region_class = 'wholeprostate'
        feature_class = 'glcm'
        settings = getSettings(image_array,mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # whole prostate - glrlm
        region_class = 'wholeprostate'
        feature_class = 'glrlm'
        settings = getSettings(image_array,mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)      
        featureVector = extractor.execute(image,mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # whole prostate - glszm
        region_class = 'wholeprostate'
        feature_class = 'glszm'
        settings = getSettings(image_array,mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)      
        featureVector = extractor.execute(image,mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))

        # whole prostate - ngtdm
        region_class = 'wholeprostate'
        feature_class = 'ngtdm'
        settings = getSettings(image_array,mask_array,64)     
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # whole prostate - gldm
        region_class = 'wholeprostate'
        feature_class = 'gldm'
        settings = getSettings(image_array,mask_array,64)      
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)       
        featureVector = extractor.execute(image,mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
                      
        #---Apex---# 
        
        # prepare input
        slice_nr = index[0][0:math.floor(np.size(index)/3)]
        new_mask = getSliceFromMask(mask,slice_nr)
        new_mask_array = sitk.GetArrayFromImage(new_mask)
        
        # apex- firstorder
        region_class = 'apex'
        feature_class = 'firstorder'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
                    
        # apex - shape 3d
        region_class = 'apex'
        feature_class = 'shape'
        settings = getSettings(image_array,new_mask_array,64)       
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
       # apex - glcm
        region_class = 'apex'
        feature_class = 'glcm'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # apex - glrlm
        region_class = 'apex'
        feature_class = 'glrlm'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)      
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # apex - glszm
        region_class = 'apex'
        feature_class = 'glszm'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)      
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))

        # apex - ngtdm
        region_class = 'apex'
        feature_class = 'ngtdm'
        settings = getSettings(image_array,new_mask_array,64)     
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # apex - gldm
        region_class = 'apex'
        feature_class = 'gldm'
        settings = getSettings(image_array,new_mask_array,64)      
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)       
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        #---Middle---# 
        
        # prepare input
        slice_nr = index[0][math.floor(np.size(index)/3):(np.size(index)-math.floor(np.size(index)/3))]  
        new_mask = getSliceFromMask(mask,slice_nr)
        new_mask_array = sitk.GetArrayFromImage(new_mask)
        
        # middle- firstorder
        region_class = 'middle'
        feature_class = 'firstorder'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
                    
        # middle - shape 3d
        region_class = 'middle'
        feature_class = 'shape'
        settings = getSettings(image_array,new_mask_array,64)       
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
       # middle - glcm
        region_class = 'middle'
        feature_class = 'glcm'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # middle - glrlm
        region_class = 'middle'
        feature_class = 'glrlm'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)      
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # middle - glszm
        region_class = 'middle'
        feature_class = 'glszm'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)      
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))

        # middle - ngtdm
        region_class = 'middle'
        feature_class = 'ngtdm'
        settings = getSettings(image_array,new_mask_array,64)     
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # middle - gldm
        region_class = 'middle'
        feature_class = 'gldm'
        settings = getSettings(image_array,new_mask_array,64)      
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)       
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))

        #---Base---# 
        
        # prepare input
        slice_nr = index[0][np.size(index)-math.floor(np.size(index)/3):]  
        new_mask = getSliceFromMask(mask,slice_nr)
        new_mask_array = sitk.GetArrayFromImage(new_mask)
        
        # base - firstorder
        region_class = 'base'
        feature_class = 'firstorder'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
                    
        # base - shape 3d
        region_class = 'base'
        feature_class = 'shape'
        settings = getSettings(image_array,new_mask_array,64)       
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
       # base - glcm
        region_class = 'base'
        feature_class = 'glcm'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # base - glrlm
        region_class = 'base'
        feature_class = 'glrlm'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)      
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # base - glszm
        region_class = 'base'
        feature_class = 'glszm'
        settings = getSettings(image_array,new_mask_array,64)
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)      
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))

        # base - ngtdm
        region_class = 'base'
        feature_class = 'ngtdm'
        settings = getSettings(image_array,new_mask_array,64)     
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
            
        # base - gldm
        region_class = 'base'
        feature_class = 'gldm'
        settings = getSettings(image_array,new_mask_array,64)      
        extractor = radiomics.featureextractor.RadiomicsFeatureExtractor(**settings)
        extractor.disableAllFeatures()
        extractor.enableFeatureClassByName(feature_class)       
        featureVector = extractor.execute(image,new_mask)
        for key in featureVector.keys():
            if type(featureVector[key]) == type(np.array(1)):
                featureVector[key] = float(featureVector[key])        
        results_name = str(patient_nr[:-17])+'_'+region_class+'_'+feature_class+'.json'
        with open(os.path.join(results_dir,results_name), 'w') as f:
            f.write(json.dumps(featureVector))
        
                    