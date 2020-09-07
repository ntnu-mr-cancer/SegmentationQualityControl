%% elxComposeLineOfStructuredFile
%
% Compose one line of the parameter or transform file.
%
%% Syntax
%
% |Line = elxComposeLineOfStructuredFile(ParameterName, Value)|
%
%% Input arguments
%
% * |ParameterName| (character array): Name of the parameter
% * |Value| (boolean, numeric, caracter array or cell...): value
%
%% Output arguments
%
% * |Line| (character array): formated line of the structured file.
%
%% Description
%
% Compose one line of the parameter or transform file.
%
%% See also 
%
% <elxElastix.html |elxElastix|>, <elxTransformix.html |elxTransformix|>
% <elxDecomposeLineOfStructuredFile.html |elxDecomposeLineOfStructuredFile|>
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
% $Id: elxComposeLineOfStructuredFile.m 1 2012-04-27 18:47:40Z coron $
function Line = elxComposeLineOfStructuredFile(ParameterName, Value)

if strcmpi(ParameterName, 'Comment')
  if ~isstr(Value)
    error('ParameterValue should be a character array');
  end
  if numel(Value) == 0
    Line = sprintf('');
    return;
  end
  Line = sprintf('// %s', ParameterValue);
  return;
end

if islogical(Value)
  String = {' "false"',' "true"'};
  TmpLine = String(1+double(Value));
  Line = ['(' ParameterName strcat(TmpLine{:}) ')'];
elseif ischar(Value)
  Line = ['(' ParameterName ' "' Value '")'];
elseif iscell(Value)
  TmpLine = strcat(' "', Value, '"');
  Line = ['(' ParameterName strcat(TmpLine{:}) ')'];
elseif isnumeric(Value)
  Line = ['(' ParameterName sprintf(' %g', Value(:)) ')'];
else
  error('Unknown type.');
end
  
