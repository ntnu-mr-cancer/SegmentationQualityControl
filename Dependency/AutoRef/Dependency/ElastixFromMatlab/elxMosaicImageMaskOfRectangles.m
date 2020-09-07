%% elxMosaicImageMaskOfRectangles
%
% Create the mask needed by the function elxMosaicImage.
%
%% Syntax
%
% |Mask = elxMosaicImageMaskOfRectangles(SizeImage, Size, Offset)|
%
%% Input arguments
%
% * |SizeImage| 1xN integers: the size of the images (N the dimension)
% * |Size| 1xN integers: the size of the rectangle of the mosaic along each
% dimension
% * |Offset|: 1xN integers: To be able to the translate the origins of the
% rectangles.
%
%% Output arguments
%
% * |Mask| (logical array): the output mask.
%
%% Description
%
% Create the mask needed by the function elxMosaicImage. The output image 
% will be rectangular patches from the first or second image.  Image may be N-D.
%
%% See also 
%
% <elxMosaicImage.html |elxMosaicImage|>
%
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
% $Id: elxMosaicImageMaskOfRectangles.m 1 2012-04-27 18:47:40Z coron $
function Mask = elxMosaicImageMaskOfRectangles(SizeImage, Size, Offset)

NeedTranspose = false;
NDims = numel(SizeImage);
if NDims == 2 && (SizeImage(1) == 1 || SizeImage(2) == 1)
  NDims = 1;
  if SizeImage(1) == 1
    NeedTranspose = true;
    SizeImage = SizeImage([2 1]);
  end
end

Value = cell(1, NDims);
for CptDim = 1:NDims
  x{CptDim} = (0:SizeImage(CptDim)-1).';
  Value{CptDim} = uint8(rem(fix((x{CptDim}+Offset(CptDim))/Size(CptDim)), 2));
end

MaskX = cell(NDims, 1);
if NDims == 1,
  MaskX{1} = Value{1};
else
  [MaskX{:}] = ndgrid(Value{:});
end

Mask = zeros(SizeImage, 'uint8');
for Cpt = 1:NDims
  Mask = Mask + MaskX{Cpt};
end
Mask = logical(rem(Mask, 2));

if NeedTranspose
  Mask = Mask.';
end
