%%% elxWriteParameterFile
%
% Write in a file the set of Elastix parameters stored in a structure.
%
%% Syntax
%
% |[Success, Message] = elxWriteParameterFile(StrParam, Filename)|
%
%% Input arguments
%
% * |StrParam| (structure): Each field of the structure is an Elastix parameter 
% * |Filename| (string): the name of the parameter file to be written.
%
%% Output arguments
%
% * |Success| (logical): true if ok.  Otherwise false;
% * |Message|`(string): error message
%
%% Description
%
% Write in a file the set of Elastix parameters stored in a structure.  Each 
% field (name, value) of |StrParam| is considered as an Elastix 
% (name, value) parameter.
%
%% See also 
%
% <elxElastix.html |elxElastix|>, <elxTransformix.html |elxTransformix|>
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
% $Id: elxWriteParameterFile.m 1 2012-04-27 18:47:40Z coron $
function [Success, Message] = elxWriteParameterFile(StrParam, Filename)


Success = true;
[Fid, Message] = fopen(Filename, 'w');
if Fid == -1
  Success = 0;
  return
end

for Field = {'FixedInternalImagePixelType', ...
    'MovingInternalImagePixelType', ...
    'FixedImageDimension', ...
    'MovingImageDimension'}
  if isfield(StrParam, Field{1})
    Line = elxComposeLineOfStructuredFile(Field{1}, StrParam.(Field{1}));
    fprintf(Fid, [Line '\n']);
  else
    error(['The parameter ' Field{1} ' is missing.']);
  end
  StrParam = rmfield(StrParam, Field{1});
end

FieldsNames = fieldnames(StrParam);
NbFieldsNames = numel(FieldsNames);
for Cpt = 1:NbFieldsNames
  Line = elxComposeLineOfStructuredFile(FieldsNames{Cpt}, ...
					StrParam.(FieldsNames{Cpt}));
  Count = fprintf(Fid, [Line '\n']);
  if Count ~= numel(Line) + 1
    Success = false;
    Message = sprintf('Error writing %s.', Filename);
    fclose(Fid);
    return;
  end
end
fclose(Fid);

