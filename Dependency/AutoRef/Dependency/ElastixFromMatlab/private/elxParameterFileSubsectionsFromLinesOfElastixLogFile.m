%% elxParameterFileSubsectionsFromLinesOfElastixLogFile
%
% Find the beginning and end of the main sections of the log file
%
%% Syntax
%
% |[Sub, Status] = elxParameterFileSubsectionsFromLinesOfElastixLogFile(Lines)|
%
%% Input arguments
%
% * |Lines| (cell array of strings): Lines of the Log file
%
%% Output arguments
%
% * |Sub| (structure): Begin and end of each subsection.
%
%% Description
%
% Find the beginning and end of the main sections of the log file.
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
% $Id: elxParameterFileSubsectionsFromLinesOfElastixLogFile.m 1 2012-04-27 18:47:40Z coron $
function [Sub, Status] = elxParameterFileSubsectionsFromLinesOfElastixLogFile(Lines)

% StartingElastix
% ParameterFile
% Initialisation
% ResolutionXXX
% TransformParameterFile
% EndingSection
Status = false;
Sub.StartingElastix = -1*ones(2, 1);
Sub.ParameterFile = -1*ones(2, 1);
Sub.Initialisation = -1*ones(2, 1);
Sub.Resolution = -1*ones(2, 1);
Sub.TransformParameterFile = -1*ones(2, 1);
Sub.EndingElastix = -1*ones(2, 1);

NbLines = numel(Lines);

[MissingMarker, LineNum] = FindMarker(Lines, ...
  '^=+ start of ParameterFile: ');
if MissingMarker
  return;
end
Sub.ParameterFile(1, 1:numel(LineNum)) = LineNum + 1;
Sub.StartingElastix(2, 1) = LineNum(1) - 1;

Offset = Sub.ParameterFile(1);
[MissingMarker, LineNum] = FindMarker(Lines(Offset:end), ...
  '^=+ end of ParameterFile');
if MissingMarker
  return;
end
Sub.ParameterFile(2,:) = LineNum + Offset - 2;
Sub.Initialisation(1) = LineNum + Offset;

%%% Find resolution part Section
Offset = Sub.Initialisation(1);
[MissingMarker, LineNum] = FindMarker(Lines(Offset:end), ...
  '^Resolution: \d+$');
if MissingMarker
  return;
end
ReportMissingMarker(MissingMarker, ' Resolution marker.');
Sub.Initialisation(2) = LineNum(1) + Offset - 2;
Sub.Resolution(1, 1:numel(LineNum)) = LineNum + Offset;
Sub.Resolution(2, 1:numel(LineNum)-1) = LineNum(2:end) + Offset - 1;

%%% Find beginning TransformParameterFile Section
Offset = Sub.Resolution(1, end);
[MissingMarker, LineNum] = FindMarker(Lines(Offset:end), ...
  '^=+ start of TransformParameterFile =+$');
if MissingMarker
  return;
end
Sub.TransformParameterFile(1) = LineNum + Offset;
Sub.Resolution(2, end) = LineNum + Offset - 1;

%%% Find Ending Section
Offset = Sub.TransformParameterFile(1);
[MissingMarker, LineNum] = FindMarker(Lines(Offset:end), ...
  '^=+ end of TransformParameterFile =+$');
if MissingMarker
  return;
end
Sub.TransformParameterFile(2) = LineNum + Offset - 2;
Sub.EndingElastix = [LineNum+Offset+1; NbLines];
Status = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [MissingMarker, LineNumber] = FindMarker(Lines, MarkerAsRegExp)
MissingMarker = true;
Start = regexp(Lines, MarkerAsRegExp, 'start', 'once');
LineNumber = find(cellfun(@numel, Start) >= 1);
if numel(LineNumber)
  MissingMarker = false;
end
end

function ReportMissingMarker(MissingMarker, MarkerName)
if MissingMarker
  error(['Internal error. Can''t find ' MarkerName ' .']);
end
end
