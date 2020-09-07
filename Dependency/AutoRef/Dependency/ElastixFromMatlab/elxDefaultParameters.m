%% elxDefaultParameters
% Return a (sub)set of Elastix default parameters.

%% Syntax
% |StrParam = elxDefaultParameters(Transform, Dimension)|

%% Input arguments
% * |Transform|: (string) the transform among 'TranslationTransform',
% 'EulerTransform', 'SimilarityTransform', 'AffineTransform',
% 'BSplineTransform'
% * |Dimension|: (integer) The dimension of the data

%% Output arguments
% * |StrParam|: A structure of some of the default elastix parameters.

%% Description
% Return a (sub)set of Elastix default parameters.  Some of the  
% essential parameters are field members of the returned structure and are
% set to a reasonable default value.  This list is far from being complete.
% Please read the Elastix documentation and add new members if you wish.

%% License
%
% Copyright (C) CNRS and Riverside Research 
% Contributors: Alain CORON, Jonathan MAMOU (2010)
% 
% <alain.coron@upmc.fr>, <JMamou@riversideresearch.org>
% 
% This software is a computer program whose purpose is to 
% effectively register images within Matlab (http://www.mathworks.com) 
% with elastix (http://elastix.isi.uu.nl/), an open-source image-registration
% software.
%
% This software was supported in part by NIH Grant CA100183, the Riverside 
% Research Biomedical Engineering Research Fund, and CNRS.
%
% This software is governed by the CeCILL-B license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL-B
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% As a counterpart to the access to the source code and  rights to copy,
% modify and redistribute granted by the license, users are provided only
% with a limited warranty  and the software's author,  the holder of the
% economic rights,  and the successive licensors  have only  limited
% liability. 
%
% In this respect, the user's attention is drawn to the risks associated
% with loading,  using,  modifying and/or developing or reproducing the
% software by the user in light of its specific status of free software,
% that may mean  that it is complicated to manipulate,  and  that  also
% therefore means  that it is reserved for developers  and  experienced
% professionals having in-depth computer knowledge. Users are therefore
% encouraged to load and test the software's suitability as regards their
% requirements in conditions enabling the security of their systems and/or 
% data to be ensured and,  more generally, to use and operate it in the 
% same conditions as regards security. 
% 
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL-B license and that you accept its terms.
%
% $Id: elxDefaultParameters.m 1 2012-04-27 18:47:40Z coron $
function StrParam = elxDefaultParameters(Transform, Dimension)

switch lower(Transform)
  case 'translationtransform'
    StrParam.Transform = 'TranslationTransform';
  case 'eulertransform'
    StrParam.Transform = 'EulerTransform';
  case 'similaritytransform'
    StrParam.Transform = 'SimilarityTransform';
  case 'affinetransform'
    StrParam.Transform = 'AffineTransform';
  case 'bsplinetransform'
    StrParam.Transform = 'BSplineTransform';
  otherwise
    error(['Invalid/unsupported ' Transform ' transform. Supported transforms are '...
      'TranslationTransform, EulerTransform, SimilarityTransform, AffineTransform, '...
      'BSplineTransform.']);
end
    
StrParam.FixedInternalImagePixelType = 'float';
StrParam.MovingInternalImagePixelType = 'float';

StrParam.FixedImageDimension = Dimension;
StrParam.MovingImageDimension = Dimension;

% Most important parameters
StrParam.Registration = 'MultiResolutionRegistration';
StrParam.FixedImagePyramid = 'FixedSmoothingImagePyramid';
StrParam.MovingImagePyramid = 'MovingSmoothingImagePyramid';
StrParam.ImageSampler = 'RandomCoordinate';
StrParam.Interpolator = 'BSplineInterpolator';
StrParam.Metric = 'AdvancedMattesMutualInformation';
StrParam.Optimizer = 'AdaptiveStochasticGradientDescent';

StrParam.NumberOfSpatialSamples = 2048;
StrParam.NewSamplesEveryIteration = true;

StrParam.BSplineInterpolationOrder = 1;

StrParam.HowToCombineTransforms = 'Compose';
StrParam.MaximumNumberOfIterations = 300;

% Parameters specific to RandomCoordinate ImageSampler
% If UseRandomSampleRegion is set to true, the sampler randomly selects
% one voxel and selects the remaining samples in a square neighborhood
% around that voxel.  The size of the neighborhood is determined by
% SampleRegionSize, the number of pixels by NumberOfSpatialSamples
StrParam.UseRandomSampleRegion = false;
% SampleRegionSize in _physical_ coordinates.  You may try 1/3 of the total
% image size.
StrParam.SampleRegionSize = [50 50 50];

% Probably non need to modify ResampleInterpolator + Resampler
StrParam.ResampleInterpolator = 'FinalBSplineInterpolator';
StrParam.Resampler = 'DefaultResampler';

StrParam.NumberOfResolutions = 4;
StrParam.ErodeMask = true;

% DefaultResampler configuration
StrParam.FinalBSplineInterpolationOrder = 1;
StrParam.ResultImagePixelType = 'float';
StrParam.DefaultPixelValue = 0;
StrParam.WriteTransformParametersEachIteration = false;
StrParam.WriteTransformParametersEachResolution = false;
StrParam.WriteResultImageAfterEachResolution = false;

StrParam.UseDirectionCosines = true;
