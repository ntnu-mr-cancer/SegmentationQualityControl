%% elxIsStrPointSet
%
% Check whether the input is a StrPointSet structure.
%
%% Syntax
%
% |[Status, Message] = elxIsStrPointSet(input)|
%
%% Input arguments
%
% * |input|: Structure
%
%% Output arguments
%
% * |Status| (boolean): true if ok.
% * |Msg| (character array): Explanatory message.  
%
%% Description
%
% Check whether the input is a StrPointSet structure.
%
%% See also 
%
% <elxElastix.html |elxElastix|>, <elxTransformix.html |elxTransformix|>,
% <StrPointSet_help.html |StrPointSet|>
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
% $Id: elxIsStrPointSet.m 4 2012-05-25 20:09:12Z coron $
function [Status, Msg] = elxIsStrPointSet(Input)

Status = false;
Msg = '';

if ~isstruct(Input)
  Msg = 'Input must be a structure.';
  return;
end

if isfield(Input, 'Indices')
  SizeIndices = size(Input.Indices);
  if ~isnumeric(Input.Indices) || ndims(Input.Indices)~=2 ...
    || numel(Input.Indices)==1 || SizeIndices(2)<2 || SizeIndices(2)>4
    Msg = ['Indices must be a 2D numeric array of size nxD, n number of indices.' ...
      ' D space dimension<4.'];
    return;
  end 
end

if isfield(Input, 'Points')
  SizePoints = size(Input.Points);
  if ~isnumeric(Input.Points) || ndims(Input.Points)~=2 ...
      || numel(Input.Points)==1 || SizePoints(2)<2 || SizePoints(2)>4
    Msg = ['Indices must be a 2D numeric array of size nxD, n number of indices.' ...
      ' D space dimension<4.'];
    return;
  end
end

Status = true;
return;
