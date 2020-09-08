# Retrain the system

***If you want to retrain the system to generate a better Genral model for your data then follow these step:***

1. Check your data format
    - Make sure to have your scans in ".mhd" format.
    - Make sure that you have a manual segmentation for each scan saved in ".mhd" format.

2. Perform segmentation using the following four deep learning-based methods:
    - U-Net: https://github.com/mirzaevinom/promise12_segmentation
    - V-Net: https://github.com/huangmozhilv/promise12_vnet_pytorch
    - nnU-Net in 2D: https://github.com/MIC-DKFZ/nnUNet 
    - nnU-Net in 3D: https://github.com/MIC-DKFZ/nnUNet
    
3. Open *runAnalysis.m* and follow the steps:

- Set your base path. This where the data, codes and reports will be saved.
- Set you original data path. To be copied to the subfolder of base path.
- Keep an eye on the analysis steps. It is recommended to run one step a time and double check the results.
  - Pre-processing: this step normalize the orignal scans using the AutoRef method and correct the generated masks by the segmentation methods to make sure they can be correctly read. You need here to change the directories of the masks paths.
  - Features Extraction: this step extract the radiomics features. Make sure to change the directories and check the comments that refer to a possible changes in the python scripts. This step required Python environment with Pyradiomics (V 2.2) and python (3.7). (possibly will work with Pyradiomics (V 3.0) and python (3.6/3.5), but not tested). Pyradiomics is by: Computational Imaging & Bioinformatics Lab. Harvard Medical School, MA , USA. https://pyradiomics.readthedocs.io/en/2.2.0/.
  - Getting Responses: This step calculate the reference scores (model responses).
      - Calculate factors: this if you want to recalculate the factors to be used in the next step. This will require a second reader to manually segment few cases. therefore we highly recommend using one of the already provided *factors.. .mat*.
      - Calculate scores
