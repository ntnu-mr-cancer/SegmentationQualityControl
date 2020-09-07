%% elxPublish
%
% Update ElastixFromMatlab documentation
%
%% Syntax
%
% |elxPublish|
%
%% Input arguments
%
% No input arguments
%
%% Output arguments
%
% No output arguments
%
%% Description
%
% Update ElastixFromMatlab documentation.
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
% $Id: elxPublish.m 11 2013-03-25 12:35:25Z coron $
function elxPublish

p = mfilename('fullpath');
ToolboxDir = fileparts(p);

opt.evalCode = false;
opt.showCode = false;
opt.outputDir = fullfile(ToolboxDir, 'html');
files = dir(fullfile(ToolboxDir, '*.m'));
disp(['Publishing files in ' ToolboxDir '.'])
PublishListOfFiles(ToolboxDir, files, opt);

CurDir = fullfile(ToolboxDir, 'src_html');
files = dir(fullfile(CurDir, '*.m'));
disp(['Publishing files in ' CurDir '.']);
PublishListOfFiles(CurDir, files, opt);

opt.evalCode = true;
opt.showCode = true;
CurDir = fullfile(ToolboxDir);
files = dir(fullfile(ToolboxDir, 'elxExample*.m'));
disp(['Publishing examples in ' ToolboxDir '.']);
PublishListOfFiles(ToolboxDir, files, opt)

% Copy xml file to documentation directory.
disp(['Copying xml files.']);
copyfile(fullfile(ToolboxDir, 'src_html', '*.xml'), ...
  fullfile(ToolboxDir, 'html')); 

% Copy also   as the index.html file
copyfile(fullfile(ToolboxDir, 'html', 'ElastixFromMatlab_product_page.html'), ...
  fullfile(ToolboxDir, 'html', 'index.html'))
end

function PublishListOfFiles(dir, files, opt)

for cur = files.'
  publish(fullfile(dir, cur.name), opt);
end
end
