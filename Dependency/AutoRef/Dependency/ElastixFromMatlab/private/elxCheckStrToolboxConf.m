%% elxCheckStrToolboxConf
%
% Check the field names of the StrToolboxConf input structure.
%
%% Syntax
%
% |OutConf = elxCheckStrToolboxConf(InConf)|
%
%% Input arguments
%
% * |InConf| (<StrToolboxConf_help.html |StrToolboxConf| structure>): A structure 
% with Elastix general configuration (Input/Output directories, executables...).  
%
%% Output arguments
%
% * |OutConf| (<StrToolboxConf_help.html |StrToolboxConfx| structure>): Missing
% mandatory fiels are added to the input structure.
%
%% Description
%
% Check the field names of the StrToolboxConf input structure. If some of fields are
% missing, they are set to the default value.
%
%% See also 
%
% <elxElastix.html |elxElastix|>, <elxTransformix.html |elxTransformix|>,
% <elxDefaultConfiguration.html |elxDefaultConfiguration|>
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
% $Id: elxCheckStrToolboxConf.m 1 2012-04-27 18:47:40Z coron $
function OutConf = elxCheckStrToolboxConf(InConf)

OutConf = elxDefaultConfiguration;
if isstruct(InConf)
  InvalidFieldNames = setdiff(fieldnames(InConf), fieldnames(OutConf));
  if numel(InvalidFieldNames)
    error(['Few fields (' sprintf('%s ', InvalidFieldNames{:}) ...
      ') of the elastix configuration are invalid.']);
  end
  for Field = fieldnames(InConf).'
    OutConf(1).(Field{1}) = InConf(1).(Field{1});
  end
elseif ~isempty(InConf)
  error('InConf must be empty or a structure.');
end
