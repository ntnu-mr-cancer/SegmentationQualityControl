%% elxParseLinesOfResolutionOfElastixLogFile
%
% Short description
%
%% Syntax
%
% |[Resolution, Status] = elxParseLinesOfResolutionOfElastixLogFile(Lines, NumLineRes)|
%
%% Input arguments
%
% * |Lines| (cell array of strings): 
% * |NumLineRes|: 
%
%% Output arguments
%
% * |Resolution|: 
% * |Status|: 
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
% $Id: elxParseLinesOfResolutionOfElastixLogFile.m 1 2012-04-27 18:47:40Z coron $
function [Resolution, Status] = elxParseLinesOfResolutionOfElastixLogFile(...
  Lines, NumLineRes)

Resolution = struct();
Status = false;
NbResolutions = size(NumLineRes, 2);

for CptR = 1:NbResolutions
  %% Find the begining of the iteration section
  IterStart = regexp(Lines(NumLineRes(1,CptR):NumLineRes(2, CptR)), ...
    '^1:ItNr.*', 'match', 'once');
  IndIterStart = find(cellfun(@numel, IterStart)) + NumLineRes(1, CptR) - 1;
  % Lines{IndIterStart};
  Fields = regexp(Lines{IndIterStart}, '\S+', 'match');
  % Fields{:}
  NbFields = numel(Fields);
  FieldNames = FieldToFieldName(Fields);
  
  %% Find the end of the iteration section
  IterStop = regexp(Lines(IndIterStart:NumLineRes(2, CptR)), ...
    '^\d+', 'start', 'once');
  IndIterStop = find(cellfun(@numel, IterStop)==0, 1, 'first') + IndIterStart - 2;

  %% Extract the warnings
  [Resolution(CptR).DefaultParameters, ...
      Resolution(CptR).UnprocessedWarnings]  = elxProcessWarningLines(...
      Lines(NumLineRes(1,CptR):NumLineRes(2, CptR)));
  
  %% Extract the values at resolution CptR-1
  NbIter = IndIterStop - IndIterStart;
  % NbIter, NbFields
  
  %% Those values are not always scalars.  Sometimes they may be textual indication 
  % for example with QuasiNewtonLBFGS
  ValueClass = cellstr(repmat('scalar', [NbFields, 1]));
  FirstLineValues = regexp(Lines{IndIterStart + 1}, '\S+', 'match');
  ValueIsnan = isnan(str2double(FirstLineValues));
  ValueClass(ValueIsnan) = cellstr(repmat('string', [sum(ValueIsnan) 1]));
  ValueIsLogical = strcmp(FirstLineValues, 'true') | strcmp(FirstLineValues, 'false');
  ValueClass(ValueIsLogical) = cellstr(repmat('logical', [sum(ValueIsLogical) 1]));
 
  %% Preallocate the fields of the structure
  for CptFields = 1:NbFields
    if strcmp(FieldNames{CptFields}, 'ItNr')
      continue;
    end
    switch ValueClass{CptFields}
      case 'scalar'
        Resolution(CptR).(FieldNames{CptFields}) = zeros([NbIter 1]);
      case 'logical'
        Resolution(CptR).(FieldNames{CptFields}) = true([NbIter 1]);
      case 'string'
        Resolution(CptR).(FieldNames{CptFields}) = cell([NbIter 1]);
      case 'otherwise'
        error('Internal error');
    end
  end
  
  % Analyze each line
  for CptIter = 1:NbIter
    nextindex = 1;
    for CptFields = 1:NbFields
       switch ValueClass{CptFields}
        case 'scalar'
          [TmpV, tmpc, tmperr, ...
            tmpnext] = sscanf(Lines{IndIterStart + CptIter}(nextindex:end), ...
            '%g', 1);
          if ~strcmp(FieldNames{CptFields}, 'ItNr')
            Resolution(CptR).(FieldNames{CptFields})(CptIter) = TmpV;
          end
        case 'logical'
          [TmpV, tmpc, tmperr, tmpnext] ...
            = sscanf(Lines{IndIterStart + CptIter}(nextindex:end), ...
            '%s', 1);
          Resolution(CptR).(FieldNames{CptFields})(CptIter) = strcmp(TmpV, 'true');
        case 'string'
          [Resolution(CptR).(FieldNames{CptFields}){CptIter}, tmpc, tmperr, ...
            tmpnext] = sscanf(Lines{IndIterStart + CptIter}(nextindex:end), ...
            '%s', 1);
        otherwise
          error('Internal error');
       end
       nextindex = nextindex + tmpnext;
    end
  end
end
end

function FieldName = FieldToFieldName(Fields)
% We must check that the field name are unique, simple and valid.

% % Replace ||x|| by xNorm                                                  %% EDIT M.E.
% Fields = regexprep(Fields, '\|\|(\w+)\|\|', '$1Norm');                    %% EDIT M.E.
% Remove [ and ], replace - by _.
Fields = regexprep(Fields, '[\[\]]', '');
Fields = regexprep(Fields, '-', '_');
Fields = regexprep(Fields, '(\d+\w*:)(.*)', '$2');
% Replace ||x|| by xNorm                                                    %% EDIT M.E.
Fields = regexprep(Fields, '\|\|(\w+)\|\|', '$1Norm');                      %% EDIT M.E.

FieldName = cell(size(Fields));

MyMap = containers.Map();
for CptF = 1:numel(Fields)
  TmpFieldName = Fields{CptF};
  if MyMap.isKey(TmpFieldName)
    TmpFieldName = 'NotSet';
  else
    MyMap(TmpFieldName) = 1;
  end
  FieldName{CptF} = TmpFieldName;
end

for CptF = 1:numel(Fields)  
  if strcmp(FieldName{CptF}, 'NotSet')
    Cpt = 1;
    FoundFieldName = false;
    while ~FoundFieldName
      TmpFieldName = [Fields{CptF} '_' sprintf('%02', Cpt)];
      if MyMap.isKey(TmpFieldName)
        Cpt = Cpt + 1;
      else
        FoundFieldName = true;
      end
    end
    FieldName{CptF} = TmpFieldName;
    MyMap(TmpFieldName) = 1;
  end
end
end
