%% elxIm3dToStrDatax.m
% created by Mattijs Elschot 20140617
% creates a StrDatax structure for ElastixFromMatlab from im3d structure
%
% input: 
% im3d              - im3d structure; 

% output:
% StrDatax          - StrDatax structure;
% 
% remark: rows ans columns of image are switched with respect to im3d


%% main function
function StrDatax = elxIm3dToStrDatax(im3d)

% get number of rows, columns, and slices
nRow = size(im3d.Data,1);
nCol = size(im3d.Data,2);
nSlc = size(im3d.Data,3);

% get origin (mm)
iX = im3d.A(1,4);
iY = im3d.A(2,4);
iZ = im3d.A(3,4);

% get voxel size (mm)
dRow = sqrt(sum(im3d.A(:,1).^2));
dCol = sqrt(sum(im3d.A(:,2).^2));
dSlc = sqrt(sum(im3d.A(:,3).^2));

% set StrDatax.x
x{1} = iX + (0:nCol-1) * dCol;
x{2} = iY + (0:nRow-1) * dRow;
x{3} = iZ + (0:nSlc-1) * dSlc;
StrDatax.x = x;

% set StrDatax.DirectionCosines
X = im3d.A(1:3,1)./dCol;
Y = im3d.A(1:3,2)./dRow;
Z = im3d.A(1:3,3)./dSlc;
StrDatax.DirectionCosines = [X Y Z];

% set StrDatax.Data
StrDatax.Data = single(permute(im3d.Data,[2 1 3]));

end