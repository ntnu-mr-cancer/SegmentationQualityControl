%% ElastixFromMatlab toolbox
%
% *Introduction*
%
% ElastixFromMatlab is a set of Matlab functions to register images with 
% |elastix| <http://elastix.isi.uu.nl>.  So it is a
% wrapper around |elastix|.  Thanks to ElastixFromMatlab:
% 
% * you create, manipulate your images and |elastix| parameters within Matlab,
% * transparently run |elastix| and get back the results into Matlab
% 
% Then you may easily display the registered images, the metric, the transforms...
%
% ElastixFromMatlab was released under CeCILL-B free software license.
% The text of the license is available in English and in French in the files COPYING.txt
% and COPYING-FR.txt.
%
% *Available documentation*
%
% * <ElastixFromMatlab_reqts.html Requirements>
% * <ElastixFromMatlab_examples.html Examples>
% * <ElastixFromMatlab_functions.html List of public functions>
% * <ElastixFromMatlab_datastructures.html List of important data structures>
%
% *Downloading the project*
%
% ElastixFromMatlab is now hosted at <https://sourcesup.renater.fr
% SourceSup>.  You may download
%  
% * the latest released version from <https://sourcesup.renater.fr/projects/elxfrommatlab/>.
% * the development version from the <http://subversion.apache.org/ subversion>
%   repository with the following command 
%
%  svn checkout https://subversion.renater.fr/elxfrommatlab/trunk ElastixFromMatlab
%
% *License*
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
% $Id: ElastixFromMatlab_product_page.m 13 2013-05-27 09:55:44Z coron $
