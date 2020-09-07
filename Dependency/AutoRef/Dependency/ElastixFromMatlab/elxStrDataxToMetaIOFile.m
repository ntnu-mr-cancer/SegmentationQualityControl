%% elxStrDataxToMetaIOFile
%
% Write the <StrDatax_help.html StrDatax> structure in a MetaIO file.
%
%% Syntax
%
% |Status, ErrorMsg = elxStrDataxToMetaIOFile(StrData, Filename, PermuteAxes)|
%
%% Input argument
%
% * |StrData| (<StrDatax_help.html StrDatax>: a structure describing the data
% * |Filename|: the filename
% * |PermuteAxes| (boolean optional, default: false): In 2D allows to 
% switch the two axes
%
%% Output argument
%
% * |Status|: true if the operation succeeds.
% * |ErrorMsg|: A string which either is empty when the funcion succeeds, or
%   contains an error message. 
%
%% Description
%
% Write the <StrDatax_help.html StrDatax> structure in a MetaIO file.
%
%% See also 
%
% <elxElastix.html |elxElastix|>, <elxTransformix.html |elxTransformix|>,
% <StrDatax_help.html StrDatax>
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
% $Id: elxStrDataxToMetaIOFile.m 1 2012-04-27 18:47:40Z coron $
function [Status, ErrorMsg] = elxStrDataxToMetaIOFile(StrData, Filename, PermuteAxes)

if nargin < 3
  PermuteAxes = false;
end

Status = false;
ErrorMsg = '';
NDims = numel(StrData.x);
NDimsData = ndims(StrData.Data);
SizeData = size(StrData.Data);
if NDimsData-NDims ~= 0 && NDimsData-NDims ~= 1
  ErrorMsg = 'The dimension of the members x and Data are not consistent.';
  return;
end

if NDims ~= 2 && PermuteAxes
  ErrorMsg = 'PermuteAxes is only available for 2-D images';
  return;
end

ObjectType = 'Image';
ElementNumberOfChannels = 1;
if NDims ~= NDimsData
  ElementNumberOfChannels = SizeData(NDimsData); 
end
Origin = zeros(1, NDims);
ElementSpacing = zeros(1, NDims);
for Cpt = 1:NDims
  Origin(Cpt) = StrData.x{Cpt}(1);
  ElementSpacing(Cpt) = diff(StrData.x{Cpt}(1:2));
end

switch class(StrData.Data)
  case 'logical'
    ElementType = 'MET_CHAR';
    StrData.Data = int8(StrData.Data);
  case 'uint8', 
    ElementType = 'MET_UCHAR';
  case 'int8',
    ElementType = 'MET_CHAR';
  case 'uint16',
    ElementType = 'MET_USHORT';
  case 'int16',
    ElementType = 'MET_SHORT';
  case 'single',
    ElementType = 'MET_FLOAT';
  case 'double',
    ElementType = 'MET_DOUBLE';
  otherwise
    ErrorMsg = sprintf('Unrecognised data type %s.', class(StrData.Data));
    return;
end

TransformMatrix = eye(NDims);                                               %% EDIT M.E
if isfield(StrData,'DirectionCosines')                                      %% EDIT M.E
    TransformMatrix = StrData.DirectionCosines;                             %% EDIT M.E
end                                                                         %% EDIT M.E

if PermuteAxes
  TransformMatrix(:,[1 2]) = TransformMatrix(:,[2 1]);                      %% EDIT M.E
  Origin([1 2]) = Origin([2 1]);
  ElementSpacing([1 2]) = ElementSpacing([2 1]);
  SizeData([1 2]) = SizeData([2 1]);
  StrData.Data = permute(StrData.Data, [2 1 3:NDimsData]);
end

[Path,Name,~] = fileparts(Filename);                                        %% EDIT M.E
[Fid, ErrorMsg] = fopen(Filename, 'w', 'l');
if Fid == -1
  return;
end
fprintf(Fid, 'ObjectType = %s\n', ObjectType);
fprintf(Fid, 'NDims = %i\n', NDims);
fprintf(Fid, 'BinaryData = true\n');
fprintf(Fid, 'BinaryDataByteOrderMSB = false\n');
fprintf(Fid, 'TransformMatrix = ');                                         %% EDIT M.E
fprintf(Fid, ' %g', TransformMatrix(:)); fprintf(Fid, '\n');                %% EDIT M.E
fprintf(Fid, 'DimSize =');
fprintf(Fid, ' %i', SizeData(1:NDims)); fprintf(Fid, '\n');
fprintf(Fid, 'Origin = ');
fprintf(Fid, ' %g', Origin); fprintf(Fid, '\n');
fprintf(Fid, 'ElementSpacing =');
fprintf(Fid, ' %g', ElementSpacing); fprintf(Fid, '\n');
fprintf(Fid, 'ElementNumberOfChannels = %i\n', ElementNumberOfChannels);
fprintf(Fid, 'ElementType = %s\n', ElementType);
% fprintf(Fid, 'ElementDataFile = LOCAL\n');                                %% EDIT M.E
fprintf(Fid, 'ElementDataFile = %s.raw\n',Name);                            %% EDIT M.E
fclose(Fid);                                                                %% EDIT M.E

[Fid, ErrorMsg] = fopen(fullfile(Path,[Name '.raw']), 'w', 'l');            %% EDIT M.E
if Fid == -1                                                                %% EDIT M.E
  return;                                                                   %% EDIT M.E
end                                                                         %% EDIT M.E
if ElementNumberOfChannels ~= 1
  StrData.Data = permute(StrData.Data, [NDimsData 1:NDims]);
end
Count = fwrite(Fid, StrData.Data(:), class(StrData.Data));
fclose(Fid);
if Count ~= prod(SizeData)
  ErrorMsg = 'Error when writing the data.';
  return;
end
Status = true;
