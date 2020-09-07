%% elxWritePointSetFile
%
% Write point set in a file readable by elastix/transformix.
%
%% Syntax
%
% |[Success, Message] = elxWritePointSetFile(PointSet, Filename)|
%
%% Input arguments
%
% * |PointSet| (<StrPointSet_help.html |StrPointSet|> structure): The point set.
% * |Filename| (string): The file to be written.
%
%% Output arguments
%
% * |Success| (boolean): true if ok.
% * |Message| (string): Message.
%
%% Description
%
% Write point set in a file readable by elastix/transformix.  If PointSet 
% has the two fields |Points| and |Indices|, then the function only
% consider the field |Points| and write those coordinates in the file.
%
%% See also 
%
% <elxTransformix.html |elxTransformix|> <StrPointSet_help.html
% |StrPointSet|>
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
% $Id: elxWritePointSetFile.m 3 2012-05-25 19:37:07Z coron $
function [Success, Message] = elxWritePointSetFile(PointSet, Filename)

Success = true;
[Success, Message] = elxIsStrPointSet(PointSet);
if ~Success
  return;
end

if isfield(PointSet, 'Points')
  Format = '%g';
  Coordinates = PointSet.Points.'; % .' easier when writing in file.
  IndexOrPoint = 'point';
elseif isfield(PointSet, 'Indices')
  Format = '%i';
  Coordinates = PointSet.Indices.';
  IndexOrPoint = 'index';
else
  Success = false;
  Message = [mfilename ':Internal error'];
  return;
end

[Fid, Message] = fopen(Filename, 'w');
if Fid == -1
  Success = false;
  return;
end

SizeCoordinates = size(Coordinates);
if numel(SizeCoordinates) > 2
  Success = false;
  Message = [mfilename ': Coordinates must be a 2-D array.'];
  return;
end

NDims = SizeCoordinates(1);
for Cpt = 1:NDims
  switch Cpt
    case 1
      FormatString = [Format];
    otherwise
      FormatString = [FormatString ' ' Format];
  end
end
FormatString(end+1:end+2) = '\n';

% Write data in the file
fprintf(Fid, '%s\n', IndexOrPoint);
fprintf(Fid, '%i\n', SizeCoordinates(2)); % Number of points
fprintf(Fid, FormatString, Coordinates);
[Message, Errnum] = ferror(Fid);
fclose(Fid);

if Errnum ~= 0
  Message = [mfilename ':' Message];
  Success = false;
end
