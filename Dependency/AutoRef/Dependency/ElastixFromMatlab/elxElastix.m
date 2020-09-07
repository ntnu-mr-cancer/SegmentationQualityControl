%% elxElastix
%
% Register two images with Elastix <http://elastix.isi.uu.nl>
%
%% Syntax
%
% |[StrDataxRegMoving, Transforms, Log, Success, Message]
% =elxElastix(myConf, myParam, FixedImages, MovingImages, 
% 'FixedMask', FixedMask, 'MovingMask', MovingMask, 
% 'InitialTransform', InitialTransform)|
%
%% Input arguments
%
% * |elxConf| (<StrToolboxConf_help.html |StrToolboxConf| structure>): Elastix and toolbox configuration 
%  See <elxDefaultConfiguration.html |elxDefaultConfiguration|>
% * |myParam|: Structure describing the registration parameters
% * |FixedImages| (<StrDatax_help.html |StrDatax| structure> or filename): The fixed image 
% * |MovingImages| (<StrDatax_help.html |StrDatax| structure> or filename): The moving image
% * |'FixedMask', FixedMask| (optional <StrDatax_help |StrDatax| structure> or filename):
% The mask of the fixed image
% * |'MovingMask', MovingMask| (optional <StrDatax_help |StrDatax| structure>): The mask of the moving image
% (default to [])
% * |'InitialTransform', InitialTransform| (optional): An inital transfrom 
% (default to [])
% * |'FixedPointSet', FixedPointSet, 'MovingPointSet', MovingPointSet| 
% (optional <StrPointSet_help.html |StrPointSet| structures> or PointSet file): Correspoinding
% points to help the registration.  You must also specify 
% the CorrespondingPointsEuclideanDistanceMetric metric.  See §6.1.7 of
% elastix 4.5 manual.
%
%% Output arguments
%
% * |StrDataxRegMoving| (<StrDatax_help.html |StrDatax| structure>): The registered moving image.
% * |Transforms|: Cell array of the transform parameters.
% * |Log|: Structure that represents most of the information stored in the 
%   Elastix log File (Convergence at each resolution, parameters, 
%   default parameters, transform...).  Its structure is rather complex 
%   and depends on the Elastix configuration.  I advise to check the field 
%   Log.Error.
% * |Success| (Boolean): true if ok
% * |Message| (String): Error message.  Empty if ok.  
%
%% Description
%
% Register the fixed and moving image with Elastix.  This function creates
% the elastix command line, run elastix thanks to the |system| command, 
% analyze the log file and load the registered image.
%
%% See also 
%
% <elxTransformix.html |elxTransformix|>, 
% <elxMetaIOFileToStrDatax.html MetaIOFileToStrDatax>, 
% <elxStrDataxToMetaIOFile.html |elxStrDataxToMetaIOFile|>,
% <StrDatax_help.html |StrDatax|>
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
% $Id: elxElastix.m 3 2012-05-25 19:37:07Z coron $
function [StrDataxRegMoving, Transforms, Log, Success, Message] ...
  = elxElastix(myConf, myParam, FixedImages, MovingImages, ...
  varargin)

IsAFile = @(x) exist(x, 'file');

p = inputParser();
p.addRequired('myConf', @(x) isstruct(x));
p.addRequired('myParam', @(x) ((isstruct(x) && numel(x) == 1) ...
  || (iscell(x) && all(cellfun(@(x) (isstruct(x) && numel(x)==1), x)))));
p.addRequired('FixedImage', ...
  @(x) (elxIsStrDatax(x) || (ischar(x) && IsAFile(x)) ...
  || (iscellstr(x) && cellfun(IsAFile, x))));
p.addRequired('MovingImage', ...
  @(x) (elxIsStrDatax(x) || (ischar(x) && IsAFile(x)) ...
  || (iscellstr(x) && cellfun(IsAFile, x))));
p.addParamValue('FixedMask', [], ...
  @(x) (isempty(x) || (elxIsStrDatax(x) && numel(x)==1) || (ischar(x) && IsAFile(x))));
p.addParamValue('MovingMask', [], ...
  @(x) (isempty(x) || (elxIsStrDatax(x) && numel(x)==1) || (ischar(x) && IsAFile(x))));
p.addParamValue('InitialTransform', [], ...
  @(x) (isempty(x) ...
  || (isstruct(x) && numel(x) == 1) ...
  || (iscell(x) && all(cellfun(@(x) (isstruct(x) && numel(x)==1),x))) ...
  || (ischar(x) && IsAFile(x))));
p.addParamValue('FixedPointSet', [], ...
  @(x) (isempty(x) ...
  || elxIsStrPointSet(x)...
  || (ischar(x) && IsAFile(x))));
p.addParamValue('MovingPointSet', [], ...
  @(x) (isempty(x) ...
  || elxIsStrPointSet(x) ...
  || (ischar(x) && IsAFile(x))));
p.parse(myConf, myParam, FixedImages, MovingImages, varargin{:});
FixedMask = p.Results.FixedMask;
MovingMask = p.Results.MovingMask;
InitialTransform = p.Results.InitialTransform;
FixedPointSet = p.Results.FixedPointSet;
MovingPointSet = p.Results.MovingPointSet;

Log = struct();
Transforms = cell(0);
StrDataxRegMoving = struct();
Conf = elxCheckStrToolboxConf(myConf);
[Success, Message] = elxCreateOrCleanIODirectories(Conf);
if ~Success,  return; end

ParameterFilename = fullfile(Conf.InputDirectory, Conf.ParameterFilename);
ArgParameter = '';
if isstruct(myParam)
  TmpCell{1} = myParam;
  myParam = TmpCell;
end
NbParameterFiles = numel(myParam);
for Cpt = 1:NbParameterFiles
  TmpParameterFilename = sprintf(ParameterFilename, Cpt - 1);
  if numel(myParam{Cpt}) ~= 1
    Success = false;
    Message = 'myParam must be a one element structure or a cell array of structure';
    return;
  end
  [Success, Message] = elxWriteParameterFile(myParam{Cpt}, ...
    TmpParameterFilename);
  if ~Success,    return;  end
  ArgParameter = [ArgParameter ' -p ' TmpParameterFilename];
end

[ArgFixedImages, Success, Message] = elxConstructImageArgument('fixed image(s)', ...
  'f', fullfile(Conf.InputDirectory, Conf.FixedImageFilename), ...
  FixedImages);
if ~Success,  return;  end
      
[ArgMovingImages, Success, Message] = elxConstructImageArgument('moving image(s)', ...
  'm', fullfile(Conf.InputDirectory, Conf.MovingImageFilename), ...
  MovingImages);
if ~Success, return; end

[ArgFixedMask, Success, Message] = elxConstructImageArgument('fixed mask', ...
  'fMask', fullfile(Conf.InputDirectory, Conf.FixedMaskFilename), ...
  FixedMask);
if ~Success, return; end

[ArgMovingMask, Success, Message] = elxConstructImageArgument('fixed mask', ...
  'mMask', fullfile(Conf.InputDirectory, Conf.MovingMaskFilename), ...
  MovingMask);
if ~Success, return; end

ArgInitialTransform = '';
UseInitialTransform = false;
InitialTransformIsAFile = false;
% MapTransformFileName:  Transforms are read from files and written to 
% files by Elastix and Transformix.  However in Matlab, I wish Transforms 
% to be represented by structures that have to be written consistently
% before running Transformix.  I have chosen to write them under the names
% sprintf(TransformParameters.%i.txt, Cpt-1) if Cpt is the nth cell of the 
% Transform cell array. 
% So I may need to rename some transforms before exporting them to Matlab.
MapTransformFileName = containers.Map;
MapTransformFileNameCpt = 0;
if ~isempty(InitialTransform)
  UseInitialTransform = true;
  if ischar(InitialTransform)
    InitialTransformIsAFile = true;
    InitialTransformFileName = InitialTransform;
    MapTransformFileName(InitialTransform) = InitialTransform;
  else
    if isstruct(InitialTransform)
      % Transform the structure into a cell array and process only cell
      % of structure.
      TmpCell{1} = InitialTransform;
      InitialTransform = TmpCell;
    end
    NbInitialTransforms = numel(InitialTransform);
    for Cpt = 1:NbInitialTransforms
      InitialTransformFileName = fullfile(Conf.InputDirectory, ...
        sprintf('initial_transform.%i.txt', Cpt-1));
      MapTransformFileName(InitialTransformFileName) ...
        = sprintf('TransformParameters.%i.txt', MapTransformFileNameCpt);
      MapTransformFileNameCpt = MapTransformFileNameCpt + 1;
      TmpIni = InitialTransform{Cpt}.InitialTransformParametersFileName;
      if ~strcmp(TmpIni, 'NoInitialTransform')
        TmpIni = fullfile(myConf.InputDirectory, ...
          sprintf('initial_transform.%i.txt',Cpt-2));
        InitialTransform{Cpt}.InitialTransformParametersFileName = TmpIni;
      end
      [Success, Message] = elxWriteTransformParameterFile(InitialTransform{Cpt}, ...
        InitialTransformFileName);
      if ~Success, return; end
    end
  end
  ArgInitialTransform = [' -t0 ' InitialTransformFileName];
end
for Cpt = 1:NbParameterFiles
  MapTransformFileName(...
    fullfile(Conf.OutputDirectory, sprintf('TransformParameters.%i.txt',Cpt-1))) ...
    = sprintf('TransformParameters.%i.txt', MapTransformFileNameCpt);
  MapTransformFileNameCpt = MapTransformFileNameCpt + 1;
end

ArgFixedPointSet = '';
if numel(FixedPointSet)
  [ArgFixedPointSet, Success, Message] = elxConstructPointSetArgument('fixed PointSet', ...
    'fp', fullfile(Conf.InputDirectory, Conf.FixedPointSetFilename), ...
    FixedPointSet);
  if ~Success, return; end
end

ArgMovingPointSet = '';
if numel(MovingPointSet)
  [ArgMovingPointSet, Success, Message] = elxConstructPointSetArgument('moving PointSet', ...
    'mp', fullfile(Conf.InputDirectory, Conf.MovingPointSetFilename), ...
    MovingPointSet);
  if ~Success, return; end
end

% ArgFixedImages = ' -f lulu.mhd'
Cmd = [Conf.ElastixProgram  ...
  ArgFixedImages ...
  ArgMovingImages ...
  ArgFixedMask ...
  ArgMovingMask ...
  ' -out ' Conf.OutputDirectory...
  ArgParameter ...
  ArgInitialTransform ...
  ArgFixedPointSet ...
  ArgMovingPointSet];

Log.Command = Cmd;
[CommandStatus, DummyResult] = system(Cmd);
Log.CommandStatus = CommandStatus;
if CommandStatus == 127
  Success = false;
  Message = DummyResult;
  return;
end

[ElastixVersion, ParameterFile, ElapsedTimeInSec, Success, Message] ...
  = elxElastixLogFileToStructure(fullfile(Conf.OutputDirectory, 'elastix.log'));
Log.ElastixVersion = ElastixVersion;
Log.ParameterFile = ParameterFile;
Log.ElapsedTimeInSec = ElapsedTimeInSec;
if ~Success, return; end

% Read the registered moving image
clear StrDataxRegMoving;
CptTransform = 0;
if UseInitialTransform && ~InitialTransformIsAFile
  CptTransform = numel(InitialTransform);
  Transforms = InitialTransform;  
end
for Cpt = 1:NbParameterFiles
  ResultFilename = fullfile(Conf.OutputDirectory, ...
    sprintf('result.%i.mhd', Cpt-1));
  if exist(ResultFilename, 'file')
    StrDataxRegMoving(Cpt) = elxMetaIOFileToStrDatax(ResultFilename);
    Tmp = Log.ParameterFile(Cpt).Transform.InitialTransformParametersFileName;
    % Remove the name of the output directory from the field
    % InitialTransformParametersFileName.  
    if ~strcmp(Tmp, 'NoInitialTransform')
      if MapTransformFileName.isKey(Tmp)
        Log.ParameterFile(Cpt).Transform.InitialTransformParametersFileName ...
          = MapTransformFileName(Tmp);
      end
    end
    Transforms{Cpt+CptTransform} = Log.ParameterFile(Cpt).Transform;
  end
end
