%% elxElastixVersion
%
% Return the Elastix version
%
%% Syntax
%
% |Version = elxElastixVersion(elxConf)|
%
%% Input arguments
%
% * |elxConf| (<StrToolboxConf_help.html |StrToolboxConf|> Structure): Elastix configuration
%
%% Output arguments
%
% * |Version| (1x2 vector): The major and minor version of Elastix.  [0 0] if not
% found.
%
%% See also 
%
% <elxElastix.html |elxElastix|>, <elxTransformix.html |elxTransformix|>, 
% <StrToolboxConf_help.html |StrToolboxConf|>
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
% $Id: elxElastixVersion.m 4 2012-05-25 20:09:12Z coron $
function Version = elxElastixVersion(elxConf)

% Format potential error messages.
MESystem = 'The system call to %1$s failed with the following error message\n%2$s\n';
MEConf = ['There is something wrong with the %1$s command (%2$s) stored in the field' ...
  ' %3$s of the first argument of the function. '];
elxMEConf = sprintf(MEConf, 'elastix', elxConf.ElastixProgram, 'ElastixProgram');
trxMEConf = sprintf(MEConf, 'transformix', elxConf.TransformixProgram, 'TransformixProgram');
MEVersion = 'Can''t determine the %1$s version.\n\n'; 

Version = zeros(1, 2);

% Check elastix
[s_elx, elxMessage] = system([elxConf.ElastixProgram ' --version']);
if s_elx ~= 0 
  error('elx:confelastix',[sprintf(MESystem, 'elastix', elxMessage)  elxMEConf]);
end
[elxMajor, elxMinor, status] = major_and_minor_version('elastix', elxMessage);
if ~status
  error('elx:confelastix',[sprintf(MEVersion, 'elastix') elxMEConf])
end

% Check transformix
[s_trx, trxMessage] = system([elxConf.TransformixProgram ' --version']);
if s_trx ~= 0
  error('elx:conftransformix',[sprintf(MESystem, 'transformix', trxMessage) trxMEConf]);...
end
[trxMajor, trxMinor, status] = major_and_minor_version('transformix', trxMessage);
if ~status
  error('elx:conftransformix',[sprintf(MEVersion, 'transformix') trxMEConf])
end

% Same version?
if elxMajor~=trxMajor || elxMinor~=trxMinor
  error('elx:elxtrxversion', 'elastix and transformix have not the same version %i.%i~=%i.%i',...
    elxMajor, elxMinor, trxMajor, trxMinor);
  return;
end
Version = [elxMajor elxMinor];

end

%% 
function [major, minor, status] = major_and_minor_version(program, string_version)

status = false;
minor=0; major = 0;
Tokens = regexp(string_version, [program ' version: (\d+).(\d+)'],'tokens', 'once');
if numel(Tokens) == 2
  major = str2double(Tokens{1});
  minor = str2double(Tokens{2});
  status = true;
end
end
