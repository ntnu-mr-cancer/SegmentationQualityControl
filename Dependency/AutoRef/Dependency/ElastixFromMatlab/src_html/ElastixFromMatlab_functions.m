%%% ElastixFromMatlab list of public functions
%
% *Most important ElastixFromMatlab functions*
%
% * <elxDefaultConfiguration.html elxDefaultConfiguration>: Return a
% default ElastixFromMatlab configuration
% * <elxDefaultParameters.html elxDefaultParameters>: Return a set of default
% Elastix parameters 
% * <elxElastix.html elxElastix> Run elastix
% * <elxTransformix.html elxTransformix> Run transformix
% * <elxElastixVersion.html elxElastixVersion> Return elastix version
%
% *Functions for reading or writing elastix/transformix files*
%
% * <elxElastixLogFileToStructure.html elxElastixLogFileToStructure>
% * <elxMetaIOFileToStrDatax.html elxMetaIOFileToStrDatax>
% * <elxReadOutputPointsFile.html elxReadOutputPointsFile>
% * <elxReadTransformParameterFile.html elxReadTransformParameterFile>
% * <elxStrDataxToMetaIOFile.html StrDataxToMetaIOFile>
% * <elxWriteParameterFile.html elxWriteParameterFile>
% * <elxWritePointSetFile.html elxWritePointSetFile>
% * <elxWriteTransformParameterFile.html elxWriteTransformParameterFile>
%
% *Functions to display a mosaic from two images*
%
% * <elxMosaicImage.html elxMosaicImage>
% * <elxMosaicImageMaskOfRectangles.html elxMosaicImageMaskOfRectangles>
%
% *Examples*
%
% * <elxExampleElastix.html elxExampleElastix>
% * <elxExampleStreet.html elxExampleStreet>
% * <elxExampleCorrespondingPoints.html elxExampleCorrespondingPoints>
%
% *Other public functions*
% 
% * <elxIdentityTransform.html elxIdentityTransform>
% * <elxIsStrDatax.html elxIsStrDatax>
% * <elxIsStrPointSet.html elxIsStrPointSet>
% * <elxPublish.html elxPublish>
% * <elxTestDefaultConfiguration.html elxTestDefaultConfiguration>
% * <elxTestElastixVersion.html elxTestElastixVersion>
% 
% *License*
%
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
% $Id: ElastixFromMatlab_functions.m 4 2012-05-25 20:09:12Z coron $
