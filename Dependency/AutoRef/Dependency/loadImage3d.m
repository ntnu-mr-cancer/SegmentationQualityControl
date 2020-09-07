%% loadImage3d
% create im3d for MR, PET, and CT images
% im3d.Data     - 3d image data
% im3d.info     - dicom info, organized per slice
% im3d.A        - affine transformation matrix to transform image to the
%               world coordinate system
% im3d.R        - reference image coordinate system

% This function was was written by Dr. Mattijs Elschot from the MR center at the Norwegian University of Science and Technology (NTNU), Trondheim, Norway.
% Please refer to the author in case of using this function.

% Read dicom slices into 3D volume and get dicom info for each slice
function [im3d] = loadImage3d(dirName)

% get all files in dirName
fileNames = dir(fullfile(dirName));
dirFlags = [~strcmp({fileNames.name},'.') & ~strcmp({fileNames.name},'..')];
fileNames = fileNames(dirFlags);

% read meta-data of first image
tmpInfo = try_dicominfo(fullfile(dirName,fileNames(1).name));

% get colorType
colorType = tmpInfo.ColorType;

% load image
switch colorType
    case 'grayscale'
        im3d = loadGreyscale3d(dirName,fileNames,tmpInfo);
    otherwise
        error('colorType not supported')
end

end % end function


%% loadGreyscale3d
% Read greyscale slices into 3D volume and get dicom info for each slice
function [im3d] = loadGreyscale3d(dirName,fileNames,tmpInfo)

% read the first slice
tmpImage = try_dicomread(tmpInfo);

% set 3d matrix dimensions
imDims = [size(tmpImage) length(fileNames)];

% store metadata of first slice in structure
info(1) = tmpInfo;

% store first slice in 3D matrix
im = zeros(imDims);
im(:,:,1) = tmpImage;

% read rest of the slices
for ii = 2:imDims(end)
    % get current info
    tmpInfo = try_dicominfo(fullfile(dirName,fileNames(ii).name));
    
    % store in existing info struct
    fieldNames = fieldnames(tmpInfo);
    for ff=1:length(fieldNames)
        info(ii).(fieldNames{ff}) = tmpInfo.(fieldNames{ff});
    end
    
    % get current image
    im(:,:,ii) = try_dicomread(info(ii));

end

% reshape 3d image
[im3d] = reshapeImage3d(im,info);

end % end function


%% reshapeImage3d
% - create im3d
% - order slices
% - create affine transformation matrix and image coordinate system
function [im3d] = reshapeImage3d(inpImage,inpInfo)

% check modality and create im3d struct
modalityName = inpInfo(1).Modality;
switch modalityName
    case 'MR'
        im3d = makeMR3d(inpImage,inpInfo);
    case 'PT'
        im3d = makePET3d(inpImage,inpInfo);
    case 'CT'
        im3d = makeCT3d(inpImage,inpInfo);
    otherwise
        error('modalityName not supported')
end

% reposition slices
im3d = repositionSlices(im3d);

% create affine transformation matrix
im3d = makeTransformationMatrix(im3d);

end % end function


%% makeMR3d
% create im3d for MR data.
% First split images according to
% 1. dynamic series
% 2. multiple sequences
% 3. some other reason that slices have the same position
% 4. Then check if image series is MOSAIC or not
function [im3d] = makeMR3d(inpImage,inpInfo)

% Dynamic series and multiple MR sequences: split images
% 1: split images according to AcquisitionNumber (dynamic series)
imCount = 0;
acquisitionNumbers = unique([inpInfo.AcquisitionNumber]);
nAcquisitions = length(acquisitionNumbers);
for ii=1:nAcquisitions
    
    % make list with acquisition number ii
    includeList = find([inpInfo.AcquisitionNumber] == acquisitionNumbers(ii));
    
    % get data with acquisition number ii
    tmpImage = inpImage(:,:,includeList);
    tmpInfo = inpInfo(includeList);
    
    % 2: split images according to SequenceName (multiple sequences)
    sequenceNames = unique({tmpInfo.SequenceName});
    nSequences = length(sequenceNames);
    for jj=1:nSequences
        
        % form data with acquisition number ii, make a list with
        % sequence name jj
        includeList = strcmp({tmpInfo.SequenceName},sequenceNames(jj));
        
        % update image counter
        imCount = imCount+1;
        % split images according to AcquisitionNumber and
        % SequenceName
        im3d(imCount).Data = tmpImage(:,:,includeList);
        im3d(imCount).info = tmpInfo(includeList);
        
        % create a list to sort by subimages by InstanceNumber
        sortList(imCount) = im3d(imCount).info(1).InstanceNumber;
        
    end
    
end

% sort sub-images by InstantNumber
[~,IX] = sort(sortList);
im3d = im3d(IX);

% 3. check if all slices have unique slice locations. If not, split volumes
imCount = 0;
for ii = 1:numel(im3d)
    
    % check if slice locations are unique
    sliceLocations = [im3d(ii).info(:).SliceLocation]';
    uniqueSliceLocations = unique(sliceLocations);
    if not(isequal(sliceLocations,uniqueSliceLocations)) % if not unique, split data
        
        % assumes nNewVol 'whole volumes' in this case
        nNewVol = numel(sliceLocations)/numel(uniqueSliceLocations); 
        
        % sort slices according to slice location info
        [~,IX] = sort(sliceLocations);
        tmpData = im3d(ii).Data(:,:,IX);
        tmpInfo = im3d(ii).info(IX);
        
        % loop over number of new volumes
        for jj = 1:nNewVol
        
            % update image counter
            imCount = imCount+1;
            
            % assign new values
            tmpim(imCount).Data = tmpData(:,:,jj:nNewVol:end);
            tmpim(imCount).info = tmpInfo(jj:nNewVol:end);
            
        end
    else 
        % update image counter
        imCount = imCount+1;
        
        % but keep same data
        tmpim(imCount) = im3d(ii);
    
    end
end

% assign new structure to im3d
im3d = tmpim;


% 4. if mosaic image, create 3D volume
if(~isempty(strfind(im3d(1).info(1).ImageType,'MOSAIC')))
    for ii = 1:numel(im3d)
        
        % get number of slices
        if(isfield(im3d(ii).info(1),'Private_0019_100a'))
            nSlices=single(im3d(ii).info(1).Private_0019_100a);
        else
            sInfo=SiemensInfo(im3d(ii).info(1));
            nSlices=single(sInfo.sSliceArray.lSize);
        end
        mimg=ceil(sqrt(nSlices));
        realwidth=single(im3d(ii).info(1).Width)/mimg;
        realheight=single(im3d(ii).info(1).Height)/mimg;
        
        % 2D --> 3D
        J=blockproc(im3d(ii).Data',[realwidth realheight],@(x)x.data(:));
        J=reshape(J,realwidth,realheight,[]);
        J=permute(J,[2,1,3]);
        tmpvolume=J(:,:,1:nSlices);
        im3d(ii).Data = tmpvolume;
        
        % create rotation matrix to obtain patient position
        % get directional cosines
        X = im3d(ii).info(1).ImageOrientationPatient(1:3);
        Y = im3d(ii).info(1).ImageOrientationPatient(4:6);
        Z = cross(X,Y);
        % get voxel spacing
        dRow = im3d(ii).info(1).PixelSpacing(1);
        dCol = im3d(ii).info(1).PixelSpacing(2);
        dSlc = im3d(ii).info(1).SpacingBetweenSlices;
        % correct initial image position (MOSAIC style)
        Q = double([X(1)*dCol Y(1)*dRow;
            X(2)*dCol Y(2)*dRow;
            X(3)*dCol Y(3)*dRow]);
        % calculate translation
        trans = Q*[(single(im3d(ii).info(1).Width)-realwidth)/2;
            (single(im3d(ii).info(1).Height)-realheight)/2];
        % set new image position of voxel (0,0,0)
        oldIPP = im3d(ii).info(1).ImagePositionPatient;
        newIPP = oldIPP+trans;
        % create affine matrix
        A = double([X(1)*dCol Y(1)*dRow Z(1)*dSlc newIPP(1);
            X(2)*dCol Y(2)*dRow Z(2)*dSlc newIPP(2);
            X(3)*dCol Y(3)*dRow Z(3)*dSlc newIPP(3);
            0 0 0 1]);

        % copy info to each slice and set image position
        for jj = 1:nSlices
            im3d(ii).info(jj) = im3d(ii).info(1);
            newIPPjj = A*[0 0 (jj-1) 1]';
            im3d(ii).info(jj).ImagePositionPatient = newIPPjj(1:3);
        end
        
    end
end

end % end function


%% makePET3d
% create im3d for PET data.
% - Split images according to dynamic series
% - scale image intensity
function [im3d] = makePET3d(inpImage,inpInfo)

% get number of time bins and slices per bin
nTimeBins = 1;
nSlices = inpInfo(1).NumberOfSlices ;
if isfield(inpInfo,'NumberOfTimeSlices')
    nTimeBins = inpInfo(1).NumberOfTimeSlices;
end

% loop over time bins
for ii=1:nTimeBins
    
    % split image according to time frames
    im3d(ii).Data = inpImage(:,:,(ii-1)*nSlices+1:ii*nSlices);
    im3d(ii).info = inpInfo((ii-1)*nSlices+1:ii*nSlices);
    
    % scale intensity
    im3d(ii).Data = im3d(ii).info(1).RescaleIntercept + im3d(ii).Data*im3d(ii).info(1).RescaleSlope;
    
end

end % end function


%% makeCT3d
% create im3d for PET data.
% - scale image intensity
function [im3d] = makeCT3d(inpImage,inpInfo)

% assign Data and info to im3d struct
im3d.Data = inpImage;
im3d.info = inpInfo;

% scale intensity
im3d.Data = im3d.info(1).RescaleIntercept + im3d.Data*im3d.info(1).RescaleSlope;

end


%% repositionSlices
% reposition slices
% - sagital: right --> left
% - coronal: anterior --> posterior
% - transverse: inferior --> superior
function [OUT] = repositionSlices(IN)

for ii=1:numel(IN)
    
    %     % check if MOSAIC (already sorted)
    %     if(isempty(strfind(im3d(ii).info(1).ImageType,'MOSAIC')))
    % determine normal to slice direction
    sliceDir = cross(IN(ii).info(1).ImageOrientationPatient(1:3),...
        IN(ii).info(1).ImageOrientationPatient(4:6));
    
    % take inner product with image position to sort slices
    sortList = sum([IN(ii).info.ImagePositionPatient].* ...
        repmat(sliceDir,[1,numel(IN(ii).info)]));
    
    % sort slice positions
    [~,IX] = sort(sortList);
    
    % sort Data and info
    OUT(ii).Data = IN(ii).Data(:,:,IX);
    OUT(ii).info = IN(ii).info(IX);
    
end

end % end function


%% makeTransformationMatrix
function [OUT] = makeTransformationMatrix(IN)

% allocate im3d struct OUT;
OUT = IN;

% create transformation matrix
for ii=1:numel(IN)
    
    % get directional cosines X and Y from dicom info
    X = IN(ii).info(1).ImageOrientationPatient(1:3);
    Y = IN(ii).info(1).ImageOrientationPatient(4:6);
    
    % get row and column spacing from dicom info
    dRow = IN(ii).info(1).PixelSpacing(1);
    dCol = IN(ii).info(1).PixelSpacing(2);
    
    % calculate pixelspacing in slice direction
    ZdSlc = [IN(ii).info(1).ImagePositionPatient(1) - IN(ii).info(end).ImagePositionPatient(1);
        IN(ii).info(1).ImagePositionPatient(2) - IN(ii).info(end).ImagePositionPatient(2);
        IN(ii).info(1).ImagePositionPatient(3) - IN(ii).info(end).ImagePositionPatient(3)]/(1-numel(IN(ii).info));
    
    % get (x,y,z) position of voxel (1,1,1)
    iX = IN(ii).info(1).ImagePositionPatient(1);
    iY = IN(ii).info(1).ImagePositionPatient(2);
    iZ = IN(ii).info(1).ImagePositionPatient(3);
    
    % create transformation matrix A
    A = double([X(1)*dCol Y(1)*dRow ZdSlc(1) iX;
        X(2)*dCol Y(2)*dRow ZdSlc(2) iY;
        X(3)*dCol Y(3)*dRow ZdSlc(3) iZ;
        0 0 0 1]);
    
    % create reference image coordinate system
    R = imref3d(size(IN(ii).Data),[-0.5 size(IN(ii).Data,2)-0.5],...
        [-0.5 size(IN(ii).Data,1)-0.5],[-0.5 size(IN(ii).Data,3)-0.5]);
    
    % assign A and R to im3d struct
    OUT(ii).A = A;
    OUT(ii).R = R;
    
end

end % end function


%% try_dicominfo
function [OUT] = try_dicominfo(IN)

% if error, try again. May have been a tmp network problem
try
    OUT = dicominfo(IN);
catch
    pause(1); % wait one second
    try
        OUT = dicominfo(IN); 
    catch exception
        rethrow(exception)
    end
end

end


%% try_dicomread
function [OUT] = try_dicomread(IN)

% if error, try again. May have been a tmp network problem
try
    OUT = dicomread(IN);
catch 
    pause(1); % wait one second
    try
        OUT = dicomread(IN); 
    catch exception
        rethrow(exception)
    end
end

end


%% % This function reads the information from the Siemens Private tag 0029 1020 
% from a struct with all dicom info. Copied and adjusted from DJ Kroon
% Dirk-Jan Kroon (2020). Dicom Toolbox (https://www.mathworks.com/matlabcentral/fileexchange/27941-dicom-toolbox), MATLAB Central File Exchange. Retrieved August 3, 2020.
function sinfo=SiemensInfo(info)

str=char(info.Private_0029_1020(:))';
% a1=strfind(str,'### ASCCONV BEGIN ###');                                              % edit ME
a0=strfind(str,'### ASCCONV BEGIN');                                                    % edit ME
str=str(a0+4:end);                                                                      % edit ME
a1=strfind(str,'###');                                                                  % edit ME
a2=strfind(str,'### ASCCONV END ###');
% str=str((a1+22):a2-2);                                                                % edit ME
str=str((a1+4):a2-2);                                                                   % edit ME
request_lines = regexp(str, '\n+', 'split');
request_words = regexp(request_lines, '=', 'split');
sinfo=struct;
for i=1:length(request_lines)
    s=request_words{i};
    name=s{1};
%     while(name(end)==' '); name=name(1:end-1); end                                    % edit ME
    while(any(regexp(name,'[ \t]')==length(name))); name=name(1:end-1); end             % edit ME
%     while(name(1)==' '); name=name(2:end); end                                        % edit ME
    while(any(regexp(name,'[ \t]')==1)); name=name(2:end); end                          % edit ME
%     value=s{2}; value=value(2:end);                                                   % edit ME
    value=s{2};                                                                         % edit ME
    while(any(regexp(value,'[ \t]')==length(value))); value=value(1:end-1); end         % edit ME
    while(any(regexp(value,'[ \t]')==1)); value=value(2:end); end                       % edit ME
    if(any(value=='"'))
        value(value=='"')=[];
        valstr=true;
    else
        valstr=false;
    end
    names = regexp(name, '\.', 'split');
    ind=zeros(1,length(names));
    for j=1:length(names)
        name=names{j};
        ps=find(name=='[');
        if(~isempty(ps))
            pe=find(name==']');
            ind(j)=str2double(name(ps+1:pe-1))+1;
            names{j}=name(1:ps-1);
        end
    end
    try
    evalstr='sinfo';
    for j=1:length(names)
        if(ind(j)==0)
            evalstr=[evalstr '.(names{' num2str(j) '})'];
        else
            evalstr=[evalstr '.(names{' num2str(j) '})(' num2str(ind(j)) ')'];
        end
    end
    if(valstr)
        evalstr=[evalstr '=''' value ''';'];
    else
        if(strcmp(value(1:min(2:end)),'0x'))
            evalstr=[evalstr '='  num2str(hex2dec(value(3:end))) ';'];
        else
        evalstr=[evalstr '=' value ';'];
        end
    end
    eval(evalstr);
    catch ME
        warning(ME.message);
    end
end

end % end function

