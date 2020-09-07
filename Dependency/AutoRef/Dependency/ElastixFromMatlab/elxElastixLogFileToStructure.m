%% elxElastixLogFileToStructure
%
% Read the Elastix log file and convert most of the information into a Matlab
% structure.
%
%% Syntax
%
% |[Log, Success] = elxElastixLogFileToStructures(LogFilename)|
%
%% Input arguments
%
% * |LogFilename|: Name of the Elastix log file
%
%% Output Arguments
%
% * |Log|: The log file information as a Matlab structure
% * |Success|: true if ok, false otherwise
%
%% Description
%
% Read the Elastix log file and convert most of the information into a Matlab
% structure.
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
% $Id: elxElastixLogFileToStructure.m 11 2013-03-25 12:35:25Z coron $
%
function [ElastixVersion, ParameterFile, ElapsedTimeInSec, Success, Message] ...
  = elxElastixLogFileToStructure(LogFilename)


ElastixVersion = [NaN NaN];
ElapsedTimeInSec = NaN;
ParameterFile = struct();

[Lines, Success, Message] = elxTextFileToCellArrayOfStrings(LogFilename);
if ~Success
  Success = false;
  return;
end

NbValidLines = numel(Lines);

% First check for error message
Match = regexpi(Lines, '(^ERROR.*)|(ERROR IN)', 'start', 'once');
IndErrorLine = find(cellfun(@numel, Match) >= 1);
if ~isempty(IndErrorLine)
  Success = false;
  Message = Lines(IndErrorLine:end);
  return;
end

ElastixVersion = elxElastixVersionFromLinesOfLogFile(Lines);

if all(~isnan(ElastixVersion)) ...
    && any(ElastixVersion ~= [4 300]) && any(ElastixVersion ~= [4 400]) ...
    && any(ElastixVersion ~= [4 500]) && any(ElastixVersion ~= [4 600]) ...
    && any(ElastixVersion ~= [4 700]) && any(ElastixVersion ~= [4 800])
  % With Elastix 4.300, it may be impossible to reach the version if 
  % for example the parameter file is incorrect.
  Success = false;
  Message = ['The ELASTIX version was not found' ...
    ' (problem with parameter file) or the program expects ELASTIX ' ...
    ' version 4.300 to 4.800.'];
  return;
end


% In the log file we get 
%     Starting section
%     ParameterFile section
%     Ending section
StartingSection = [1; Inf];
for Cpt = 1:NbValidLines
  Match = regexp(Lines{Cpt}, '^-+$', 'match', 'once');
  if numel(Match) 
    StartingSection(2) = Cpt - 1;
    break;
  end
end

% Find the begining of each ParameterFile sections
Offset = StartingSection(2);
Tokens = regexp(Lines(Offset:NbValidLines), ...
  '^Running elastix with parameter file (\d+): "([^"]+)"\.', ...
  'tokens', 'once');
LineNumber = find(cellfun(@numel, Tokens) == 2);
NbParameterFiles = numel(LineNumber);
ParameterFileSection = [1;NbValidLines]*ones(1, NbParameterFiles);
ParameterFileSection(1, :) = LineNumber + Offset -1;

% Find the end of each ParameterFile sections
Offset = ParameterFileSection(1, 1);
Start = regexp(Lines(Offset:NbValidLines), ...
  '^Time used for running elastix with this parameter file', 'start', 'once');
LineNumber = find(cellfun(@numel, Start));
ParameterFileSection(2, 1:numel(LineNumber)) = LineNumber + Offset - 1;

ParameterFile = struct('Parameters', {}, ...
  'DefaultParameters', {}, ...
  'EstimatedParameters', {}, ...
  'Transform', {}, ...
  'NbResolutions', {}, ...
  'Resolution', {});
% Analyze each parameter file Section.
for Cpt = 1:NbParameterFiles
  % Subdivide each parameter file Section into subsections.
  LinesParameterFile = Lines(ParameterFileSection(1, Cpt)...
    :ParameterFileSection(2, Cpt));
  [SubS, TmpSuccess] = elxParameterFileSubsectionsFromLinesOfElastixLogFile(...
    LinesParameterFile);
  if TmpSuccess
    ParameterFile(Cpt).Parameters = elxLinesOfStructuredFileToStructure(...
      LinesParameterFile(SubS.ParameterFile(1):SubS.ParameterFile(2)));
    [ParameterFile(Cpt).DefaultParameters, ...
      ParameterFile(Cpt).UnprocessedWarnings] ...
      = elxProcessWarningLines(LinesParameterFile(...
      SubS.Initialisation(1):SubS.Initialisation(2)));
    ParameterFile(Cpt).NbResolutions = size(SubS.Resolution, 2);
    ParameterFile(Cpt).Resolution ...
      = elxParseLinesOfResolutionOfElastixLogFile(LinesParameterFile, ...
      SubS.Resolution);
    ParameterFile(Cpt).Transform = elxLinesOfStructuredFileToStructure(...
      LinesParameterFile(SubS.TransformParameterFile(1):SubS.TransformParameterFile(2)));
  end
end

% Find the ending section
EndingSection = [ParameterFileSection(2,end)+3; NbValidLines];
[ElapsedTimeInSec, Success, Message] = elxParseLinesOfEndingSectionOfElastixLogFile(...
    Lines(EndingSection(1):EndingSection(2)));

