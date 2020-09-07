%% elxStrDataxToIm3d.m
% created by Mattijs Elschot 20140618
% creates an im3d structure from a StrDatax structure
%
% input: 
% StrDatax          - StrDatax structure;

% output:
% im3d              - im3d structure; 
% 
% remark: rows ans columns of transformation matrix and origin of im3d
% are switched with respect to those of StrDatax


%% main function
function im3d = elxStrDataxToIm3d(StrDatax)

% get origin (mm)
iX = StrDatax.x{1}(1);
iY = StrDatax.x{2}(1);
iZ = StrDatax.x{3}(1);

% get voxel size (mm)
dRow = StrDatax.x{1}(2)-StrDatax.x{1}(1);
dCol = StrDatax.x{2}(2)-StrDatax.x{2}(1);
dSlc = StrDatax.x{3}(2)-StrDatax.x{3}(1);

% get direction cosines
X = StrDatax.DirectionCosines(:,1);
Y = StrDatax.DirectionCosines(:,2);
Z = StrDatax.DirectionCosines(:,3);

% set im3d.Data
im3d.Data = double(permute(StrDatax.Data,[2 1 3]));

% set dummy info
im3d.info = [];

% set im3d.A
A = double([X(1)*dCol Y(1)*dRow Z(1)*dSlc iX;
    X(2)*dCol Y(2)*dRow Z(2)*dSlc iY;
    X(3)*dCol Y(3)*dRow Z(3)*dSlc iZ;
    0 0 0 1]);
im3d.A = A;

% set im3d.R
R = imref3d(size(im3d.Data),[-0.5 size(im3d.Data,2)-0.5],...
    [-0.5 size(im3d.Data,1)-0.5],[-0.5 size(im3d.Data,3)-0.5]);
im3d.R = R;

end