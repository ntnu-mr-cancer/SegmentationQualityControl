# PSQC
"A quality control system for automated prostate segmentation on T2-weighted MRI"

This is a fully automated quality control system that generate a quality score for assessing the accuracy of automated prostate segmentations on T2W MR imagese.

This fully automated quality control system employs radiomics features for estimating the quality of deep-learning based prostate segmentation on T2W MR images.
The performance of our system is developed and tested using two data cohorts and 4 different deep-learning based segmentation algorithms

The method was developed at the MR Cancer group at the Norwegian University of Science and Technology (NTNU) in Trondheim, Norway.
https://www.ntnu.edu/isb/mr-cancer

For detailed information about this method, please read our paper:

# Note
The provided algorithm was developed for research use and was NOT meant to be used in clinic.

# How to cite the system
In case of using or refering to AutoRef, please cite it as:


# How to use the system
This is a MATLAB® function, the function was written and tested using MATLAB® R2019b.

To run the function you can use the SQC.m file and make sure to install the trained model "trainedModel.mat", 'pyradiomicsFeatureExtraction.py', the Dependency folder and prepare python environment.
In addition, you have to install the requisted third party toolboxes as desciped in the Dependency section below.

Make sure that all of these files are in the same folder.

To use the function, you simply have to provide the full directories (string) to your scan and segmentation (DICOM foldr or MetaIO (.mha/.mhd)) image as an input to the SQC function. You also need to specify if your scan normalized using AutoRef or not and you need to set a threshould to distinguish the acceptable and not acceptable segmentations.
```matlab
[qualityScore,qualityClass] = SQC(scanPath,segPathIn,normStatus,qualityClassThr);
```
**Input:**

  1- scanPath: The path of the Image you run the segmentation on.The scan must be in .mhd, .mha, .mat or DICOM format. (string)
  
  2- segPath: The path of the resulted segmentation.The segmentation must be in .mhd, .mha, .mat or DICOM format. (string)
  
  3- normStatus: You have to set a number (1,2 or 3). (numeric)
  
  4- qualityClassThr: The threshould, which any qualityScore less than it would be considered NOT acceptable, and any value eqault or higher than it will be considered    Acceptable. (numeric)


**Output:**

  1- qualityScore: The segmentation quality score. (numeric)
  
  2- qualityClass: The segmentaion quality class. (string)
  

**Example for unnormalized scan with DICOM format:**

*Let say you have a the images resulted from an unnormalized T2-weighted MRI scan of the prostate (Case10) and the segmentation of that scan (Case10_segmentation) in DICOM format (3D image).
And let assume that you want to concider any quality score more than 85 acceptable.
Then you have to type this:*
```matlab
scanPath = 'C:\Data\Case10';
segPath = 'C:\Data\Case10_segmentation';
[qualityScore,qualityClass] = SQC(scanPath,segPath,1,85)
```
**Example for unnormalized scan with MetaIO format:**

*Let say you have a the images resulted from an unnormalized T2-weighted MRI scan of the prostate (Case10) and the segmentation of that scan (Case10_segmentation) in MetaIO format (3D image).
And let assume that you want to concider any quality score more than 85 acceptable.
Then you have to type this:*
```matlab
scanPath = 'C:\Data\Case10.mhd';
segPath = 'C:\Data\Case10_segmentation.mhd';
[qualityScore,qualityClass] = SQC(scanPath,segPath,1,85)
```
**Example for normalized scan with AutoRef normalization method:**

*Let say you have a the images resulted from a normalized T2-weighted MRI scan of the prostate (Case10_normalized) and the segmentation of that scan (Case10_segmentation) in MetaIO format (3D image).
And let assume that you want to concider any quality score more than 85 acceptable.
Then you have to type this:*
```matlab
scanPath = 'C:\Data\Case10_normalized.mhd';
segPath = 'C:\Data\Case10_segmentation.mhd';
[qualityScore,qualityClass] = SQC(scanPath,segPath,2,85)
```
**Example for normalized scan with AutoRef normalization method that sved as .mat:**

*Let say you have a the images resulted from a normalized T2-weighted MRI scan of the prostate (Case10_normalized), which was saved as .mat, and the segmentation of that scan (Case10_segmentation) in MetaIO format (3D image).
And let assume that you want to concider any quality score more than 85 acceptable.
Then you have to type this:*
```matlab
scanPath = 'C:\Data\Case10_normalized.mat';
segPath = 'C:\Data\Case10_segmentation.mhd';
[qualityScore,qualityClass] = SQC(scanPath,segPath,3,85)
```
# Dependency 
This function depend on the followings, which you should make sure that you have correctly installed them on your computer:
1. Convert3D tool from ITK 
  by ITK-SNAP http://www.itksnap.org
  - You MUST install it to your computer and complie it with your system as descriped: 
    + Install the "CONVERT3D NIGHTLY BUILD" folder from: http://www.itksnap.org/pmwiki/pmwiki.php?n=Downloads.C3D
    + Follow the guide in the documents to install and compile: http://www.itksnap.org/pmwiki/pmwiki.php?n=Convert3D.Convert3D  
2. elastix toolbox (4.3<=version<=4.7):
  by: Image Sciences Institute, University Medical Center Utrecht, The Netherlands.
  - It is included in the Dependency folder, so no need to download it unless you faced a problem with it, in that case:
    + Download and compile as descriped at: http://elastix.isi.uu.nl/
    + Read and follow the section 1.2 at: http://elastix.isi.uu.nl/download/elastix-5.0.0-manual.pdf
3. ElastixFromMatlab (a MATLAB® wrapper around elastix)
  by: CNRS,France and Riverside Research, USA https://sourcesup.renater.fr/www/elxfrommatlab/
  - It is included in the Dependency folder, so no need to download it.
  - In case of you had to redownload the elastix toolbox as mentioned above, make sure to change the paths in "elxTestDefaultConfiguration.m" script.
4. loadImage3
  by: Dr. Mattijs Elschot from the MR center at the Norwegian University of Science and Technology (NTNU), Trondheim, Norway.
  Dr. Elschot allowed the function useage and upload. 

  A function to read the DICOM images and sort them in a structure similar to that generated by ElastixFromMatlab.
  - It is included in the Dependency folder, so no need to download it.
