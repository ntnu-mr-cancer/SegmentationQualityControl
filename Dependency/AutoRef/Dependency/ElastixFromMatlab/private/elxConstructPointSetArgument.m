%% elxConstructPointSetArgument
%
% Compose a common set of elastix/transformix arguments whose values are PointSet.
%
%% Syntax
%
% |[ArgStr, Success, Message] = elxConstructPointSetArgument(Argname, ArgFlag, Filename, PointSet)|
%
%% Input arguments
%
% * |Argname| (character array): common name of the option
% * |ArgFlag| (character array): flag of the option/argument
% * |Filename| (character array): The filename
% which will be written if the PointSet is in a <StrPointSet_help.html |StrPointSet| structure>.  
% * |PointSet| (cell of strings or <StrPointSet_help.html |StrPointSet| structure>):
%   Filename of the PointSet or PointSet in a structure
%
%% Output arguments
%
% * |ArgStr| (character array): a command line argument.
% * |Success| (boolean): true if ok.
% * |Message| (character array): empty message if ok
%
%% Description
%
% Compose a common set of elastix/transformix arguments whose value is a
% PointSet.  The PointSet must already be stored in files or are written in
% files by the function.
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
% $Id: elxConstructPointSetArgument.m 3 2012-05-25 19:37:07Z coron $
function [ArgStr, Success, Message] = elxConstructPointSetArgument(Argname, ArgFlag, ...
  Filename, PointSet)

Message = '';
Success = true;
ArgStr = '';
if isempty(PointSet)
  return;
end
if iscellstr(PointSet)
  ArgType = 1;
elseif elxIsStrPointSet(PointSet)
  ArgType = 2;
else
  Success = false;
  Message = sprintf(['The %s must be either a cell of strings filename or ' ...
    'a StrDatax structure.'], Argname);
  return;
end

switch ArgType
  case 1,
    % Data image(s) specified as filename(s)
    Filename = PointSet;
    if ~exist(Filename, 'file')
      Success = false;
      Message = sprintf('%s %s does not exist', ArgName, Filename);
      return;
    end
  case 2
    % Data image(s) specified as StrDatax(s)
    [Success Message] = elxWritePointSetFile(PointSet, Filename);
    if ~Success
      return;
    end
end
ArgStr = elxConstructArgumentString(ArgFlag, false, 1, Filename);
