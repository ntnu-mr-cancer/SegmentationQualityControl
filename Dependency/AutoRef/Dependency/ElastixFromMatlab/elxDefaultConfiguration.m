%% elxDefaultConfiguration
%
% Return a <StrToolboxConf_help.html StrToolboxConf> configuration
% structure..
%
%% Syntax
% |StrConf = elxDefaultConfiguration|
%
%% Input arguments
%
% No input argument
%
%% Output arguments
%
% * |StrConf| (<StrToolboxConf_help.html StrToolboxConf>): The default Elastix and toolbox configuration structure 
%
%% Description
%
% Return a <StrToolboxConf_help.html StrToolboxConf> configuration structure>.
%
% *on Windows* elastix is supposed to be installed in c:/elastix
%
% *on Linux* elastix is supposed to be in your path.
%
% If the function |elxUserDefaultConfiguration| exists, it is
% called with one argument and must return one argument a 
% <StrToolboxConf_help.html StrToolboxConf> structure.
% So each user may overwrite the default settings by adding in his path a
% |elxUserDefaultConfiguration| function.
%
%% See also
%
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
% $Id: elxDefaultConfiguration.m 3 2012-05-25 19:37:07Z coron $
function StrConf = elxDefaultConfiguration()

if ispc
  if ~exist(fullfile('C:','tmpinput'))
    mkdir(fullfile('C:','tmpinput'))
  end
  if ~exist(fullfile('C:','tmpoutput'))
    mkdir(fullfile('C:','tmpoutput'))
  end
  
  % StrConf.InputDirectory = fullfile(tempdir, 'elx_input');
  StrConf.InputDirectory = fullfile('C:','tmpinput');
  % StrConf.OutputDirectory = fullfile(tempdir, 'elx_output');
  StrConf.OutputDirectory = fullfile('C:','tmpoutput');
else
  if ~exist(fullfile('/usr','tmpinput'))
    mkdir(fullfile('/usr','tmpinput'))
  end
  if ~exist(fullfile('/usr','tmpoutput'))
    mkdir(fullfile('/usr','tmpoutput'))
  end
  % StrConf.InputDirectory = fullfile(tempdir, 'elx_input');
  StrConf.InputDirectory = fullfile('/usr','tmpinput');
  % StrConf.OutputDirectory = fullfile(tempdir, 'elx_output');
  StrConf.OutputDirectory = fullfile('/usr','tmpoutput');
end

% DeleteContentXXXX: By setting to true, all files in InputDirectory or 
% OutputDirectory are removed before running elastix or transformix.  
% This is safer because it ensure no interference of a previous run!
StrConf.DeleteContentInputDirectory = true;
StrConf.DeleteContentOutputDirectory = true;

% Filename skeletons
StrConf.ParameterFilename = 'parameter.%d.txt';
StrConf.FixedImageFilename = 'fixed.%03i.mhd';
StrConf.FixedMaskFilename = 'fixed_mask.%03i.mhd';
StrConf.MovingImageFilename = 'moving.%03i.mhd';
StrConf.MovingMaskFilename = 'moving_mask.%03i.mhd';
StrConf.InputPointsFilename = 'inputpoints.txt';
StrConf.InputImageFilename = 'inputimage.mhd';
StrConf.FixedPointSetFilename = 'fixedPointSet.txt';
StrConf.MovingPointSetFilename = 'movingPointSet.txt';

if ispc
  pathBase = which('elxDefaultConfiguration.m');
  pathBase = pathBase(1:end-44);
  % Suppose that elastix is installed in c:/elastix
  StrConf.ElastixProgram = fullfile(pathBase,'Elastix','elastix_windows64_v4.7','elastix.exe');
  StrConf.TransformixProgram = fullfile(pathBase,'Elastix','elastix_windows64_v4.7','transformix.exe');
  % ExampleInputDirectory: Directory of the example provided with elastix
  %StrConf.ExampleInputDirectory = fullfile('C:','Data','PhD','Elastix','elastix_example_v4.8','exampleinput');
  
else
  % StrConf.ElastixProgram = 'elastix';
  % StrConf.TransformixProgram = 'transformix';
  % With the previous two configuration lines, I got this message
  % elastix: $matlab_root/sys/os/glnxa64/libstdc++.so.6: version `GLIBCXX_3.4.11' not found (required by elastix)
  % This is because Matlab set the LD_LIBRARY_PATH and elastix can't find
  % the library.  So I now set:
  StrConf.ElastixProgram = 'LD_PRELOAD=/usr/lib/libstdc++.so.6 elastix';
  StrConf.TransformixProgram = 'LD_PRELOAD=/usr/lib/libstdc++.so.6 transformix';
  % ExampleInputDirectory: Directory of the example provided with elastix
  StrConf.ExampleInputDirectory = '';
end

% Call the user configuration file if it exists.
if exist('elxUserDefaultConfiguration', 'file') == 2
  StrConf = elxUserDefaultConfiguration(StrConf);
end
