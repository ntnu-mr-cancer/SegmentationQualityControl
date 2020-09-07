%% elxStructuredValueToMatlabType
%
% Short description
%
%% Syntax
%
% |OutValue = elxStructuredValueToMatlabType(Value)|
%
%% Input arguments
%
% * |Value|: 
%
%% Output arguments
%
% * |OutValue|:
%
%% Description
%
% Long Description
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
% $Id: elxStructuredValueToMatlabType.m 1 2012-04-27 18:47:40Z coron $
function OutValue = elxStructuredValueToMatlabType(Value)

if Value(1) == '"'
  Tokens = regexp(Value, '"(.*?)"', 'Tokens');
  Tokens = [Tokens{:}];
  NbElt = numel(Tokens);
  MatTrue = strcmp(Tokens, 'true');
  MatFalse = strcmp(Tokens, 'false');
  NbTrue = sum(MatTrue);
  NbFalse = sum(MatFalse);
  if NbTrue+NbFalse == NbElt
    OutValue = MatTrue;
    return;
  end
  if NbTrue+NbFalse == 0
    if numel(Tokens) == 1
      OutValue = Tokens{1};
    else
      OutValue = Tokens;
    end
    return;
  end
  error('Value is mixing array of strings and logical.');
end

OutValue = sscanf(Value, '%g');
