%% elxTransformix
%
% Apply with transformix a transform on an input image and/or generates a
% deformation field.
%
%% Syntax
%
% |[Data, Log, Success, Message]=elxTransformix(myConf, Transforms, 
% 'Image', Image, 'Deformation', Deformation, 'Points', Points, 
% 'Indices', Indices, 'DeterminantOfJacobian', DeterminantOfJacobian,
% 'JacobianMatrix', JacobianMatrix)|
%
%% Input arguments
%
% * |myConf|: Structure with Elastix general configuration (Input/Output 
%   directory, executables...).  See |elxDefaultConfiguration|
% * |Transforms|: Structure or cell array of structures describing the 
% transformation returned by elxElastix
% * |'Image', Image|: (optional Param+Value) the input image as an StrDatax
%   structure of a filename.
% * |'Deformation', Deformation|: (optional Param+Value) Deformation is
% a string among '', 'all', or a <StrPointSet_help.html |StrPointSet|>
% structure to specify a PointSet
% * |'DeterminantOfSpatialJacobian', DeterminantOfSpatialJacobian|: (optional Param+Value)
% logical. Default to |false|. When |true| the determinant of the spatial Jacobian
% of the transformation is computed and returned in the structure Data.
% * |'SpatialJacobianMatrix', SpatialJacobianMatrix|: (optional Param+Value)
% logical. Default to |false|. When |true| the spatial Jacobian matrix is computed
% and returned in the structure Data.
%
%% Output arguments
%
% * |Data|: Structure containing the output data.
% * |Log|: Structure that represents most of the information stored in the 
%   Elastix log File (Convergence at each resolution, parameters, 
%   default parameters, transform...).  Its structure is rather complex 
%   and depends on the Elastix configuration.  I advise to check the field 
%   Log.Error.
% * |Success|; logical 1 if success
% * |Message|: Error message.
%
%% Description
%
% Call transformix to apply a transformation to an image, points or indices 
% or to compute the deformation field.  It can also compute the 
% JacobianMatrix of the deformation or its determinant.
%
%% See also 
%
% <elxElastix.html |elxElastix|>, <elxStrPointSet_help.html |StrPointSet|>
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
% $Id: elxTransformix.m 5 2012-05-25 20:17:46Z coron $
function [Data, Log, Success, Message] =  elxTransformix(myConf, ...
  Transforms, varargin)

% Several ways to use transformix
%    * transformix -def all  -out ../out2 -tp TransformParameters.0.txt
%      Output files: deformationField.mhd
%    * transformix -def inputPoints.txt -out ../out2 -tp
%           TransformParameters.0.txt
%      Output files: outputpoints.txt
%    * transformix -def inputPoints.txt -jac all
%
% Remarks about running transformix
% The file transformix.log is always written
% You must provide the mandatory arguments
%   * -out DirectoryName
%        The name of the ouput directory
%   * -tp TransformParameters.?.txt
%        The parameters of the transformation file
%
% You need at least one of the optional argument
%   * -def all
%        Output: deformationField.mhd
%   * -def inputpoints.txt
%        Output: outputpoints.txt
%      Only the first -def occurence is taken into account.
%   * -in inputImage.mhd
%        Output: result.mhd
%      Only the first -in occurence is taken into account.
%   * -jac only support all as argument
%        Output: spatialJacobian.mhd
%   * -jacmat only support all as argument
%        Output: fullSpatialJacobian.mhd
% 

Log = struct();
Data = struct();

p = inputParser();
p.addRequired('myConf', @(x) isstruct(x));
p.addRequired('Transforms', @(x) (...
  (isstruct(x) && numel(x) == 1) ...
  || (iscell(x) && all(cellfun(@(x) (isstruct(x) && numel(x)==1),x))) ...
  || (ischar(x) && exist(x, 'file'))));
p.addParamValue('Image', [], @(x) (ischar(x) && exist(x, 'file'))...
  || (elxIsStrDatax(x) && numel(x) == 1));
p.addParamValue('Deformation', '', @(x) ((ischar(x) ...
  && any(strcmp(x,{'', 'all'}))) || elxIsStrPointSet(x)));
p.addParamValue('DeterminantOfSpatialJacobian', false, @(x) islogical(x));
p.addParamValue('SpatialJacobianMatrix', false, @(x) islogical(x));
p.parse(myConf, Transforms, varargin{:});

Image = p.Results.Image;
Deformation = lower(p.Results.Deformation);
% Indices = p.Results.Indices;
% Points = p.Results.Points;
DeterminantOfSpatialJacobian = p.Results.DeterminantOfSpatialJacobian;
SpatialJacobianMatrix = p.Results.SpatialJacobianMatrix;

Conf = elxCheckStrToolboxConf(myConf);
[Success, Message] = elxCreateOrCleanIODirectories(Conf);
if ~Success,  return; end

% Process the transform argument
if isstruct(Transforms)
  % If it is a structure, convert it to cell
  TmpCell{1} = Transforms;
  Transforms = TmpCell;
end
NbTransforms = numel(Transforms);
for Cpt = 1:NbTransforms
  if ischar(Transforms)
    % The transforms is a filename
    ArgTransformFilename = Transforms;
  else
    % Transforms is a cell array of structure
    TransformFilename = fullfile(Conf.InputDirectory, ...
      sprintf('TransformParameters.%d.txt', Cpt-1));
    ArgTransformFilename = TransformFilename;
%     TmpIni = Transforms{Cpt}.InitialTransformParametersFileName;          % EDIT M.E.
    [~,NAME,EXT] = ...                                                      % EDIT M.E.
        fileparts(Transforms{Cpt}.InitialTransformParametersFileName);      % EDIT M.E.
    TmpIni = [NAME EXT];                                                    % EDIT M.E.
    if ~strcmp(TmpIni, 'NoInitialTransform')
      TmpIni = fullfile(myConf.InputDirectory, TmpIni);
      Transforms{Cpt}.InitialTransformParametersFileName = TmpIni;
    end
    [Success, Message] = elxWriteTransformParameterFile(Transforms{Cpt}, ...
      TransformFilename);
    if ~Success, return; end
  end
end
ArgTransform = [' -tp ' ArgTransformFilename];

ArgImage = '';
if ~isempty(Image)
  [ArgImage, Success, Message] = elxConstructImageArgument('image', ...
    'in', fullfile(Conf.InputDirectory, Conf.MovingImageFilename), ...
    Image);
  if ~Success,  return;  end
end

ArgDeformation = '';
ReadFileDeformationField = false;
ReadFileOutputPoints = false;
if ischar(Deformation) && strcmpi(Deformation, 'all')
  ReadFileDeformationField = true;
  ArgDeformation= ' -def all';
elseif ~ischar(Deformation)
  ReadFileOutputPoints = true;
  ArgDeformationFilename = fullfile(Conf.InputDirectory, Conf.InputPointsFilename);
  ArgDeformation = [' -def ' ArgDeformationFilename];
  [Success, Message] = elxWritePointSetFile(Deformation, ArgDeformationFilename);
end

ArgDeterminantOfSpatialJacobian = '';
if DeterminantOfSpatialJacobian
  ArgDeterminantOfSpatialJacobian = ' -jac all';
end

ArgSpatialJacobianMatrix = '';
if SpatialJacobianMatrix
  ArgSpatialJacobianMatrix = ' -jacmat all';
end

Cmd = [Conf.TransformixProgram ...
  ' -out ' Conf.OutputDirectory ...
  ArgTransform ...
  ArgImage ...
  ArgDeformation ...
  ArgDeterminantOfSpatialJacobian ...
  ArgSpatialJacobianMatrix];

Log.Command = Cmd;
[CommandStatus, DummyResult] = system(Cmd);
Log.CommandStatus = CommandStatus;
if CommandStatus
  Success = false;
  Message = DummyResult;
  return;
end

if ~isempty(Image)
  Filename = fullfile(Conf.OutputDirectory, 'result.mhd');
  if exist(Filename, 'file')
    [Data.TransformedImage, Success, Message] =  elxMetaIOFileToStrDatax(Filename);
    if ~Success
      return;
    end
  end
end

if ReadFileOutputPoints
  Filename = fullfile(Conf.OutputDirectory, 'outputpoints.txt');
  OutputPoints = elxReadOutputPointsFile(Filename);
  Data.InputPointSet = OutputPoints.Input;
  Data.OutputPointSet = OutputPoints.Output;
  Data.DeformationPointSet = OutputPoints.Deformation;
end

if ReadFileDeformationField
  Filename = fullfile(Conf.OutputDirectory, 'deformationField.mhd');
  Data.DeformationField = elxMetaIOFileToStrDatax(Filename);
end

if DeterminantOfSpatialJacobian
  Filename = fullfile(Conf.OutputDirectory, 'spatialJacobian.mhd');
  if exist(Filename, 'file')
    Data.DeterminantOfSpatialJacobian = elxMetaIOFileToStrDatax(Filename);
  end
end

if SpatialJacobianMatrix
  Filename = fullfile(Conf.OutputDirectory, 'fullSpatialJacobian.mhd');
  if exist(Filename, 'file');
    Data.SpatialJacobianMatrix = elxMetaIOFileToStrDatax(Filename);
  end
end
