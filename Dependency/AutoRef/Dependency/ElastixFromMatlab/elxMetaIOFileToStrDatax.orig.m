%% elxMetaIOFileToStrDatax
%
% Read a MetaIO file and return the image in a <StrDatax_help.html StrDatax>
% structure with additional fields.
%
%% Syntax
%
% |[StrDatax, Success, Message] = elxMetaIOFileToStrDatax(Filename, PermuteAxes)|
%
%% Input arguments
%
% * |Filename| (string): The MetaIO filename
% * |PermuteAxes| (boolean): optional argument.  If true permute the first
% two axes.  Its default value is false.
%
%% Output arguments
%
% * |StrDatax| (<StrDatax_help.html StrDatax>): The image.
% * |Success| (logical): true on success.
% * |Message| (string): Error message
%
%% Description
%
% Read a MetaIO file and return the image in a <StrDatax_help.html StrDatax>
% structure with additional fields.
%
%
%% See also 
%
% <elxElastix.html |elxElastix|>, <elxTransformix.html |elxTransformix|>,
% <elxStrDataxToMetaIOFile.html |elxStrDataxToMetaIOFile|>
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
% $Id: elxMetaIOFileToStrDatax.m 1 2012-04-27 18:47:40Z coron $
function [StrDatax, Success, Message] = elxMetaIOFileToStrDatax(Filename, PermuteAxes)

Success = true;
[Dir, FName] = fileparts(Filename);
[Fid, Message] = fopen(Filename, 'r', 'l');
if Fid == -1
  Success = false;
  return;
end

if nargin < 2
  PermuteAxes = false;
end

NDims = 0;
DimSize = [];
Origin = [];
Spacing = [];
ElementNumberOfChannels = 1;
ElementByteOrderMSB = false;
ReadRawDataFile = false;
RawDataFilename = '';
BinaryData = true;
BinaryDataByteOrderMSB = false;
CompressedData = false;

FoundLastTag = false;
while ~FoundLastTag
  Line = fgetl(Fid);
  [Match, Tokens] = regexp(Line, ...
    '\s*(\w+)\s*=\s*(.*)', 'match', 'tokens', 'once');
  if ~numel(Match)
    Success = false;
    Message = [mfilename ': Can''t analyse line : ' Line];
    return;
  end
  Tag = Tokens{1};
  Value = Tokens{2};
  switch Tag
    case 'ObjectType'
      if ~strcmp(Tokens{2}, 'Image')
        Success = false;
        Message = [mfilename ':Image is the only supported ObjectType.'];
        return;
      end
    case 'NDims',
      NDims = sscanf(Tokens{2}, '%i');
      DimSize = ones(1, NDims);
      Origin = zeros(1, NDims);
      Spacing = ones(1, NDims);
    case 'ElementType'
      ElementType = Tokens{2};
      switch ElementType
        case 'MET_UCHAR',  MType = 'uint8';
        case 'MET_CHAR',   MType = 'int8';
        case 'MET_USHORT', MType = 'uint16';
        case 'MET_SHORT',  MType = 'int16';
        case 'MET_UINT',   MType = 'uint32';
        case 'MET_FLOAT',  MType = 'single';
        case 'MET_DOUBLE', MType = 'double';
        otherwise
          Success = false;
          Message = [mfilename ': Unrecognised ElementType ' ElementType];
      end
    case {'Offset', 'Origin', 'Position' }
      Origin = sscanf(Tokens{2},'%g').';
    case 'DimSize', 
      DimSize = sscanf(Tokens{2},'%i').';
    case 'ElementSpacing'
      Spacing = sscanf(Tokens{2}, '%g').';
    case 'ElementDataFile',
      DataFile = Tokens{2};
      if strcmp(Tokens{2}, 'LOCAL')
        ReadRawDataFile = false;
        RawDataFilename = '';
      else
        ReadRawDataFile = true;
        RawDataFilename = Tokens{2};
      end
      FoundLastTag = true;
    case {'ElementByteOrderMSB', 'BinaryData',...
        'BinaryDataByteOrderMSB', 'CompressedData'}
      eval([Tokens{1} '=' lower(Tokens{2}) ';']);
    case 'ElementNumberOfChannels',
      ElementNumberOfChannels = sscanf(Tokens{2}, '%i');
    case 'TransformMatrix'
      TransformMatrix = sscanf(Tokens{2}, '%f');
      TransformMatrix = reshape(TransformMatrix, [NDims NDims]);
      if any(TransformMatrix ~= eye(NDims))
        Success = false;
        Message = [mfilename ': TransformMatrix ~= Id is not yet supported'];
      end
    case 'CenterOfRotation'
      CenterOfRotation = sscanf(Tokens{2}, '%f');
      StrDatax.CenterOfRotation = CenterOfRotation(:).';
    case 'AnatomicalOrientation'
      StrDatax.AnatomicalOrientation = Tokens{2};
    case 'Color',
      % Ignore
    otherwise
      Success = false;
      Message = [mfilename ': Unsupported tag ' Tag];
  end
end

if CompressedData
  Success = false;
  Message = [mfilename ':CompressedData is not yet supported.'];
  return;
end

StrDatax.x = cell(1, NDims);
for Cpt = 1:NDims
  StrDatax.x{Cpt} = Origin(Cpt)+Spacing(Cpt)*(0:DimSize(Cpt)-1);
end

if ReadRawDataFile
  fclose(Fid);
  RawFilename = fullfile(Dir, RawDataFilename);
  if BinaryDataByteOrderMSB
    RawFileMachineFormat = 'b'
  else
    RawFileMachineFormat = 'l';
  end
  [Fid, Message] = fopen(RawFilename, 'r', RawFileMachineFormat);
  if Fid == -1
    Success = false;
    return;
  end
else
  FPosition = ftell(Fid);
  fclose(Fid);
  if ElementByteOrderMSB
    FileMachineFormat = 'b';
  else
    FileMachineFormat = 'l';
  end
  Fid = fopen(Filename, 'r', FileMachineFormat);
  fseek(Fid, FPosition, 'bof');
end
StrDatax.Data = fread(Fid, ElementNumberOfChannels*prod(DimSize), ...
  ['*' MType]);
fclose(Fid);
if ElementNumberOfChannels == 1
  StrDatax.Data = reshape(StrDatax.Data, DimSize);
else
  StrDatax.Data = reshape(StrDatax.Data, [ElementNumberOfChannels DimSize]);
  StrDatax.Data = permute(StrDatax.Data, [2:NDims+1 1]);
end

if PermuteAxes
  StrDatax.x([1 2]) = StrDatax.x([2 1]);
  NDimsData = ndims(StrDatax.Data);
  StrDatax.Data = permute(StrDatax.Data, [2 1 3:NDimsData]);
  if isfield(StrDatax, 'CenterOfRotation')
    StrDatax.CenterOfRotation = StrDatax.CenterOfRotation([2 1]);
  end
end

end

function Bool = StringToLogical(String)
switch String
  case 'true',  Bool = true;
  case 'false', Bool = false;
  otherwise
    error(['Incorrect boolean value ' ...
      String]);
end

end
